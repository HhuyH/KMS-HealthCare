from fastapi import APIRouter, Body
from fastapi.responses import StreamingResponse
import json
import asyncio
import logging
logger = logging.getLogger(__name__)

from models import Message,ResetRequest
from config.intents import INTENT_MAPPING, INTENT_PIPELINES
from utils.auth_utils import has_permission, normalize_role
from utils.session_store import get_session_data, save_session_data, save_symptoms_to_session, get_symptoms_from_session, clear_followup_asked_all_keys, clear_symptoms_all_keys
from utils.intent_utils import detect_intent, build_system_message, generate_next_health_action
from utils.symptom_utils import (
    extract_symptoms_gpt,
    save_symptoms_to_db,
    generate_friendly_followup_question,
    generate_related_symptom_question,
    get_symptom_list,
    get_related_symptoms_by_disease,
    should_attempt_symptom_extraction,
    gpt_detect_symptom_intent
)
from utils.limit_history import limit_history_by_tokens, refresh_system_context
from utils.openai_utils import stream_chat
from utils.sql_executor import run_sql_query
from utils.health_care import (
    health_talk,
    gpt_health_talk,
    generate_symptom_note,
    predict_disease_based_on_symptoms,
    save_prediction_to_db,
    generate_diagnosis_summary,
)

router = APIRouter()

symptom_list = get_symptom_list()

@router.post("/chat/stream")
async def chat_stream(msg: Message = Body(...)):
    role = normalize_role(msg.role)
    # logger.info(f"ID: {msg.user_id} User: ({msg.username}) Session:({msg.session_id}) với vai trò {role} gửi: {msg.message}")
    logger.info(f"📨 Nhận tin User: {msg.user_id} || Role: {role} || Message: {msg.message}")
    if not has_permission(role, "chat"):
        async def denied_stream():
            yield "data: ⚠️ Bạn không được phép thực hiện chức năng này.\n\n"
            await asyncio.sleep(1)
            yield "data: 😅 Vui lòng liên hệ admin để biết thêm chi tiết.\n\n"
        return StreamingResponse(denied_stream(), media_type="text/event-stream; charset=utf-8")

    # ✅ Load session data trước
    session_data = await get_session_data(msg.session_id)
    
    recent_messages = list(session_data.get("recent_messages") or [])

    # Gộp bot reply gần nhất nếu có
    last_bot_reply = session_data.get("last_bot_message", None)
    if last_bot_reply:
        recent_messages.append(f"🤖 {last_bot_reply}")

    # Thêm tin nhắn mới từ user
    recent_messages.append(f"👤 {msg.message}")

    # Giữ lại tối đa 6 dòng gần nhất (3 cặp user-bot)
    recent_messages = recent_messages[-6:]

    # Tạo 2 danh sách riêng biệt
    recent_user_messages = [m.replace("👤 ", "") for m in recent_messages if m.startswith("👤")]
    recent_assistant_messages = [m.replace("🤖 ", "") for m in recent_messages if m.startswith("🤖")][-3:]

    # Lưu vào session
    session_data["recent_messages"] = recent_messages                   # Full hội thoại gần đây
    session_data["recent_user_messages"] = recent_user_messages         # Chỉ tin nhắn user
    session_data["recent_assistant_messages"] = recent_assistant_messages  # Chỉ tin nhắn bot

    # 🔁 Phát hiện intent
    last_intent = session_data.get("last_intent", None)
    intent = await detect_intent(
        user_message=msg.message,
        session_key=msg.session_id,
        last_intent=last_intent,
        recent_messages=recent_messages
    )

    session_data["last_intent"] = intent
    save_session_data(msg.session_id, session_data)

    # Xác định mục tiêu người dùng để lấy chức năng phù hợp
    intent = intent.replace("intent:", "").strip()
    logger.info(f"🎯 Intent phát hiện: {intent}")

    # Xác định các bước xử lý
    pipeline = INTENT_PIPELINES.get(intent, [])
    logger.debug(f"[PIPELINE] Pipeline for intent '{intent}': {pipeline}")

    updated_session_data = None  # Sẽ lưu lại nếu cần
    symptoms = []
    suggestion = None

    async def event_generator():
        buffer = ""
        is_json_mode = True

        nonlocal symptoms, suggestion, updated_session_data
        sql_query = None
        natural_text = ""

        session_key = msg.user_id or msg.session_id
        stored_symptoms = await get_symptoms_from_session(session_key)

        for step in pipeline:
            # --- Step 1: Chat tự nhiên ---
            if step == "chat":
                limited_history, _ = refresh_system_context(intent, stored_symptoms, msg.history)
                symptoms = [s['name'] for s in stored_symptoms] if stored_symptoms else []
                system_message_dict = build_system_message(intent, symptoms)
                if stored_symptoms:
                    system_message_dict.update(build_system_message(intent, [s['name'] for s in stored_symptoms]))
                    limited_history.clear()
                    limited_history.extend(limit_history_by_tokens(system_message_dict, msg.history))

                async for chunk in stream_chat(msg.message, limited_history, system_message_dict):
                    delta = chunk.choices[0].delta
                    content = getattr(delta, "content", None)

                    if content:
                        logger.info(f"[STREAM] 🌊 Đang stream ra: {repr(content)}")  # 👈 Thêm dòng này để log từng mẩu
                        buffer += content

                        if intent not in ["sql_query", "product_query"]:
                            is_json_mode = False
                        if intent in ["sql_query", "product_query"]:
                            if content.strip().startswith("{") or '"sql_query":' in content:
                                is_json_mode = True

                        if not is_json_mode:
                            yield f"data: {json.dumps({'natural_text': content})}\n\n"
                            await asyncio.sleep(0.01)

            # --- Step 2: GPT điều phối health_talk ---
            elif step == "health_talk":
                chunks = []

                async for chunk in health_talk(
                    user_message=msg.message,
                    stored_symptoms=stored_symptoms,
                    recent_messages=recent_messages,
                    recent_user_messages=recent_user_messages,
                    recent_assistant_messages=recent_assistant_messages,
                    session_key=msg.user_id or msg.session_id,
                    user_id=msg.user_id,
                    chat_id=getattr(msg, "chat_id", None)
                ):
                    chunks.append(chunk)
                    yield f"data: {json.dumps({'natural_text': chunk}, ensure_ascii=False)}\n\n"

                full_message = "".join(chunks).strip()

                final_message = full_message

                # ✅ Lưu message cuối của bot
                session_data["last_bot_message"] = final_message
                save_session_data(msg.session_id, session_data)

                yield "data: [DONE]\n\n"
                return

            # --- Step 3: Xử lý SQL query nếu có ---
            elif step == "sql":
                try:
                    logger.info(f"[DEBUG] Nội dung buffer để parse SQL: {buffer.strip()}")

                    buffer_clean = buffer.strip()
                    if not buffer_clean.startswith("{") or not buffer_clean.endswith("}"):
                        raise ValueError("Dữ liệu không phải JSON hợp lệ")
                    
                    parsed = json.loads(buffer_clean)
                    sql_query = parsed.get("sql_query")
                    natural_text = parsed.get("natural_text", "").strip()

                except Exception as e:
                    sql_query = None
                    logger.warning(f"Lỗi phân tích JSON: {e}")
                    yield f"data: {json.dumps({'natural_text': '⚠️ Không thể xử lý câu hỏi SQL từ tin nhắn vừa rồi.'})}\n\n"
                    yield "data: [DONE]\n\n"
                    return

                if sql_query:
                    result = run_sql_query(sql_query)
                    if result.get("status") == "success":
                        rows = result.get("data", [])
                        if rows:
                            result_text = natural_text
                        else:
                            result_text = "📋 Không có dữ liệu phù hợp."

                        yield f"data: {json.dumps({'natural_text': result_text, 'table': rows})}\n\n"
                        payload = {'natural_text': result_text, 'table': rows}
                        logger.debug(f"[DEBUG] Payload gửi về frontend: {json.dumps(payload, ensure_ascii=False, indent=2)}")
                    else:
                        error_msg = result.get("error", "Lỗi không xác định.")
                        yield f"data: {json.dumps({'natural_text': f'⚠️ Lỗi SQL: {error_msg}'})}\n\n"

                yield "data: [DONE]\n\n"

        # ✅ Lưu session nếu có cập nhật
        if updated_session_data:
            save_session_data(msg.session_id, updated_session_data)

        yield "data: [DONE]\n\n"
    

    return StreamingResponse(event_generator(), media_type="text/event-stream; charset=utf-8")


@router.post("/chat/reset")
async def reset_session(data: ResetRequest):
    session_id = data.session_id
    user_id = data.user_id

    # 🔁 Reset toàn bộ session RAM (session_store)
    save_session_data(session_id, {
        "last_intent": None,
        "recent_messages": [],
        "symptoms": [],
        "followup_asked": []
    })

    # 🧹 Reset luôn bộ nhớ symptom riêng nếu có
    await clear_symptoms_all_keys(user_id=user_id, session_id=session_id)
    await clear_followup_asked_all_keys(user_id=user_id, session_id=session_id)

    logger.info(f"✅ Đã reset session cho user_id={user_id}, session_id={session_id}")
    logger.debug(await get_session_data(session_id))  # Log lại để xác nhận

    return {"status": "success", "message": "Đã reset session!"}





async def not_use():
            # # --- Step 2: GPT điều phối health_talk ---
            # elif step == "health_talk":
            #     result = await gpt_health_talk(
            #         user_message=msg.message,
            #         stored_symptoms=stored_symptoms,
            #         recent_messages=recent_messages,
            #         session_key=msg.user_id or msg.session_id,
            #         user_id=msg.user_id,
            #         chat_id=getattr(msg, "chat_id", None)
            #     )

            #     if result.get("symptoms"):
            #         updated = save_symptoms_to_session(session_key, result["symptoms"])
            #         stored_symptoms = updated

            #     # ✅ Stream từng dòng nếu là message dài
            #     if result.get("trigger_diagnosis") or result.get("light_summary") or result.get("playful_reply"):
            #         async for line in stream_response_text(result["message"]):
            #             yield line
            #     elif result.get("followup_question"):
            #         yield f"data: {json.dumps({'natural_text': result['followup_question']})}\n\n"
            #     else:
            #         yield f"data: {json.dumps({'natural_text': result['message']})}\n\n"

            #     if result.get("end"):
            #         clear_symptoms_all_keys(user_id=msg.user_id, session_id=msg.session_id)

            #     yield "data: [DONE]\n\n"
            #     return

            # async def stream_response_text(text: str):
            #     for line in text.split("\n"):
            #         if line.strip():
            #             yield f"data: {json.dumps({'natural_text': line.strip()})}\n\n"
            #             await asyncio.sleep(0.01)
    return
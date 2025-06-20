import pymysql
import logging
logger = logging.getLogger(__name__)
import json
from datetime import date
from rapidfuzz import fuzz, process
import re
from utils.openai_client import chat_completion
from utils.symptom_session import get_symptoms_from_session
from config.config import DB_CONFIG
from utils.text_utils import normalize_text

SYMPTOM_LIST = []  # Cache triệu chứng toàn cục

# Nhận diện câu trả lời mơ hồ với ngôn ngữ không chuẩn (lóng, sai chính tả...)
def is_vague_response(text: str) -> bool:
    vague_phrases = [
        "khong biet", "khong ro", "toi khong ro", "hinh nhu", "chac vay",
        "toi nghi la", "co the", "cung duoc", "hoi hoi", "chac la", "hem biet", "k biet", "k ro"
    ]
    text_norm = normalize_text(text)

    for phrase in vague_phrases:
        if phrase in text_norm or fuzz.partial_ratio(phrase, text_norm) > 85:
            return True
    return False

# Load danh sách symptoms từ db lên gồm id và name
def load_symptom_list():
    """
    Load danh sách triệu chứng từ DB, bao gồm ID, tên gốc, alias và các trường đã chuẩn hóa để tra nhanh.
    Lưu vào biến toàn cục SYMPTOM_LIST.
    """
    global SYMPTOM_LIST
    try:
        conn = pymysql.connect(**DB_CONFIG)
        with conn.cursor() as cursor:
            cursor.execute("SELECT symptom_id, name, alias FROM symptoms")
            results = cursor.fetchall()

            SYMPTOM_LIST = []
            for row in results:
                symptom_id, name, alias_raw = row
                norm_name = normalize_text(name)

                aliases = [norm_name]
                if alias_raw:
                    aliases += [normalize_text(a.strip()) for a in alias_raw.split(',') if a.strip()]

                SYMPTOM_LIST.append({
                    "id": symptom_id,
                    "name": name,
                    "aliases": alias_raw,
                    "norm_name": norm_name,
                    "norm_aliases": aliases
                })

            print(f"✅ SYMPTOM_LIST nạp {len(SYMPTOM_LIST)} triệu chứng.")
    
    except Exception as e:
        print(f"❌ Lỗi khi load SYMPTOM_LIST từ DB: {e}")
    
    finally:
        if conn:
            conn.close()

# Lấy và load danh sách đã được lấy 1 lần duy nhất mà ko cần gọi lại quá nhiều hoặc gọi khi không cần thiết
def get_symptom_list():
    global SYMPTOM_LIST
    if not SYMPTOM_LIST:
        print("🔁 Loading SYMPTOM_LIST for the first time...")
        load_symptom_list()
    return SYMPTOM_LIST

# Refresh symptom list neu có symptom mới được thêm vào
def refresh_symptom_list():
    global SYMPTOM_LIST
    SYMPTOM_LIST = []
    load_symptom_list()

def extract_symptoms(text):
    text_norm = normalize_text(text)
    found = []
    seen_ids = set()
    for symptom in SYMPTOM_LIST:
        for keyword in symptom["aliases"]:
            if keyword in text_norm and symptom["id"] not in seen_ids:
                found.append({"id": symptom["id"], "name": symptom["name"]})
                seen_ids.add(symptom["id"])
                break
    return found

def extract_symptoms_gpt(user_message, recent_messages, session_key=None, debug=False):
    # Chuẩn bị danh sách triệu chứng cho GPT
    symptom_lines = []
    name_to_symptom = {}

    for s in SYMPTOM_LIST:
        line = f"- {s['name']}: {s['aliases']}"
        symptom_lines.append(line)
        name_to_symptom[normalize_text(s["name"])] = s

    prompt = f"""
        You are a smart and careful medical assistant.

        Below is a list of known health symptoms, each with informal ways users might describe them (Vietnamese aliases):

        {chr(10).join(symptom_lines)}

        Now read the conversation below. Your task:

        - Identify which symptom **names** the user is directly describing or clearly implying.
        - Be careful: only extract a symptom if it is clearly mentioned or strongly suggested as something the user is **personally experiencing**.
        - Do NOT infer based on cause/effect (e.g. "tim đập nhanh khi hít thở mạnh" ≠ "khó thở").
        - If you are unsure (e.g., message is vague), return an empty list [].

        Examples of valid symptom extraction:
        - "Tôi thấy hơi chóng mặt và đau đầu" → ["Chóng mặt", "Đau đầu"]
        - "Mình cảm thấy không khỏe mấy" → []

        ---

        Sentence:
        "{user_message}"

        Return a list of names in Vietnamese. Example: ["Mệt mỏi", "Đau đầu"]
    """.strip()

    try:
        reply = chat_completion(
            [{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=150
        )
        content = reply.choices[0].message.content.strip()

        # Cleanup if GPT wraps in ```json
        if content.startswith("```json"):
            content = content.replace("```json", "").replace("```", "").strip()
        elif not content.startswith("["):
            content = "[" + content.split("[")[-1]

        names = json.loads(content)
        if not isinstance(names, list):
            raise ValueError("GPT returned non-list symptom names.")

        matched = []
        seen_ids = set()
        for name in names:
            norm = normalize_text(name)
            symptom = name_to_symptom.get(norm)
            if symptom and symptom["id"] not in seen_ids:
                matched.append({"id": symptom["id"], "name": symptom["name"]})
                seen_ids.add(symptom["id"])

        return matched, None if matched else ("Bạn có thể mô tả rõ hơn bạn cảm thấy gì không?")

    except Exception as e:
        if debug:
            print("❌ GPT symptom extraction failed:", str(e))
        return [], "Xin lỗi, mình chưa rõ bạn đang cảm thấy gì. Bạn có thể mô tả cụ thể hơn không?"

# lưu triệu chứng vào database lưu vào user_symptom_history khi đang thực hiện chẩn đoán kết quả
def save_symptoms_to_db(user_id: int, symptoms: list[dict], note: str = "") -> list[int]:
    conn = pymysql.connect(**DB_CONFIG)
    saved_symptom_ids = []

    try:
        with conn.cursor() as cursor:
            for symptom in symptoms:
                symptom_id = symptom.get("id")
                if not symptom_id:
                    continue  # Bỏ qua nếu thiếu ID

                cursor.execute("""
                    INSERT INTO user_symptom_history (user_id, symptom_id, record_date, notes)
                    VALUES (%s, %s, %s, %s)
                """, (user_id, symptom_id, date.today(), note))
                
                saved_symptom_ids.append(symptom_id)

        conn.commit()
    finally:
        conn.close()

    return saved_symptom_ids

# Tạo câu hỏi tiếp theo nhẹ nhàng, thân thiện, gợi ý người dùng chia sẻ thêm thông tin dựa trên các triệu chứng đã ghi nhận.
def join_symptom_names_vietnamese(names: list[str]) -> str:
    if not names:
        return ""
    if len(names) == 1:
        return names[0]
    if len(names) == 2:
        return f"{names[0]} và {names[1]}"
    return f"{', '.join(names[:-1])} và {names[-1]}"

# Dựa vào các symptom_id hiện có truy bảng disease_symptoms → lấy danh sách các disease_id có liên quan truy ngược lại → lấy thêm các symptom khác thuộc cùng bệnh (trừ cái đã có)
def get_related_symptoms_by_disease(symptom_ids: list[int]) -> list[dict]:
    if not symptom_ids:
        return []

    conn = pymysql.connect(**DB_CONFIG)
    related_symptoms = []

    try:
        with conn.cursor() as cursor:
            # B1: Lấy các disease_id liên quan tới các symptom hiện tại
            format_strings = ','.join(['%s'] * len(symptom_ids))
            cursor.execute(f"""
                SELECT DISTINCT disease_id
                FROM disease_symptoms
                WHERE symptom_id IN ({format_strings})
            """, tuple(symptom_ids))
            disease_ids = [row[0] for row in cursor.fetchall()]

            if not disease_ids:
                return []

            # B2: Lấy các symptom_id khác cùng thuộc các disease đó
            format_diseases = ','.join(['%s'] * len(disease_ids))
            cursor.execute(f"""
                SELECT DISTINCT s.symptom_id, s.name
                FROM disease_symptoms ds
                JOIN symptoms s ON ds.symptom_id = s.symptom_id
                WHERE ds.disease_id IN ({format_diseases})
                  AND ds.symptom_id NOT IN ({format_strings})
            """, tuple(disease_ids + symptom_ids))

            related_symptoms = [{"id": row[0], "name": row[1]} for row in cursor.fetchall()]

    finally:
        conn.close()

    return related_symptoms

# Tự động nhận biết nếu message chứa triệu chứng hay không
def gpt_detect_symptom_intent(text: str) -> bool:
    prompt = (
        "Please determine whether the following sentence is a description of health symptoms.\n"
        "Answer with YES or NO only.\n\n"
        f"Sentence: \"{text}\"\n"
        "Answer: "
    )
    response = chat_completion(
        [{"role": "user", "content": prompt}],
        max_tokens=5,
        temperature=0
    )
    result = response.choices[0].message.content.strip().lower()
    return result.startswith("yes")

# Tạo 1 câu hỏi thân thiện về triệu chứng đã trích xuất được
async def generate_friendly_followup_question(symptoms: list[dict], session_key: str = None) -> str:

    symptom_ids = [s['id'] for s in symptoms]
    all_symptoms = symptoms

    if session_key:
        session_symptoms = await get_symptoms_from_session(session_key)
        if session_symptoms:
            all_symptoms = session_symptoms

    all_symptom_names = [s['name'] for s in all_symptoms]
    symptom_text = join_symptom_names_vietnamese(all_symptom_names)

    # Truy vấn follow-up từ DB
    conn = pymysql.connect(**DB_CONFIG)
    try:
        with conn.cursor() as cursor:
            format_strings = ','.join(['%s'] * len(symptom_ids))
            cursor.execute(f"""
                SELECT name, followup_question
                FROM symptoms
                WHERE symptom_id IN ({format_strings})
            """, symptom_ids)

            results = cursor.fetchall()
    finally:
        conn.close()

    if results:
        names = []
        questions = []
        for name, question in results:
            if question:
                names.append(name)
                questions.append(question.strip())

        gpt_prompt = f"""
            You are a warm and understanding doctor. The patient has shared the following symptoms: {', '.join(names)}.

            Here are the follow-up questions you'd normally ask:
            {chr(10).join([f"- {n}: {q}" for n, q in zip(names, questions)])}

            Now write a single, fluent, caring conversation in Vietnamese to follow up with the patient.

            Instructions:
            - Combine all follow-up questions into one natural Vietnamese message.
            - Connect questions smoothly. If symptoms are related, group them in one paragraph.
            - Vary transitions. You may use phrases like "Bên cạnh đó", "Một điều nữa", or "Thêm vào đó", but each only once.
            - Do not ask about any additional or related symptoms in this message.
            - Avoid repeating sentence structure. Keep it soft, natural, and human.
            - No greetings or thank yous — continue mid-conversation.

            Your response must be in Vietnamese.
            """
        try:
            response = chat_completion([
                {"role": "user", "content": gpt_prompt}
            ], temperature=0.4, max_tokens=200)

            return response.choices[0].message.content.strip()
        except Exception as e:
            # fallback nếu GPT lỗi
            return "Bạn có thể chia sẻ thêm về các triệu chứng để mình hỗ trợ tốt hơn nhé?"

    # Nếu không có câu hỏi follow-up từ DB → fallback
    symptom_prompt = join_symptom_names_vietnamese([s['name'] for s in symptoms])
    fallback_prompt = (
        f"You are a helpful medical assistant. The user reported the following symptoms: {symptom_prompt}. "
        "Write a natural, open-ended follow-up question in Vietnamese to ask about timing, severity, or other related details. "
        "Avoid technical language. No greetings — just ask naturally."
    )

    response = chat_completion([
        {"role": "user", "content": fallback_prompt}
    ])
    fallback_text = response.choices[0].message.content.strip()
    return fallback_text

# Hỏi triệu chứng tiếp theo khi đã hỏi xong nhưng vẫn đề từ triệu chứng trước đó
async def generate_related_symptom_question(related_names: list[str]) -> str:

    related_names_str = ', '.join(related_names)

    prompt = f"""
        You're a warm and understanding health assistant. The user has already shared one or more symptom(s).

        Now, based on possibly related symptoms like: {related_names_str}, ask if they’ve experienced any of those too — without making it sound like a checklist.

        Write your response in Vietnamese.

        Tone guide:
        - The message should sound like a gentle, mid-conversation follow-up.
        - Do NOT start with “những triệu chứng bạn đã chia sẻ” — instead, adapt naturally:
        - If there was only one symptom before, refer to it as “triệu chứng đó” or skip it.
        - If there were multiple, you may say “bên cạnh những gì bạn đã chia sẻ”.
        - Do NOT say "tôi" — use “mình” when referring to yourself.
        - No greetings or thank-you phrases.
        - Avoid overly formal, medical, or robotic language.
        - No emoji or slang.
        - Group related symptoms subtly if possible (e.g., mệt mỏi, đau đầu, chóng mặt).
        - Write as **one fluid, caring message**.
    """


    response = chat_completion([{"role": "user", "content": prompt}])
    return response.choices[0].message.content.strip()

def load_followup_keywords():
    """
    Trả về dict: {normalized symptom name → follow-up question}
    """
    conn = pymysql.connect(**DB_CONFIG)
    keyword_map = {}

    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT name, followup_question
                FROM symptoms
                WHERE followup_question IS NOT NULL
            """)
            results = cursor.fetchall()
            for name, question in results:
                norm_name = normalize_text(name)
                keyword_map[norm_name] = question
    finally:
        conn.close()

    return keyword_map

def should_attempt_symptom_extraction(message: str, session_data: dict, stored_symptoms: list) -> bool:
    from utils.openai_client import chat_completion

    prompt = f"""
    You are a smart assistant helping identify whether a sentence from a user in a medical chat should trigger symptom extraction.

    Your task is simple:
    If the sentence contains, suggests, or continues a description of physical or emotional health symptoms — even vaguely — respond with YES.
    Otherwise, respond with NO. Do not add anything else.

    Examples:
    - "Tôi bị nhức đầu từ sáng" → YES
    - "Mình thấy không khỏe lắm" → YES
    - "Ừ đúng rồi" → NO
    - "Cảm ơn bạn" → NO
    - "Chắc là không sao đâu" → MAYBE → YES

    Sentence: "{message.strip()}"
    Answer:
    """

    try:
        reply = chat_completion([
            {"role": "user", "content": prompt}
        ], temperature=0, max_tokens=5)

        content = reply.choices[0].message.content.strip().lower()
        return content.startswith("yes")
    except Exception as e:
        print("❌ should_attempt_symptom_extraction error:", e)
        return False


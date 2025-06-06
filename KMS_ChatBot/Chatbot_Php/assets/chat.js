function appendMessage(message, sender = "user") {
    const div = document.createElement("div");
    div.innerHTML = marked.parse(message);
    div.className = sender === "user" ? "user-msg" : "bot-msg";
    document.getElementById("chat-box").appendChild(div);
    scrollToBottom();
}


function scrollToBottom() {
    const chatBox = document.getElementById("chat-box");
    setTimeout(() => {
        chatBox.scrollTop = chatBox.scrollHeight;
    }, 50);
}

const userInfo = JSON.parse(localStorage.getItem("userInfo")); // Được lưu sau khi login


// Gọi API chat không stream, trả về reply đầy đủ 1 lần
async function sendChatMessage(message, history) {
    const response = await fetch("http://127.0.0.1:8000/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            message,
            history,
            user_id: userInfo.user_id,
            role: userInfo.role
        }),
    });


    if (!response.ok) throw new Error("Lỗi khi kết nối server");
    const data = await response.json();
    return data.reply;
}

async function sendChatStream({ message, history }, onUpdate) {
    const userInfo = JSON.parse(localStorage.getItem("userInfo")) || {};
    const { user_id, username, role } = userInfo;

    const payload = {
        message,
        history,
        user_id,
        username,
        role
    };

    const response = await fetch("http://127.0.0.1:8000/chat/stream", {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "Accept": "text/event-stream",
        },
        body: JSON.stringify(payload),
    });

    if (!response.ok) {
        const errorText = await response.text();
        console.error("Lỗi chi tiết:", errorText);
        throw new Error("Lỗi khi kết nối server");
    }

    const reader = response.body.getReader();
    const decoder = new TextDecoder("utf-8");
    let buffer = "";

    while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const parts = buffer.split("\n\n");

        for (let i = 0; i < parts.length - 1; i++) {
            const part = parts[i].trim();
            if (part.startsWith("data:")) {
                const jsonStr = part.replace(/^data:\s*/, "");
                if (jsonStr === "[DONE]") return;
                try {
                    const parsed = JSON.parse(jsonStr);
                    const textToShow = parsed.natural_text;
                    if (textToShow && textToShow.trim() !== "") {
                        onUpdate(textToShow);
                    } else {
                        // Không làm gì hoặc log debug
                        console.debug("Chunk không có natural_text hợp lệ:", parsed);
                    }
                } catch (err) {
                    console.warn("Không phải JSON, hiển thị raw text:", jsonStr);
                    if (jsonStr.trim() !== "") {
                        onUpdate(jsonStr); // fallback plain text, nhưng tránh string rỗng
                    }
                }
            }

        }

        buffer = parts[parts.length - 1];
    }
}



document.getElementById("chat-form").addEventListener("submit", async function (e) {
    e.preventDefault();

    const input = document.getElementById("userInput");
    const message = input.value.trim();
    if (!message) return;

    // Lấy userInfo từ localStorage ngay đây
    const userInfo = JSON.parse(localStorage.getItem("userInfo")) || {};
    const role = userInfo.role || "guest";
    
    appendMessage(message + " 👤", "user");
    input.value = "";
    input.disabled = true;

    const history = await fetch("get_history.php", {
        credentials: "include"
    }).then(res => res.json());

    await fetch("update_history.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ role: "user", content: message }),
        credentials: "include"
    });

    // Tạo payload chung có thêm userInfo
    const payload = {
        message: message,
        user_id: userInfo.user_id || null,
        username: userInfo.username || null,
        role: role,
        history: history // Nếu backend cần lịch sử luôn thì gửi kèm
    };

    const useStreaming = true; // hoặc false tùy bạn

    if (!useStreaming) {
        try {
            // Gọi backend gửi chat, đính kèm payload
            const res = await fetch('/api/chatbot_backend', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });

            const data = await res.json();

            const reply = data.reply;
            appendMessage("🤖 " + reply, "bot");

            await fetch("update_history.php", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ role: "assistant", content: reply }),
                credentials: "include"
            });
        } catch (err) {
            appendMessage("[Lỗi kết nối server]");
            console.error(err);
        } finally {
            input.disabled = false;
            input.focus();
        }
    } else {
        const botMessageDiv = document.createElement("div");
        botMessageDiv.className = "bot-msg";
        botMessageDiv.innerHTML = "<strong>🤖</strong> ";
        document.getElementById("chat-box").appendChild(botMessageDiv);

        let fullBotReply = "";

        try {
            await sendChatStream(payload, (text) => {
                // parse và render như bạn đã có
                let parsed;
                try {
                    parsed = JSON.parse(text);
                } catch (e) {
                    parsed = null;
                }

                if (parsed && parsed.natural_text) {
                    fullBotReply += parsed.natural_text;
                    botMessageDiv.innerHTML = "<strong>🤖</strong> " + marked.parse(fullBotReply);

                    if (parsed.sql_query) {
                        const sqlDiv = document.createElement("pre");
                        sqlDiv.textContent = "[SQL nội bộ]\n" + parsed.sql_query;
                        sqlDiv.style.color = "gray";
                        sqlDiv.style.fontSize = "0.9em";
                        sqlDiv.style.marginTop = "5px";
                        document.getElementById("chat-box").appendChild(sqlDiv);
                    }
                } else {
                    fullBotReply += text;
                    botMessageDiv.innerHTML = "<strong>🤖</strong> " + marked.parse(fullBotReply);
                }

                scrollToBottom();
            });

            await fetch("update_history.php", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ role: "assistant", content: fullBotReply }),
                credentials: "include"
            });

        } catch (err) {
            botMessageDiv.textContent += "\n[Error xảy ra khi nhận dữ liệu]";
            console.error(err);
        } finally {
            input.disabled = false;
            input.focus();
        }
    }
});


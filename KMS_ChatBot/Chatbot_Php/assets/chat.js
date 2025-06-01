function appendMessage(message) {
    const div = document.createElement("div");
    div.textContent = message;
    document.getElementById("chat-box").appendChild(div);
    scrollToBottom();
}

function scrollToBottom() {
    const chatBox = document.getElementById("chat-box");
    chatBox.scrollTop = chatBox.scrollHeight;
}

// Gọi API chat không stream, trả về reply đầy đủ 1 lần
async function sendChatMessage(message, history) {
    const response = await fetch("http://127.0.0.1:8000/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message, history }),
    });
    if (!response.ok) throw new Error("Lỗi khi kết nối server");
    const data = await response.json();
    return data.reply;
}

// Gọi API chat stream trả về từng phần nhỏ, gọi callback onUpdate mỗi lần nhận text mới
async function sendChatStream(message, history, onUpdate) {
    const response = await fetch("http://127.0.0.1:8000/chat/stream", {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "Accept": "text/event-stream",
        },
        body: JSON.stringify({ message, history }),
    });

    if (!response.ok) throw new Error("Lỗi khi kết nối server");

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
                    const dataObj = JSON.parse(jsonStr);
                    onUpdate(dataObj.text);
                } catch (err) {
                    console.error("Lỗi parse JSON:", err);
                    onUpdate("[Lỗi dữ liệu]");
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

    appendMessage("👤 Bạn: " + message);
    input.value = "";
    input.disabled = true;

    // Lấy history từ PHP session
    const history = await fetch("get_history.php", {
    credentials: "include"
    }).then(res => res.json());


    // Cập nhật history user
    await fetch("update_history.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ role: "user", content: message }),
        credentials: "include"
    });

    // Biến chọn dùng streaming hay không
    const useStreaming = true; // true để dùng stream, false để gọi API bình thường

    if (!useStreaming) {
        // Gọi API bình thường (không stream)
        try {
            const reply = await sendChatMessage(message, history);
            appendMessage("🤖 Bot: " + reply);
            // Cập nhật history assistant
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
        // Gọi API stream
        const botMessageDiv = document.createElement("div");
        botMessageDiv.textContent = "🤖 Bot: ";
        document.getElementById("chat-box").appendChild(botMessageDiv);

        let fullBotReply = "";
        try {
            await sendChatStream(message, history, (text) => {
                botMessageDiv.textContent += text;
                fullBotReply += text;
                scrollToBottom();
            });

            // Cập nhật history assistant
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

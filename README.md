Link Website Project : https://github.com/TdDangxkus/KMS-HealthCare

## 📦 KMS ChatBot – Hệ thống Tư Vấn Sức Khỏe & Đặt Lịch Khám

Đây là mô-đun chính trong đồ án KMS HealthCare, đảm nhiệm vai trò:

* Trò chuyện thông minh với người dùng dựa trên GPT-4.
* Phân tích triệu chứng sức khỏe, gợi ý chuyên khoa phù hợp.
* Gợi ý sản phẩm liên quan đến sức khỏe.
* Hỗ trợ đặt lịch khám thông qua tương tác tự nhiên.

---

## 📁 Cấu trúc dự án

```
KMS_ChatBot/
│
├── Chatbot_BackEnd/       # Toàn bộ code backend chạy bằng FastAPI
│   ├── main.py            # Điểm khởi chạy FastAPI
│   ├── models.py          # Model Pydantic
│   ├── config/            # Cấu hình hệ thống & intent
│   ├── prompts/           # Prompting cho GPT (chia theo module)
│   └── ...
│
├── Chatbot_FrontEnd/      # Web frontend đơn giản để test chatbot
│   └── ...
│
├── requirements.txt       # Thư viện Python cần thiết
└── Readme.md              # (File hiện tại)
```

---

## 🛠️ Cài đặt môi trường

### 1. Python

Yêu cầu Python >= 3.10 (khuyên dùng Python 3.12 trở lên)

### 2. Redis (Session lưu trữ tạm)

#### Cài đặt Redis trên Windows:

1. Truy cập: [https://github.com/tporadowski/redis/releases](https://github.com/tporadowski/redis/releases)
2. Tải bản `.zip` phù hợp và giải nén.
3. Trong thư mục đó, tạo file `redis.conf` với nội dung sau:

```
save 60 1
appendonly yes
appendfsync everysec
dir ./
dbfilename dump.rdb
appendfilename "appendonly.aof"
```

4. Chạy Redis bằng lệnh sau trong `cmd`:

```bash
redis-server.exe redis.conf
```

---

### 3. Cài đặt thư viện Python

Vào thư mục `KMS_ChatBot`, chạy:

```bash
pip install -r requirements.txt
```

---

## 🚀 Chạy hệ thống

Di chuyển vào thư mục `Chatbot_BackEnd` và chạy FastAPI:

```bash
uvicorn main:app --reload
```

Truy cập thử tại:

```
http://localhost:8000
```

---

## ✅ Các chức năng chính

* **Health Talk**: Phân tích triệu chứng, hỏi đáp follow-up, đưa ra lời khuyên sức khỏe cơ bản.
* **Tư vấn sức khỏe**: Dưa theo mong muốn của người dùng mà gợi ý cách có thể cải thiện vấn đề mà người dùng đang gập phải.
* **Đặt lịch khám**: Tạo lịch khám qua chat, xác nhận đầy đủ thông tin trước khi lưu.
* **Gợi ý sản phẩm**: Gợi ý thực phẩm chức năng, thiết bị y tế nếu thấy phù hợp.
* **Báo cáo cho bác sĩ**: Tổng hợp dữ liệu sức khỏe bệnh nhân gửi cho bác sĩ.
* **Tác vụ dành cho Admin**: Chatbot có thể xử lý yêu cầu đặc biệt từ admin dưới dạng ngôn ngữ tự nhiên (truy vấn sản phẩm, đơn hàng...).

---

## 🧠 Lưu ý

* Toàn bộ logic phân tích triệu chứng và chọn chuyên khoa sử dụng **OpenAI GPT-4 API**.
* Redis dùng để lưu session tạm giữa các lượt chat, đảm bảo hội thoại mạch lạc.
* Dữ liệu chẩn đoán, lịch sử cuộc trò chuyện và lịch khám sẽ được lưu vào MySQL.


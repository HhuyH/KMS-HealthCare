----------------------------------------------USERS----------------------------------------------------------------------------------------------------------------
INSERT INTO users (username, email, password_hash, role_id, created_at)
VALUES
('admin', 'admin@gmail.com',
 '$2b$12$KIX9W96S6PvuYcM1vHtrKuu6LSDuCMUCylKBD8eEkF2ZQDfMBzJwC',--id 1
 1, NOW()),

('huy', 'hoanhuy12@gmail.com',
 '$2b$12$KIX9W96S6PvuYcM1vHtrKuu6LSDuCMUCylKBD8eEkF2ZQDfMBzJwC',--id 2
 1, NOW()),

('dr.hanh', 'docter@example.com',
 '$2b$12$KIX9W96S6PvuYcM1vHtrKuu6LSDuCMUCylKBD8eEkF2ZQDfMBzJwC',--id 3
 2, NOW());

('nguyenvana', 'vana@example.com',
 '$2b$12$KIX9W96S6PvuYcM1vHtrKuu6LSDuCMUCylKBD8eEkF2ZQDfMBzJwC',--id 4
 3, NOW());

('linh', 'linh@gmail.com',
 '$2b$12$KIX9W96S6PvuYcM1vHtrKuu6LSDuCMUCylKBD8eEkF2ZQDfMBzJwC',--id 6
 2, NOW()), 

----------------------------------------------GUEST_USERS----------------------------------------------------------------------------------------------------------------
INSERT INTO guest_users (full_name, phone, email)
VALUES
('Nguyễn Văn A', '0909123456', 'nva@example.com'),
('Trần Thị B', '0911234567', 'ttb@example.com'),
('Lê Văn C', '0922345678', 'lvc@example.com');

----------------------------------------------USERS_info----------------------------------------------------------------------------------------------------------------
INSERT INTO users_info (user_id, full_name, gender, date_of_birth, phone)
VALUES
(1, 'Quản trị viên', 'Nam', '1990-01-01', '0123456789'),
(2, 'Huy', 'Nam', '1985-06-15','0999999999'),
(3, 'Dr.Hand', 'nữ', '2000-12-01', '0888888888');
(4, 'Nguyễn Văn A', 'Nam', '1995-08-15', '0901234567');
(6, 'Dr.Linh', 'Nữ', '1995-08-15', '0123466789');

----------------------------------------------USERS_ADDRESSES----------------------------------------------------------------------------------------------------------------
INSERT INTO user_addresses (
    user_id, address_line, ward, district, city, postal_code, country, is_default
)
VALUES
-- Quản trị viên (user_id = 1)
(1, '123 Trần Hưng Đạo', 'Nguyễn Cư Trinh', 'Quận 1', 'TP.HCM', '700000', 'Vietnam', TRUE),

-- Hòa Huy (user_id = 2)
(2, '456 Lê Lợi', 'Bến Nghé', 'Quận 1', 'TP.HCM', '700000', 'Vietnam', TRUE),
(2, '111 Đường long', 'Bến Nghé', 'Quận 11', 'TP.HCM', '110000', 'Vietnam', TRUE),

-- John Doe (user_id = 3)
(3, '789 Lý Thường Kiệt', 'Phường 7', 'Quận 10', 'TP.HCM', '700000', 'Vietnam', TRUE);

-- Nguyễn văn A (user_id=4)
(4, '123 Đường Lý Thường Kiệt', 'Phường 7', 'Quận 10', 'TP.HCM', '70000', TRUE);

-------------------------------------------------------medical_categories--------------------------------------------------------------------------------------------------------------
INSERT INTO medical_categories (name, description) VALUES
('Tim mạch', 'Chuyên khoa liên quan đến tim và mạch máu'),
('Hô hấp', 'Chuyên khoa về phổi và hệ hô hấp'),
('Tiêu hóa', 'Chuyên khoa về dạ dày, ruột, gan...'),
('Thần kinh', 'Chuyên khoa về não và hệ thần kinh'),
('Da liễu', 'Chuyên khoa về da, tóc và móng');


-------------------------------------------------------diseases--------------------------------------------------------------------------------------------------------------

INSERT INTO diseases (name, description, treatment_guidelines, category_id) VALUES
('Tăng huyết áp', 'Huyết áp cao mãn tính', 'Theo dõi huyết áp thường xuyên, dùng thuốc hạ áp', 1),
('Đột quỵ', 'Rối loạn tuần hoàn não nghiêm trọng', 'Can thiệp y tế khẩn cấp, phục hồi chức năng', 1),
('Hen suyễn', 'Bệnh mãn tính ảnh hưởng đến đường thở', 'Sử dụng thuốc giãn phế quản và kiểm soát dị ứng', 2),
('Viêm phổi', 'Nhiễm trùng phổi do vi khuẩn hoặc virus', 'Kháng sinh, nghỉ ngơi và điều trị hỗ trợ', 2),
('Viêm dạ dày', 'Viêm lớp niêm mạc dạ dày', 'Tránh thức ăn cay, dùng thuốc kháng acid', 3),
('Xơ gan', 'Tổn thương gan mạn tính', 'Kiểm soát nguyên nhân, chế độ ăn và theo dõi y tế', 3),
('Động kinh', 'Rối loạn thần kinh gây co giật lặp lại', 'Dùng thuốc chống động kinh, theo dõi điện não đồ', 4),
('Trầm cảm', 'Rối loạn tâm trạng kéo dài', 'Liệu pháp tâm lý và thuốc chống trầm cảm', 4),
('Viêm da cơ địa', 'Bệnh da mãn tính gây ngứa và phát ban', 'Dưỡng ẩm, thuốc bôi chống viêm', 5),
('Nấm da', 'Nhiễm trùng da do nấm', 'Thuốc kháng nấm dạng bôi hoặc uống', 5);
('Cảm lạnh thông thường', 'Nhiễm virus nhẹ gây hắt hơi, sổ mũi', 'Nghỉ ngơi, uống nhiều nước, dùng thuốc giảm triệu chứng', 2),
('Đau đầu căng thẳng', 'Đau đầu do căng thẳng, stress hoặc sai tư thế', 'Nghỉ ngơi, thư giãn, thuốc giảm đau nếu cần', 4),
('Viêm họng cấp', 'Viêm vùng họng do virus hoặc vi khuẩn', 'Súc họng, uống nước ấm, thuốc kháng sinh nếu cần', 2),
('Nổi mề đay', 'Phản ứng dị ứng gây ngứa, nổi ban đỏ', 'Thuốc kháng histamin, tránh tác nhân gây dị ứng', 5),
('Táo bón chức năng', 'Khó đi tiêu do rối loạn tiêu hoá nhẹ', 'Ăn nhiều chất xơ, uống đủ nước, luyện tập thể dục', 3),
('Đau bụng kinh', 'Đau bụng khi hành kinh', 'Thuốc giảm đau, nghỉ ngơi, chườm ấm', 3),
('Lupus ban đỏ hệ thống', 'Bệnh tự miễn tấn công nhiều cơ quan', 'Dùng thuốc ức chế miễn dịch và theo dõi định kỳ', 4),
('Bạch cầu cấp', 'Ung thư máu tiến triển nhanh', 'Hóa trị, ghép tủy, chăm sóc đặc biệt', 4),
('Xơ cứng bì', 'Bệnh tự miễn hiếm gây dày cứng da và tổn thương nội tạng', 'Điều trị triệu chứng và ức chế miễn dịch', 5),
('Xơ nang', 'Rối loạn di truyền ảnh hưởng phổi và tiêu hóa', 'Điều trị hỗ trợ hô hấp, enzyme tiêu hóa', 2),
('U não ác tính', 'Khối u trong não gây triệu chứng thần kinh nghiêm trọng', 'Phẫu thuật, xạ trị, hóa trị', 4);


-------------------------------------------------------symptoms--------------------------------------------------------------------------------------------------------------
INSERT INTO symptoms (name, description) VALUES
('Đau đầu', 'Cảm giác đau ở vùng đầu hoặc cổ'),
('Khó thở', 'Khó khăn trong việc hít thở bình thường'),
('Buồn nôn', 'Cảm giác muốn nôn mửa'),
('Sốt', 'Nhiệt độ cơ thể cao hơn bình thường'),
('Tức ngực', 'Cảm giác đau hoặc áp lực ở ngực'),
('Mệt mỏi', 'Cảm giác kiệt sức, thiếu năng lượng'),
('Co giật', 'Chuyển động không kiểm soát của cơ'),
('Ngứa da', 'Cảm giác châm chích khiến muốn gãi'),
('Phát ban', 'Vùng da bị nổi mẩn đỏ hoặc sưng'),
('Chán ăn', 'Mất cảm giác thèm ăn, không muốn ăn uống'),
('Ho', 'Phản xạ đẩy không khí ra khỏi phổi để làm sạch đường hô hấp'),
('Hắt hơi', 'Phản xạ mạnh của mũi để đẩy chất gây kích ứng ra ngoài'),
('Chảy nước mũi', 'Dịch nhầy chảy ra từ mũi do viêm hoặc dị ứng'),
('Đau họng', 'Cảm giác đau hoặc rát ở vùng họng'),
('Khó nuốt', 'Cảm giác vướng hoặc đau khi nuốt thức ăn hoặc nước'),
('Đau bụng', 'Cảm giác khó chịu hoặc đau ở vùng bụng'),
('Tiêu chảy', 'Đi ngoài phân lỏng, thường xuyên'),
('Táo bón', 'Đi đại tiện khó khăn hoặc không thường xuyên'),
('Hoa mắt chóng mặt', 'Cảm giác quay cuồng hoặc mất thăng bằng'),
('Đổ mồ hôi nhiều', 'Ra mồ hôi quá mức, không do vận động'),
('Run tay chân', 'Chuyển động không tự chủ ở tay hoặc chân'),
('Khó ngủ', 'Gặp vấn đề khi ngủ hoặc ngủ không ngon giấc'),
('Thở gấp', 'Hơi thở nhanh, ngắn do thiếu oxy'),
('Tim đập nhanh', 'Nhịp tim tăng bất thường, có thể do lo âu hoặc bệnh'),
('Tê tay chân', 'Mất cảm giác hoặc cảm giác châm chích ở tay hoặc chân'),
('Đau lưng', 'Cảm giác đau hoặc khó chịu ở vùng lưng'),
('Buồn nôn', 'Cảm giác muốn nôn mửa'),
('Đau cơ', 'Cảm giác đau hoặc căng cứng cơ bắp'),
('Mất ngủ', 'Không thể ngủ hoặc ngủ không sâu giấc'),
('Hơi thở hôi', 'Có mùi khó chịu khi thở ra'),
('Nấc cụt', 'Hiện tượng thở ra đột ngột gây tiếng nấc'),
('Đau họng', 'Cảm giác đau hoặc rát ở vùng họng'),
('Chóng mặt', 'Cảm giác quay cuồng hoặc mất thăng bằng'),
('Mờ mắt', 'Giảm khả năng nhìn rõ hoặc bị mờ mắt'),
('Phù nề', 'Sưng lên do tích tụ dịch ở các mô'),
('Khó thở khi nằm', 'Cảm giác khó thở tăng lên khi nằm xuống');
-------------------------------------------------------liên kết diseases với symptoms--------------------------------------------------------------------------------------------------------------

INSERT INTO disease_symptoms (disease_id, symptom_id) VALUES
-- Tăng huyết áp
(1, 5),  -- Tức ngực
(1, 6),  -- Mệt mỏi
(1, 23), -- Tim đập nhanh
(1, 19), -- Hoa mắt chóng mặt

-- Đột quỵ
(2, 6),  -- Mệt mỏi
(2, 20), -- Run tay chân
(2, 24), -- Tê tay chân
(2, 31), -- Chóng mặt

-- Hen suyễn
(3, 2),  -- Khó thở
(3, 11), -- Ho
(3, 22), -- Thở gấp
(3, 23), -- Tim đập nhanh

-- Viêm phổi
(4, 2),  -- Khó thở
(4, 4),  -- Sốt
(4, 11), -- Ho
(4, 5),  -- Tức ngực

-- Viêm dạ dày
(5, 3),  -- Buồn nôn
(5, 16), -- Tiêu chảy
(5, 15), -- Đau bụng
(5, 30), -- Hơi thở hôi

-- Xơ gan
(6, 6),  -- Mệt mỏi
(6, 10), -- Chán ăn
(6, 15), -- Đau bụng
(6, 34), -- Phù nề

-- Động kinh
(7, 7),  -- Co giật
(7, 6),  -- Mệt mỏi
(7, 24), -- Tê tay chân
(7, 31), -- Chóng mặt

-- Trầm cảm
(8, 6),  -- Mệt mỏi
(8, 21), -- Khó ngủ
(8, 28), -- Mất ngủ
(8, 10), -- Chán ăn

-- Viêm da cơ địa
(9, 8),  -- Ngứa da
(9, 9),  -- Phát ban
(9, 34), -- Phù nề

-- Nấm da
(10, 8), -- Ngứa da
(10, 9), -- Phát ban
(10, 34), -- Phù nề

-- Cảm lạnh thông thường
(11, 4),  -- Sốt
(11, 11), -- Ho
(11, 12), -- Hắt hơi
(11, 13), -- Chảy nước mũi
(11, 14), -- Đau họng

-- Đau đầu căng thẳng
(12, 1),  -- Đau đầu
(12, 6),  -- Mệt mỏi
(12, 21), -- Khó ngủ
(12, 28), -- Mất ngủ

-- Viêm họng cấp
(13, 4),  -- Sốt
(13, 11), -- Ho
(13, 14), -- Đau họng
(13, 15), -- Khó nuốt

-- Nổi mề đay
(14, 8),  -- Ngứa da
(14, 9),  -- Phát ban

-- Táo bón chức năng
(15, 17), -- Táo bón
(15, 15), -- Đau bụng

-- Đau bụng kinh
(16, 15), -- Đau bụng
(16, 6),  -- Mệt mỏi
(16, 28), -- Mất ngủ

-- Lupus ban đỏ hệ thống
(17, 6),  -- Mệt mỏi
(17, 9),  -- Phát ban
(17, 34), -- Phù nề
(17, 24), -- Tê tay chân

-- Bạch cầu cấp
(18, 4),  -- Sốt
(18, 6),  -- Mệt mỏi
(18, 10), -- Chán ăn
(18, 15), -- Đau bụng

-- Xơ cứng bì
(19, 9),  -- Phát ban
(19, 34), -- Phù nề
(19, 24), -- Tê tay chân

-- Xơ nang
(20, 2),  -- Khó thở
(20, 11), -- Ho
(20, 3),  -- Buồn nôn
(20, 16), -- Tiêu chảy

-- U não ác tính
(21, 1),  -- Đau đầu
(21, 6),  -- Mệt mỏi
(21, 31), -- Chóng mặt
(21, 32); -- Mờ mắt



-------------------------------------------------------Lịch sử chiệu chứng của bênh nhân Nguyễn Văn A user_id = 4--------------------------------------------------------------------------------------------------------------
INSERT INTO user_symptom_history (user_id, symptom_id, record_date, notes) VALUES
(4, 1, '2025-05-18', 'Sốt cao 39 độ, kéo dài 2 ngày'),
(4, 2, '2025-05-18', 'Ho khan, không có đờm'),
(4, 3, '2025-05-19', 'Cổ họng đau rát, nuốt đau'),
(4, 5, '2025-05-20', 'Đau đầu nhẹ, chủ yếu vào buổi sáng'),
(4, 4, '2025-05-21', 'Cảm giác khó thở nhẹ khi vận động'),
(4, 4, '2025-05-18', 'Sốt cao 39 độ, kéo dài 2 ngày');
(4, 1, '2025-05-18', 'Đau đầu âm ỉ vùng trán và sau gáy'),
(4, 2, '2025-05-19', 'Khó thở nhẹ, đặc biệt khi leo cầu thang'),
(4, 6, '2025-05-20', 'Cảm thấy mệt mỏi suốt cả ngày'),
(4, 5, '2025-05-21', 'Cảm giác tức ngực nhẹ khi hít sâu');

-------------------------------------------------------Phòng khám--------------------------------------------------------------------------------------------------------------
INSERT INTO clinics (name, address, phone, email, description) VALUES
('Phòng khám Đa khoa Hòa Hảo', '254 Hòa Hảo, Quận 10, TP.HCM', '02838553085', 'hoahao@example.com', 'Phòng khám tư nhân uy tín với nhiều chuyên khoa.'),
('Bệnh viện Chợ Rẫy', '201B Nguyễn Chí Thanh, Quận 5, TP.HCM', '02838554137', 'choray@hospital.vn', 'Bệnh viện tuyến trung ương chuyên điều trị các ca nặng.'),
('Phòng khám Quốc tế Victoria Healthcare', '79 Điện Biên Phủ, Quận 1, TP.HCM', '02839101717', 'info@victoriavn.com', 'Dịch vụ khám chữa bệnh theo tiêu chuẩn quốc tế.'),
('Bệnh viện Đại học Y Dược', '215 Hồng Bàng, Quận 5, TP.HCM', '02838552307', 'contact@umc.edu.vn', 'Bệnh viện trực thuộc Đại học Y Dược TP.HCM.'),
('Phòng khám đa khoa Pasteur', '27 Nguyễn Thị Minh Khai, Quận 1, TP.HCM', '02838232299', 'pasteurclinic@vnmail.com', 'Chuyên nội tổng quát, tim mạch, tiêu hóa.');

---------------------------------------------------------------------------------Khoa--------------------------------------------------------------------------------------------------------------
INSERT INTO specialties (name, description) VALUES
('Nội khoa', 'Chẩn đoán và điều trị không phẫu thuật các bệnh lý nội tạng.'),
('Ngoại khoa', 'Chẩn đoán và điều trị bệnh thông qua phẫu thuật.'),
('Tai - Mũi - Họng', 'Khám và điều trị các bệnh lý về tai, mũi và họng.'),
('Tim mạch', 'Chuyên điều trị bệnh về tim và hệ tuần hoàn.'),
('Nhi khoa', 'Chăm sóc và điều trị cho trẻ em từ sơ sinh đến 15 tuổi.'),
('Da liễu', 'Chẩn đoán và điều trị các bệnh về da, tóc và móng.'),
('Tiêu hóa', 'Chuyên về hệ tiêu hóa như dạ dày, gan, ruột.'),
('Thần kinh', 'Khám và điều trị các bệnh về hệ thần kinh trung ương và ngoại biên.');

---------------------------------------------------------------------------------Bác sĩ---------------------------------------------------------------------------------------------------------------------
-- user_id = 3 là bác sĩ Nội khoa tại Phòng khám Đa khoa Hòa Hảo
-- user_id = 6 là bác sĩ Tim mạch tại Bệnh viện Chợ Rẫy

INSERT INTO doctors (user_id, specialty_id, clinic_id, biography)
VALUES
(3, 1, 1, 'Bác sĩ Nội khoa với hơn 10 năm kinh nghiệm trong điều trị tiểu đường, huyết áp. Tốt nghiệp Đại học Y Dược TP.HCM.'),
(6, 4, 2, 'Bác sĩ Tim mạch từng công tác tại Viện Tim TP.HCM. Có bằng Thạc sĩ Y khoa từ Đại học Paris, Pháp.');

---------------------------------------------------------------------------------Lịch làm việc bác sĩ---------------------------------------------------------------------------------------------------------------------
-- Lịch bác sĩ Nội khoa (doctor_id = 1) tại phòng khám 1
INSERT INTO doctor_schedules (doctor_id, clinic_id, day_of_week, start_time, end_time)
VALUES
(1, 1, 'Monday', '08:00:00', '12:00:00'),
(1, 1, 'Wednesday', '08:00:00', '12:00:00'),
(1, 1, 'Friday', '13:30:00', '17:30:00');

-- Lịch bác sĩ Tim mạch (doctor_id = 2) tại phòng khám 2
INSERT INTO doctor_schedules (doctor_id, clinic_id, day_of_week, start_time, end_time)
VALUES
(2, 2, 'Tuesday', '09:00:00', '12:00:00'),
(2, 2, 'Thursday', '14:00:00', '18:00:00'),
(2, 2, 'Saturday', '08:30:00', '11:30:00');

---------------------------------------------------------------------------------Đặt lịch khám---------------------------------------------------------------------------------------------------------------------

-- user_id = 4 đặt khám bác sĩ Nội khoa (user_id = 3, doctor_id = 1) tại Phòng khám Đa khoa Hòa Hảo
INSERT INTO appointments (user_id, doctor_id, clinic_id, appointment_time, reason, status)
VALUES 
(4, 1, 1, '2025-05-28 09:00:00', 'Khám huyết áp và mệt mỏi kéo dài', 'confirmed'),
(4, 1, 1, '2025-06-01 14:30:00', 'Theo dõi tiểu đường định kỳ', 'pending');

-- guest_id = 1 khám Nội khoa (doctor_id = 1) tại Phòng khám Đa khoa Hòa Hảo
-- guest_id = 2 khám Tim mạch (doctor_id = 2) tại Bệnh viện Chợ Rẫy
-- guest_id = 3 khám Tim mạch (doctor_id = 2) tại Bệnh viện Chợ Rẫy

INSERT INTO appointments (guest_id, doctor_id, clinic_id, appointment_time, reason, status)
VALUES
(1, 1, 1, '2025-05-25 10:00:00', 'Đau đầu và cao huyết áp gần đây', 'confirmed'),
(2, 2, 2, '2025-05-27 08:00:00', 'Khó thở, nghi ngờ bệnh tim', 'pending'),
(3, 2, 2, '2025-05-29 15:00:00', 'Đặt lịch kiểm tra tim định kỳ', 'canceled');

---------------------------------------------------------------------------------Đơn thuốc---------------------------------------------------------------------------------------------------------------------

-- Đơn thuốc cho lịch hẹn của user_id = 4 (appointment_id = 1 và 2)
INSERT INTO prescriptions (appointment_id, prescribed_date, medications, notes)
VALUES
(1, '2025-05-28', '[
  {"name": "Thuốc hạ áp Amlodipine", "dosage": "5mg", "frequency": "1 viên/ngày"},
  {"name": "Paracetamol", "dosage": "500mg", "frequency": "2 viên/ngày khi đau đầu"}
]', 'Uống vào buổi sáng sau ăn. Tránh dùng với rượu bia.'),

(2, '2025-06-01', '[
  {"name": "Metformin", "dosage": "500mg", "frequency": "2 lần/ngày"},
  {"name": "Glimepiride", "dosage": "2mg", "frequency": "1 lần/ngày trước ăn sáng"}
]', 'Kiểm tra đường huyết trước mỗi lần dùng thuốc.');

-- Đơn thuốc cho khách vãng lai guest_id = 1 (appointment_id = 3)
INSERT INTO prescriptions (appointment_id, prescribed_date, medications, notes)
VALUES
(3, '2025-05-25', '[
  {"name": "Losartan", "dosage": "50mg", "frequency": "1 viên mỗi sáng"},
  {"name": "Vitamin B1", "dosage": "100mg", "frequency": "1 viên/ngày"}
]', 'Tái khám sau 1 tuần nếu triệu chứng không giảm.');

---------------------------------------------------------------------------------Ghi chú của bác sĩ---------------------------------------------------------------------------------------------------------------------

-- Ghi chú khám của bác sĩ cho các lịch hẹn của user_id = 4
INSERT INTO medical_records (appointment_id, diagnosis, recommendations)
VALUES
(1, 'Tăng huyết áp giai đoạn 1', 'Cần điều chỉnh chế độ ăn và tập thể dục. Uống thuốc đều đặn.'),
(2, 'Tiểu đường tuýp 2', 'Kiểm tra HbA1c 3 tháng/lần. Hạn chế đường và tinh bột.');

-- Ghi chú khám cho khách guest_id = 1
INSERT INTO medical_records (appointment_id, diagnosis, recommendations)
VALUES
(3, 'Cao huyết áp do căng thẳng', 'Nghỉ ngơi hợp lý, tránh thức khuya. Theo dõi huyết áp hàng ngày.');

----------------------------------------------------------------4. Thương mại điện tử-------------------------------------------------------------------------------

--🗂️ product_categories: Danh mục sản phẩm
INSERT INTO product_categories (name, description) VALUES
('Thuốc điều trị', 'Các loại thuốc dùng để điều trị bệnh lý.'),
('Thực phẩm chức năng', 'Sản phẩm hỗ trợ tăng cường sức khỏe.'),
('Thiết bị y tế', 'Các thiết bị và dụng cụ y tế sử dụng trong chẩn đoán và điều trị.'),
('Vật tư tiêu hao', 'Găng tay, khẩu trang, bông băng,... sử dụng một lần.');

--📦 products: Danh sách sản phẩm
INSERT INTO products (category_id, name, description, price, stock, image_url)
VALUES
(1, 'Paracetamol 500mg', 'Thuốc hạ sốt, giảm đau thường dùng.', 15000, 100, 'https://example.com/images/paracetamol.jpg'),
(1, 'Amoxicillin 500mg', 'Kháng sinh phổ rộng nhóm penicillin.', 28000, 60, 'https://example.com/images/amoxicillin.jpg'),
(2, 'Vitamin C 1000mg', 'Hỗ trợ tăng cường đề kháng.', 50000, 200, 'https://example.com/images/vitaminC.jpg'),
(3, 'Máy đo huyết áp điện tử', 'Thiết bị đo huyết áp tại nhà.', 650000, 15, 'https://example.com/images/blood_pressure_monitor.jpg'),
(4, 'Khẩu trang y tế 4 lớp', 'Hộp 50 cái, đạt chuẩn kháng khuẩn.', 40000, 500, 'https://example.com/images/face_mask.jpg');

------------------------------------------------------------💊 medicines: Thông tin chi tiết thuốc (chỉ áp dụng với sản phẩm là thuốc)------------------------------------------------------------------------------------
INSERT INTO medicines (medicine_id, active_ingredient, dosage_form, unit, usage_instructions)
VALUES
(1, 'Paracetamol', 'Viên nén', 'viên', 'Uống 1–2 viên mỗi 4–6 giờ nếu cần. Không dùng quá 8 viên/ngày.'),
(2, 'Amoxicillin', 'Viên nang', 'viên', 'Uống 1 viên mỗi 8 giờ, duy trì trong 5–7 ngày.');

--------------------------------------------------- prescription_products: Sản phẩm thực tế được kê trong đơn thuốc------------------------------------------------------------------------------------
-- Đơn thuốc 1 (của user_id = 4, appointment_id = 1)
INSERT INTO prescription_products (prescription_id, product_id, quantity, dosage, usage_time)
VALUES
(1, 1, 10, '500mg', '2 viên/ngày khi đau đầu'),    -- Paracetamol
(1, NULL, 7, '5mg', '1 viên/ngày');                -- Amlodipine chưa có trong products, có thể là thuốc ngoài danh mục

-- Đơn thuốc 2 (của user_id = 4, appointment_id = 2)
INSERT INTO prescription_products (prescription_id, product_id, quantity, dosage, usage_time)
VALUES
(2, NULL, 14, '500mg', '2 lần/ngày'),              -- Metformin, không có trong bảng `products`
(2, NULL, 7, '2mg', '1 lần/ngày trước ăn sáng');   -- Glimepiride, cũng không có trong bảng `products`

-- Đơn thuốc 3 (của guest_id = 1, appointment_id = 3)
INSERT INTO prescription_products (prescription_id, product_id, quantity, dosage, usage_time)
VALUES
(3, NULL, 7, '50mg', '1 viên mỗi sáng'),           -- Losartan
(3, NULL, 7, '100mg', '1 viên/ngày');              -- Vitamin B1


-------------------------------------------------------------------------------------- product_reviews------------------------------------------------------------------------------------
-- Huy (user_id = 2) đánh giá Paracetamol (product_id = 1)
INSERT INTO product_reviews (product_id, user_id, rating, comment)
VALUES
(1, 2, 5, 'Thuốc giảm đau hiệu quả, ít tác dụng phụ.'),

-- Huy (user_id = 2) đánh giá Amoxicillin (product_id = 2)
(2, 2, 4, 'Tốt nhưng gây buồn nôn nhẹ.'),

-- Admin (user_id = 1) đánh giá máy đo huyết áp (product_id = 4)
(4, 1, 5, 'Dễ sử dụng và rất chính xác.'),

-- Người dùng "dr.hanh" (user_id = 3) đánh giá Vitamin C (product_id = 3)
(3, 3, 4, 'Khá ổn để tăng sức đề kháng. Đóng gói đẹp.');

----------------------------------------------------------------3. Chatbot AI-------------------------------------------------------------------------------
INSERT INTO chatbot_knowledge_base (intent, question, answer, category)
VALUES
-- Hành chính
('ask_working_hours', 'Bệnh viện làm việc vào thời gian nào?', 'Bệnh viện hoạt động từ 7h00 đến 17h00, từ thứ Hai đến thứ Bảy.', 'Thông tin chung'),
('ask_contact_info', 'Tôi có thể liên hệ bệnh viện qua số điện thoại nào?', 'Bạn có thể gọi đến số 1900-1234 để được hỗ trợ.', 'Thông tin chung'),
('ask_location', 'Địa chỉ bệnh viện là gì?', 'Bệnh viện tọa lạc tại số 123 Đường Sức Khỏe, Quận 10, TP.HCM.', 'Thông tin chung'),
('ask_services', 'Bệnh viện có những dịch vụ gì?', 'Chúng tôi cung cấp khám chữa bệnh, xét nghiệm, chẩn đoán hình ảnh, điều trị nội trú và các dịch vụ chuyên khoa khác.', 'Thông tin chung'),

-- Phân tích triệu chứng
('symptom_analysis', 'Tôi bị sốt, mệt mỏi và ho, có thể là bệnh gì?', 'Đây là triệu chứng thường gặp của cảm lạnh, viêm họng hoặc cúm. Bạn nên nghỉ ngơi, uống nhiều nước và theo dõi. Nếu không đỡ sau vài ngày, hãy đi khám.', 'Triệu chứng chung'),
('symptom_analysis', 'Tôi bị đau đầu và chóng mặt, có thể là bệnh gì?', 'Triệu chứng này có thể do căng thẳng, thiếu ngủ, hoặc huyết áp bất thường. Nếu kéo dài hoặc nặng hơn, bạn nên đi khám.', 'Triệu chứng chung'),
('symptom_analysis', 'Tôi bị khó thở và tức ngực, có thể là bệnh gì?', 'Triệu chứng này có thể liên quan đến hen suyễn, viêm phổi, hoặc bệnh tim mạch. Bạn cần được kiểm tra y tế càng sớm càng tốt.', 'Triệu chứng chung'),
('symptom_analysis', 'Tôi bị ngứa da và phát ban, có thể là do bệnh gì?', 'Đây có thể là dấu hiệu của dị ứng, viêm da cơ địa, hoặc nhiễm nấm da. Tránh gãi và nên đến bác sĩ da liễu nếu triệu chứng nặng.', 'Triệu chứng chung'),
('symptom_analysis', 'Tôi bị buồn nôn và chán ăn, có thể do bệnh gì?', 'Có thể do rối loạn tiêu hóa, căng thẳng hoặc nhiễm trùng nhẹ. Nếu kéo dài nhiều ngày, bạn nên đi khám để xác định nguyên nhân.', 'Triệu chứng chung'),

-- Thông tin bệnh
('disease_info', 'Bệnh tiểu đường có những triệu chứng gì?', 'Các triệu chứng bao gồm: khát nước liên tục, đi tiểu nhiều lần, mệt mỏi, mờ mắt và sụt cân không rõ nguyên nhân.', 'Thông tin bệnh'),

-- Hướng dẫn dùng thuốc
('medicine_usage', 'Tôi nên uống thuốc hạ sốt như thế nào?', 'Bạn nên uống thuốc hạ sốt theo đúng liều bác sĩ chỉ định. Thường chỉ dùng khi sốt từ 38.5°C trở lên.', 'Hướng dẫn dùng thuốc'),

-- Hỗ trợ kỹ thuật
('account_help', 'Tôi quên mật khẩu đăng nhập thì phải làm sao?', 'Bạn hãy dùng chức năng "Quên mật khẩu" trên màn hình đăng nhập để đặt lại mật khẩu.', 'Hỗ trợ tài khoản'),
('app_issue', 'Ứng dụng bị lỗi khi tôi mở lên, phải làm sao?', 'Bạn nên thử khởi động lại ứng dụng hoặc cập nhật phiên bản mới nhất. Nếu vẫn gặp lỗi, hãy liên hệ bộ phận hỗ trợ.', 'Hỗ trợ kỹ thuật'),
('payment_issue', 'Tôi không thể thanh toán đơn thuốc, phải làm sao?', 'Bạn hãy kiểm tra lại thông tin tài khoản ngân hàng hoặc phương thức thanh toán. Nếu vẫn không được, hãy liên hệ bộ phận hỗ trợ.', 'Hỗ trợ thanh toán');


-- Có thể sẽ có thây đổi nên chưa dùng
-- Đặt lịch hẹn
-- ('booking_procedure', 'Làm sao để đặt lịch khám?', 'Bạn có thể đặt lịch khám trực tuyến qua website hoặc gọi tổng đài 1900-1234.', 'Đặt lịch'),
-- ('booking_available_slots', 'Tôi muốn biết lịch khám của bác sĩ A vào tuần tới?', 'Bạn có thể kiểm tra lịch khám trên trang web hoặc ứng dụng của bệnh viện.', 'Đặt lịch'),
-- ('booking_cancellation', 'Tôi muốn huỷ lịch hẹn đã đặt thì làm sao?', 'Bạn có thể huỷ lịch hẹn trong tài khoản cá nhân hoặc liên hệ tổng đài để được hỗ trợ.', 'Đặt lịch'),
-- ('booking_confirmation', 'Tôi đã đặt lịch khám nhưng chưa nhận được xác nhận, phải làm sao?', 'Bạn có thể kiểm tra trong mục "Lịch sử đặt lịch" hoặc liên hệ tổng đài để được hỗ trợ.', 'Đặt lịch'),
-- ('reschedule_booking', 'Tôi muốn thay đổi lịch hẹn đã đặt thì làm sao?', 'Bạn có thể thay đổi lịch hẹn qua tài khoản cá nhân hoặc gọi đến tổng đài.', 'Đặt lịch'),
-- ('cancel_booking', 'Tôi muốn huỷ lịch hẹn thì làm sao?', 'Bạn có thể huỷ lịch qua tài khoản cá nhân hoặc liên hệ tổng đài để được hỗ trợ.', 'Đặt lịch'),

----------------------------------------------------------------5. Dịch vụ y tế-------------------------------------------------------------------------------

----------------------------------------------------------------Dữ liệu mẫu cho categories--------------------------------------------------------------------------------------------------------------------------
INSERT INTO service_categories (name, slug, icon, description) VALUES
('Khám Tổng Quát', 'kham-tong-quat', 'fas fa-stethoscope', 'Dịch vụ khám sức khỏe tổng quát và tầm soát bệnh'),
('Tim Mạch', 'tim-mach', 'fas fa-heartbeat', 'Chẩn đoán và điều trị các bệnh lý tim mạch'),
('Tiêu Hóa', 'tieu-hoa', 'fas fa-prescription-bottle-alt', 'Điều trị các bệnh về đường tiêu hóa'),
('Thần Kinh', 'than-kinh', 'fas fa-brain', 'Điều trị các bệnh lý thần kinh'),
('Chấn Thương Chỉnh Hình', 'chan-thuong-chinh-hinh', 'fas fa-bone', 'Điều trị chấn thương và bệnh lý xương khớp'),
('Cấp Cứu', 'cap-cuu', 'fas fa-ambulance', 'Dịch vụ cấp cứu 24/7');

----------------------------------------------------------------Dữ liệu mẫu cho services--------------------------------------------------------------------------------------------------------------------------
INSERT INTO services (category_id, name, slug, short_description, price_from, price_to, is_featured, is_emergency) VALUES
(1, 'Khám Tổng Quát', 'kham-tong-quat', 'Khám sức khỏe định kỳ và tầm soát các bệnh lý thường gặp', 200000, 500000, FALSE, FALSE),
(2, 'Khám Tim Mạch', 'kham-tim-mach', 'Chẩn đoán và điều trị các bệnh lý tim mạch với trang thiết bị hiện đại', 300000, 2000000, TRUE, FALSE),
(3, 'Khám Tiêu Hóa', 'kham-tieu-hoa', 'Chẩn đoán và điều trị các bệnh lý về đường tiêu hóa, gan mật', 250000, 1500000, FALSE, FALSE),
(6, 'Dịch Vụ Cấp Cứu', 'dich-vu-cap-cuu', 'Dịch vụ cấp cứu 24/7 với đội ngũ y bác sĩ luôn sẵn sàng', NULL, NULL, FALSE, TRUE);

----------------------------------------------------------------Dữ liệu mẫu cho service_features----------------------------------------------------------------
INSERT INTO service_features (service_id, feature_name) VALUES
(1, 'Khám lâm sàng toàn diện'),
(1, 'Xét nghiệm máu cơ bản'),
(1, 'Đo huyết áp, nhịp tim'),
(1, 'Tư vấn dinh dưỡng'),
(2, 'Siêu âm tim'),
(2, 'Điện tim'),
(2, 'Holter 24h'),
(2, 'Thăm dò chức năng tim');

----------------------------------------------------------------Dữ liệu mẫu cho service_packages----------------------------------------------------------------
INSERT INTO service_packages (name, slug, description, price, duration, is_featured) VALUES
('Gói Cơ Bản', 'goi-co-ban', 'Gói khám sức khỏe cơ bản', 1500000, '/lần', FALSE),
('Gói Nâng Cao', 'goi-nang-cao', 'Gói khám sức khỏe nâng cao', 3500000, '/lần', TRUE),
('Gói Cao Cấp', 'goi-cao-cap', 'Gói khám sức khỏe cao cấp', 6500000, '/lần', FALSE);

----------------------------------------------------------------Dữ liệu mẫu cho --------------------------------------------------------------------------------------------------------------------------------
INSERT INTO package_features (package_id, feature_name) VALUES
(1, 'Khám lâm sàng tổng quát'),
(1, 'Xét nghiệm máu cơ bản'),
(1, 'Xét nghiệm nước tiểu'),
(1, 'X-quang phổi'),
(1, 'Điện tim'),
(1, 'Tư vấn kết quả'),
(2, 'Tất cả gói cơ bản'),
(2, 'Siêu âm bụng tổng quát'),
(2, 'Siêu âm tim');

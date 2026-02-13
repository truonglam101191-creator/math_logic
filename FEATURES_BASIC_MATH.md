FEATURES — BASIC MATH
=====================

Tập hợp các chủ đề "Toán cơ bản" trong dự án (danh sách được trích từ `lib/cores/datas/topic_data.dart`).

Mục tiêu: dùng để tham khảo nhanh, làm bộ câu hỏi học tập hoặc export sang JSON.

---

1) Addition (Phép cộng)
- Key (l10n): `Shared.instance.context.l10n.addition`
- File: `lib/cores/datas/topic_data.dart`
- Mô tả: câu hỏi dạng "a + b = ?" ở 3 mức difficulty (easy/medium/hard).

2) Subtraction (Phép trừ)
- Key (l10n): `Shared.instance.context.l10n.subtraction`
- File: `lib/cores/datas/topic_data.dart`
- Mô tả: câu hỏi "a - b = ?" (đảm bảo a >= b ở implementation).

3) Basic Math (Hỗn hợp số học cơ bản)
- Key (l10n): `Shared.instance.context.l10n.basicMath`
- File: `lib/cores/datas/topic_data.dart`
- Mô tả: hỗn hợp phép cộng, trừ, nhân; so sánh >/</=; điền số thiếu; tìm số lớn/nhỏ; kiểm tra chẵn/lẻ.

4) Advanced Arithmetic (Phép nhân/chia cơ bản nâng cao)
- Key (l10n): `Shared.instance.context.l10n.advancedArithmetic`
- File: `lib/cores/datas/topic_data.dart`
- Mô tả: phép nhân và phép chia (chia hết, tích, phân công độ khó theo phạm vi số).

5) Division (Phép chia riêng)
- Key (l10n): `Shared.instance.context.l10n.divisionMath`
- File: `lib/cores/datas/topic_data.dart`
- Mô tả: câu hỏi chia a ÷ b (a được tạo là b * k để đáp số nguyên).

6) Comprehensive Arithmetic (Toán tổng hợp cơ bản)
- Key (l10n): `Shared.instance.context.l10n.comprehensiveArithmetic`
- File: `lib/cores/datas/topic_data.dart`
- Mô tả: biểu thức kết hợp (a + b), (a + b) * c, ((a + b) * c) - a; thích hợp cho bài tập tổng hợp.

7) Fractions (Phân số) — nằm trong Visual Logic / Fraction section
- l10n keys: `fractionAddition`, `fractionSubtraction`, `fractionMultiplication`
- File: `lib/cores/datas/topic_data.dart` (topic `visualLogicMath`)
- Mô tả: phép cộng/trừ/nhân phân số, kết quả trả về ở dạng thập phân (toFixed).

8) Odd/Even (Chẵn/Lẻ)
- Key (l10n): `Shared.instance.context.l10n.oddEvenNumberMath`
- File: `lib/cores/datas/topic_data.dart`
- Mô tả: kiểm tra chẵn hay lẻ, cho mọi mức độ.

9) Prime Numbers (Số nguyên tố)
- Key (l10n): `Shared.instance.context.l10n.primeNumberMath`
- File: `lib/cores/datas/topic_data.dart`
- Mô tả: kiểm tra số nguyên tố, tìm số nguyên tố tiếp theo, đếm số nguyên tố < n.

10) Power & Root (Lũy thừa và căn)
- Key (l10n): `Shared.instance.context.l10n.powerAndRootMath`
- File: `lib/cores/datas/topic_data.dart`
- Mô tả: bình phương, lũy thừa nhỏ, căn bậc hai (làm tròn cho mức khó cao).

11) Modulo (Phép chia lấy dư)
- Key (l10n): `Shared.instance.context.l10n.moduloMath`
- File: `lib/cores/datas/topic_data.dart`
- Mô tả: phép toán modulo cho cộng/nhân/lũy thừa; hữu ích cho bài toán số học và lập trình cơ bản.

---

Gợi ý tiếp theo:
- Muốn tôi tạo thêm một file JSON hoặc Dart map export từ `TopicData.allTopics` chỉ chứa các topic cơ bản để dùng runtime? (Tôi có thể tạo `assets/basic_math_topics.json` tự động.)
- Muốn tôi thêm một helper function trong `topic_data.dart` như `TopicData.basicMathTopics()` trả về `List<TopicData>` lọc sẵn?


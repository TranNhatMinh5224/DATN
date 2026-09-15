# TỪ ĐIỂN THUẬT NGỮ Y KHOA — MIMIC-IV

Tài liệu này giải thích các thuật ngữ, từ viết tắt và giá trị mã hóa xuất hiện trong dữ liệu thực tế của bộ MIMIC-IV. Mọi ví dụ đều được trích xuất trực tiếp từ các file CSV gốc.

---

## PHẦN 1: LOẠI HÌNH NHẬP VIỆN (`admission_type`)

| Giá trị trong CSV | Giải thích tiếng Việt |
|---|---|
| `URGENT` | Cấp cứu — Bệnh nhân cần nhập viện gấp, không đủ thời gian lên kế hoạch trước |
| `ELECTIVE` | Có kế hoạch — Đã đặt lịch từ trước (mổ theo hẹn, khám định kỳ) |
| `EU OBSERVATION` | Theo dõi cấp cứu — Vào phòng cấp cứu để quan sát, chưa quyết định nhập viện hẳn |
| `AMBULATORY OBSERVATION` | Theo dõi ngoại trú — Theo dõi tại phòng khám, không cần nằm viện |
| `DIRECT OBSERVATION` | Theo dõi trực tiếp — Được gửi thẳng đến để theo dõi theo chỉ định bác sĩ |
| `SURGICAL SAME DAY ADMISSION` | Mổ trong ngày — Nhập viện mổ và xuất viện trong cùng 1 ngày |

---

## PHẦN 2: NƠI NHẬP VIỆN (`admission_location`)

| Giá trị trong CSV | Giải thích |
|---|---|
| `EMERGENCY ROOM` | Đến từ phòng cấp cứu (ER) của chính bệnh viện |
| `TRANSFER FROM HOSPITAL` | Chuyển từ bệnh viện khác sang |
| `PHYSICIAN REFERRAL` | Bác sĩ gia đình/phòng khám giới thiệu vào |
| `WALK-IN/SELF REFERRAL` | Bệnh nhân tự đến, không có ai giới thiệu |
| `CLINIC REFERRAL` | Từ phòng khám ngoại trú của chính bệnh viện chuyển vào |
| `PACU` | Từ phòng hồi tỉnh sau gây mê (Post-Anesthesia Care Unit) |
| `PROCEDURE SITE` | Nhập viện từ phòng thủ thuật |
| `INFORMATION NOT AVAILABLE` | Không có thông tin |

---

## PHẦN 3: NƠI XUẤT VIỆN (`discharge_location`)

| Giá trị trong CSV | Giải thích |
|---|---|
| `HOME` | Về nhà tự chăm sóc |
| `HOME HEALTH CARE` | Về nhà có y tá/hộ lý đến chăm |
| `SKILLED NURSING FACILITY` | Chuyển đến nhà dưỡng lão có y tá |
| `REHAB` | Chuyển đến cơ sở phục hồi chức năng |
| `LONG TERM CARE HOSPITAL` | Chuyển đến bệnh viện điều trị dài hạn |
| `CHRONIC/LONG TERM ACUTE CARE` | Điều trị dài hạn cho bệnh mãn tính |
| `ACUTE HOSPITAL` | Chuyển sang bệnh viện cấp tính khác |
| `HOSPICE` | Chuyển đến cơ sở chăm sóc cuối đời |
| `DIED` | Bệnh nhân qua đời trong đợt này |

---

## PHẦN 4: BẢO HIỂM Y TẾ (`insurance`)

| Giá trị trong CSV | Giải thích |
|---|---|
| `Medicare` | Bảo hiểm liên bang Mỹ — Dành cho người ≥ 65 tuổi hoặc khuyết tật |
| `Medicaid` | Bảo hiểm tiểu bang Mỹ — Dành cho người thu nhập thấp |
| `Other` | Bảo hiểm tư nhân hoặc nguồn khác |

---

## PHẦN 5: CHỦNG TỘC (`race`)

| Giá trị trong CSV | Giải thích |
|---|---|
| `WHITE` | Người da trắng (Gốc Châu Âu) |
| `BLACK/AFRICAN AMERICAN` | Người Mỹ gốc Phi |
| `HISPANIC OR LATINO` | Người gốc Tây Ban Nha/Mỹ Latinh |
| `ASIAN` | Người gốc Châu Á |
| `UNKNOWN` / `UNABLE TO OBTAIN` | Không xác định được |
| `OTHER` | Chủng tộc khác |

---

## PHẦN 6: LOẠI KHOA/PHÒNG ICU (`careunit`)

| Giá trị trong CSV | Tên đầy đủ | Giải thích |
|---|---|---|
| `MICU` | Medical ICU | Hồi sức Nội khoa (Tim mạch, Tiêu hóa, Hô hấp) |
| `SICU` | Surgical ICU | Hồi sức Ngoại khoa (sau phẫu thuật lớn) |
| `TSICU` | Trauma/Surgical ICU | Hồi sức Chấn thương và Ngoại khoa |
| `CCU` | Coronary Care Unit | Đơn vị chăm sóc bệnh Tim mạch đặc biệt |
| `CVICU` | Cardiovascular ICU | Hồi sức Tim mạch (sau mổ tim) |
| `NICU` | Neonatal ICU | Hồi sức Sơ sinh |
| `NEURO SICU` | Neurosurgical ICU | Hồi sức Phẫu thuật Thần kinh |
| `NEURO MICU` | Neuro Medical ICU | Hồi sức Nội Thần kinh |
| `Neuro Intermediate` | Neuro Intermediate Care | Khoa Thần kinh bán ICU |
| `Emergency Department` | Emergency Department | Phòng Cấp cứu |

---

## PHẦN 7: PHÂN LOẠI NHÓM XÉT NGHIỆM MÁU (`category` / `fluid`)

### Nhóm xét nghiệm (category):
| Giá trị | Giải thích |
|---|---|
| `Blood Gas` | Khí máu động mạch — Đo pH, CO2, O2, tình trạng toan/kiềm |
| `Chemistry` | Sinh hóa máu — Glucose, Creatinine, Bilirubin, Điện giải |
| `Hematology` | Huyết học — Số lượng tế bào máu (bạch cầu, hồng cầu, tiểu cầu) |
| `Microbiology` | Vi sinh vật học — Cấy máu, cấy nước tiểu |
| `Coagulation` | Đông máu — PT, PTT, INR |
| `Urinalysis` | Xét nghiệm nước tiểu |
| `Toxicology` | Độc chất học — Phát hiện ma túy, ngộ độc |

### Loại dịch (fluid):
| Giá trị | Giải thích |
|---|---|
| `Blood` | Máu — xét nghiệm máu thông thường |
| `Urine` | Nước tiểu |
| `Pleural` | Dịch màng phổi |
| `Cerebrospinal Fluid (CSF)` | Dịch não tủy |
| `Ascites` | Dịch báng bụng |
| `Other Body Fluid` | Dịch cơ thể khác |

---

## PHẦN 8: CÁC XÉT NGHIỆM MÁU PHỔ BIẾN NHẤT (`d_labitems.label`)

| Tên xét nghiệm | Ý nghĩa lâm sàng | Đơn vị thường gặp |
|---|---|---|
| `Glucose` | Đường huyết — Đánh giá tiểu đường, hạ đường huyết | mg/dL |
| `Creatinine` | Chức năng thận — Cao = thận suy | mg/dL |
| `Sodium` | Natri máu — Rối loạn điện giải | mEq/L |
| `Potassium` | Kali máu — Ảnh hưởng nhịp tim | mEq/L |
| `Chloride` | Chlorua máu — Cân bằng axit-bazơ | mEq/L |
| `Bicarbonate` | Dự trữ kiềm — Đánh giá toan chuyển hóa | mEq/L |
| `White Blood Cells (WBC)` | Bạch cầu — Cao = nhiễm trùng/viêm | K/uL |
| `Hemoglobin` | Huyết sắc tố — Thấp = thiếu máu | g/dL |
| `Hematocrit` | Tỷ lệ hồng cầu trong máu — Thấp = mất máu | % |
| `Platelets` | Tiểu cầu — Thấp = nguy cơ chảy máu | K/uL |
| `Lactate` | Axit lactic — Cao = sốc, thiếu oxy mô | mmol/L |
| `Troponin T` | Troponin tim — Cao = nhồi máu cơ tim | ng/mL |
| `ALT` | Men gan — Cao = tổn thương tế bào gan | IU/L |
| `AST` | Men gan — Cao = tổn thương gan/cơ | IU/L |
| `Bilirubin, Total` | Bilirubin toàn phần — Cao = vàng da | mg/dL |
| `pH` | Độ pH máu — 7.35-7.45 là bình thường | |
| `pCO2` | Áp suất riêng phần CO2 — Đánh giá thông khí phổi | mmHg |
| `pO2` | Áp suất riêng phần O2 — Đánh giá oxy hóa máu | mmHg |
| `PT` | Thời gian Prothrombin — Đánh giá đông máu | sec |
| `INR(PT)` | Chỉ số chuẩn hóa đông máu — Bệnh nhân uống thuốc chống đông | |
| `Urea Nitrogen (BUN)` | Ure máu — Cao = suy thận hoặc mất nước | mg/dL |
| `Magnesium` | Magie máu — Thiếu gây co giật, loạn nhịp | mg/dL |
| `Calcium, Total` | Canxi máu — Ảnh hưởng cơ tim và xương | mg/dL |
| `C-Reactive Protein (CRP)` | Protein phản ứng C — Cao = đang có viêm nhiễm | mg/L |
| `Procalcitonin` | Procalcitonin — Cao = nhiễm khuẩn nặng (Sepsis) | ng/mL |

---

## PHẦN 9: ĐƯỜNG DÙNG THUỐC (`route`)

| Giá trị trong CSV | Tên đầy đủ | Giải thích |
|---|---|---|
| `PO` | Per Os (By Mouth) | Uống qua miệng |
| `PO/NG` | Per Os / Nasogastric | Uống hoặc qua ống thông mũi-dạ dày |
| `IV` | Intravenous | Tiêm/Truyền tĩnh mạch — Tác dụng nhanh nhất |
| `IV DRIP` | Intravenous Drip | Truyền tĩnh mạch nhỏ giọt (chậm, liên tục) |
| `IVPCA` | IV Patient-Controlled Analgesia | Truyền TM giảm đau do bệnh nhân tự điều chỉnh |
| `IM` | Intramuscular | Tiêm bắp |
| `SC` / `SUBCUT` | Subcutaneous | Tiêm dưới da (Vd: Insulin, Heparin) |
| `IH` | Inhaled | Xịt/Hít qua đường hô hấp (bơm phổi) |
| `PR` | Per Rectum | Đặt thuốc qua hậu môn |
| `TD` / `TRANSDERMAL` | Transdermal | Dán qua da (miếng dán giảm đau, nicotine) |
| `TP` | Topical | Bôi ngoài da |
| `NG` | Nasogastric | Qua ống mũi-dạ dày |
| `BOTH EYES` | Both Eyes | Nhỏ mắt cả hai mắt |

---

## PHẦN 10: LOẠI THUỐC (`drug_type`)

| Giá trị | Giải thích |
|---|---|
| `MAIN` | Thuốc chính — Hoạt chất trị liệu chính |
| `BASE` | Dung môi pha — Dung dịch để pha thuốc (thường là Nước muối hoặc Glucose) |

---

## PHẦN 11: NHÓM THUỐC TIÊM ICU PHỔ BIẾN

| Tên thuốc | Nhóm | Công dụng |
|---|---|---|
| `Norepinephrine` | Vận mạch | Nâng huyết áp trong sốc nhiễm trùng |
| `Vasopressin` | Vận mạch | Nâng huyết áp khi Norepinephrine không đủ |
| `Dopamine` | Vận mạch | Nâng huyết áp và hỗ trợ thận |
| `Dobutamine` | Tăng co bóp tim | Hỗ trợ tim trong suy tim cấp |
| `Epinephrine` | Cấp cứu tim | Tim ngừng đập, phản ứng sốc phản vệ |
| `Propofol` | Gây mê/An thần | An thần sâu cho bệnh nhân thở máy |
| `Midazolam (Versed)` | An thần | An thần nhẹ-vừa |
| `Fentanyl` | Giảm đau mạnh | Giảm đau opioid mạnh qua tĩnh mạch |
| `Hydromorphone (Dilaudid)` | Giảm đau mạnh | Giảm đau opioid rất mạnh |
| `Ketamine` | Gây mê/Giảm đau | Giảm đau đặc biệt và dự phòng co giật |
| `Lorazepam (Ativan)` | Chống lo âu/co giật | Điều trị co giật, an thần |
| `Haloperidol (Haldol)` | Chống loạn thần | Điều trị mê sảng (Delirium) ICU |
| `Amiodarone` | Chống loạn nhịp | Điều chỉnh nhịp tim |
| `Furosemide (Lasix)` | Lợi tiểu | Thải nước dư trong suy tim, phù phổi |
| `Insulin - Regular` | Hạ đường huyết | Kiểm soát đường huyết trong ICU |
| `Heparin` | Chống đông | Phòng huyết khối, tắc mạch |
| `Magnesium Sulfate` | Điện giải/Chống co giật | Bổ sung Magie, điều trị tiền sản giật |
| `Nitroglycerin` | Giãn mạch vành | Giảm đau ngực, giảm huyết áp |
| `Naloxone (Narcan)` | Giải độc | Giải độc opioid (ngộ độc morphine) |
| `Cisatracurium` | Giãn cơ | Giãn cơ hoàn toàn để đặt nội khí quản |

---

## PHẦN 12: SỰ KIỆN DÙNG THUỐC THỰC TẾ (`emar.event_txt`)

| Giá trị trong CSV | Giải thích |
|---|---|
| `Administered` | Đã cho dùng — Y tá đã đưa thuốc cho bệnh nhân thành công |
| `Partial Administered` | Đã cho dùng một phần — Bệnh nhân không dùng hết |
| `Delayed Administered` | Đã cho dùng trễ hơn giờ dự kiến |
| `Not Given` | Không cho dùng — Bác sĩ hoặc y tá quyết định bỏ liều này |
| `Not Given per Sliding Scale` | Không cho do đường huyết chưa đạt ngưỡng cần tiêm insulin |
| `Hold Dose` | Tạm giữ liều — Chờ thêm thông tin trước khi cho dùng |
| `Applied` | Đã dán/đặt — Dùng cho thuốc dán da, đặt hậu môn |
| `Not Applied` | Chưa dán/đặt |
| `Flushed` | Đã bơm tráng ống — Bơm nước muối để thông ống truyền |
| `Not Flushed` | Không tráng ống |
| `Started` | Đã bắt đầu truyền (dành cho thuốc truyền dài giờ) |
| `Stopped` | Đã dừng truyền |
| `Stopped - Unscheduled` | Dừng truyền đột xuất, không theo kế hoạch |
| `Assessed` | Đã kiểm tra/đánh giá bệnh nhân |
| `Confirmed` | Đã xác nhận |
| `Administered in Other Location` | Đã cho dùng ở khoa/phòng khác |
| `Removed` | Đã tháo ra (dành cho miếng dán) |

---

## PHẦN 13: CÁC CHỈ SỐ SINH HIỆU ICU PHỔ BIẾN (`d_items.label`)

| Tên chỉ số | Ý nghĩa lâm sàng | Đơn vị | Ngưỡng bình thường |
|---|---|---|---|
| `Heart Rate` | Nhịp tim | bpm | 60 – 100 |
| `Respiratory Rate` | Nhịp thở | insp/min | 12 – 20 |
| `O2 Saturation Pulseoxymetry` | SpO2 — Độ bão hòa oxy mao mạch | % | ≥ 95% |
| `Non Invasive Blood Pressure [Systolic]` | Huyết áp tối đa (không xâm lấn) | mmHg | 90 – 140 |
| `Non Invasive Blood Pressure [Diastolic]` | Huyết áp tối thiểu | mmHg | 60 – 90 |
| `Non Invasive Blood Pressure mean` | Huyết áp trung bình | mmHg | 70 – 105 |
| `Arterial Blood Pressure [Systolic]` | Huyết áp đo qua động mạch xâm lấn | mmHg | 90 – 140 |
| `Temperature Celsius` | Nhiệt độ cơ thể (Celsius) | °C | 36.1 – 37.2 |
| `Temperature Fahrenheit` | Nhiệt độ cơ thể (Fahrenheit) | °F | 97 – 99 |
| `GCS - Eye Opening` | Thang điểm hôn mê Glasgow — Mắt | điểm | 1–4 |
| `GCS - Verbal Response` | Thang điểm hôn mê Glasgow — Lời nói | điểm | 1–5 |
| `GCS - Motor Response` | Thang điểm hôn mê Glasgow — Vận động | điểm | 1–6 |
| `Ventilator Mode` | Chế độ máy thở | — | — |
| `Tidal Volume (Set)` | Thể tích khí lưu thông cài đặt máy thở | mL | 400–600 |
| `PEEP Set` | Áp lực dương cuối kỳ thở ra | cmH2O | 5–10 |
| `Inspired O2 Fraction` | FiO2 — Nồng độ oxy cài đặt | fraction | 0.21–1.0 |
| `PH (Arterial)` | pH máu động mạch | | 7.35–7.45 |
| `Bladder Pressure` | Áp lực bàng quang — Phát hiện hội chứng khoang bụng | cmH2O | < 12 |
| `Pain Level` | Mức độ đau bệnh nhân tự đánh giá | 0–10 | ≤ 3 |
| `SvO2` | Độ bão hòa oxy máu tĩnh mạch trộn | % | 65–75% |
| `PCWP` | Áp lực mao mạch phổi bít — Đánh giá áp lực tim trái | mmHg | 6–12 |

---

## PHẦN 14: NHÓM PHÂN LOẠI ICU (`icu.d_items.category`)

| Category | Giải thích |
|---|---|
| `Routine Vital Signs` | Sinh hiệu thường quy (Nhịp tim, Huyết áp, Nhiệt độ...) |
| `Hemodynamics` | Huyết động học — Theo dõi áp lực tim mạch chuyên sâu |
| `Respiratory` | Hô hấp — Máy thở, SpO2, khí máu |
| `Neurological` | Thần kinh — Glasgow, đồng tử, co giật |
| `Fluids/Intake` | Theo dõi dịch vào cơ thể |
| `Labs` | Kết quả xét nghiệm ghi nhận tại giường |
| `Medications` | Thuốc truyền tĩnh mạch |
| `Blood Products/Colloids` | Máu và chế phẩm máu (truyền máu, albumin) |
| `Nutrition - Enteral` | Dinh dưỡng qua ống thông ruột |
| `Nutrition - Parenteral` | Dinh dưỡng qua đường tĩnh mạch |
| `Pain/Sedation` | Giảm đau và an thần |
| `Alarms` | Cài đặt ngưỡng cảnh báo máy monitor |
| `Intubation` | Đặt nội khí quản — Thở máy |
| `Cardiovascular` | Tim mạch — Máy tạo nhịp, van tim |
| `Pulmonary` | Phổi — Siêu âm phổi, Dẫn lưu màng phổi |
| `GI/GU` | Tiêu hóa/Tiết niệu — Nuôi ăn, nước tiểu, ống thông |

---

## PHẦN 15: THUẬT NGỮ LÂM SÀNG QUAN TRỌNG TRONG CHẨN ĐOÁN

| Thuật ngữ tiếng Anh | Giải thích |
|---|---|
| `Sepsis` | Nhiễm khuẩn huyết — Vi khuẩn vào máu gây phản ứng toàn thân nguy hiểm |
| `Septic Shock` | Sốc nhiễm khuẩn — Giai đoạn nặng của Sepsis, huyết áp tụt, cần vận mạch |
| `Pneumonia` | Viêm phổi — Nhiễm trùng phổi do vi khuẩn, virus |
| `ARDS` | Hội chứng suy hô hấp cấp tiến triển — Phổi tổn thương nặng, không lấy đủ oxy |
| `CHF` / `Heart Failure` | Suy tim — Tim bơm không đủ máu cho cơ thể |
| `COPD` | Bệnh phổi tắc nghẽn mãn tính — Khó thở mãn tính do hút thuốc |
| `AKI` | Tổn thương thận cấp — Thận đột ngột không lọc máu được |
| `CKD` | Bệnh thận mãn tính — Thận suy dần theo thời gian |
| `DM` / `Diabetes Mellitus` | Đái tháo đường — Rối loạn chuyển hóa glucose |
| `MI` / `Myocardial Infarction` | Nhồi máu cơ tim — Mạch vành tắc, cơ tim chết do thiếu oxy |
| `CVA` / `Stroke` | Đột quỵ não — Nhồi máu não hoặc xuất huyết não |
| `UTI` | Nhiễm trùng đường tiết niệu — Vi khuẩn trong nước tiểu |
| `DVT` | Huyết khối tĩnh mạch sâu — Cục máu đông ở chân |
| `PE` | Thuyên tắc phổi — Cục máu đông chạy lên phổi |
| `GI Bleed` | Xuất huyết tiêu hóa — Chảy máu trong dạ dày hoặc ruột |
| `Hypertension` | Tăng huyết áp — Huyết áp > 140/90 mmHg mãn tính |
| `Cirrhosis` | Xơ gan — Gan bị tổn thương thay thế bằng mô xơ |
| `Delirium` | Mê sảng — Rối loạn ý thức cấp, thường xảy ra ở ICU |
| `Intubation` | Đặt nội khí quản — Đưa ống vào khí quản để thở máy |
| `Extubation` | Rút nội khí quản — Rút ống thở ra khi bệnh nhân tự thở được |
| `Dialysis / CRRT` | Lọc máu — Thay thế chức năng thận khi thận suy |
| `Code Status` | Mức độ can thiệp cấp cứu (Full Code = Cứu hết mức, DNR = Không cấp cứu) |
| `DNR` | Do Not Resuscitate — Không hồi sức tim phổi theo nguyện vọng bệnh nhân |
| `Palliative Care` | Chăm sóc giảm nhẹ — Tập trung giảm đau, nâng chất lượng sống cuối đời |
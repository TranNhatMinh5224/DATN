# TỪ ĐIỂN DỮ LIỆU MIMIC-IV (DATA DICTIONARY) - CÓ VÍ DỤ THỰC TẾ

Tài liệu này giải thích chi tiết ý nghĩa của 22 bảng trong nhóm `hosp` (dữ liệu bệnh viện chung) và 9 bảng trong nhóm `icu` (dữ liệu Hồi sức tích cực), bao gồm tất cả các trường (cột) bên trong. Các ví dụ minh họa được trích xuất trực tiếp từ dòng dữ liệu thực tế của MIMIC-IV.

---

## PHẦN 1: NHÓM DỮ LIỆU BỆNH VIỆN (HOSP) - 22 BẢNG

Nhóm `hosp` chứa thông tin hành chính, chẩn đoán, xét nghiệm và đơn thuốc chung trong suốt quá trình bệnh nhân ở bệnh viện.

### 1. Bảng `patients` (Thông tin bệnh nhân)
Chứa thông tin cốt lõi, không thay đổi của bệnh nhân.
- `subject_id`: Mã định danh duy nhất. _(VD: 10000032)_
- `gender`: Giới tính. _(VD: F)_
- `anchor_age`: Tuổi của bệnh nhân tại năm mốc `anchor_year`. _(VD: 52)_
- `anchor_year`: Năm mốc tham chiếu để tính tuổi. _(VD: 2180)_
- `anchor_year_group`: Khoảng thời gian 3 năm tương ứng với năm mốc. _(VD: 2014 - 2016)_
- `dod`: Ngày qua đời. _(VD: 2180-09-09)_

### 2. Bảng `admissions` (Lịch sử nhập viện)
Ghi nhận mỗi lần bệnh nhân làm thủ tục nhập viện.
- `subject_id`: Mã bệnh nhân. _(VD: 10000032)_
- `hadm_id`: Mã đợt nhập viện. _(VD: 22595853)_
- `admittime`: Thời gian nhập viện. _(VD: 2180-05-06 22:23:00)_
- `dischtime`: Thời gian xuất viện. _(VD: 2180-05-07 17:15:00)_
- `deathtime`: Thời gian tử vong tại viện. _(VD: )_
- `admission_type`: Loại hình nhập viện. _(VD: URGENT)_
- `admit_provider_id`: Mã bác sĩ phụ trách. _(VD: P49AFC)_
- `admission_location`: Nơi chuyển tới. _(VD: TRANSFER FROM HOSPITAL)_
- `discharge_location`: Nơi chuyển đi sau xuất viện. _(VD: HOME)_
- `insurance`: Loại bảo hiểm. _(VD: Medicaid)_
- `language`: Ngôn ngữ. _(VD: English)_
- `marital_status`: Hôn nhân. _(VD: WIDOWED)_
- `race`: Chủng tộc. _(VD: WHITE)_
- `edregtime`: Thời gian đến cấp cứu. _(VD: 2180-05-06 19:17:00)_
- `edouttime`: Thời gian rời cấp cứu. _(VD: 2180-05-06 23:30:00)_
- `hospital_expire_flag`: Nhãn tử vong. _(VD: 0)_

### 3. Bảng `transfers` (Luân chuyển khoa phòng)
Theo dõi hành trình di chuyển của bệnh nhân.
- `subject_id`, `hadm_id`: Mã bệnh nhân, mã nhập viện. _(VD: 10000032, 22595853)_
- `transfer_id`: Mã lần luân chuyển. _(VD: 33258284)_
- `eventtype`: Loại sự kiện. _(VD: ED)_
- `careunit`: Khoa/phòng bệnh. _(VD: Emergency Department)_
- `intime`: Giờ vào khoa. _(VD: 2180-05-06 19:17:00)_
- `outtime`: Giờ rời khoa. _(VD: 2180-05-06 23:30:00)_

### 4. Bảng `services` (Dịch vụ y tế)
Các dịch vụ lâm sàng (chuyên khoa) mà bệnh nhân sử dụng.
- `subject_id`, `hadm_id`: Mã bệnh nhân, mã nhập viện. _(VD: 10000032, 22595853)_
- `transfertime`: Thời gian chuyển dịch vụ. _(VD: 2180-05-06 22:24:57)_
- `prev_service`: Dịch vụ trước đó. _(VD: )_
- `curr_service`: Dịch vụ hiện tại. _(VD: MED)_

### 5. Bảng `diagnoses_icd` (Chẩn đoán bệnh)
Danh sách các mã bệnh theo ICD.
- `subject_id`, `hadm_id`: Khóa ngoại. _(VD: 10000032, 22595853)_
- `seq_num`: Số thứ tự ưu tiên bệnh. _(VD: 1)_
- `icd_code`: Mã bệnh ICD. _(VD: 5723)_
- `icd_version`: Phiên bản ICD. _(VD: 9)_

### 6. Bảng `d_icd_diagnoses` (Từ điển mã bệnh ICD)
Tra cứu `icd_code` thực chất là bệnh gì.
- `icd_code`: Mã bệnh. _(VD: 0010)_
- `icd_version`: Phiên bản. _(VD: 9)_
- `long_title`: Tên tiếng Anh đầy đủ của bệnh. _(VD: Cholera due to vibrio cholerae)_

### 7. Bảng `procedures_icd` (Thủ thuật y khoa)
Các thủ thuật bệnh nhân đã làm toàn viện.
- `subject_id`, `hadm_id`: Khóa ngoại. _(VD: 10000032, 22595853)_
- `seq_num`: Số thứ tự thủ thuật. _(VD: 1)_
- `chartdate`: Ngày thực hiện thủ thuật. _(VD: 2180-05-07)_
- `icd_code`: Mã thủ thuật ICD. _(VD: 5491)_
- `icd_version`: Phiên bản ICD. _(VD: 9)_

### 8. Bảng `d_icd_procedures` (Từ điển mã thủ thuật ICD)
Tra cứu tên của thủ thuật.
- `icd_code`: Mã thủ thuật. _(VD: 0001)_
- `icd_version`: Phiên bản. _(VD: 9)_
- `long_title`: Tên đầy đủ thủ thuật. _(VD: Therapeutic ultrasound of vessels of head and neck)_

### 9. Bảng `labevents` (Kết quả xét nghiệm)
TẤT CẢ xét nghiệm máu, nước tiểu...
- `labevent_id`: Mã xét nghiệm. _(VD: 1)_
- `subject_id`, `hadm_id`: Khóa ngoại. _(VD: 10000032, 22595853)_
- `specimen_id`: Mã mẫu bệnh phẩm. _(VD: 2704548)_
- `itemid`: Mã loại xét nghiệm. _(VD: 50931)_
- `order_provider_id`: Mã bác sĩ chỉ định. _(VD: P69FQC)_
- `charttime`: Thời gian lấy mẫu. _(VD: 2180-03-23 11:51:00)_
- `storetime`: Thời gian trả kết quả. _(VD: 2180-03-23 15:56:00)_
- `value`: Kết quả (dạng text). _(VD: 95)_
- `valuenum`: Kết quả (dạng số). _(VD: 95.0)_
- `valueuom`: Đơn vị đo. _(VD: mg/dL)_
- `ref_range_lower`, `ref_range_upper`: Ngưỡng bình thường. _(VD: 70 - 100)_
- `flag`: Cảnh báo bất thường. _(VD: abnormal)_
- `priority`: Mức độ ưu tiên. _(VD: ROUTINE)_
- `comments`: Ghi chú thêm. _(VD: IF FASTING, 70-100 NORMAL, >125 PROVISIONAL DIABETES.)_

### 10. Bảng `d_labitems` (Từ điển loại xét nghiệm)
Tra cứu ý nghĩa `itemid` trong `labevents`.
- `itemid`: Mã xét nghiệm. _(VD: 50801)_
- `label`: Tên xét nghiệm. _(VD: Alveolar-arterial Gradient)_
- `fluid`: Loại dịch. _(VD: Blood)_
- `category`: Phân loại. _(VD: Blood Gas)_

### 11. Bảng `microbiologyevents` (Vi sinh vật học)
Kết quả cấy vi khuẩn, tìm vi nấm.
- `microevent_id`: Mã kết quả vi sinh. _(VD: 1)_
- `subject_id`, `hadm_id`: Khóa ngoại. _(VD: 10000032, 22595853)_
- `micro_specimen_id`: Mã mẫu cấy. _(VD: 1304715)_
- `order_provider_id`: Bác sĩ chỉ định. _(VD: P69FQC)_
- `chartdate`, `charttime`: Thời gian lấy mẫu cấy. _(VD: 2180-03-23 11:51:00)_
- `spec_itemid`, `spec_type_desc`: Loại mẫu cấy. _(VD: 70046, IMMUNOLOGY)_
- `test_seq`: Số thứ tự xét nghiệm. _(VD: 1)_
- `storedate`, `storetime`: Thời gian có kết quả. _(VD: 2180-03-26 10:54:00)_
- `test_itemid`, `test_name`: Tên xét nghiệm vi sinh. _(VD: 90123, HCV VIRAL LOAD)_
- `org_itemid`, `org_name`: Tên vi khuẩn. _(VD: )_
- `isolate_num`: Số thứ tự khuẩn lạc. _(VD: )_
- `quantity`: Số lượng vi khuẩn. _(VD: )_
- `ab_itemid`, `ab_name`: Tên kháng sinh thử nghiệm. _(VD: )_
- `dilution_text`, `dilution_comparison`, `dilution_value`: Nồng độ kháng sinh (MIC). _(VD: )_
- `interpretation`: Đánh giá Kháng (R) hay Nhạy (S). _(VD: )_
- `comments`: Ghi chú. _(VD: )_

### 12. Bảng `prescriptions` (Đơn thuốc)
Các loại thuốc bác sĩ kê.
- `subject_id`, `hadm_id`: Khóa ngoại. _(VD: 10000032, 22595853)_
- `pharmacy_id`: Mã bên dược. _(VD: 12775705)_
- `poe_id`, `poe_seq`: Kết nối y lệnh POE. _(VD: 10000032-55, 55)_
- `order_provider_id`: Bác sĩ kê đơn. _(VD: P85UQ1)_
- `starttime`, `stoptime`: Thời gian dùng. _(VD: 2180-05-08 08:00:00 - 2180-05-07 22:00:00)_
- `drug_type`: Loại thuốc (MAIN/BASE). _(VD: MAIN)_
- `drug`: Tên thuốc. _(VD: Furosemide)_
- `formulary_drug_cd`: Mã thuốc nội bộ. _(VD: FURO40)_
- `gsn`, `ndc`: Bộ mã tiêu chuẩn quốc tế. _(VD: 008209, 51079007320)_
- `prod_strength`: Hàm lượng. _(VD: 40mg Tablet)_
- `form_rx`: Dạng thuốc. _(VD: )_
- `dose_val_rx`, `dose_unit_rx`: Liều lượng một lần. _(VD: 40 mg)_
- `form_val_disp`, `form_unit_disp`: Lượng phát thực tế. _(VD: 1 TAB)_
- `doses_per_24_hrs`: Số liều/ngày. _(VD: 1)_
- `route`: Đường dùng. _(VD: PO/NG)_

### 13. Bảng `pharmacy` (Hệ thống nhà thuốc)
Chi tiết cấp phát thuốc.
- _Tương tự `prescriptions` cộng thêm:_
- `medication`: Tên thuốc. _(VD: Furosemide)_
- `status`: Trạng thái. _(VD: Discontinued via patient discharge)_
- `entertime`, `verifiedtime`: Thời gian xác nhận. _(VD: 2180-05-07 09:32:35)_
- `frequency`: Tần suất. _(VD: DAILY)_
- `disp_sched`: Lịch cấp phát. _(VD: 08)_
- `infusion_type`, `basal_rate`, `duration`...: Dành cho thuốc truyền. _(VD: 1 Hours)_
- `dispensation`: Kho phát. _(VD: Omnicell)_

### 14. Bảng `emar` (Quản lý dùng thuốc điện tử - Thực tế)
Ghi nhận y tá ĐÃ THỰC SỰ cho uống/tiêm.
- `subject_id`, `hadm_id`: Khóa ngoại. _(VD: 10000032, 22595853)_
- `emar_id`, `emar_seq`: Mã ghi nhận. _(VD: 10000032-10, 10)_
- `poe_id`, `pharmacy_id`: Khóa liên kết y lệnh/dược. _(VD: 10000032-32, 86768272)_
- `enter_provider_id`: Y tá cấp thuốc. _(VD: )_
- `charttime`: Thời điểm ĐÃ CHO DÙNG. _(VD: 2180-05-07 07:51:00)_
- `medication`: Tên thuốc. _(VD: Heparin)_
- `event_txt`: Hành động thực tế. _(VD: Administered)_
- `scheduletime`: Giờ dự kiến uống. _(VD: 2180-05-07 08:00:00)_
- `storetime`: Giờ lưu máy. _(VD: 2180-05-07 07:56:00)_

### 15. Bảng `emar_detail` (Chi tiết của eMAR)
Lượng thực tế đã đưa cho bệnh nhân từ `emar`.
- `administration_type`: Phân loại. _(VD: Standard Maintenance Medication)_
- `dose_due`, `dose_due_unit`: Liều dự kiến. _(VD: 5000 UNIT)_
- `dose_given`, `dose_given_unit`: Liều thực tế. _(VD: 5000 UNIT)_
- `route`: Đường dùng. _(VD: PO)_
- `product_description`: Tên cụ thể sinh phẩm. _(VD: Heparin Sodium 5000 Units / mL)_

### 16. Bảng `poe` (Y lệnh của bác sĩ - POE)
Bất kỳ y lệnh nào bác sĩ đưa ra (thuốc, X-Quang, chế độ ăn).
- `poe_id`, `poe_seq`: Mã y lệnh. _(VD: 10000032-100, 100)_
- `subject_id`, `hadm_id`: Khóa ngoại. _(VD: 10000032, 22841357)_
- `ordertime`: Giờ ra y lệnh. _(VD: 2180-06-26 22:09:02)_
- `order_type`, `order_subtype`: Loại y lệnh. _(VD: Medications, Code status)_
- `transaction_type`: Trạng thái thao tác. _(VD: New)_
- `order_provider_id`: Bác sĩ. _(VD: P992IN)_
- `order_status`: Trạng thái lệnh. _(VD: Inactive)_

### 17. Bảng `poe_detail` (Chi tiết y lệnh POE)
- `field_name`: Tên chi tiết. _(VD: Code status)_
- `field_value`: Giá trị. _(VD: Resuscitate (Full code))_

### 18. Bảng `drgcodes` (Mã thanh toán viện phí)
Mã dùng để tính tiền bảo hiểm.
- `drg_type`, `drg_code`: Loại mã và Mã nhóm. _(VD: APR, 283)_
- `description`: Mô tả nhóm. _(VD: OTHER DISORDERS OF THE LIVER)_
- `drg_severity`: Mức độ nghiêm trọng. _(VD: 2)_
- `drg_mortality`: Nguy cơ tử vong đánh giá. _(VD: 2)_

### 19. Bảng `hcpcsevents` & 20. Bảng `d_hcpcs` (Mã dịch vụ y tế)
Các dịch vụ đã làm để tính tiền.
- `hcpcs_cd`: Mã dịch vụ. _(VD: 99218)_
- `short_description`: Dịch vụ. _(VD: Hospital observation services)_

### 21. Bảng `omr` (Hồ sơ y tế trực tuyến)
Sinh hiệu thu thập ngoại trú hoặc chỉ số sức khỏe.
- `result_name`: Tên chỉ số. _(VD: Blood Pressure)_
- `result_value`: Giá trị. _(VD: 110/65)_

### 22. Bảng `provider` (Danh sách nhân viên)
- `provider_id`: Mã nhân viên. _(VD: P00019)_

---

## PHẦN 2: NHÓM DỮ LIỆU HỒI SỨC TÍCH CỰC (ICU) - 9 BẢNG

Nhóm `icu` chứa dữ liệu độ phân giải rất cao, đo từng phút/từng giờ khi bệnh nhân nằm ICU.

### 1. Bảng `icustays` (Lịch sử nằm ICU)
Xác định khoảng thời gian lưu lại ICU.
- `subject_id`, `hadm_id`: Khóa ngoại. _(VD: 10000032, 29079034)_
- `stay_id`: Mã đợt nằm ICU. _(VD: 39553978)_
- `first_careunit`, `last_careunit`: Phòng ICU. _(VD: Medical Intensive Care Unit (MICU))_
- `intime`: Giờ vào ICU. _(VD: 2180-07-23 14:00:00)_
- `outtime`: Giờ ra ICU. _(VD: 2180-07-23 23:50:47)_
- `los`: (Length of Stay) Số ngày nằm ICU. _(VD: 0.41026)_

### 2. Bảng `chartevents` (Bảng Sinh Hiệu và Khám Lâm Sàng)
**Bảng lớn nhất (hàng trăm triệu dòng)**. Mọi thứ từ monitor (Nhịp tim, Huyết áp...) và sổ tay y tá.
- `subject_id`, `hadm_id`, `stay_id`: Khóa ngoại. _(VD: 10000032, 29079034, 39553978)_
- `caregiver_id`: Y tá/Bác sĩ đo. _(VD: 18704)_
- `charttime`: Thời điểm ĐO THỰC TẾ. _(VD: 2180-07-23 12:36:00)_
- `storetime`: Thời điểm lưu máy. _(VD: 2180-07-23 14:45:00)_
- `itemid`: Mã chỉ số. _(VD: 226512)_
- `value`: Giá trị (text). _(VD: 39.4)_
- `valuenum`: Giá trị (số - dùng cho AI). _(VD: 39.4)_
- `valueuom`: Đơn vị. _(VD: kg)_
- `warning`: Báo động. _(VD: 0)_

### 3. Bảng `d_items` (Từ điển các chỉ số ICU)
Tra cứu ý nghĩa của `itemid` trong ICU.
- `itemid`: Mã chỉ số. _(VD: 220001)_
- `label`: Tên chỉ số. _(VD: Problem List)_
- `abbreviation`: Tên viết tắt. _(VD: Problem List)_
- `linksto`: Bảng chứa chỉ số này. _(VD: chartevents)_
- `category`: Phân loại. _(VD: General)_
- `unitname`: Đơn vị. _(VD: bpm)_
- `param_type`: Kiểu dữ liệu. _(VD: Text)_
- `lownormalvalue`, `highnormalvalue`: Ngưỡng chuẩn (min-max). _(VD: 90 - 140)_

### 4. Bảng `datetimeevents` (Sự kiện thời gian)
Các sự kiện chỉ liên quan đến thời điểm.
- `itemid`: Mã sự kiện. _(VD: 225754)_
- `value`: Giá trị lưu dạng giờ/ngày. _(VD: 2180-07-23 14:24:00)_
- `valueuom`: Đơn vị. _(VD: Date)_

### 5. Bảng `inputevents` (Dịch vào cơ thể)
Chất lỏng/thuốc/truyền tĩnh mạch BƠM VÀO cơ thể (Fluid In).
- `subject_id`, `hadm_id`, `stay_id`: Khóa ngoại. _(VD: 10000032, 29079034, 39553978)_
- `caregiver_id`: Y tá truyền. _(VD: 18704)_
- `starttime`, `endtime`: Giờ bắt đầu/kết thúc truyền. _(VD: 2180-07-23 17:00:00 - 17:01:00)_
- `itemid`: Mã chất truyền. _(VD: 226452)_
- `amount`: Lượng đã truyền. _(VD: 200)_
- `amountuom`: Đơn vị. _(VD: mL)_
- `rate`: Tốc độ truyền. _(VD: 100)_
- `rateuom`: Đơn vị tốc độ. _(VD: mL/hour)_
- `orderid`, `linkorderid`: Mã y lệnh. _(VD: 3782233)_
- `patientweight`: Cân nặng định liều. _(VD: 39.4)_

### 6. Bảng `outputevents` (Dịch ra khỏi cơ thể)
Những gì ĐÀO THẢI ra (Nước tiểu, dịch dẫn lưu...). (Fluid Out)
- `charttime`: Giờ xả/ghi nhận dịch. _(VD: 2180-07-23 15:00:00)_
- `itemid`: Mã loại dịch ra. _(VD: 226560)_
- `value`: Thể tích xả. _(VD: 175)_
- `valueuom`: Đơn vị. _(VD: mL)_

### 7. Bảng `ingredientevents` (Thành phần hóa chất)
Chia nhỏ `inputevents` thành phân tử cốt lõi (Glucozo, NaCl...).
- `itemid`: Mã hoạt chất. _(VD: 220490)_
- `amount`: Lượng chất hóa học. _(VD: 200)_
- `amountuom`: Đơn vị hóa học. _(VD: mL)_
- `rate`: Tốc độ hấp thụ. _(VD: 100)_
- `rateuom`: Đơn vị tốc độ. _(VD: mL/hour)_

### 8. Bảng `procedureevents` (Thủ thuật trong ICU)
Các thủ thuật thực hiện tại giường ICU (như đặt ống nội khí quản).
- `starttime`, `endtime`: Giờ thực hiện. _(VD: 2180-07-23 14:43:00 - 14:44:00)_
- `itemid`: Mã thủ thuật. _(VD: 225966)_
- `value`: Thời lượng. _(VD: 1)_
- `location`: Vị trí trên cơ thể. _(VD: RL Ant Forearm Medial)_
- `ordercategoryname`: Loại thao tác. _(VD: Procedures)_

### 9. Bảng `caregiver` (Nhân viên chăm sóc ICU)
- `caregiver_id`: Mã nhân viên. _(VD: 3)_
---

## PHẦN 3: LUỒNG TRÍCH XUẤT HỒ SƠ BỆNH ÁN CỦA MỘT BỆNH NHÂN

Trong cơ sở dữ liệu quan hệ như MIMIC-IV, hồ sơ của một bệnh nhân bị phân tán vào nhiều bảng khác nhau. Để xem toàn bộ hồ sơ của 1 bệnh nhân, ta sẽ dùng mã `subject_id` (mã bệnh nhân) và `hadm_id` (mã đợt nhập viện) để xâu chuỗi thông tin lại. Cụ thể, hồ sơ của bệnh nhân sẽ được lưu theo thứ tự thời gian như sau:

**1. Thông tin cá nhân cơ bản (Xem ở bảng `patients`)**
- Bệnh nhân này bao nhiêu tuổi? Giới tính gì? Đã mất chưa?

**2. Quá trình làm thủ tục nhập viện (Xem ở bảng `admissions`)**
- Nhập viện lúc mấy giờ? Khám cấp cứu hay đặt lịch trước? Bác sĩ nào đón? Dùng bảo hiểm gì? Tình trạng hôn nhân là gì?

**3. Khám bệnh & Xét nghiệm (Xem ở `labevents` và `microbiologyevents`)**
- Bác sĩ lấy máu, nước tiểu đi xét nghiệm. Kết quả ra sao? Đường huyết bao nhiêu? Bạch cầu cao hay thấp? Có nhiễm vi khuẩn gì không?

**4. Chẩn đoán ra bệnh (Xem ở `diagnoses_icd`)**
- Dựa vào xét nghiệm, bác sĩ chốt lại bệnh nhân này mắc bệnh gì (Tim mạch, tiểu đường, viêm phổi...)?

**5. Kê đơn thuốc (Xem ở `prescriptions`, `pharmacy` và `emar`)**
- Kê những loại thuốc gì? (`prescriptions`)
- Kho dược đã phát thuốc chưa? (`pharmacy`)
- Y tá đã thực sự đút thuốc cho bệnh nhân uống lúc mấy giờ? (`emar`)

**6. Giai đoạn Hồi sức tích cực - Nếu bệnh chuyển nặng (Xem ở 9 bảng tập `icu`)**
- Nếu nguy kịch, bệnh nhân được chuyển vào ICU (`icustays`).
- Tại đây, mọi chỉ số nhịp tim, huyết áp được máy ghi lại từng phút một (`chartevents`).
- Máy thở, lượng dịch truyền tĩnh mạch (`inputevents`), lượng nước tiểu thải ra (`outputevents`) được đo lường chính xác từng mL.
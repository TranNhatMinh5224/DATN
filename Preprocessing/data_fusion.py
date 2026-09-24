import pandas as pd
import numpy as np
from sqlalchemy import create_engine
import os

print("Bắt đầu kết nối Database...")
engine = create_engine('postgresql://postgres:12122004@localhost:5432/mimic_iv')

print("1. Đang tải dữ liệu thô từ schema du_doan_tu_vong...")
# Load admissions (mortality label)
admissions = pd.read_sql('SELECT subject_id, hadm_id, mortality_1yr FROM du_doan_tu_vong.clean_admissions', engine)
# Load icustays (first_careunit)
icustays = pd.read_sql('SELECT hadm_id, stay_id, first_careunit FROM du_doan_tu_vong.clean_icustays', engine)
# Load patients (age, gender)
patients = pd.read_sql('SELECT subject_id, gender, anchor_age FROM hosp.patients', engine)

# Load comorbidities
comorbidities = pd.read_sql('SELECT * FROM du_doan_tu_vong.clean_comorbidities', engine)

# Load chartevents (vitals, gcs, weight)
chartevents = pd.read_sql('SELECT hadm_id, itemid, valuenum FROM du_doan_tu_vong.clean_chartevents', engine)

# Load outputevents (urine)
outputevents = pd.read_sql('SELECT hadm_id, itemid, value FROM du_doan_tu_vong.clean_outputevents', engine)
# Note: outputevents value is often numeric, we need to convert
outputevents['value'] = pd.to_numeric(outputevents['value'], errors='coerce')

# Load labevents (labs)
labevents = pd.read_sql('SELECT hadm_id, itemid, valuenum FROM du_doan_tu_vong.clean_labevents', engine)

print("2. Bắt đầu xử lý và Aggregation (Chải phẳng)...")

# ==========================================
# GIAI ĐOẠN 1: XỬ LÝ SHARED FEATURES
# ==========================================
# Tính Age (Dựa vào anchor_age)
# Cần drop duplicates nếu subject_id lặp lại
patients = patients.drop_duplicates(subset=['subject_id'])
df_shared = pd.merge(admissions, patients, on='subject_id', how='left')
# Map gender to 1/0
df_shared['gender'] = df_shared['gender'].map({'M': 1, 'F': 0})
df_shared.rename(columns={'anchor_age': 'age'}, inplace=True)

# Lấy loại khoa ICU (first_careunit) - Chuyển sang dạng dummy (One-Hot)
# Đầu tiên gộp first_careunit vào df_shared
df_shared = pd.merge(df_shared, icustays[['hadm_id', 'first_careunit']], on='hadm_id', how='left')
# One-hot encode first_careunit
if 'first_careunit' in df_shared.columns:
    df_shared = pd.get_dummies(df_shared, columns=['first_careunit'], dummy_na=False)

# Bệnh nền (Từ clean_comorbidities)
# Chúng ta mapping sang các tên cột chuẩn mà User yêu cầu: diabetes, cardiovascular, v.v..
# Do clean_comorbidities có các mã Elixhauser, ta sẽ đổi tên một số cột đại diện (giả định theo chuẩn phổ biến)
# Nếu file sql tạo ra các cột cụ thể, ta sẽ lấy tất. Ở đây cứ gộp toàn bộ bảng comorbidity vào shared_features.
df_shared = pd.merge(df_shared, comorbidities, on='hadm_id', how='left')
# Điền 0 cho các bệnh nền trống
df_shared.fillna(0, inplace=True)

# Lấy GCS Min (220739 - GCS Eye, 223901 - GCS Motor, 223900 - GCS Verbal)
# Ở bảng chartevents, itemid GCS có thể khác nhau tùy cấu hình, ta tính tổng theo charttime
# Nhưng cách nhanh nhất là lấy giá trị Min của các thành phần
gcs_df = chartevents[chartevents['itemid'].isin([220739, 223900, 223901])].groupby('hadm_id')['valuenum'].min().reset_index()
gcs_df.rename(columns={'valuenum': 'gcs_min'}, inplace=True)
df_shared = pd.merge(df_shared, gcs_df, on='hadm_id', how='left')

# Lấy Weight_kg (226512 - Admission Weight (Kg))
weight_df = chartevents[chartevents['itemid'] == 226512].groupby('hadm_id')['valuenum'].mean().reset_index()
weight_df.rename(columns={'valuenum': 'weight_kg'}, inplace=True)
df_shared = pd.merge(df_shared, weight_df, on='hadm_id', how='left')


# ==========================================
# GIAI ĐOẠN 2: XỬ LÝ PRIVATE A (Vitals + Urine)
# ==========================================
# Ánh xạ itemid cho vitals
# 220045: Heart Rate, 220050: SysBP, 220051: DiasBP, 220052: MBP
# 220210: Resp Rate, 223762/223761: Temp C/F, 220277: SpO2, 223835: FiO2
vitals_map = {
    220045: 'heart_rate',
    220050: 'sbp',
    220051: 'dbp',
    220052: 'mbp',
    220210: 'resp_rate',
    223762: 'temp_c',
    220277: 'spo2',
    223835: 'fio2'
}
chartevents_vitals = chartevents[chartevents['itemid'].isin(vitals_map.keys())].copy()
chartevents_vitals['feature'] = chartevents_vitals['itemid'].map(vitals_map)

# Tính Mean, Min, Max
vitals_agg = chartevents_vitals.groupby(['hadm_id', 'feature'])['valuenum'].agg(['mean', 'max', 'min']).unstack('feature')
vitals_agg.columns = [f"{col[1]}_{col[0]}" for col in vitals_agg.columns]
vitals_agg = vitals_agg.reset_index()

# Lọc các cột cần thiết cho Private A
cols_private_a = ['hadm_id', 'heart_rate_mean', 'sbp_mean', 'dbp_mean', 'mbp_mean', 'resp_rate_mean', 'temp_c_mean', 'spo2_mean', 'fio2_max']
# Đảm bảo các cột tồn tại (nếu thiếu, thêm vào với NaN)
for col in cols_private_a:
    if col not in vitals_agg.columns:
        vitals_agg[col] = np.nan
df_private_a = vitals_agg[cols_private_a]

# Nước tiểu (Tổng trong 24h)
urine_agg = outputevents.groupby('hadm_id')['value'].sum().reset_index()
urine_agg.rename(columns={'value': 'urine_output_24h'}, inplace=True)
df_private_a = pd.merge(df_private_a, urine_agg, on='hadm_id', how='left')

# Áp dụng giới hạn sinh lý chuẩn y khoa (Physiological Limits) loại bỏ nhiễu cảm biến/lỗi nhập liệu
vitals_bounds = {
    'heart_rate_mean': (20.0, 250.0),
    'sbp_mean': (40.0, 260.0),
    'dbp_mean': (20.0, 160.0),
    'mbp_mean': (30.0, 200.0),
    'resp_rate_mean': (4.0, 60.0),
    'temp_c_mean': (28.0, 43.0),
    'spo2_mean': (50.0, 100.0),
    'fio2_max': (21.0, 100.0),
    'urine_output_24h': (0.0, 20000.0)
}
for col, (low, high) in vitals_bounds.items():
    if col in df_private_a.columns:
        df_private_a.loc[(df_private_a[col] < low) | (df_private_a[col] > high), col] = np.nan



# ==========================================
# GIAI ĐOẠN 3: XỬ LÝ PRIVATE B (Labs)
# ==========================================
# Ánh xạ itemid cho Labs (Ví dụ tượng trưng các itemid phổ biến nhất)
# Creatinine (50912), BUN (51006), Anion gap (50868), Lactate (50813), pH (50820)
# Potassium (50971), Sodium (50983), Chloride (50902), WBC (51301)
# Hemoglobin (51222), Platelets (51265), INR (51237), Glucose (50931), Bilirubin (50885)
labs_map = {
    50912: 'creatinine',
    51006: 'bun',
    50868: 'anion_gap',
    50813: 'lactate',
    50820: 'ph',
    50971: 'potassium',
    50983: 'sodium',
    50902: 'chloride',
    51301: 'wbc',
    51222: 'hemoglobin',
    51265: 'platelets',
    51237: 'inr',
    50931: 'glucose',
    50885: 'bilirubin'
}
labevents_filt = labevents[labevents['itemid'].isin(labs_map.keys())].copy()
labevents_filt['feature'] = labevents_filt['itemid'].map(labs_map)

# Tính Mean, Min, Max
labs_agg = labevents_filt.groupby(['hadm_id', 'feature'])['valuenum'].agg(['mean', 'max', 'min']).unstack('feature')
labs_agg.columns = [f"{col[1]}_{col[0]}" for col in labs_agg.columns]
labs_agg = labs_agg.reset_index()

# Lọc các cột cần thiết cho Private B theo chuẩn User
cols_private_b = [
    'hadm_id', 'creatinine_max', 'bun_max', 'anion_gap_max', 'lactate_max', 'ph_min', 
    'potassium_mean', 'sodium_mean', 'chloride_mean', 'wbc_max', 'hemoglobin_min', 
    'platelets_min', 'inr_max', 'glucose_mean', 'bilirubin_max'
]
# Ensure anion_gap_max is named anion_gap in user prompt but we take max, let's name exactly
for col in cols_private_b:
    if col not in labs_agg.columns:
        labs_agg[col] = np.nan
        
# User requested 'anion_gap' simply, let's rename anion_gap_max to anion_gap if needed, but we keep it standardized
labs_agg.rename(columns={'anion_gap_max': 'anion_gap'}, inplace=True)
if 'anion_gap' not in cols_private_b:
    cols_private_b.remove('anion_gap_max')
    cols_private_b.append('anion_gap')
    
df_private_b = labs_agg[cols_private_b]

# ==========================================
# GIAI ĐOẠN 4: ĐỒNG BỘ HADM_ID & XUẤT FILE
# ==========================================
print("3. Đồng bộ hóa dữ liệu (Inner Join)...")
# Giữ lại các hadm_id tồn tại ở TẤT CẢ các bảng để tránh lệch dòng
# Tuy nhiên, trong thực tế, nên merge left từ shared sang và điền missing value
# Ở đây ta hợp nhất dựa trên hadm_id của bảng Admissions
final_hadm = df_shared[['hadm_id']].copy()

df_shared_final = pd.merge(final_hadm, df_shared, on='hadm_id', how='inner')
df_private_a_final = pd.merge(final_hadm, df_private_a, on='hadm_id', how='left')
df_private_b_final = pd.merge(final_hadm, df_private_b, on='hadm_id', how='left')

# Tách nhãn
labels_final = df_shared_final[['hadm_id', 'mortality_1yr']].copy()
labels_final.rename(columns={'mortality_1yr': 'mortality'}, inplace=True)
df_shared_final.drop(columns=['mortality_1yr'], inplace=True)

print("4. Xuất file CSV...")
base_dir = r"c:\Users\Admin\Desktop\Do_An_Tot_Nghiep\DATN\Data_Ready_For_Model"
os.makedirs(os.path.join(base_dir, "Shared_Features"), exist_ok=True)
os.makedirs(os.path.join(base_dir, "Hospital_A"), exist_ok=True)
os.makedirs(os.path.join(base_dir, "Hospital_B"), exist_ok=True)

df_shared_final.to_csv(os.path.join(base_dir, "Shared_Features", "shared_data.csv"), index=False)
df_private_a_final.to_csv(os.path.join(base_dir, "Hospital_A", "private_A_data.csv"), index=False)
df_private_b_final.to_csv(os.path.join(base_dir, "Hospital_B", "private_B_data.csv"), index=False)
labels_final.to_csv(os.path.join(base_dir, "labels.csv"), index=False)

print("\n--- KẾT QUẢ ĐẦU RA ---")
print(f"Số lượng bệnh nhân: {len(labels_final)}")
print(f"- Shared Features: {df_shared_final.shape}")
print(f"- Private A: {df_private_a_final.shape}")
print(f"- Private B: {df_private_b_final.shape}")
print(f"- Labels: {labels_final.shape}")
print("HOÀN THÀNH!")

-- ==============================================================================
-- 1. TẠO CÁC BẢNG (SCHEMA) CHO MIMIC-IV
-- ==============================================================================

-- Bảng patients (Hồ sơ bệnh nhân)
DROP TABLE IF EXISTS patients CASCADE;
CREATE TABLE patients (
    subject_id INT PRIMARY KEY,
    gender VARCHAR(5) NOT NULL,
    anchor_age INT NOT NULL,
    anchor_year INT NOT NULL,
    anchor_year_group VARCHAR(20) NOT NULL,
    dod TIMESTAMP
);

-- Bảng admissions (Lịch sử nhập viện)
DROP TABLE IF EXISTS admissions CASCADE;
CREATE TABLE admissions (
    subject_id INT NOT NULL,
    hadm_id INT PRIMARY KEY,
    admittime TIMESTAMP NOT NULL,
    dischtime TIMESTAMP,
    deathtime TIMESTAMP,
    admission_type VARCHAR(50),
    admit_provider_id VARCHAR(20),
    admission_location VARCHAR(100),
    discharge_location VARCHAR(100),
    insurance VARCHAR(255),
    language VARCHAR(50),
    marital_status VARCHAR(50),
    race VARCHAR(200),
    edregtime TIMESTAMP,
    edouttime TIMESTAMP,
    hospital_expire_flag INT
);

-- Bảng d_items (Từ điển các chỉ số đo đạc)
DROP TABLE IF EXISTS d_items CASCADE;
CREATE TABLE d_items (
    itemid INT PRIMARY KEY,
    label VARCHAR(255),
    abbreviation VARCHAR(100),
    linksto VARCHAR(50),
    category VARCHAR(255),
    unitname VARCHAR(100),
    param_type VARCHAR(50),
    lownormalvalue FLOAT8,
    highnormalvalue FLOAT8
);

-- Bảng chartevents (Kết quả đo đạc từ các thiết bị và y tá trong ICU)
DROP TABLE IF EXISTS chartevents CASCADE;
CREATE TABLE chartevents (
    subject_id INT NOT NULL,
    hadm_id INT,
    stay_id INT,
    caregiver_id INT,
    charttime TIMESTAMP NOT NULL,
    storetime TIMESTAMP,
    itemid INT NOT NULL,
    value TEXT,
    valuenum FLOAT8,
    valueuom VARCHAR(100),
    warning INT
);

-- Bảng labevents (Kết quả xét nghiệm máu/nước tiểu)
DROP TABLE IF EXISTS labevents CASCADE;
CREATE TABLE labevents (
    labevent_id SERIAL PRIMARY KEY,
    subject_id INT NOT NULL,
    hadm_id INT,
    specimen_id INT,
    itemid INT NOT NULL,
    order_provider_id VARCHAR(20),
    charttime TIMESTAMP,
    storetime TIMESTAMP,
    value TEXT,
    valuenum FLOAT8,
    valueuom VARCHAR(100),
    ref_range_lower FLOAT8,
    ref_range_upper FLOAT8,
    flag VARCHAR(50),
    priority VARCHAR(50),
    comments TEXT
);

-- Bảng diagnoses_icd (Chẩn đoán bệnh theo mã ICD)
DROP TABLE IF EXISTS diagnoses_icd CASCADE;
CREATE TABLE diagnoses_icd (
    subject_id INT NOT NULL,
    hadm_id INT NOT NULL,
    seq_num INT,
    icd_code VARCHAR(20) NOT NULL,
    icd_version INT NOT NULL
);

-- ==============================================================================
-- 2. TẠO KHÓA NGOẠI (FOREIGN KEYS)
-- ==============================================================================

ALTER TABLE admissions ADD CONSTRAINT fk_admissions_subject FOREIGN KEY (subject_id) REFERENCES patients(subject_id) ON DELETE CASCADE;
ALTER TABLE chartevents ADD CONSTRAINT fk_chartevents_subject FOREIGN KEY (subject_id) REFERENCES patients(subject_id) ON DELETE CASCADE;
ALTER TABLE chartevents ADD CONSTRAINT fk_chartevents_hadm FOREIGN KEY (hadm_id) REFERENCES admissions(hadm_id) ON DELETE CASCADE;
ALTER TABLE chartevents ADD CONSTRAINT fk_chartevents_item FOREIGN KEY (itemid) REFERENCES d_items(itemid) ON DELETE CASCADE;
ALTER TABLE labevents ADD CONSTRAINT fk_labevents_subject FOREIGN KEY (subject_id) REFERENCES patients(subject_id) ON DELETE CASCADE;
ALTER TABLE labevents ADD CONSTRAINT fk_labevents_hadm FOREIGN KEY (hadm_id) REFERENCES admissions(hadm_id) ON DELETE CASCADE;
ALTER TABLE diagnoses_icd ADD CONSTRAINT fk_diagnoses_subject FOREIGN KEY (subject_id) REFERENCES patients(subject_id) ON DELETE CASCADE;
ALTER TABLE diagnoses_icd ADD CONSTRAINT fk_diagnoses_hadm FOREIGN KEY (hadm_id) REFERENCES admissions(hadm_id) ON DELETE CASCADE;



-- =====================================================================
-- BƯỚC 2: LỌC BẢNG CHARTEVENTS (SINH HIỆU 24H ĐẦU ICU)
-- Schema: du_doan_tu_vong
-- =====================================================================
SET search_path TO du_doan_tu_vong, hosp, icu, public;

DROP TABLE IF EXISTS clean_chartevents CASCADE;

CREATE TABLE clean_chartevents AS
WITH first_icu_stay AS (
    -- Lấy đợt vào ICU đầu tiên của lần nhập viện
    SELECT 
        i.subject_id, 
        i.hadm_id, 
        i.stay_id, 
        i.intime, 
        i.outtime,
        ROW_NUMBER() OVER (PARTITION BY i.hadm_id ORDER BY i.intime) as rn
    FROM 
        icu.icustays i
    JOIN 
        clean_admissions ca ON i.hadm_id = ca.hadm_id
)
SELECT 
    ce.subject_id,
    ce.hadm_id,
    ce.stay_id,
    ce.charttime,
    ce.itemid,
    ce.valuenum,
    ce.valueuom
FROM 
    icu.chartevents ce
JOIN 
    first_icu_stay fi ON ce.stay_id = fi.stay_id
WHERE 
    fi.rn = 1 
    -- Chỉ lấy dữ liệu trong 24 giờ đầu tiên kể từ lúc vào ICU
    AND ce.charttime >= fi.intime 
    AND ce.charttime <= fi.intime + INTERVAL '24 hours'
    -- Lọc các biến số quan trọng (Nhịp tim, Huyết áp, Nhiệt độ, SpO2, Nhịp thở, GCS)
    -- Danh sách itemid này thu gọn để giảm tải bộ nhớ
    AND ce.itemid IN (
        220045, -- Heart Rate
        220050, -- Arterial Blood Pressure systolic
        220179, -- Non Invasive Blood Pressure systolic
        220051, -- Arterial Blood Pressure diastolic
        220180, -- Non Invasive Blood Pressure diastolic
        220052, -- Arterial Blood Pressure mean
        220181, -- Non Invasive Blood Pressure mean
        220210, -- Respiratory Rate
        223761, -- Temperature Fahrenheit
        223762, -- Temperature Celsius
        220277, -- O2 saturation pulseoxymetry
        220739, -- GCS - Eye Opening
        223900, -- GCS - Verbal Response
        223901,  -- GCS - Motor Response
        223835, -- FiO2
        226512  -- Admission Weight (Kg)
    )
    AND ce.valuenum IS NOT NULL;

CREATE INDEX idx_clean_ce_stay ON clean_chartevents (stay_id);
CREATE INDEX idx_clean_ce_item ON clean_chartevents (itemid);
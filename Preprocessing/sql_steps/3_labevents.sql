-- =====================================================================
-- BƯỚC 3: LỌC BẢNG LABEVENTS (XÉT NGHIỆM MÁU 24H ĐẦU NHẬP VIỆN)
-- Schema: du_doan_tu_vong
-- =====================================================================
SET search_path TO du_doan_tu_vong, hosp, icu, public;

DROP TABLE IF EXISTS clean_labevents CASCADE;

CREATE TABLE clean_labevents AS
SELECT 
    le.subject_id,
    le.hadm_id,
    le.charttime,
    le.itemid,
    le.valuenum,
    le.valueuom,
    le.flag
FROM 
    hosp.labevents le
JOIN 
    clean_admissions ca ON le.hadm_id = ca.hadm_id
WHERE 
    -- Lấy xét nghiệm từ 6 giờ TRƯỚC khi nhập viện (phòng cấp cứu) đến 24 giờ sau
    le.charttime >= ca.admittime - INTERVAL '6 hours'
    AND le.charttime <= ca.admittime + INTERVAL '24 hours'
    -- Các xét nghiệm quan trọng (Creatinine, Lactate, Glucose, WBC, Hemoglobin, Tiểu cầu, pH máu...)
    AND le.itemid IN (
        50912, -- Creatinine
        50813, -- Lactate
        50931, -- Glucose
        51301, -- White Blood Cells
        51222, -- Hemoglobin
        51265, -- Platelet Count
        50820, -- pH
        50802, -- Base Excess
        50804, -- Calculated Total CO2
        50821, -- pO2
        50818, -- pCO2
        50809, -- Glucose (blood gas)
        50971, -- Potassium
        50983, -- Sodium
        50902, -- Chloride
        50882, -- Bicarbonate
        51006, -- Urea Nitrogen (BUN)
        50885, -- Bilirubin, Total
        50861, -- Alanine Aminotransferase (ALT)
        50878,  -- Aspartate Aminotransferase (AST)
        51237, -- INR(PT)
        50868  -- Anion Gap
    )
    AND le.valuenum IS NOT NULL;

CREATE INDEX idx_clean_le_hadm ON clean_labevents (hadm_id);
CREATE INDEX idx_clean_le_item ON clean_labevents (itemid);
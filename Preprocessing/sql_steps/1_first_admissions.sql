-- =====================================================================
-- BƯỚC 1: LỌC LẦN NHẬP VIỆN ĐẦU TIÊN & TÍNH TUỔI, NHÃN TỬ VONG
-- Schema: du_doan_tu_vong
-- =====================================================================
SET search_path TO du_doan_tu_vong, hosp, icu, public;

DROP TABLE IF EXISTS clean_admissions CASCADE;

CREATE TABLE clean_admissions AS
WITH ranked_admissions AS (
    SELECT 
        a.subject_id,
        a.hadm_id,
        p.gender,
        a.admittime,
        a.dischtime,
        p.anchor_age,
        p.anchor_year,
        p.dod,
        ROW_NUMBER() OVER (PARTITION BY a.subject_id ORDER BY a.admittime) AS rn
    FROM 
        hosp.admissions a
    JOIN 
        hosp.patients p ON a.subject_id = p.subject_id
),
first_admissions AS (
    SELECT
        subject_id,
        hadm_id,
        gender,
        -- Công thức tính tuổi chuẩn của MIMIC-IV
        anchor_age + (CAST(EXTRACT(YEAR FROM admittime) AS INT) - anchor_year) AS age,
        dod,
        admittime,
        dischtime
    FROM 
        ranked_admissions
    WHERE 
        rn = 1
)
SELECT 
    subject_id,
    hadm_id,
    gender,
    age,
    admittime,
    dischtime,
    -- Nhãn tử vong (1 = Chết trong vòng 1 năm kể từ khi nhập viện, 0 = Sống)
    CASE 
        WHEN dod IS NOT NULL 
             AND dod >= admittime
             AND dod <= admittime + INTERVAL '365 days' 
        THEN 1
        ELSE 0
    END AS mortality_1yr
FROM 
    first_admissions
WHERE 
    age >= 18; -- Chỉ lấy người lớn

CREATE INDEX idx_clean_adm_sub ON clean_admissions (subject_id);
CREATE INDEX idx_clean_adm_hadm ON clean_admissions (hadm_id);
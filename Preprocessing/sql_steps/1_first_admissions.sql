-- =====================================================================
-- BUOC 1: LOC LAN NHAP VIEN DAU TIEN & TINH TUOI, NHAN TU VONG
-- =====================================================================
-- File nay lam 3 viec:
-- 1. Quet bang admissions, dung ROW_NUMBER() de giu lai lan nhap vien DAU TIEN (rn=1).
-- 2. Tinh Tuoi (age) bang cong thuc MIMIC-IV: anchor_age + (Nam nhap vien - anchor_year).
-- 3. Tinh Nhan tu vong (mortality_1yr): Kiem tra xem ngay mat (dod) co nam trong 365 ngay tu luc nhap vien hay khong.
-- Ket qua duoc luu vao bang moi: first_admission_data.
-- =====================================================================
DROP TABLE IF EXISTS first_admission_data CASCADE;

CREATE TABLE first_admission_data AS
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
        admissions a
    JOIN 
        patients p ON a.subject_id = p.subject_id
),
first_admissions AS (
    SELECT
        subject_id,
        hadm_id,
        gender,
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
    dod,
    admittime,
    dischtime,
    CASE 
        WHEN dod IS NOT NULL 
             AND dod >= admittime
             AND dod <= admittime + INTERVAL '365 days' 
        THEN 1
        ELSE 0
    END AS mortality_1yr,
    0 AS cardiovascular,
    0 AS neurological,
    0 AS pulmonary,
    0 AS diabetes,
    0 AS renal,
    0 AS liver,
    0 AS cancer,
    0 AS mental_substance,
    0 AS hem_metabolic,
    0 AS autoimmune
FROM 
    first_admissions
WHERE 
    age BETWEEN 1 AND 80;


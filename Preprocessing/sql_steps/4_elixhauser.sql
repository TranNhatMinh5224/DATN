-- =====================================================================
-- BƯỚC 4: TÍNH ĐIỂM BỆNH NỀN (ELIXHAUSER) TỪ ICD-9 VÀ ICD-10
-- Schema: du_doan_tu_vong
-- =====================================================================
SET search_path TO du_doan_tu_vong, hosp, icu, public;

DROP TABLE IF EXISTS clean_comorbidities CASCADE;

CREATE TABLE clean_comorbidities AS
WITH elixhauser_flags AS (
  SELECT 
    d.subject_id, 
    d.hadm_id,
    -- 1. Congestive Heart Failure
    MAX(CASE 
      WHEN icd_version = 9 AND (SUBSTR(icd_code, 1, 3) IN ('398','402','428') OR SUBSTR(icd_code, 1, 4) IN ('4041','4049')) THEN 1
      WHEN icd_version = 10 AND (SUBSTR(icd_code, 1, 3) IN ('I09','I11','I13','I50')) THEN 1
      ELSE 0 END) AS chf,
      
    -- 2. Cardiac Arrhythmias
    MAX(CASE 
      WHEN icd_version = 9 AND (SUBSTR(icd_code, 1, 3) IN ('426','427') OR SUBSTR(icd_code, 1, 4) IN ('V533')) THEN 1
      WHEN icd_version = 10 AND (SUBSTR(icd_code, 1, 3) IN ('I44','I45','I47','I48','I49')) THEN 1
      ELSE 0 END) AS arrhy,
      
    -- 3. Valvular Disease
    MAX(CASE 
      WHEN icd_version = 9 AND (SUBSTR(icd_code, 1, 3) IN ('093','394','395','396','397','424') OR SUBSTR(icd_code, 1, 4) IN ('7463','7464','7465','7466','V422','V433')) THEN 1
      WHEN icd_version = 10 AND (SUBSTR(icd_code, 1, 3) IN ('I05','I06','I07','I08','I34','I35','I36','I37')) THEN 1
      ELSE 0 END) AS valve,
      
    -- 4. Pulmonary Circulation Disorders
    MAX(CASE 
      WHEN icd_version = 9 AND (SUBSTR(icd_code, 1, 3) IN ('415','416','417')) THEN 1
      WHEN icd_version = 10 AND (SUBSTR(icd_code, 1, 3) IN ('I26','I27','I28')) THEN 1
      ELSE 0 END) AS pulmcirc,
      
    -- 5. Peripheral Vascular Disorders
    MAX(CASE 
      WHEN icd_version = 9 AND (SUBSTR(icd_code, 1, 3) IN ('440','441','442','443','444','447','448') OR SUBSTR(icd_code, 1, 4) IN ('449')) THEN 1
      WHEN icd_version = 10 AND (SUBSTR(icd_code, 1, 3) IN ('I70','I71','I73','I74','I77','I78','I79')) THEN 1
      ELSE 0 END) AS perivasc,
      
    -- 6 & 7. Hypertension (Uncomplicated & Complicated) -> Gộp chung
    MAX(CASE 
      WHEN icd_version = 9 AND (SUBSTR(icd_code, 1, 3) IN ('401','402','403','404','405')) THEN 1
      WHEN icd_version = 10 AND (SUBSTR(icd_code, 1, 3) IN ('I10','I11','I12','I13','I15')) THEN 1
      ELSE 0 END) AS htn,
      
    -- 8. Paralysis
    MAX(CASE 
      WHEN icd_version = 9 AND (SUBSTR(icd_code, 1, 3) IN ('342','343','344')) THEN 1
      WHEN icd_version = 10 AND (SUBSTR(icd_code, 1, 3) IN ('G81','G82','G83')) THEN 1
      ELSE 0 END) AS para,
      
    -- 9. Other Neurological Disorders
    MAX(CASE 
      WHEN icd_version = 9 AND (SUBSTR(icd_code, 1, 3) IN ('331','332','333','334','335','340','341','345')) THEN 1
      WHEN icd_version = 10 AND (SUBSTR(icd_code, 1, 3) IN ('G10','G11','G12','G20','G21','G22','G25','G30','G31','G32','G35','G40','G41')) THEN 1
      ELSE 0 END) AS neuro,
      
    -- 10. Chronic Pulmonary Disease
    MAX(CASE 
      WHEN icd_version = 9 AND (SUBSTR(icd_code, 1, 3) IN ('490','491','492','493','494','495','496','500','501','502','503','504','505')) THEN 1
      WHEN icd_version = 10 AND (SUBSTR(icd_code, 1, 3) IN ('J40','J41','J42','J43','J44','J45','J46','J47','J60','J61','J62','J63','J64','J65','J66','J67')) THEN 1
      ELSE 0 END) AS chrnlung,
      
    -- 11 & 12. Diabetes (Uncomplicated & Complicated)
    MAX(CASE 
      WHEN icd_version = 9 AND (SUBSTR(icd_code, 1, 3) IN ('250')) THEN 1
      WHEN icd_version = 10 AND (SUBSTR(icd_code, 1, 3) IN ('E10','E11','E12','E13','E14')) THEN 1
      ELSE 0 END) AS dm,
      
    -- 14. Renal Failure
    MAX(CASE 
      WHEN icd_version = 9 AND (SUBSTR(icd_code, 1, 3) IN ('585','586')) THEN 1
      WHEN icd_version = 10 AND (SUBSTR(icd_code, 1, 3) IN ('N18','N19')) THEN 1
      ELSE 0 END) AS renlfail,
      
    -- 15. Liver Disease
    MAX(CASE 
      WHEN icd_version = 9 AND (SUBSTR(icd_code, 1, 3) IN ('570','571','572')) THEN 1
      WHEN icd_version = 10 AND (SUBSTR(icd_code, 1, 3) IN ('K70','K71','K72','K73','K74')) THEN 1
      ELSE 0 END) AS liver,
      
    -- 17 & 18. Cancer (Lymphoma, Metastatic, Solid Tumor)
    MAX(CASE 
      WHEN icd_version = 9 AND (SUBSTR(icd_code, 1, 3) IN ('140','141','199','200','208')) THEN 1
      WHEN icd_version = 10 AND (SUBSTR(icd_code, 1, 1) IN ('C')) THEN 1
      ELSE 0 END) AS cancer,
      
    -- 29, 30, 31. Mental and Substance Abuse
    MAX(CASE 
      WHEN icd_version = 9 AND (SUBSTR(icd_code, 1, 3) IN ('290','295','296','297','298','299','300','303','304','305')) THEN 1
      WHEN icd_version = 10 AND (SUBSTR(icd_code, 1, 1) IN ('F')) THEN 1
      ELSE 0 END) AS mental_substance,
      
    -- Các nhóm khác (Gộp vào hem_metabolic, autoimmune)
    MAX(CASE 
      WHEN icd_version = 9 AND (SUBSTR(icd_code, 1, 3) IN ('286','276','280','281','285','278','244')) THEN 1
      WHEN icd_version = 10 AND (SUBSTR(icd_code, 1, 3) IN ('D65','D66','E87','D50','E66','E03')) THEN 1
      ELSE 0 END) AS hem_metabolic,
      
    MAX(CASE 
      WHEN icd_version = 9 AND (SUBSTR(icd_code, 1, 3) IN ('714','710')) THEN 1
      WHEN icd_version = 10 AND (SUBSTR(icd_code, 1, 3) IN ('M05','M06','M32')) THEN 1
      ELSE 0 END) AS autoimmune

  FROM hosp.diagnoses_icd d
  JOIN clean_admissions ca ON d.hadm_id = ca.hadm_id
  GROUP BY d.subject_id, d.hadm_id
)
SELECT 
  subject_id,
  hadm_id,
  -- Gộp 10 nhóm lớn theo luận văn gốc
  LEAST(chf + arrhy + valve + pulmcirc + perivasc + htn, 1) AS cardiovascular,
  LEAST(para + neuro, 1) AS neurological,
  chrnlung AS pulmonary,
  dm AS diabetes,
  renlfail AS renal,
  liver AS liver,
  cancer AS cancer,
  mental_substance AS mental_substance,
  hem_metabolic AS hem_metabolic,
  autoimmune AS autoimmune
FROM elixhauser_flags;

CREATE INDEX idx_clean_comorb_hadm ON clean_comorbidities (hadm_id);
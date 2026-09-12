-- =====================================================================
-- BUOC 2: LOC BANG CHARTEVENTS (SINH HIEU)
-- =====================================================================
-- File nay nham muc dich giam tai du lieu.
-- No lay bang goc chartevents (hang tram trieu dong) va dung lenh JOIN 
-- de chi giu lai nhung ket qua do dac thuoc ve LAN NHAP VIEN DAU TIEN 
-- (da duoc tinh o buoc 1).
-- Ket qua luu vao bang: chartevents_first_admission.
-- =====================================================================
DROP TABLE IF EXISTS chartevents_first_admission CASCADE;
CREATE TABLE chartevents_first_admission AS
SELECT ce.*
FROM chartevents ce
JOIN first_admission_data fa
  ON ce.subject_id = fa.subject_id
 AND ce.hadm_id = fa.hadm_id;


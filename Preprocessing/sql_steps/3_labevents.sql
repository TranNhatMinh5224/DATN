-- =====================================================================
-- BUOC 3: LOC BANG LABEVENTS (XET NGHIEM)
-- =====================================================================
-- Tuong tu nhu buoc 2, file nay giup giam tai du lieu xet nghiem.
-- No dung lenh JOIN de chi lay ket qua xet nghiem cua LAN NHAP VIEN DAU TIEN.
-- Ket qua luu vao bang: labevents_first_admission.
-- =====================================================================
DROP TABLE IF EXISTS labevents_first_admission CASCADE;
CREATE TABLE labevents_first_admission AS
SELECT le.*
FROM labevents le
JOIN first_admission_data fa
  ON le.subject_id = fa.subject_id
 AND le.hadm_id = fa.hadm_id;


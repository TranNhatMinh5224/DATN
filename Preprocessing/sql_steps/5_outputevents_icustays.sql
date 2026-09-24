-- Tạo bảng lưu trữ khoa ICU (icustays)
DROP TABLE IF EXISTS du_doan_tu_vong.clean_icustays CASCADE;
CREATE TABLE du_doan_tu_vong.clean_icustays AS
SELECT
    a.subject_id,
    a.hadm_id,
    i.stay_id,
    i.first_careunit,
    i.intime,
    i.outtime
FROM
    du_doan_tu_vong.clean_admissions a
JOIN
    icu.icustays i ON a.hadm_id = i.hadm_id;

-- Tạo bảng lưu trữ lượng nước tiểu 24h đầu (outputevents)
DROP TABLE IF EXISTS du_doan_tu_vong.clean_outputevents CASCADE;
CREATE TABLE du_doan_tu_vong.clean_outputevents AS
SELECT
    i.hadm_id,
    o.charttime,
    o.itemid,
    o.value
FROM
    du_doan_tu_vong.clean_icustays i
JOIN
    icu.outputevents o ON i.stay_id = o.stay_id
WHERE
    o.charttime >= i.intime
    AND o.charttime <= i.intime + INTERVAL '1 day';

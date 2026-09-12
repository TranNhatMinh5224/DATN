  AND fad.hadm_id = ef.hadm_id;
CREATE TABLE patients (
    row_id SERIAL PRIMARY KEY,
    subject_id INT NOT NULL UNIQUE,
    gender VARCHAR(5) NOT NULL,
    dob TIMESTAMP NOT NULL,
    dod TIMESTAMP NULL,
    dod_hosp TIMESTAMP NULL,
    dod_ssn TIMESTAMP NULL,
    expire_flag INT NOT NULL
);


CREATE TABLE admissions (
    row_id SERIAL PRIMARY KEY,
    subject_id INT NOT NULL,
    hadm_id INT NOT NULL UNIQUE,
    admittime TIMESTAMP NOT NULL,
    dischtime TIMESTAMP NULL,
    deathtime TIMESTAMP NULL,
    admission_type VARCHAR(50) NOT NULL,
    admission_location VARCHAR(50) NULL,
    discharge_location VARCHAR(50) NULL,
    insurance VARCHAR(255) NOT NULL,
    language VARCHAR(10) NULL,
    religion VARCHAR(50) NULL,
    marital_status VARCHAR(50) NULL,
    ethnicity VARCHAR(200) NULL,
    edregtime TIMESTAMP NULL,
    edouttime TIMESTAMP NULL,
    diagnosis VARCHAR(255) NULL,
    hospital_expire_flag INT NOT NULL,
    has_chartevents_data INT NOT NULL
);


CREATE TABLE d_items (
    row_id SERIAL PRIMARY KEY,
    itemid INT NOT NULL UNIQUE,
    label VARCHAR(255) NULL,
    abbreviation VARCHAR(50) NULL,
    dbsource VARCHAR(50) NULL,
    linksto VARCHAR(50) NULL,
    category VARCHAR(255) NULL,
    unitname VARCHAR(50) NULL,
    param_type VARCHAR(50) NULL,
    conceptid INT NULL
);


CREATE TABLE chartevents (
    row_id SERIAL PRIMARY KEY,
    subject_id INT NOT NULL,
    hadm_id INT NULL,
    icustay_id INT NULL,
    itemid INT NULL,
    charttime TIMESTAMP NULL,
    storetime TIMESTAMP NULL,
    cgid INT NULL,
    value VARCHAR(255) NULL,
    valuenum FLOAT8 NULL,
    valueuom VARCHAR(50) NULL,
    warning INT NULL,
    error INT NULL,
    resultstatus VARCHAR(50) NULL,
    stopped VARCHAR(50) NULL
);

--RELATIONSHIPS
ALTER TABLE admissions 
ADD CONSTRAINT fk_admissions_subject FOREIGN KEY (subject_id) 
REFERENCES patients(subject_id) ON DELETE CASCADE;

ALTER TABLE chartevents 
ADD CONSTRAINT fk_chartevents_subject FOREIGN KEY (subject_id) 
REFERENCES patients(subject_id) ON DELETE CASCADE;

ALTER TABLE chartevents 
ADD CONSTRAINT fk_chartevents_hadm FOREIGN KEY (hadm_id) 
REFERENCES admissions(hadm_id) ON DELETE CASCADE;

ALTER TABLE chartevents 
ADD CONSTRAINT fk_chartevents_item FOREIGN KEY (itemid) 
REFERENCES d_items(itemid) ON DELETE CASCADE;



--COLUMN
-- Ensure gender is only 'M', 'F', or 'O'
ALTER TABLE patients 
ADD CONSTRAINT chk_gender CHECK (gender IN ('M', 'F', 'O'));

-- Ensure dod, dod_hosp, and dod_ssn are not before dob
ALTER TABLE patients 
ADD CONSTRAINT chk_dod CHECK (dod IS NULL OR dod >= dob);

ALTER TABLE patients 
ADD CONSTRAINT chk_dod_hosp CHECK (dod_hosp IS NULL OR dod_hosp >= dob);

ALTER TABLE patients 
ADD CONSTRAINT chk_dod_ssn CHECK (dod_ssn IS NULL OR dod_ssn >= dob);

-- Ensure expire_flag is only 0 or 1
ALTER TABLE patients 
ADD CONSTRAINT chk_expire_flag CHECK (expire_flag IN (0, 1));

-- Ensure hospital_expire_flag is only 0 or 1 in admissions
ALTER TABLE admissions 
ADD CONSTRAINT chk_hospital_expire_flag CHECK (hospital_expire_flag IN (0, 1));

-- Ensure warning and error flags in chartevents are either 0 or 1
ALTER TABLE chartevents 
ADD CONSTRAINT chk_warning CHECK (warning IS NULL OR warning IN (0, 1));

ALTER TABLE chartevents 
ADD CONSTRAINT chk_error CHECK (error IS NULL OR error IN (0, 1));


CREATE TABLE labevents (
    ROW_ID SERIAL PRIMARY KEY,
    SUBJECT_ID INTEGER NOT NULL,
    HADM_ID INTEGER,
    ITEMID INTEGER NOT NULL,
    CHARTTIME TIMESTAMP,
    VALUE TEXT,
    VALUENUM NUMERIC,
    VALUEUOM TEXT,
    FLAG TEXT
);
-- Link to admissions
ALTER TABLE labevents
ADD CONSTRAINT fk_labevents_hadm
FOREIGN KEY (HADM_ID)
REFERENCES admissions(HADM_ID);


-------------------------------------------------------------------------------------------------------------------


CREATE TABLE first_admission_data AS
WITH first_admissions AS (
    SELECT 
        a.SUBJECT_ID,
        a.HADM_ID,
        p.GENDER,
        a.ADMITTIME,
        a.DISCHTIME,
        p.DOB,
        p.DOD,
        FLOOR(EXTRACT(EPOCH FROM (a.ADMITTIME - p.DOB)) / (365.25 * 24 * 60 * 60)) AS AGE,
        ROW_NUMBER() OVER (PARTITION BY a.SUBJECT_ID ORDER BY a.ADMITTIME) AS rn
    FROM 
        ADMISSIONS a
    JOIN 
        PATIENTS p ON a.SUBJECT_ID = p.SUBJECT_ID
    WHERE 
        p.DOB IS NOT NULL
), no_attributes AS (
    SELECT
        SUBJECT_ID,
        HADM_ID,
        GENDER,
        AGE,
        DOB,
        DOD,
        ADMITTIME,
        CASE 
            WHEN DOD IS NOT NULL 
                 AND DOD >= ADMITTIME
                 AND DOD <= ADMITTIME + INTERVAL '365 days' 
            THEN 1
            ELSE 0
        END AS mortality_1yr
    FROM 
        first_admissions
    WHERE 
        rn = 1
        AND AGE BETWEEN 1 AND 80
)SELECT * from no_attributes 


--This table contains 45.5% less rows, it has 180M instead of 330M, GREAT!
CREATE TABLE chartevents_first_admission AS
SELECT ce.*
FROM chartevents ce
JOIN first_admission_data fa
  ON ce.subject_id = fa.subject_id
 AND ce.hadm_id = fa.hadm_id

--This table contains 50% less rows, it has 138M instead of 278M, GREAT!
CREATE TABLE labevents_first_admission AS
SELECT ce.*
FROM labevents ce
JOIN first_admission_data fa
  ON ce.subject_id = fa.subject_id
 AND ce.hadm_id = fa.hadm_id

--For counting after filtering:
SELECT 
    COUNT(*) FILTER (WHERE source = 'filtered') AS filtered_count,
    COUNT(*) FILTER (WHERE source = 'total') AS total_count,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE source = 'filtered') 
        / NULLIF(COUNT(*) FILTER (WHERE source = 'total'), 0), 
        2
    ) AS percentage_filtered
FROM (
    SELECT 'filtered' AS source FROM labevents_first_admission
    UNION ALL
    SELECT 'total' AS source FROM labevents
) AS combined; 

--Para contar cuanto hay de un item_d
SELECT 
    itemid, 
    COUNT(*) AS count
FROM 
    chartevents_first_admission
WHERE 
    itemid IN ( 226512)
GROUP BY 
    itemid
ORDER BY 
    count DESC;


--To count just one of them 

SELECT 
    itemid, 
    COUNT(*) AS count
FROM (
    SELECT DISTINCT subject_id, hadm_id, itemid
    FROM labevents_first_admission
    WHERE itemid IN (50983, 50971, 50893, 50808)
) AS unique_items
GROUP BY itemid
ORDER BY count DESC;

"""Adding the columns and weight"""

ALTER TABLE first_admission_data ADD COLUMN weight_kg NUMERIC;

UPDATE first_admission_data f
SET weight_kg = ce.valuenum
FROM (
    SELECT subject_id, hadm_id, valuenum,
           ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) AS rn
    FROM chartevents_first_admission
    WHERE itemid IN (763, 226512) AND valuenum IS NOT NULL
) ce
WHERE f.subject_id = ce.subject_id
  AND f.hadm_id = ce.hadm_id
  AND ce.rn = 1;


--count not nulls for a field
SELECT COUNT(weight_kg) AS non_null_weight_count
FROM first_admission_data;




ALTER TABLE first_admission_data ADD COLUMN respiratory_rate NUMERIC;
ALTER TABLE first_admission_data ADD COLUMN heart_rate NUMERIC;
ALTER TABLE first_admission_data ADD COLUMN nbp_systolic NUMERIC;
ALTER TABLE first_admission_data ADD COLUMN nbp_diastolic NUMERIC;
ALTER TABLE first_admission_data ADD COLUMN nbp_mean NUMERIC;
ALTER TABLE first_admission_data ADD COLUMN cvp NUMERIC;
ALTER TABLE first_admission_data ADD COLUMN heart_rhythm NUMERIC;
ALTER TABLE first_admission_data ADD COLUMN pap_systolic NUMERIC;
ALTER TABLE first_admission_data ADD COLUMN pap_diastolic NUMERIC;
ALTER TABLE first_admission_data ADD COLUMN pap_mean NUMERIC;



WITH rr AS (
  SELECT subject_id, hadm_id, valuenum AS respiratory_rate
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) AS rn
    FROM chartevents_first_admission
    WHERE itemid IN (618, 220210) AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
hr AS (
  SELECT subject_id, hadm_id, valuenum AS heart_rate
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) AS rn
    FROM chartevents_first_admission
    WHERE itemid IN (211, 220045) AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
nbp_sys AS (
  SELECT subject_id, hadm_id, valuenum AS nbp_systolic
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) AS rn
    FROM chartevents_first_admission
    WHERE itemid IN (455, 220179) AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
nbp_dia AS (
  SELECT subject_id, hadm_id, valuenum AS nbp_diastolic
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) AS rn
    FROM chartevents_first_admission
    WHERE itemid IN (456, 220180) AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
nbp_mean AS (
  SELECT subject_id, hadm_id, valuenum AS nbp_mean
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) AS rn
    FROM chartevents_first_admission
    WHERE itemid IN (457, 220182) AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
cvp AS (
  SELECT subject_id, hadm_id, valuenum AS cvp
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) AS rn
    FROM chartevents_first_admission
    WHERE itemid IN (113, 4304) AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
rhythm AS (
  SELECT subject_id, hadm_id, valuenum AS heart_rhythm
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) AS rn
    FROM chartevents_first_admission
    WHERE itemid IN (212, 220048) AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
pap_sys AS (
  SELECT subject_id, hadm_id, valuenum AS pap_systolic
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) AS rn
    FROM chartevents_first_admission
    WHERE itemid IN (220059, 492) AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
pap_dia AS (
  SELECT subject_id, hadm_id, valuenum AS pap_diastolic
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) AS rn
    FROM chartevents_first_admission
    WHERE itemid IN (220060, 8448) AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
pap_mean AS (
  SELECT subject_id, hadm_id, valuenum AS pap_mean
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) AS rn
    FROM chartevents_first_admission
    WHERE itemid IN (220061, 491) AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
)

UPDATE first_admission_data f
SET
  respiratory_rate = rr.respiratory_rate,
  heart_rate = hr.heart_rate,
  nbp_systolic = nbp_sys.nbp_systolic,
  nbp_diastolic = nbp_dia.nbp_diastolic,
  nbp_mean = nbp_mean.nbp_mean,
  cvp = cvp.cvp,
  heart_rhythm = rhythm.heart_rhythm,
  pap_systolic = pap_sys.pap_systolic,
  pap_diastolic = pap_dia.pap_diastolic,
  pap_mean = pap_mean.pap_mean
FROM rr
LEFT JOIN hr ON rr.subject_id = hr.subject_id AND rr.hadm_id = hr.hadm_id
LEFT JOIN nbp_sys ON rr.subject_id = nbp_sys.subject_id AND rr.hadm_id = nbp_sys.hadm_id
LEFT JOIN nbp_dia ON rr.subject_id = nbp_dia.subject_id AND rr.hadm_id = nbp_dia.hadm_id
LEFT JOIN nbp_mean ON rr.subject_id = nbp_mean.subject_id AND rr.hadm_id = nbp_mean.hadm_id
LEFT JOIN cvp ON rr.subject_id = cvp.subject_id AND rr.hadm_id = cvp.hadm_id
LEFT JOIN rhythm ON rr.subject_id = rhythm.subject_id AND rr.hadm_id = rhythm.hadm_id
LEFT JOIN pap_sys ON rr.subject_id = pap_sys.subject_id AND rr.hadm_id = pap_sys.hadm_id
LEFT JOIN pap_dia ON rr.subject_id = pap_dia.subject_id AND rr.hadm_id = pap_dia.hadm_id
LEFT JOIN pap_mean ON rr.subject_id = pap_mean.subject_id AND rr.hadm_id = pap_mean.hadm_id
WHERE f.subject_id = rr.subject_id AND f.hadm_id = rr.hadm_id;


ALTER TABLE first_admission_data
ADD COLUMN spo2 NUMERIC,
ADD COLUMN fio2 NUMERIC,
ADD COLUMN po2 NUMERIC,
ADD COLUMN pco2 NUMERIC,
ADD COLUMN ph NUMERIC,
ADD COLUMN sodium NUMERIC,
ADD COLUMN potassium NUMERIC,
ADD COLUMN calcium NUMERIC,
ADD COLUMN glucose NUMERIC,
ADD COLUMN creatinine NUMERIC,
ADD COLUMN bun NUMERIC,
ADD COLUMN anion_gap NUMERIC,
ADD COLUMN bilirubin NUMERIC,
ADD COLUMN albumin NUMERIC,
ADD COLUMN wbc NUMERIC,
ADD COLUMN hemoglobin NUMERIC,
ADD COLUMN hematocrit NUMERIC,
ADD COLUMN platelet_count NUMERIC,
ADD COLUMN inr NUMERIC,
ADD COLUMN pt NUMERIC,
ADD COLUMN ptt NUMERIC;

WITH spo2 AS (
  SELECT subject_id, hadm_id, valuenum AS spo2
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM chartevents_first_admission
    WHERE itemid IN (646, 220277) AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
fio2 AS (
  SELECT subject_id, hadm_id, valuenum AS fio2
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM chartevents_first_admission
    WHERE itemid IN (190, 223835) AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
po2 AS (
  SELECT subject_id, hadm_id, valuenum AS po2
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 50821 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
pco2 AS (
  SELECT subject_id, hadm_id, valuenum AS pco2
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 50818 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
ph AS (
  SELECT subject_id, hadm_id, valuenum AS ph
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 50820 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
sodium AS (
  SELECT subject_id, hadm_id, valuenum AS sodium
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 50983 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
potassium AS (
  SELECT subject_id, hadm_id, valuenum AS potassium
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 50971 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
calcium AS (
  SELECT subject_id, hadm_id, valuenum AS calcium
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 50893 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
glucose AS (
  SELECT subject_id, hadm_id, valuenum AS glucose
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 50931 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
creatinine AS (
  SELECT subject_id, hadm_id, valuenum AS creatinine
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 50912 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
bun AS (
  SELECT subject_id, hadm_id, valuenum AS bun
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 51006 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
anion_gap AS (
  SELECT subject_id, hadm_id, valuenum AS anion_gap
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 50868 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
bilirubin AS (
  SELECT subject_id, hadm_id, valuenum AS bilirubin
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 50885 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
albumin AS (
  SELECT subject_id, hadm_id, valuenum AS albumin
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 50862 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
wbc AS (
  SELECT subject_id, hadm_id, valuenum AS wbc
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 51301 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
hemoglobin AS (
  SELECT subject_id, hadm_id, valuenum AS hemoglobin
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 51222 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
hematocrit AS (
  SELECT subject_id, hadm_id, valuenum AS hematocrit
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 51221 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
platelet_count AS (
  SELECT subject_id, hadm_id, valuenum AS platelet_count
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 51265 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
inr AS (
  SELECT subject_id, hadm_id, valuenum AS inr
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 51237 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
pt AS (
  SELECT subject_id, hadm_id, valuenum AS pt
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 51274 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
),
ptt AS (
  SELECT subject_id, hadm_id, valuenum AS ptt
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY charttime) rn
    FROM labevents_first_admission
    WHERE itemid = 51275 AND valuenum IS NOT NULL
  ) sub WHERE rn = 1
)

UPDATE first_admission_data f
SET
  spo2 = spo2.spo2,
  fio2 = fio2.fio2,
  po2 = po2.po2,
  pco2 = pco2.pco2,
  ph = ph.ph,
  sodium = sodium.sodium,
  potassium = potassium.potassium,
  calcium = calcium.calcium,
  glucose = glucose.glucose,
  creatinine = creatinine.creatinine,
  bun = bun.bun,
  anion_gap = anion_gap.anion_gap,
  bilirubin = bilirubin.bilirubin,
  albumin = albumin.albumin,
  wbc = wbc.wbc,
  hemoglobin = hemoglobin.hemoglobin,
  hematocrit = hematocrit.hematocrit,
  platelet_count = platelet_count.platelet_count,
  inr = inr.inr,
  pt = pt.pt,
  ptt = ptt.ptt
FROM spo2
LEFT JOIN fio2 ON spo2.subject_id = fio2.subject_id AND spo2.hadm_id = fio2.hadm_id
LEFT JOIN po2 ON spo2.subject_id = po2.subject_id AND spo2.hadm_id = po2.hadm_id
LEFT JOIN pco2 ON spo2.subject_id = pco2.subject_id AND spo2.hadm_id = pco2.hadm_id
LEFT JOIN ph ON spo2.subject_id = ph.subject_id AND spo2.hadm_id = ph.hadm_id
LEFT JOIN sodium ON spo2.subject_id = sodium.subject_id AND spo2.hadm_id = sodium.hadm_id
LEFT JOIN potassium ON spo2.subject_id = potassium.subject_id AND spo2.hadm_id = potassium.hadm_id
LEFT JOIN calcium ON spo2.subject_id = calcium.subject_id AND spo2.hadm_id = calcium.hadm_id
LEFT JOIN glucose ON spo2.subject_id = glucose.subject_id AND spo2.hadm_id = glucose.hadm_id
LEFT JOIN creatinine ON spo2.subject_id = creatinine.subject_id AND spo2.hadm_id = creatinine.hadm_id
LEFT JOIN bun ON spo2.subject_id = bun.subject_id AND spo2.hadm_id = bun.hadm_id
LEFT JOIN anion_gap ON spo2.subject_id = anion_gap.subject_id AND spo2.hadm_id = anion_gap.hadm_id
LEFT JOIN bilirubin ON spo2.subject_id = bilirubin.subject_id AND spo2.hadm_id = bilirubin.hadm_id
LEFT JOIN albumin ON spo2.subject_id = albumin.subject_id AND spo2.hadm_id = albumin.hadm_id
LEFT JOIN wbc ON spo2.subject_id = wbc.subject_id AND spo2.hadm_id = wbc.hadm_id
LEFT JOIN hemoglobin ON spo2.subject_id = hemoglobin.subject_id AND spo2.hadm_id = hemoglobin.hadm_id
LEFT JOIN hematocrit ON spo2.subject_id = hematocrit.subject_id AND spo2.hadm_id = hematocrit.hadm_id
LEFT JOIN platelet_count ON spo2.subject_id = platelet_count.subject_id AND spo2.hadm_id = platelet_count.hadm_id
LEFT JOIN inr ON spo2.subject_id = inr.subject_id AND spo2.hadm_id = inr.hadm_id
LEFT JOIN pt ON spo2.subject_id = pt.subject_id AND spo2.hadm_id = pt.hadm_id
LEFT JOIN ptt ON spo2.subject_id = ptt.subject_id AND spo2.hadm_id = ptt.hadm_id
WHERE f.subject_id = spo2.subject_id AND f.hadm_id = spo2.hadm_id;



--Temperature
ALTER TABLE first_admission_data
ADD COLUMN temperature_cv NUMERIC,
ADD COLUMN temperature_mv NUMERIC;

WITH cv_first AS (
  SELECT DISTINCT ON (subject_id, hadm_id)
    subject_id,
    hadm_id,
    (valuenum - 32) * 5.0 / 9.0 AS temperature_cv
  FROM chartevents_first_admission
  WHERE itemid = 223761 AND valuenum IS NOT NULL
  ORDER BY subject_id, hadm_id, charttime
)
UPDATE first_admission_data f
SET temperature_cv = cv.temperature_cv
FROM cv_first cv
WHERE f.subject_id = cv.subject_id AND f.hadm_id = cv.hadm_id;

WITH mv_first AS (
  SELECT DISTINCT ON (subject_id, hadm_id)
    subject_id,
    hadm_id,
    valuenum AS temperature_mv
  FROM chartevents_first_admission
  WHERE itemid = 677 AND valuenum IS NOT NULL
  ORDER BY subject_id, hadm_id, charttime
)
UPDATE first_admission_data f
SET temperature_mv = mv.temperature_mv
FROM mv_first mv
WHERE f.subject_id = mv.subject_id AND f.hadm_id = mv.hadm_id;


ALTER TABLE first_admission_data
ADD COLUMN temperature NUMERIC;

UPDATE first_admission_data f
SET temperature = 
  CASE
    WHEN temperature_mv IS NOT NULL THEN temperature_mv
    WHEN temperature_cv IS NOT NULL THEN temperature_cv
    ELSE NULL
  END;


--GCS
ALTER TABLE first_admission_data
ADD COLUMN gcs_cv NUMERIC,
ADD COLUMN gcs_mv NUMERIC;

WITH cv_first AS (
  SELECT DISTINCT ON (subject_id, hadm_id)
    subject_id,
    hadm_id,
    valuenum AS gcs_cv
  FROM chartevents_first_admission
  WHERE itemid = 198 AND valuenum IS NOT NULL
  ORDER BY subject_id, hadm_id, charttime
)
UPDATE first_admission_data f
SET gcs_cv = cv.gcs_cv
FROM cv_first cv
WHERE f.subject_id = cv.subject_id AND f.hadm_id = cv.hadm_id;


WITH mv_first AS (
  SELECT DISTINCT ON (subject_id, hadm_id)
    subject_id,
    hadm_id,
    avg(CASE WHEN itemid = 223900 THEN valuenum END) AS gcs_verbal,
    avg(CASE WHEN itemid = 223901 THEN valuenum END) AS gcs_motor,
    avg(CASE WHEN itemid = 220739 THEN valuenum END) AS gcs_eye
  FROM chartevents_first_admission
  WHERE itemid IN (223900, 223901, 220739) AND valuenum IS NOT NULL
  GROUP BY subject_id, hadm_id
)
UPDATE first_admission_data f
SET gcs_mv = mv.gcs_verbal + mv.gcs_motor + mv.gcs_eye
FROM mv_first mv
WHERE f.subject_id = mv.subject_id AND f.hadm_id = mv.hadm_id;

ALTER TABLE first_admission_data
ADD COLUMN gcs NUMERIC;

UPDATE first_admission_data f
SET gcs = 
  CASE
    -- If MetaVision GCS (MV) is available, take that
    WHEN gcs_mv IS NOT NULL THEN gcs_mv
    -- If MetaVision GCS is not available, use CareVue GCS (CV)
    WHEN gcs_cv IS NOT NULL THEN gcs_cv
    ELSE NULL
  END;

SELECT AVG(gcs) AS avg_gcs
FROM first_admission_data
WHERE gcs IS NOT NULL;



--We have 2514 rows with more than 12 nulls in attributes
SELECT COUNT(*)
FROM first_admission_data
WHERE (
    (CASE WHEN weight_kg IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN respiratory_rate IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN heart_rate IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN nbp_systolic IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN nbp_diastolic IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN nbp_mean IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN cvp IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN heart_rhythm IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN pap_systolic IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN pap_diastolic IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN pap_mean IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN spo2 IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN fio2 IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN po2 IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN pco2 IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN ph IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN sodium IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN potassium IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN calcium IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN glucose IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN creatinine IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN bun IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN anion_gap IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN bilirubin IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN albumin IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN wbc IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN hemoglobin IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN hematocrit IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN platelet_count IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN inr IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN pt IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN ptt IS NULL THEN 1 ELSE 0 END)+
    (CASE WHEN temperature IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN gcs IS NULL THEN 1 ELSE 0 END)
) > 12;


DELETE FROM first_admission_data
WHERE (
    (CASE WHEN weight_kg IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN respiratory_rate IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN heart_rate IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN nbp_systolic IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN nbp_diastolic IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN nbp_mean IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN cvp IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN heart_rhythm IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN pap_systolic IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN pap_diastolic IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN pap_mean IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN spo2 IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN fio2 IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN po2 IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN pco2 IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN ph IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN sodium IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN potassium IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN calcium IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN glucose IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN creatinine IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN bun IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN anion_gap IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN bilirubin IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN albumin IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN wbc IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN hemoglobin IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN hematocrit IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN platelet_count IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN inr IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN pt IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN ptt IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN temperature IS NULL THEN 1 ELSE 0 END) +
    (CASE WHEN gcs IS NULL THEN 1 ELSE 0 END)
) > 12;

--For counting nulls of each columns
SELECT
  COUNT(*) FILTER (WHERE weight_kg IS NULL) AS weight_kg_nulls,
  COUNT(*) FILTER (WHERE respiratory_rate IS NULL) AS respiratory_rate_nulls,
  COUNT(*) FILTER (WHERE heart_rate IS NULL) AS heart_rate_nulls,
  COUNT(*) FILTER (WHERE nbp_systolic IS NULL) AS nbp_systolic_nulls,
  COUNT(*) FILTER (WHERE nbp_diastolic IS NULL) AS nbp_diastolic_nulls,
  COUNT(*) FILTER (WHERE nbp_mean IS NULL) AS nbp_mean_nulls,
  COUNT(*) FILTER (WHERE cvp IS NULL) AS cvp_nulls,
  COUNT(*) FILTER (WHERE heart_rhythm IS NULL) AS heart_rhythm_nulls,
  COUNT(*) FILTER (WHERE pap_systolic IS NULL) AS pap_systolic_nulls,
  COUNT(*) FILTER (WHERE pap_diastolic IS NULL) AS pap_diastolic_nulls,
  COUNT(*) FILTER (WHERE pap_mean IS NULL) AS pap_mean_nulls,
  COUNT(*) FILTER (WHERE spo2 IS NULL) AS spo2_nulls,
  COUNT(*) FILTER (WHERE fio2 IS NULL) AS fio2_nulls,
  COUNT(*) FILTER (WHERE po2 IS NULL) AS po2_nulls,
  COUNT(*) FILTER (WHERE pco2 IS NULL) AS pco2_nulls,
  COUNT(*) FILTER (WHERE ph IS NULL) AS ph_nulls,
  COUNT(*) FILTER (WHERE sodium IS NULL) AS sodium_nulls,
  COUNT(*) FILTER (WHERE potassium IS NULL) AS potassium_nulls,
  COUNT(*) FILTER (WHERE calcium IS NULL) AS calcium_nulls,
  COUNT(*) FILTER (WHERE glucose IS NULL) AS glucose_nulls,
  COUNT(*) FILTER (WHERE creatinine IS NULL) AS creatinine_nulls,
  COUNT(*) FILTER (WHERE bun IS NULL) AS bun_nulls,
  COUNT(*) FILTER (WHERE anion_gap IS NULL) AS anion_gap_nulls,
  COUNT(*) FILTER (WHERE bilirubin IS NULL) AS bilirubin_nulls,
  COUNT(*) FILTER (WHERE albumin IS NULL) AS albumin_nulls,
  COUNT(*) FILTER (WHERE wbc IS NULL) AS wbc_nulls,
  COUNT(*) FILTER (WHERE hemoglobin IS NULL) AS hemoglobin_nulls,
  COUNT(*) FILTER (WHERE hematocrit IS NULL) AS hematocrit_nulls,
  COUNT(*) FILTER (WHERE platelet_count IS NULL) AS platelet_count_nulls,
  COUNT(*) FILTER (WHERE inr IS NULL) AS inr_nulls,
  COUNT(*) FILTER (WHERE pt IS NULL) AS pt_nulls,
  COUNT(*) FILTER (WHERE ptt IS NULL) AS ptt_nulls,
  COUNT(*) FILTER (WHERE temperature IS NULL) AS temperature_nulls,
  COUNT(*) FILTER (WHERE gcs IS NULL) AS gcs_nulls
FROM first_admission_data;

--For counting not nulls from chartevents or labevents when joining with first_admission_data
WITH base AS (
  SELECT subject_id, hadm_id FROM first_admission_data
),

nbp_mean AS (
  SELECT DISTINCT subject_id, hadm_id
  FROM chartevents_first_admission
  WHERE itemid IN (457, 220182) AND valuenum IS NOT NULL
),

cvp AS (
  SELECT DISTINCT subject_id, hadm_id
  FROM chartevents_first_admission
  WHERE itemid IN (113, 4304) AND valuenum IS NOT NULL
),

heart_rhythm AS (
  SELECT DISTINCT subject_id, hadm_id
  FROM chartevents_first_admission
  WHERE itemid IN (212, 220048) AND valuenum IS NOT NULL
),

pap_systolic AS (
  SELECT DISTINCT subject_id, hadm_id
  FROM chartevents_first_admission
  WHERE itemid IN (220059, 492) AND valuenum IS NOT NULL
),

pap_diastolic AS (
  SELECT DISTINCT subject_id, hadm_id
  FROM chartevents_first_admission
  WHERE itemid IN (220060, 8448) AND valuenum IS NOT NULL
),

pap_mean AS (
  SELECT DISTINCT subject_id, hadm_id
  FROM chartevents_first_admission
  WHERE itemid IN (220061, 491) AND valuenum IS NOT NULL
),

fio2 AS (
  SELECT DISTINCT subject_id, hadm_id
  FROM chartevents_first_admission
  WHERE itemid IN (190, 223835) AND valuenum IS NOT NULL
),

po2 AS (
  SELECT DISTINCT subject_id, hadm_id
  FROM labevents_first_admission
  WHERE itemid = 50821 AND valuenum IS NOT NULL
),

pco2 AS (
  SELECT DISTINCT subject_id, hadm_id
  FROM labevents_first_admission
  WHERE itemid = 50818 AND valuenum IS NOT NULL
),

ph AS (
  SELECT DISTINCT subject_id, hadm_id
  FROM labevents_first_admission
  WHERE itemid = 50820 AND valuenum IS NOT NULL
),

bilirubin AS (
  SELECT DISTINCT subject_id, hadm_id
  FROM labevents_first_admission
  WHERE itemid = 50885 AND valuenum IS NOT NULL
),

albumin AS (
  SELECT DISTINCT subject_id, hadm_id
  FROM labevents_first_admission
  WHERE itemid = 50862 AND valuenum IS NOT NULL
)

SELECT
  (SELECT COUNT(*) FROM base b JOIN nbp_mean USING (subject_id, hadm_id)) AS nbp_mean_not_nulls,
  (SELECT COUNT(*) FROM base b JOIN cvp USING (subject_id, hadm_id)) AS cvp_not_nulls,
  (SELECT COUNT(*) FROM base b JOIN heart_rhythm USING (subject_id, hadm_id)) AS heart_rhythm_not_nulls,
  (SELECT COUNT(*) FROM base b JOIN pap_systolic USING (subject_id, hadm_id)) AS pap_systolic_not_nulls,
  (SELECT COUNT(*) FROM base b JOIN pap_diastolic USING (subject_id, hadm_id)) AS pap_diastolic_not_nulls,
  (SELECT COUNT(*) FROM base b JOIN pap_mean USING (subject_id, hadm_id)) AS pap_mean_not_nulls,
  (SELECT COUNT(*) FROM base b JOIN fio2 USING (subject_id, hadm_id)) AS fio2_not_nulls,
  (SELECT COUNT(*) FROM base b JOIN po2 USING (subject_id, hadm_id)) AS po2_not_nulls,
  (SELECT COUNT(*) FROM base b JOIN pco2 USING (subject_id, hadm_id)) AS pco2_not_nulls,
  (SELECT COUNT(*) FROM base b JOIN ph USING (subject_id, hadm_id)) AS ph_not_nulls,
  (SELECT COUNT(*) FROM base b JOIN bilirubin USING (subject_id, hadm_id)) AS bilirubin_not_nulls,
  (SELECT COUNT(*) FROM base b JOIN albumin USING (subject_id, hadm_id)) AS albumin_not_nulls;


-- Drop some of the columns with many nulls
ALTER TABLE first_admission_data
DROP COLUMN nbp_mean,
DROP COLUMN cvp,
DROP COLUMN heart_rhythm,
DROP COLUMN pap_systolic,
DROP COLUMN pap_diastolic,
DROP COLUMN pap_mean;


-- Adding comorbilities
WITH elixhauser_flags AS (
  SELECT
    subject_id,
    hadm_id,
    CASE
  when icd_code in ('39891','40201','40211','40291','40401','40403','40411','40413','40491','40493') then 1
  when SUBSTR(icd_code, 1, 4) in ('4254','4255','4257','4258','4259') then 1
  when SUBSTR(icd_code, 1, 3) in ('428') then 1
  else 0 end as chf       /* Congestive heart failure */

, CASE
  when icd_code in ('42613','42610','42612','99601','99604') then 1
  when SUBSTR(icd_code, 1, 4) in ('4260','4267','4269','4270','4271','4272','4273','4274','4276','4278','4279','7850','V450','V533') then 1
  else 0 end as arrhy

, CASE
  when SUBSTR(icd_code, 1, 4) in ('0932','7463','7464','7465','7466','V422','V433') then 1
  when SUBSTR(icd_code, 1, 3) in ('394','395','396','397','424') then 1
  else 0 end as valve     /* Valvular disease */

, CASE
  when SUBSTR(icd_code, 1, 4) in ('4150','4151','4170','4178','4179') then 1
  when SUBSTR(icd_code, 1, 3) in ('416') then 1
  else 0 end as pulmcirc  /* Pulmonary circulation disorder */

, CASE
  when SUBSTR(icd_code, 1, 4) in ('0930','4373','4431','4432','4438','4439','4471','5571','5579','V434') then 1
  when SUBSTR(icd_code, 1, 3) in ('440','441') then 1
  else 0 end as perivasc  /* Peripheral vascular disorder */

, CASE
  when SUBSTR(icd_code, 1, 3) in ('401') then 1
  else 0 end as htn       /* Hypertension, uncomplicated */

, CASE
  when SUBSTR(icd_code, 1, 3) in ('402','403','404','405') then 1
  else 0 end as htncx     /* Hypertension, complicated */

, CASE
  when SUBSTR(icd_code, 1, 4) in ('3341','3440','3441','3442','3443','3444','3445','3446','3449') then 1
  when SUBSTR(icd_code, 1, 3) in ('342','343') then 1
  else 0 end as para      /* Paralysis */

, CASE
  when icd_code in ('33392') then 1
  when SUBSTR(icd_code, 1, 4) in ('3319','3320','3321','3334','3335','3362','3481','3483','7803','7843') then 1
  when SUBSTR(icd_code, 1, 3) in ('334','335','340','341','345') then 1
  else 0 end as neuro     /* Other neurological */

, CASE
  when SUBSTR(icd_code, 1, 4) in ('4168','4169','5064','5081','5088') then 1
  when SUBSTR(icd_code, 1, 3) in ('490','491','492','493','494','495','496','500','501','502','503','504','505') then 1
  else 0 end as chrnlung  /* Chronic pulmonary disease */

, CASE
  when SUBSTR(icd_code, 1, 4) in ('2500','2501','2502','2503') then 1
  else 0 end as dm        /* Diabetes w/o chronic complications*/

, CASE
  when SUBSTR(icd_code, 1, 4) in ('2504','2505','2506','2507','2508','2509') then 1
  else 0 end as dmcx      /* Diabetes w/ chronic complications */

, CASE
  when SUBSTR(icd_code, 1, 4) in ('2409','2461','2468') then 1
  when SUBSTR(icd_code, 1, 3) in ('243','244') then 1
  else 0 end as hypothy   /* Hypothyroidism */

, CASE
  when icd_code in ('40301','40311','40391','40402','40403','40412','40413','40492','40493') then 1
  when SUBSTR(icd_code, 1, 4) in ('5880','V420','V451') then 1
  when SUBSTR(icd_code, 1, 3) in ('585','586','V56') then 1
  else 0 end as renlfail  /* Renal failure */

, CASE
  when icd_code in ('07022','07023','07032','07033','07044','07054') then 1
  when SUBSTR(icd_code, 1, 4) in ('0706','0709','4560','4561','4562','5722','5723','5724','5728','5733','5734','5738','5739','V427') then 1
  when SUBSTR(icd_code, 1, 3) in ('570','571') then 1
  else 0 end as liver     /* Liver disease */

, CASE
  when SUBSTR(icd_code, 1, 4) in ('5317','5319','5327','5329','5337','5339','5347','5349') then 1
  else 0 end as ulcer     /* Chronic Peptic ulcer disease (includes bleeding only if obstruction is also present) */

, CASE
  when SUBSTR(icd_code, 1, 3) in ('042','043','044') then 1
  else 0 end as aids      /* HIV and AIDS */

, CASE
  when SUBSTR(icd_code, 1, 4) in ('2030','2386') then 1
  when SUBSTR(icd_code, 1, 3) in ('200','201','202') then 1
  else 0 end as lymph     /* Lymphoma */

, CASE
  when SUBSTR(icd_code, 1, 3) in ('196','197','198','199') then 1
  else 0 end as mets      /* Metastatic cancer */

, CASE
  when SUBSTR(icd_code, 1, 3) in
  (
     '140','141','142','143','144','145','146','147','148','149','150','151','152'
    ,'153','154','155','156','157','158','159','160','161','162','163','164','165'
    ,'166','167','168','169','170','171','172','174','175','176','177','178','179'
    ,'180','181','182','183','184','185','186','187','188','189','190','191','192'
    ,'193','194','195'
  ) then 1
  else 0 end as tumor     /* Solid tumor without metastasis */

, CASE
  when icd_code in ('72889','72930') then 1
  when SUBSTR(icd_code, 1, 4) in ('7010','7100','7101','7102','7103','7104','7108','7109','7112','7193','7285') then 1
  when SUBSTR(icd_code, 1, 3) in ('446','714','720','725') then 1
  else 0 end as arth              /* Rheumatoid arthritis/collagen vascular diseases */

, CASE
  when SUBSTR(icd_code, 1, 4) in ('2871','2873','2874','2875') then 1
  when SUBSTR(icd_code, 1, 3) in ('286') then 1
  else 0 end as coag      /* Coagulation deficiency */

, CASE
  when SUBSTR(icd_code, 1, 4) in ('2780') then 1
  else 0 end as obese     /* Obesity      */

, CASE
  when SUBSTR(icd_code, 1, 4) in ('7832','7994') then 1
  when SUBSTR(icd_code, 1, 3) in ('260','261','262','263') then 1
  else 0 end as wghtloss  /* Weight loss */

, CASE
  when SUBSTR(icd_code, 1, 4) in ('2536') then 1
  when SUBSTR(icd_code, 1, 3) in ('276') then 1
  else 0 end as lytes     /* Fluid and electrolyte disorders */

, CASE
  when SUBSTR(icd_code, 1, 4) in ('2800') then 1
  else 0 end as bldloss   /* Blood loss anemia */

, CASE
  when SUBSTR(icd_code, 1, 4) in ('2801','2808','2809') then 1
  when SUBSTR(icd_code, 1, 3) in ('281') then 1
  else 0 end as anemdef  /* Deficiency anemias */

, CASE
  when SUBSTR(icd_code, 1, 4) in ('2652','2911','2912','2913','2915','2918','2919','3030','3039','3050','3575','4255','5353','5710','5711','5712','5713','V113') then 1
  when SUBSTR(icd_code, 1, 3) in ('980') then 1
  else 0 end as alcohol /* Alcohol abuse */

, CASE
  when icd_code in ('V6542') then 1
  when SUBSTR(icd_code, 1, 4) in ('3052','3053','3054','3055','3056','3057','3058','3059') then 1
  when SUBSTR(icd_code, 1, 3) in ('292','304') then 1
  else 0 end as drug /* Drug abuse */

, CASE
  when icd_code in ('29604','29614','29644','29654') then 1
  when SUBSTR(icd_code, 1, 4) in ('2938') then 1
  when SUBSTR(icd_code, 1, 3) in ('295','297','298') then 1
  else 0 end as psych /* Psychoses */

, CASE
  when SUBSTR(icd_code, 1, 4) in ('2962','2963','2965','3004') then 1
  when SUBSTR(icd_code, 1, 3) in ('309','311') then 1
  else 0 end as depress  /* Depression */


from diagnoses_icd

), elixhauser_by_hadm as
(
  select subject_id,hadm_id
    , max(chf) as chf
    , max(arrhy) as arrhy
    , max(valve) as valve
    , max(pulmcirc) as pulmcirc
    , max(perivasc) as perivasc
    , max(htn) as htn
    , max(htncx) as htncx
    , max(para) as para
    , max(neuro) as neuro
    , max(chrnlung) as chrnlung
    , max(dm) as dm
    , max(dmcx) as dmcx
    , max(hypothy) as hypothy
    , max(renlfail) as renlfail
    , max(liver) as liver
    , max(ulcer) as ulcer
    , max(aids) as aids
    , max(lymph) as lymph
    , max(mets) as mets
    , max(tumor) as tumor
    , max(arth) as arth
    , max(coag) as coag
    , max(obese) as obese
    , max(wghtloss) as wghtloss
    , max(lytes) as lytes
    , max(bldloss) as bldloss
    , max(anemdef) as anemdef
    , max(alcohol) as alcohol
    , max(drug) as drug
    , max(psych) as psych
    , max(depress) as depress
from elixhauser_flags
group by subject_id,hadm_id
), elixhauser_rename AS(
  SELECT
    subject_id,hadm_id
    ,  chf as congestive_heart_failure
    , arrhy as cardiac_arrhythmias
    , valve as valvular_disease
    , pulmcirc as pulmonary_circulation
    , perivasc as peripheral_vascular
    -- we combine "htn" and "htncx" into "HYPERTENSION"
    , case
        when htn = 1 then 1
        when htncx = 1 then 1
      else 0 end as hypertension
    , para as paralysis
    , neuro as other_neurological
    , chrnlung as chronic_pulmonary
    -- only the more severe comorbidity (complicated diabetes) is kept
    , case
        when dmcx = 1 then 0
        when dm = 1 then 1
      else 0 end as diabetes_uncomplicated
    , dmcx as diabetes_complicated
    , hypothy as hypothyroidism
    , renlfail as renal_failure
    , liver as liver_disease
    , ulcer as peptic_ulcer
    , aids as aids
    , lymph as lymphoma
    , mets as metastatic_cancer
    -- only the more severe comorbidity (metastatic cancer) is kept
    , case
        when mets = 1 then 0
        when tumor = 1 then 1
      else 0 end as solid_tumor
    , arth as rheumatoid_arthritis
    , coag as coagulopathy
    , obese as obesity
    , wghtloss as weight_loss
    , lytes as fluid_electrolyte
    , bldloss as blood_loss_anemia
    , anemdef as deficiency_anemias
    , alcohol as alcohol_abuse
    , drug as drug_abuse
    , psych as psychoses
    , depress as depression
  FROM elixhauser_by_hadm
), elixhauser_final AS(
  SELECT
      subject_id,hadm_id,
      LEAST(congestive_heart_failure + cardiac_arrhythmias + valvular_disease + pulmonary_circulation + peripheral_vascular + hypertension, 1) AS cardiovascular,
      LEAST(paralysis + other_neurological, 1) AS neurological,
      chronic_pulmonary AS pulmonary,
      LEAST(diabetes_uncomplicated + diabetes_complicated, 1) AS diabetes,
      renal_failure AS renal,
      LEAST(liver_disease + peptic_ulcer, 1) AS liver,
      LEAST(metastatic_cancer + solid_tumor + lymphoma, 1) AS cancer,
      LEAST(psychoses + depression + alcohol_abuse + drug_abuse, 1) AS mental_substance,
      LEAST(coagulopathy + fluid_electrolyte + deficiency_anemias + blood_loss_anemia + obesity + weight_loss + hypothyroidism, 1) AS hem_metabolic,
      rheumatoid_arthritis AS autoimmune
    FROM elixhauser_rename
)
UPDATE first_admission_data fad
SET
  cardiovascular     = ef.cardiovascular,
  neurological       = ef.neurological,
  pulmonary          = ef.pulmonary,
  diabetes           = ef.diabetes,
  renal              = ef.renal,
  liver              = ef.liver,
  cancer             = ef.cancer,
  mental_substance   = ef.mental_substance,
  hem_metabolic      = ef.hem_metabolic,
  autoimmune         = ef.autoimmune
FROM elixhauser_final ef
WHERE fad.subject_id = ef.subject_id
  AND fad.hadm_id = ef.hadm_id;

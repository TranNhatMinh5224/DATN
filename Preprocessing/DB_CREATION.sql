-- =====================================================================
-- MIMIC-IV DATABASE CREATION SCRIPT
-- Duoc tao dua tren du lieu thuc te tu CSV (kiem tra 5000 dong dau)
-- Cot co free-text (mo ta, ghi chu, ten thuoc) dung TEXT thay VARCHAR
-- Tat ca cot deu NULLABLE de tranh loi khi import
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS hosp;
CREATE SCHEMA IF NOT EXISTS icu;

-- =====================================================================
-- SCHEMA: hosp
-- =====================================================================

-- 1. hosp.patients
DROP TABLE IF EXISTS hosp.patients CASCADE;
CREATE TABLE hosp.patients (
    subject_id          INTEGER,
    gender              VARCHAR(1),
    anchor_age          INTEGER,
    anchor_year         INTEGER,
    anchor_year_group   VARCHAR(15),
    dod                 DATE
);

-- 2. hosp.admissions
DROP TABLE IF EXISTS hosp.admissions CASCADE;
CREATE TABLE hosp.admissions (
    subject_id              INTEGER,
    hadm_id                 INTEGER,
    admittime               TIMESTAMP,
    dischtime               TIMESTAMP,
    deathtime               TIMESTAMP,
    admission_type          VARCHAR(50),
    admit_provider_id       VARCHAR(10),
    admission_location      VARCHAR(60),
    discharge_location      VARCHAR(60),
    insurance               VARCHAR(20),
    language                VARCHAR(30),
    marital_status          VARCHAR(20),
    race                    VARCHAR(80),
    edregtime               TIMESTAMP,
    edouttime               TIMESTAMP,
    hospital_expire_flag    SMALLINT
);

-- 3. hosp.transfers
DROP TABLE IF EXISTS hosp.transfers CASCADE;
CREATE TABLE hosp.transfers (
    subject_id  INTEGER,
    hadm_id     INTEGER,
    transfer_id INTEGER,
    eventtype   VARCHAR(15),
    careunit    VARCHAR(60),
    intime      TIMESTAMP,
    outtime     TIMESTAMP
);

-- 4. hosp.services
DROP TABLE IF EXISTS hosp.services CASCADE;
CREATE TABLE hosp.services (
    subject_id      INTEGER,
    hadm_id         INTEGER,
    transfertime    TIMESTAMP,
    prev_service    VARCHAR(10),
    curr_service    VARCHAR(10)
);

-- 5. hosp.diagnoses_icd
DROP TABLE IF EXISTS hosp.diagnoses_icd CASCADE;
CREATE TABLE hosp.diagnoses_icd (
    subject_id  INTEGER,
    hadm_id     INTEGER,
    seq_num     INTEGER,
    icd_code    VARCHAR(10),
    icd_version SMALLINT
);

-- 6. hosp.d_icd_diagnoses
DROP TABLE IF EXISTS hosp.d_icd_diagnoses CASCADE;
CREATE TABLE hosp.d_icd_diagnoses (
    icd_code    VARCHAR(10),
    icd_version SMALLINT,
    long_title  TEXT
);

-- 7. hosp.procedures_icd
DROP TABLE IF EXISTS hosp.procedures_icd CASCADE;
CREATE TABLE hosp.procedures_icd (
    subject_id  INTEGER,
    hadm_id     INTEGER,
    seq_num     INTEGER,
    chartdate   DATE,
    icd_code    VARCHAR(10),
    icd_version SMALLINT
);

-- 8. hosp.d_icd_procedures
DROP TABLE IF EXISTS hosp.d_icd_procedures CASCADE;
CREATE TABLE hosp.d_icd_procedures (
    icd_code    VARCHAR(10),
    icd_version SMALLINT,
    long_title  TEXT
);

-- 9. hosp.labevents
DROP TABLE IF EXISTS hosp.labevents CASCADE;
CREATE TABLE hosp.labevents (
    labevent_id         BIGINT,
    subject_id          INTEGER,
    hadm_id             INTEGER,
    specimen_id         INTEGER,
    itemid              INTEGER,
    order_provider_id   VARCHAR(10),
    charttime           TIMESTAMP,
    storetime           TIMESTAMP,
    value               TEXT,
    valuenum            DOUBLE PRECISION,
    valueuom            VARCHAR(50),
    ref_range_lower     DOUBLE PRECISION,
    ref_range_upper     DOUBLE PRECISION,
    flag                VARCHAR(20),
    priority            VARCHAR(20),
    comments            TEXT
);

-- 10. hosp.d_labitems
DROP TABLE IF EXISTS hosp.d_labitems CASCADE;
CREATE TABLE hosp.d_labitems (
    itemid      INTEGER,
    label       VARCHAR(60),
    fluid       VARCHAR(30),
    category    VARCHAR(20)
);

-- 11. hosp.microbiologyevents
DROP TABLE IF EXISTS hosp.microbiologyevents CASCADE;
CREATE TABLE hosp.microbiologyevents (
    microevent_id           BIGINT,
    subject_id              INTEGER,
    hadm_id                 INTEGER,
    micro_specimen_id       INTEGER,
    order_provider_id       VARCHAR(10),
    chartdate               TIMESTAMP,
    charttime               TIMESTAMP,
    spec_itemid             INTEGER,
    spec_type_desc          VARCHAR(60),
    test_seq                INTEGER,
    storedate               TIMESTAMP,
    storetime               TIMESTAMP,
    test_itemid             INTEGER,
    test_name               VARCHAR(100),
    org_itemid              INTEGER,
    org_name                VARCHAR(100),
    isolate_num             SMALLINT,
    quantity                VARCHAR(20),
    ab_itemid               INTEGER,
    ab_name                 VARCHAR(40),
    dilution_text           VARCHAR(15),
    dilution_comparison     VARCHAR(15),
    dilution_value          DOUBLE PRECISION,
    interpretation          VARCHAR(5),
    comments                TEXT
);

-- 12. hosp.prescriptions
DROP TABLE IF EXISTS hosp.prescriptions CASCADE;
CREATE TABLE hosp.prescriptions (
    subject_id          INTEGER,
    hadm_id             INTEGER,
    pharmacy_id         INTEGER,
    poe_id              TEXT,
    poe_seq             INTEGER,
    order_provider_id   TEXT,
    starttime           TIMESTAMP,
    stoptime            TIMESTAMP,
    drug_type           TEXT,
    drug                TEXT,
    formulary_drug_cd   TEXT,
    gsn                 TEXT,
    ndc                 TEXT,
    prod_strength       TEXT,
    form_rx             TEXT,
    dose_val_rx         TEXT,
    dose_unit_rx        TEXT,
    form_val_disp       TEXT,
    form_unit_disp      TEXT,
    doses_per_24_hrs    DOUBLE PRECISION,
    route               TEXT
);

-- 13. hosp.pharmacy
DROP TABLE IF EXISTS hosp.pharmacy CASCADE;
CREATE TABLE hosp.pharmacy (
    subject_id          INTEGER,
    hadm_id             INTEGER,
    pharmacy_id         INTEGER,
    poe_id              TEXT,
    starttime           TIMESTAMP,
    stoptime            TIMESTAMP,
    medication          TEXT,
    proc_type           TEXT,
    status              TEXT,
    entertime           TIMESTAMP,
    verifiedtime        TIMESTAMP,
    route               TEXT,
    frequency           TEXT,
    disp_sched          TEXT,
    infusion_type       TEXT,
    sliding_scale       TEXT,
    lockout_interval    TEXT,
    basal_rate          DOUBLE PRECISION,
    one_hr_max          TEXT,
    doses_per_24_hrs    DOUBLE PRECISION,
    duration            DOUBLE PRECISION,
    duration_interval   TEXT,
    expiration_value    DOUBLE PRECISION,
    expiration_unit     TEXT,
    expirationdate      TIMESTAMP,
    dispensation        TEXT,
    fill_quantity       TEXT
);

-- 14. hosp.emar
DROP TABLE IF EXISTS hosp.emar CASCADE;
CREATE TABLE hosp.emar (
    subject_id          INTEGER,
    hadm_id             INTEGER,
    emar_id             TEXT,
    emar_seq            INTEGER,
    poe_id              TEXT,
    pharmacy_id         INTEGER,
    enter_provider_id   TEXT,
    charttime           TIMESTAMP,
    medication          TEXT,
    event_txt           TEXT,
    scheduletime        TIMESTAMP,
    storetime           TIMESTAMP
);

-- 15. hosp.emar_detail
DROP TABLE IF EXISTS hosp.emar_detail CASCADE;
CREATE TABLE hosp.emar_detail (
    subject_id                              INTEGER,
    emar_id                                 VARCHAR(20),
    emar_seq                                INTEGER,
    parent_field_ordinal                    VARCHAR(10),
    administration_type                     VARCHAR(40),
    pharmacy_id                             INTEGER,
    barcode_type                            VARCHAR(10),
    reason_for_no_barcode                   VARCHAR(80),
    complete_dose_not_given                 VARCHAR(5),
    dose_due                                VARCHAR(20),
    dose_due_unit                           VARCHAR(15),
    dose_given                              TEXT,
    dose_given_unit                         VARCHAR(15),
    will_remainder_of_dose_be_given         VARCHAR(5),
    product_amount_given                    VARCHAR(10),
    product_unit                            VARCHAR(15),
    product_code                            VARCHAR(25),
    product_description                     TEXT,
    product_description_other               TEXT,
    prior_infusion_rate                     VARCHAR(15),
    infusion_rate                           VARCHAR(15),
    infusion_rate_adjustment                VARCHAR(40),
    infusion_rate_adjustment_amount         VARCHAR(10),
    infusion_rate_unit                      VARCHAR(15),
    route                                   VARCHAR(10),
    infusion_complete                       VARCHAR(5),
    completion_interval                     VARCHAR(25),
    new_iv_bag_hung                         VARCHAR(5),
    continued_infusion_in_other_location    VARCHAR(5),
    restart_interval                        VARCHAR(20),
    side                                    VARCHAR(10),
    site                                    VARCHAR(20),
    non_formulary_visual_verification       VARCHAR(5)
);

-- 16. hosp.poe
DROP TABLE IF EXISTS hosp.poe CASCADE;
CREATE TABLE hosp.poe (
    poe_id                  VARCHAR(20),
    poe_seq                 INTEGER,
    subject_id              INTEGER,
    hadm_id                 INTEGER,
    ordertime               TIMESTAMP,
    order_type              VARCHAR(20),
    order_subtype           VARCHAR(60),
    transaction_type        VARCHAR(10),
    discontinue_of_poe_id   VARCHAR(20),
    discontinued_by_poe_id  VARCHAR(20),
    order_provider_id       VARCHAR(10),
    order_status            VARCHAR(15)
);

-- 17. hosp.poe_detail
DROP TABLE IF EXISTS hosp.poe_detail CASCADE;
CREATE TABLE hosp.poe_detail (
    poe_id      VARCHAR(20),
    poe_seq     INTEGER,
    subject_id  INTEGER,
    field_name  VARCHAR(30),
    field_value TEXT
);

-- 18. hosp.drgcodes
DROP TABLE IF EXISTS hosp.drgcodes CASCADE;
CREATE TABLE hosp.drgcodes (
    subject_id      INTEGER,
    hadm_id         INTEGER,
    drg_type        VARCHAR(5),
    drg_code        VARCHAR(10),
    description     TEXT,
    drg_severity    SMALLINT,
    drg_mortality   SMALLINT
);

-- 19. hosp.hcpcsevents
DROP TABLE IF EXISTS hosp.hcpcsevents CASCADE;
CREATE TABLE hosp.hcpcsevents (
    subject_id          INTEGER,
    hadm_id             INTEGER,
    chartdate           DATE,
    hcpcs_cd            VARCHAR(10),
    seq_num             INTEGER,
    short_description   TEXT
);

-- 20. hosp.d_hcpcs
DROP TABLE IF EXISTS hosp.d_hcpcs CASCADE;
CREATE TABLE hosp.d_hcpcs (
    code                VARCHAR(10),
    category            SMALLINT,
    long_description    TEXT,
    short_description   TEXT
);

-- 21. hosp.omr
DROP TABLE IF EXISTS hosp.omr CASCADE;
CREATE TABLE hosp.omr (
    subject_id      INTEGER,
    chartdate       DATE,
    seq_num         INTEGER,
    result_name     VARCHAR(50),
    result_value    TEXT
);

-- 22. hosp.provider
DROP TABLE IF EXISTS hosp.provider CASCADE;
CREATE TABLE hosp.provider (
    provider_id VARCHAR(10)
);

-- =====================================================================
-- SCHEMA: icu
-- =====================================================================

-- 23. icu.icustays
DROP TABLE IF EXISTS icu.icustays CASCADE;
CREATE TABLE icu.icustays (
    subject_id      INTEGER,
    hadm_id         INTEGER,
    stay_id         INTEGER,
    first_careunit  VARCHAR(60),
    last_careunit   VARCHAR(60),
    intime          TIMESTAMP,
    outtime         TIMESTAMP,
    los             DOUBLE PRECISION
);

-- 24. icu.chartevents
DROP TABLE IF EXISTS icu.chartevents CASCADE;
CREATE TABLE icu.chartevents (
    subject_id      INTEGER,
    hadm_id         INTEGER,
    stay_id         INTEGER,
    caregiver_id    INTEGER,
    charttime       TIMESTAMP,
    storetime       TIMESTAMP,
    itemid          INTEGER,
    value           TEXT,
    valuenum        DOUBLE PRECISION,
    valueuom        VARCHAR(50),
    warning         SMALLINT
);

-- 25. icu.d_items
DROP TABLE IF EXISTS icu.d_items CASCADE;
CREATE TABLE icu.d_items (
    itemid              INTEGER,
    label               VARCHAR(120),
    abbreviation        VARCHAR(60),
    linksto             VARCHAR(25),
    category            VARCHAR(50),
    unitname            VARCHAR(30),
    param_type          VARCHAR(25),
    lownormalvalue      DOUBLE PRECISION,
    highnormalvalue     DOUBLE PRECISION
);

-- 26. icu.datetimeevents
DROP TABLE IF EXISTS icu.datetimeevents CASCADE;
CREATE TABLE icu.datetimeevents (
    subject_id      INTEGER,
    hadm_id         INTEGER,
    stay_id         INTEGER,
    caregiver_id    INTEGER,
    charttime       TIMESTAMP,
    storetime       TIMESTAMP,
    itemid          INTEGER,
    value           TIMESTAMP,
    valueuom        VARCHAR(20),
    warning         SMALLINT
);

-- 27. icu.inputevents
DROP TABLE IF EXISTS icu.inputevents CASCADE;
CREATE TABLE icu.inputevents (
    subject_id                          INTEGER,
    hadm_id                             INTEGER,
    stay_id                             INTEGER,
    caregiver_id                        INTEGER,
    starttime                           TIMESTAMP,
    endtime                             TIMESTAMP,
    storetime                           TIMESTAMP,
    itemid                              INTEGER,
    amount                              DOUBLE PRECISION,
    amountuom                           VARCHAR(10),
    rate                                DOUBLE PRECISION,
    rateuom                             VARCHAR(15),
    orderid                             BIGINT,
    linkorderid                         BIGINT,
    ordercategoryname                   VARCHAR(40),
    secondaryordercategoryname          VARCHAR(40),
    ordercomponenttypedescription       VARCHAR(120),
    ordercategorydescription            VARCHAR(20),
    patientweight                       DOUBLE PRECISION,
    totalamount                         DOUBLE PRECISION,
    totalamountuom                      VARCHAR(10),
    isopenbag                           SMALLINT,
    continueinnextdept                  SMALLINT,
    statusdescription                   VARCHAR(25),
    originalamount                      DOUBLE PRECISION,
    originalrate                        DOUBLE PRECISION
);

-- 28. icu.outputevents
DROP TABLE IF EXISTS icu.outputevents CASCADE;
CREATE TABLE icu.outputevents (
    subject_id      INTEGER,
    hadm_id         INTEGER,
    stay_id         INTEGER,
    caregiver_id    INTEGER,
    charttime       TIMESTAMP,
    storetime       TIMESTAMP,
    itemid          INTEGER,
    value           DOUBLE PRECISION,
    valueuom        VARCHAR(10)
);

-- 29. icu.ingredientevents
DROP TABLE IF EXISTS icu.ingredientevents CASCADE;
CREATE TABLE icu.ingredientevents (
    subject_id          INTEGER,
    hadm_id             INTEGER,
    stay_id             INTEGER,
    caregiver_id        INTEGER,
    starttime           TIMESTAMP,
    endtime             TIMESTAMP,
    storetime           TIMESTAMP,
    itemid              INTEGER,
    amount              DOUBLE PRECISION,
    amountuom           VARCHAR(10),
    rate                DOUBLE PRECISION,
    rateuom             VARCHAR(15),
    orderid             BIGINT,
    linkorderid         BIGINT,
    statusdescription   VARCHAR(25),
    originalamount      DOUBLE PRECISION,
    originalrate        DOUBLE PRECISION
);

-- 30. icu.procedureevents
DROP TABLE IF EXISTS icu.procedureevents CASCADE;
CREATE TABLE icu.procedureevents (
    subject_id                  INTEGER,
    hadm_id                     INTEGER,
    stay_id                     INTEGER,
    caregiver_id                INTEGER,
    starttime                   TIMESTAMP,
    endtime                     TIMESTAMP,
    storetime                   TIMESTAMP,
    itemid                      INTEGER,
    value                       DOUBLE PRECISION,
    valueuom                    VARCHAR(10),
    location                    VARCHAR(35),
    locationcategory            VARCHAR(25),
    orderid                     BIGINT,
    linkorderid                 BIGINT,
    ordercategoryname           VARCHAR(30),
    ordercategorydescription    VARCHAR(25),
    patientweight               DOUBLE PRECISION,
    isopenbag                   SMALLINT,
    continueinnextdept          SMALLINT,
    statusdescription           VARCHAR(25),
    originalamount              DOUBLE PRECISION,
    originalrate                DOUBLE PRECISION
);

-- 31. icu.caregiver
DROP TABLE IF EXISTS icu.caregiver CASCADE;
CREATE TABLE icu.caregiver (
    caregiver_id INTEGER
);
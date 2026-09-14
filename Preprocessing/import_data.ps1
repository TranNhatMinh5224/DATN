Write-Host "========================================================"
Write-Host "   SCRIPT IMPORT DU LIEU MIMIC-IV VAO POSTGRESQL"
Write-Host "========================================================"
Write-Host ""
$env:PGPASSWORD = Read-Host "Nhap mat khau cua user postgres (roi an Enter)"
$psql = "C:\Program Files\PostgreSQL\17\bin\psql.exe"
$db = "mimic_iv"
$user = "postgres"
$base = "C:\Users\Admin\Desktop\Do_An_Tot_Nghiep\MIMIC_IV"

# Dung LATIN1 cho tat ca bang:
# - LATIN1 (ISO-8859-1): moi byte 0x00-0xFF deu map sang Unicode hop le
# - Khac WIN1252: WIN1252 co mot so byte undefined (vd: 0x9d) gay loi convert
# - File thuan ASCII van doc duoc binh thuong
function Import-Table {
    param($schema, $table, $csvPath)
    Write-Host "  --> $schema.$table ..."
    & $psql -U $user -d $db -c "\copy $schema.$table FROM '$csvPath' WITH (FORMAT CSV, HEADER, NULL '', ENCODING 'LATIN1')"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [LOI] $schema.$table" -ForegroundColor Red
    } else {
        Write-Host "  [OK]  $schema.$table" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "[B1] Tao cau truc database tu DB_CREATION.sql..."
& $psql -U $user -d $db -f "C:\Users\Admin\Desktop\Do_An_Tot_Nghiep\DATN\Preprocessing\DB_CREATION.sql"

Write-Host ""
Write-Host "[B2] Import cac bang HOSP (22 bang)..."
Import-Table "hosp" "patients"           "$base\hosp\patients.csv\patients.csv"
Import-Table "hosp" "admissions"         "$base\hosp\admissions.csv\admissions.csv"
Import-Table "hosp" "transfers"          "$base\hosp\transfers.csv\transfers.csv"
Import-Table "hosp" "services"           "$base\hosp\services.csv\services.csv"
Import-Table "hosp" "diagnoses_icd"      "$base\hosp\diagnoses_icd.csv\diagnoses_icd.csv"
Import-Table "hosp" "d_icd_diagnoses"    "$base\hosp\d_icd_diagnoses.csv\d_icd_diagnoses.csv"
Import-Table "hosp" "procedures_icd"     "$base\hosp\procedures_icd.csv\procedures_icd.csv"
Import-Table "hosp" "d_icd_procedures"   "$base\hosp\d_icd_procedures.csv\d_icd_procedures.csv"
Import-Table "hosp" "labevents"          "$base\hosp\labevents.csv\labevents.csv"
Import-Table "hosp" "d_labitems"         "$base\hosp\d_labitems.csv\d_labitems.csv"
Import-Table "hosp" "microbiologyevents" "$base\hosp\microbiologyevents.csv\microbiologyevents.csv"
Import-Table "hosp" "prescriptions"      "$base\hosp\prescriptions.csv\prescriptions.csv"
Import-Table "hosp" "pharmacy"           "$base\hosp\pharmacy.csv\pharmacy.csv"
Import-Table "hosp" "emar"               "$base\hosp\emar.csv\emar.csv"
Import-Table "hosp" "emar_detail"        "$base\hosp\emar_detail.csv\emar_detail.csv"
Import-Table "hosp" "poe"                "$base\hosp\poe.csv\poe.csv"
Import-Table "hosp" "poe_detail"         "$base\hosp\poe_detail.csv\poe_detail.csv"
Import-Table "hosp" "drgcodes"           "$base\hosp\drgcodes.csv\drgcodes.csv"
Import-Table "hosp" "hcpcsevents"        "$base\hosp\hcpcsevents.csv\hcpcsevents.csv"
Import-Table "hosp" "d_hcpcs"            "$base\hosp\d_hcpcs.csv\d_hcpcs.csv"
Import-Table "hosp" "omr"                "$base\hosp\omr.csv\omr.csv"
Import-Table "hosp" "provider"           "$base\hosp\provider.csv\provider.csv"

Write-Host ""
Write-Host "[B3] Import cac bang ICU (9 bang, chartevents co the mat 20-40 phut)..."
Import-Table "icu" "icustays"         "$base\icu\icustays.csv\icustays.csv"
Import-Table "icu" "caregiver"        "$base\icu\caregiver.csv\caregiver.csv"
Import-Table "icu" "d_items"          "$base\icu\d_items.csv\d_items.csv"
Import-Table "icu" "chartevents"      "$base\icu\chartevents.csv\chartevents.csv"
Import-Table "icu" "datetimeevents"   "$base\icu\datetimeevents.csv\datetimeevents.csv"
Import-Table "icu" "inputevents"      "$base\icu\inputevents.csv\inputevents.csv"
Import-Table "icu" "outputevents"     "$base\icu\outputevents.csv\outputevents.csv"
Import-Table "icu" "ingredientevents" "$base\icu\ingredientevents.csv\ingredientevents.csv"
Import-Table "icu" "procedureevents"  "$base\icu\procedureevents.csv\procedureevents.csv"

Write-Host ""
Write-Host "========================================================"
Write-Host "HOAN THANH IMPORT DU LIEU!"
Write-Host "========================================================"
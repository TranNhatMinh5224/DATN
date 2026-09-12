Write-Host "========================================================"
Write-Host "   SCRIPT IMPORT DU LIEU MIMIC-IV VAO POSTGRESQL"
Write-Host "========================================================"
Write-Host ""
$env:PGPASSWORD = Read-Host "Nhap mat khau cua user postgres (roi an Enter)"
Write-Host ""

Write-Host "[1/6] Dang import bang patients..."
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d mimic_iv -c "\copy patients FROM 'C:\Users\Admin\Desktop\Do_An_Tot_Nghiep\MIMIC_IV\hosp\patients.csv\patients.csv' DELIMITER ',' CSV HEADER"

Write-Host "[2/6] Dang import bang admissions..."
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d mimic_iv -c "\copy admissions FROM 'C:\Users\Admin\Desktop\Do_An_Tot_Nghiep\MIMIC_IV\hosp\admissions.csv\admissions.csv' DELIMITER ',' CSV HEADER"

Write-Host "[3/6] Dang import bang d_items..."
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d mimic_iv -c "\copy d_items FROM 'C:\Users\Admin\Desktop\Do_An_Tot_Nghiep\MIMIC_IV\icu\d_items.csv\d_items.csv' DELIMITER ',' CSV HEADER"

Write-Host "[4/6] Dang import bang chartevents (File rat nang, se mat nhieu phut)..."
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d mimic_iv -c "\copy chartevents FROM 'C:\Users\Admin\Desktop\Do_An_Tot_Nghiep\MIMIC_IV\icu\chartevents.csv\chartevents.csv' DELIMITER ',' CSV HEADER"

Write-Host "[5/6] Dang import bang labevents (File rat nang, se mat nhieu phut)..."
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d mimic_iv -c "\copy labevents FROM 'C:\Users\Admin\Desktop\Do_An_Tot_Nghiep\MIMIC_IV\hosp\labevents.csv\labevents.csv' DELIMITER ',' CSV HEADER"

Write-Host "[6/6] Dang import bang diagnoses_icd..."
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d mimic_iv -c "\copy diagnoses_icd FROM 'C:\Users\Admin\Desktop\Do_An_Tot_Nghiep\MIMIC_IV\hosp\diagnoses_icd.csv\diagnoses_icd.csv' DELIMITER ',' CSV HEADER"

Write-Host ""
Write-Host "========================================================"
Write-Host "HOAN THANH IMPORT DU LIEU!"
Write-Host "========================================================"

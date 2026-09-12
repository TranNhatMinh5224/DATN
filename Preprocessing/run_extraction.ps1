Write-Host "========================================================"
Write-Host "   SCRIPT TRICH XUAT DAC TRUNG (FEATURE EXTRACTION)"
Write-Host "========================================================"
Write-Host ""
$env:PGPASSWORD = Read-Host "Nhap mat khau cua user postgres (roi an Enter)"
Write-Host ""

$psql = "C:\Program Files\PostgreSQL\17\bin\psql.exe"
$base_path = "C:\Users\Admin\Desktop\Do_An_Tot_Nghiep\DATN\Preprocessing\sql_steps"

Write-Host "[1/4] Dang loc benh nhan nhap vien lan dau, tinh Tuoi va Nhan tu vong..."
& $psql -U postgres -d mimic_iv -f "$base_path\1_first_admissions.sql"
if ($LASTEXITCODE -ne 0) { Write-Host "Loi o buoc 1!"; exit }

Write-Host "[2/4] Dang loc bang chartevents (Buoc nay rat nang, co the mat 15-20 phut)..."
& $psql -U postgres -d mimic_iv -f "$base_path\2_chartevents.sql"
if ($LASTEXITCODE -ne 0) { Write-Host "Loi o buoc 2!"; exit }

Write-Host "[3/4] Dang loc bang labevents (Buoc nay nang, co the mat 5-10 phut)..."
& $psql -U postgres -d mimic_iv -f "$base_path\3_labevents.sql"
if ($LASTEXITCODE -ne 0) { Write-Host "Loi o buoc 3!"; exit }

Write-Host "[4/4] Dang tinh toan diem benh nen Elixhauser va hoan thien du lieu..."
& $psql -U postgres -d mimic_iv -f "$base_path\4_elixhauser.sql"
if ($LASTEXITCODE -ne 0) { Write-Host "Loi o buoc 4!"; exit }

Write-Host ""
Write-Host "========================================================"
Write-Host "HOAN THANH TRICH XUAT DU LIEU THANH CONG!"
Write-Host "========================================================"

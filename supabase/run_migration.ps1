# PowerShell script to run Supabase migrations
# Usage: .\run_migration.ps1 -MigrationFile "003_add_is_favorite_column.sql"

param(
    [Parameter(Mandatory=$true)]
    [string]$MigrationFile
)

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Supabase Migration Runner" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$migrationPath = Join-Path $PSScriptRoot "migrations\$MigrationFile"

if (-not (Test-Path $migrationPath)) {
    Write-Host "Error: Migration file not found: $migrationPath" -ForegroundColor Red
    exit 1
}

Write-Host "Migration file: $MigrationFile" -ForegroundColor Green
Write-Host ""

# Read the SQL content
$sqlContent = Get-Content $migrationPath -Raw

Write-Host "SQL Content:" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Gray
Write-Host $sqlContent -ForegroundColor White
Write-Host "-----------------------------------" -ForegroundColor Gray
Write-Host ""

Write-Host "To run this migration, follow these steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open Supabase Dashboard:" -ForegroundColor White
Write-Host "   https://app.supabase.com/project/wdcwjnshzocibvwrbuok/sql" -ForegroundColor Blue
Write-Host ""
Write-Host "2. Click 'New Query' button" -ForegroundColor White
Write-Host ""
Write-Host "3. Copy the SQL content above and paste it into the editor" -ForegroundColor White
Write-Host ""
Write-Host "4. Click 'Run' to execute the migration" -ForegroundColor White
Write-Host ""
Write-Host "5. Verify the changes in Table Editor" -ForegroundColor White
Write-Host ""

# Copy to clipboard if available
try {
    Set-Clipboard -Value $sqlContent
    Write-Host "✓ SQL content has been copied to your clipboard!" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "Note: Could not copy to clipboard automatically" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Press any key to open Supabase Dashboard in browser..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Start-Process "https://app.supabase.com/project/wdcwjnshzocibvwrbuok/sql"

Write-Host ""
Write-Host "Dashboard opened in browser!" -ForegroundColor Green

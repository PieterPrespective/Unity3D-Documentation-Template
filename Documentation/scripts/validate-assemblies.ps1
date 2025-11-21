# Quick validation script for assembly setup
& "$PSScriptRoot\setup-api-assemblies.ps1" -ValidateOnly

# Check for XML files
Write-Host ""
Write-Host "Checking for generated XML files:" -ForegroundColor Cyan
$apiPath = Join-Path (Split-Path $PSScriptRoot -Parent) "api"
$xmlFiles = Get-ChildItem -Path $apiPath -Filter "*.xml" -ErrorAction SilentlyContinue

if ($xmlFiles.Count -gt 0) {
    Write-Host "Found $($xmlFiles.Count) XML documentation files:" -ForegroundColor Green
    foreach ($xml in $xmlFiles) {
        $size = [math]::Round($xml.Length / 1KB, 2)
        Write-Host "  - $($xml.Name) ($size KB)" -ForegroundColor DarkGray
    }
} else {
    Write-Host "No XML files found. Recompile in Unity after setup." -ForegroundColor Yellow
}

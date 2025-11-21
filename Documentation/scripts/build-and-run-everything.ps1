#Requires -Version 5.0
<#
.SYNOPSIS
    Runs all documentation generation scripts in the correct sequence
.DESCRIPTION
    This script executes all required documentation generation scripts in order:
    1. Setup API assemblies for documentation  
    2. Generate diagram images from Draw.io files
    3. Include code coverage reports
    4. Build the documentation
    5. Test/host the documentation locally
.PARAMETER SkipApi
    Skip the API assembly setup step
.PARAMETER SkipDiagrams
    Skip the diagram image generation step
.PARAMETER SkipCoverage
    Skip the code coverage inclusion step
.PARAMETER NoBrowser
    Don't automatically open the browser after hosting
.PARAMETER Port
    Port number for the local documentation server (default: 8080)
.PARAMETER StopOnError
    Stop execution if any script fails (default: true)
.EXAMPLE
    .\build-and-run-everything.ps1
    Run all scripts with default settings
.EXAMPLE
    .\build-and-run-everything.ps1 -SkipApi -Port 8081
    Skip API setup and host on port 8081
#>

param(
    [switch]$SkipApi = $false,
    [switch]$SkipDiagrams = $false,
    [switch]$SkipCoverage = $false,
    [switch]$NoBrowser = $false,
    [int]$Port = 8080,
    [switch]$StopOnError = $true,
    [switch]$Help = $false
)

# Show help if requested
if ($Help) {
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit 0
}

# Store the original directory
$originalLocation = Get-Location
$scriptPath = $PSScriptRoot

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   Complete Documentation Build and Host" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$startTotalTime = Get-Date
$successCount = 0
$failCount = 0
$skipCount = 0

# Navigate to scripts directory
Set-Location $scriptPath

# Step 1: Setup API Assemblies
Write-Host ""
if (-not $SkipApi) {
    Write-Host "[1/5] Setting up API documentation assemblies" -ForegroundColor Yellow
    Write-Host "Running: setup-api-assemblies.ps1" -ForegroundColor DarkGray
    $startTime = Get-Date
    
    try {
        & "$scriptPath\setup-api-assemblies.ps1" 2>&1 | Out-Host
        $duration = (Get-Date) - $startTime
        Write-Host "[OK] Completed in $([math]::Round($duration.TotalSeconds, 1)) seconds" -ForegroundColor Green
        $successCount++
    }
    catch {
        $duration = (Get-Date) - $startTime
        Write-Host "[ERROR] Failed after $([math]::Round($duration.TotalSeconds, 1)) seconds" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        $failCount++
        if ($StopOnError) {
            Set-Location $originalLocation
            exit 1
        }
    }
} else {
    Write-Host "[1/5] Skipping API assembly setup (-SkipApi flag)" -ForegroundColor DarkGray
    $skipCount++
}

# Step 2: Generate Diagram Images
Write-Host ""
if (-not $SkipDiagrams) {
    Write-Host "[2/5] Generating diagram images from Draw.io files" -ForegroundColor Yellow
    Write-Host "Running: make-diagram-images.ps1" -ForegroundColor DarkGray
    $startTime = Get-Date
    
    try {
        & "$scriptPath\make-diagram-images.ps1" 2>&1 | Out-Host
        $duration = (Get-Date) - $startTime
        Write-Host "[OK] Completed in $([math]::Round($duration.TotalSeconds, 1)) seconds" -ForegroundColor Green
        $successCount++
    }
    catch {
        $duration = (Get-Date) - $startTime
        Write-Host "[ERROR] Failed after $([math]::Round($duration.TotalSeconds, 1)) seconds" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        $failCount++
        if ($StopOnError) {
            Set-Location $originalLocation
            exit 1
        }
    }
} else {
    Write-Host "[2/5] Skipping diagram generation (-SkipDiagrams flag)" -ForegroundColor DarkGray
    $skipCount++
}

# Step 3: Include Code Coverage
Write-Host ""
if (-not $SkipCoverage) {
    Write-Host "[3/5] Including code coverage reports" -ForegroundColor Yellow
    Write-Host "Running: include-codecoverage.ps1" -ForegroundColor DarkGray
    $startTime = Get-Date
    
    try {
        & "$scriptPath\include-codecoverage.ps1" 2>&1 | Out-Host
        $duration = (Get-Date) - $startTime
        Write-Host "[OK] Completed in $([math]::Round($duration.TotalSeconds, 1)) seconds" -ForegroundColor Green
        $successCount++
    }
    catch {
        $duration = (Get-Date) - $startTime
        Write-Host "[ERROR] Failed after $([math]::Round($duration.TotalSeconds, 1)) seconds" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        $failCount++
        if ($StopOnError) {
            Set-Location $originalLocation
            exit 1
        }
    }
} else {
    Write-Host "[3/5] Skipping code coverage (-SkipCoverage flag)" -ForegroundColor DarkGray
    $skipCount++
}

# Step 4: Build Documentation
Write-Host ""
Write-Host "[4/5] Building documentation with DocFX" -ForegroundColor Yellow
Write-Host "Running: build-docs.ps1" -ForegroundColor DarkGray
$startTime = Get-Date

try {
    & "$scriptPath\build-docs.ps1" 2>&1 | Out-Host
    $duration = (Get-Date) - $startTime
    Write-Host "[OK] Completed in $([math]::Round($duration.TotalSeconds, 1)) seconds" -ForegroundColor Green
    $successCount++
}
catch {
    $duration = (Get-Date) - $startTime
    Write-Host "[ERROR] Failed after $([math]::Round($duration.TotalSeconds, 1)) seconds" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    $failCount++
    if ($StopOnError) {
        Set-Location $originalLocation
        exit 1
    }
}

# Summary
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "              Summary" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$totalDuration = (Get-Date) - $startTotalTime
Write-Host ""
Write-Host "Total build time: $([math]::Round($totalDuration.TotalSeconds, 1)) seconds" -ForegroundColor Gray
Write-Host "Steps completed: $successCount" -ForegroundColor Green
if ($failCount -gt 0) {
    Write-Host "Steps failed: $failCount" -ForegroundColor Red
}
if ($skipCount -gt 0) {
    Write-Host "Steps skipped: $skipCount" -ForegroundColor DarkGray
}

# Step 5: Test/Host Documentation
Write-Host ""
Write-Host "[5/5] Starting local documentation server" -ForegroundColor Yellow

$hostArgs = @()
if ($NoBrowser) {
    $hostArgs += "-NoOpen"
}
if ($Port -ne 8080) {
    $hostArgs += "-Port"
    $hostArgs += $Port
}

$argsString = if ($hostArgs) { $hostArgs -join " " } else { "" }
Write-Host "Running: test-host-documentation.ps1 $argsString" -ForegroundColor DarkGray

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Documentation is ready!" -ForegroundColor Green
Write-Host "Starting server on http://localhost:$Port" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Run the host script (this will block until Ctrl+C)
# Build proper parameters
$hostParams = @{}
if ($NoBrowser) {
    $hostParams['NoOpen'] = $true
}
if ($Port -ne 8080) {
    $hostParams['Port'] = $Port
}

if ($hostParams.Count -gt 0) {
    & "$scriptPath\test-host-documentation.ps1" @hostParams
} else {
    & "$scriptPath\test-host-documentation.ps1"
}

# Return to original directory
Set-Location $originalLocation

Write-Host ""
Write-Host "All documentation tasks completed!" -ForegroundColor Green
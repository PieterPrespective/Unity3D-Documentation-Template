#Requires -Version 5.0
<#
.SYNOPSIS
    Integrate code coverage HTML pages into DocFX build website
.DESCRIPTION
    This script processes the dynamically generated code coverage HTML files
    and integrates them into the DocFX build by:
    1. Copying coverage files to the DocFX resource directory
    2. Creating a coverage section in the main table of contents
    3. Generating a coverage index page for navigation
    4. Updating DocFX configuration if needed
.EXAMPLE
    .\include-codecoverage.ps1
    Process code coverage files and integrate into DocFX
.EXAMPLE
    .\include-codecoverage.ps1 -DryRun
    Preview what changes would be made without applying them
.EXAMPLE
    .\include-codecoverage.ps1 -Force
    Force regeneration of all coverage integration files
#>

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Force,
    
    [Parameter()]
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$DocumentationPath = Split-Path $PSScriptRoot -Parent
$CoveragePath = Join-Path $DocumentationPath "codecoverage"
$CoverageReportPath = Join-Path $CoveragePath "Report"
$DocFXConfigPath = Join-Path $DocumentationPath "docfx.json"
$MainTocPath = Join-Path $DocumentationPath "toc.yml"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   Code Coverage Integration Tool" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if code coverage report exists
function Test-CoverageReport {
    return (Test-Path $CoverageReportPath) -and (Test-Path (Join-Path $CoverageReportPath "index.html"))
}

# Function to get all HTML files from coverage report
function Get-CoverageHtmlFiles {
    if (-not (Test-CoverageReport)) {
        return @()
    }
    
    return Get-ChildItem -Path $CoverageReportPath -Filter "*.html" -File
}

# Function to create coverage directory in DocFX resources
function New-DocFXCoverageDirectory {
    $coverageDestPath = Join-Path $DocumentationPath "codecoverage-web"
    
    if (-not (Test-Path $coverageDestPath)) {
        if ($DryRun) {
            Write-Host "  [DRY-RUN] Would create directory: codecoverage-web/" -ForegroundColor Cyan
        } else {
            New-Item -ItemType Directory -Path $coverageDestPath -Force | Out-Null
            Write-Host "  [CREATE] Created directory: codecoverage-web/" -ForegroundColor Green
        }
    }
    
    return $coverageDestPath
}

# Function to copy coverage files to DocFX directory
function Copy-CoverageFiles {
    param([string]$DestinationPath)
    
    if (-not (Test-CoverageReport)) {
        Write-Host "  [WARN] No coverage report found at: $CoverageReportPath" -ForegroundColor Yellow
        return $false
    }
    
    if ($DryRun) {
        $htmlFiles = Get-CoverageHtmlFiles
        Write-Host "  [DRY-RUN] Would copy $($htmlFiles.Count) HTML files and assets" -ForegroundColor Cyan
        return $true
    }
    
    # Copy all files from Report directory
    try {
        Copy-Item -Path "$CoverageReportPath\*" -Destination $DestinationPath -Recurse -Force
        
        $copiedFiles = Get-ChildItem -Path $DestinationPath -Recurse | Measure-Object
        Write-Host "  [COPY] Copied $($copiedFiles.Count) coverage files" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "  [ERROR] Failed to copy coverage files: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to update DocFX configuration
function Update-DocFXConfig {
    if (-not (Test-Path $DocFXConfigPath)) {
        Write-Host "  [WARN] DocFX config not found: $DocFXConfigPath" -ForegroundColor Yellow
        return $false
    }
    
    try {
        $config = Get-Content $DocFXConfigPath -Raw | ConvertFrom-Json
        
        # Check if codecoverage-web is already in resources
        $resourceExists = $false
        foreach ($resource in $config.build.resource) {
            if ($resource.files -contains "codecoverage-web/**") {
                $resourceExists = $true
                break
            }
        }
        
        if (-not $resourceExists) {
            if ($DryRun) {
                Write-Host "  [DRY-RUN] Would add codecoverage-web/** to DocFX resources" -ForegroundColor Cyan
            } else {
                # Add codecoverage-web to resources
                $newResource = @{
                    files = @("codecoverage-web/**")
                }
                $config.build.resource += $newResource
                
                # Save updated config
                $config | ConvertTo-Json -Depth 10 | Set-Content $DocFXConfigPath -Encoding UTF8
                Write-Host "  [UPDATE] Added codecoverage-web to DocFX resources" -ForegroundColor Green
            }
        } else {
            Write-Host "  [SKIP] codecoverage-web already in DocFX resources" -ForegroundColor DarkGray
        }
        
        return $true
    } catch {
        Write-Host "  [ERROR] Failed to update DocFX config: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to create coverage index markdown page
function New-CoverageIndexPage {
    param([string]$CoverageDestPath)
    
    $indexMdPath = Join-Path $DocumentationPath "codecoverage.md"
    
    # Check if we should regenerate
    if ((Test-Path $indexMdPath) -and -not $Force) {
        Write-Host "  [SKIP] Coverage index page already exists: codecoverage.md" -ForegroundColor DarkGray
        return $true
    }
    
    if ($DryRun) {
        Write-Host "  [DRY-RUN] Would create coverage index page: codecoverage.md" -ForegroundColor Cyan
        return $true
    }
    
    # Read the main coverage HTML to extract summary information
    $summaryInfo = ""
    $indexHtmlPath = Join-Path $CoverageDestPath "index.html"
    if (Test-Path $indexHtmlPath) {
        try {
            $htmlContent = Get-Content $indexHtmlPath -Raw
            
            # Extract key metrics using regex
            if ($htmlContent -match '<th>Line coverage:</th><td>([^<]+)</td>') {
                $lineCoverage = $matches[1]
                $summaryInfo += "- **Line Coverage:** $lineCoverage`n"
            }
            if ($htmlContent -match '<th>Method coverage:</th><td>([^<]+)</td>') {
                $methodCoverage = $matches[1]
                $summaryInfo += "- **Method Coverage:** $methodCoverage`n"
            }
            if ($htmlContent -match '<th>Generated on:</th><td>([^<]+)</td>') {
                $generatedOn = $matches[1]
                $summaryInfo += "- **Generated:** $generatedOn`n"
            }
        } catch {
            Write-Host "  [WARN] Could not extract summary from coverage HTML" -ForegroundColor Yellow
        }
    }
    
    $markdownContent = @"
# Code Coverage Report

This section contains the detailed code coverage analysis for the Unity project.

## Summary

$summaryInfo

## Coverage Reports

The coverage analysis includes detailed reports for each assembly and class in the project:

<iframe src="codecoverage-web/index.html" width="100%" height="800px" style="border: 1px solid #ccc; border-radius: 4px;">
Your browser does not support iframes. <a href="codecoverage-web/index.html" target="_blank">View the coverage report directly</a>.
</iframe>

## Direct Links

- [**Full Coverage Report**](codecoverage-web/index.html) - Complete coverage analysis
- [**Summary Report**](codecoverage-web/Summary.md) - Coverage summary in markdown format

## Understanding the Report

The coverage report shows:

- **Line Coverage**: Percentage of code lines that were executed during testing
- **Method Coverage**: Percentage of methods that were called during testing
- **Branch Coverage**: Percentage of code branches that were taken during testing

Green highlighting indicates covered code, while red highlighting shows uncovered areas that may need additional testing.

---

*This coverage report is automatically generated and updated as part of the continuous integration process.*
"@
    
    try {
        $markdownContent | Out-File -FilePath $indexMdPath -Encoding UTF8
        Write-Host "  [CREATE] Created coverage index page: codecoverage.md" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "  [ERROR] Failed to create coverage index page: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to update main table of contents
function Update-MainToc {
    if (-not (Test-Path $MainTocPath)) {
        Write-Host "  [WARN] Main TOC not found: $MainTocPath" -ForegroundColor Yellow
        return $false
    }
    
    try {
        $tocContent = Get-Content $MainTocPath -Raw
        
        # Check if coverage entry already exists
        if ($tocContent -match "Code Coverage|codecoverage\.md") {
            Write-Host "  [SKIP] Coverage entry already exists in main TOC" -ForegroundColor DarkGray
            return $true
        }
        
        if ($DryRun) {
            Write-Host "  [DRY-RUN] Would add Code Coverage entry to main TOC" -ForegroundColor Cyan
            return $true
        }
        
        # Add coverage entry to TOC
        $coverageEntry = "- name: Code Coverage`n  href: codecoverage.md"
        
        # Insert before API Documentation if it exists, otherwise append
        if ($tocContent -match "- name: API Documentation") {
            $tocContent = $tocContent -replace "(- name: API Documentation)", "$coverageEntry`n`$1"
        } else {
            $tocContent = $tocContent.TrimEnd() + "`n$coverageEntry"
        }
        
        $tocContent | Out-File -FilePath $MainTocPath -Encoding UTF8 -NoNewline
        Write-Host "  [UPDATE] Added Code Coverage to main TOC" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "  [ERROR] Failed to update main TOC: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main execution
Write-Host "Checking for code coverage reports..." -ForegroundColor Yellow

if (-not (Test-CoverageReport)) {
    Write-Host "  [ERROR] No code coverage report found at: $CoverageReportPath" -ForegroundColor Red
    Write-Host "  Please run your code coverage analysis first to generate the reports." -ForegroundColor Yellow
    exit 1
}

$htmlFiles = Get-CoverageHtmlFiles
Write-Host "  [FOUND] $($htmlFiles.Count) HTML coverage files" -ForegroundColor Green

Write-Host ""
Write-Host "Integrating coverage into DocFX..." -ForegroundColor Yellow

# Step 1: Create coverage directory in DocFX structure
$coverageDestPath = New-DocFXCoverageDirectory

# Step 2: Copy coverage files
$copySuccess = Copy-CoverageFiles -DestinationPath $coverageDestPath

# Step 3: Update DocFX configuration
$configSuccess = Update-DocFXConfig

# Step 4: Create coverage index page
$indexSuccess = New-CoverageIndexPage -CoverageDestPath $coverageDestPath

# Step 5: Update main table of contents
$tocSuccess = Update-MainToc

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "           Integration Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

if (-not $DryRun) {
    Write-Host "Summary:" -ForegroundColor Yellow
    Write-Host "  • HTML files processed: $($htmlFiles.Count)" -ForegroundColor DarkGray
    Write-Host "  • Files copied: $(if ($copySuccess) { 'Success' } else { 'Failed' })" -ForegroundColor $(if ($copySuccess) { 'Green' } else { 'Red' })
    Write-Host "  • DocFX config updated: $(if ($configSuccess) { 'Success' } else { 'Failed' })" -ForegroundColor $(if ($configSuccess) { 'Green' } else { 'Red' })
    Write-Host "  • Index page created: $(if ($indexSuccess) { 'Success' } else { 'Failed' })" -ForegroundColor $(if ($indexSuccess) { 'Green' } else { 'Red' })
    Write-Host "  • TOC updated: $(if ($tocSuccess) { 'Success' } else { 'Failed' })" -ForegroundColor $(if ($tocSuccess) { 'Green' } else { 'Red' })
    
    if ($copySuccess -and $configSuccess -and $indexSuccess -and $tocSuccess) {
        Write-Host ""
        Write-Host "Next Steps:" -ForegroundColor Yellow
        Write-Host "  1. Run 'docfx serve' or your build process" -ForegroundColor DarkGray
        Write-Host "  2. Navigate to 'Code Coverage' in the documentation site" -ForegroundColor DarkGray
        Write-Host "  3. Coverage reports will be accessible via iframe and direct links" -ForegroundColor DarkGray
    } else {
        Write-Host ""
        Write-Host "Some steps failed. Please check the errors above." -ForegroundColor Red
    }
} else {
    Write-Host "DRY RUN SUMMARY:" -ForegroundColor Cyan
    Write-Host "  • HTML files found: $($htmlFiles.Count)" -ForegroundColor DarkGray
    Write-Host "  • Changes that would be made:" -ForegroundColor DarkGray
    Write-Host "    - Copy coverage files to codecoverage-web/" -ForegroundColor DarkGray
    Write-Host "    - Update DocFX configuration" -ForegroundColor DarkGray
    Write-Host "    - Create codecoverage.md index page" -ForegroundColor DarkGray
    Write-Host "    - Update main table of contents" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "Usage tips:" -ForegroundColor Yellow
Write-Host "  • Run this script after generating new coverage reports" -ForegroundColor DarkGray
Write-Host "  • Use -Force to regenerate the coverage index page" -ForegroundColor DarkGray
Write-Host "  • Use -DryRun to preview changes without applying them" -ForegroundColor DarkGray
Write-Host "  • Coverage reports are embedded via iframe for seamless integration" -ForegroundColor DarkGray
Write-Host ""
#Requires -Version 5.0
<#
.SYNOPSIS
    Build and serve DocFX documentation for local testing
.DESCRIPTION
    This script builds the DocFX documentation and optionally serves it locally for preview.
    It includes options for cleaning previous builds and watching for changes.
.PARAMETER Clean
    Remove previous build artifacts before building
.PARAMETER Build
    Build the documentation (default: true)
.PARAMETER Serve
    Serve the documentation locally after building (default: true)
.PARAMETER Port
    Port number for the local server (default: 8080)
.PARAMETER Watch
    Watch for changes and rebuild automatically
.PARAMETER SkipApi
    Skip API documentation generation (faster for testing articles only)
.PARAMETER NoOpen
    Don't automatically open the browser after starting the server
.EXAMPLE
    .\test-host-documentation.ps1
    Build and serve documentation on default port, opening browser automatically
.EXAMPLE
    .\test-host-documentation.ps1 -Clean -Port 8081
    Clean, build, and serve on port 8081
.EXAMPLE
    .\test-host-documentation.ps1 -Watch
    Build, serve, and watch for changes
#>

param(
    [switch]$Clean = $false,
    [switch]$Build = $true,
    [switch]$Serve = $true,
    [int]$Port = 8080,
    [switch]$Watch = $false,
    [switch]$SkipApi = $false,
    [switch]$NoOpen = $false,
    [switch]$Help = $false
)

# Show help if requested
if ($Help) {
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit 0
}

# Script configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Colors for output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Navigate to Documentation folder (parent of scripts folder)
$DocumentationPath = Split-Path $PSScriptRoot -Parent
$ProjectRoot = Split-Path $DocumentationPath -Parent

Write-Host ""
Write-ColorOutput Green "========================================="
Write-ColorOutput Green "   DocFX Documentation Test Script"
Write-ColorOutput Green "========================================="
Write-Host ""

# Check if DocFX is installed
Write-Host "Checking DocFX installation..." -ForegroundColor Yellow
$docfxCheck = $null
try {
    $docfxCheck = docfx --version 2>$null
}
catch {
    # Silently catch if docfx is not found
}

if (-not $docfxCheck) {
    Write-ColorOutput Red "[ERROR] DocFX is not installed!"
    Write-Host ""
    Write-Host "To install DocFX, run:" -ForegroundColor Yellow
    Write-Host "  dotnet tool install -g docfx" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Or install via Chocolatey:" -ForegroundColor Yellow
    Write-Host "  choco install docfx" -ForegroundColor Cyan
    exit 1
}

Write-ColorOutput Green "[OK] DocFX version: $docfxCheck"
Write-Host ""

# Change to Documentation directory
Set-Location $DocumentationPath
Write-Host "Working directory: $DocumentationPath" -ForegroundColor Cyan
Write-Host ""

# Clean if requested
if ($Clean) {
    Write-Host "Cleaning previous build artifacts..." -ForegroundColor Yellow
    
    $itemsToClean = @(
        "_site",
        "api/*.yml",
        "api/.manifest",
        "obj"
    )
    
    foreach ($item in $itemsToClean) {
        $path = Join-Path $DocumentationPath $item
        if (Test-Path $path) {
            Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  Removed: $item" -ForegroundColor DarkGray
        }
    }
    
    Write-ColorOutput Green "[OK] Clean completed"
    Write-Host ""
}

# Build documentation
if ($Build) {
    try {
        # Build metadata (API documentation from C# code)
        if (-not $SkipApi) {
            Write-Host "Generating API documentation..." -ForegroundColor Yellow
            
            # Check if there are any C# files to document
            $csFiles = Get-ChildItem -Path "$ProjectRoot/Assets/Scripts" -Filter "*.cs" -Recurse -ErrorAction SilentlyContinue
            
            if ($csFiles.Count -gt 0) {
                $output = docfx metadata 2>&1
                if ($LASTEXITCODE -ne 0) {
                    Write-ColorOutput Red "[ERROR] Metadata generation failed"
                    Write-Host $output
                    exit 1
                }
                Write-ColorOutput Green "[OK] API documentation generated ($($csFiles.Count) source files)"
            }
            else {
                Write-Host "  No C# files found in Assets/Scripts - skipping API generation" -ForegroundColor DarkGray
            }
        }
        else {
            Write-Host "Skipping API documentation generation (--skip-api flag)" -ForegroundColor DarkGray
        }
        
        Write-Host ""
        Write-Host "Building documentation site..." -ForegroundColor Yellow
        
        # Build the documentation
        if ($Watch) {
            # Build with watch mode in background
            $buildArgs = "build --serve:$Port"
            Write-Host "Starting DocFX in watch mode on port $Port..." -ForegroundColor Cyan
            Write-Host "Press Ctrl+C to stop" -ForegroundColor DarkGray
            Write-Host ""
            
            # Open browser if not disabled
            if (-not $NoOpen) {
                try {
                    $url = "http://localhost:$Port"
                    Write-Host "Opening browser to $url..." -ForegroundColor DarkGray
                    Start-Sleep -Seconds 2  # Give server a moment to start
                    Start-Process $url -ErrorAction SilentlyContinue
                    Write-Host ""
                }
                catch {
                    Write-Host "Could not automatically open browser. Please navigate to http://localhost:$Port manually." -ForegroundColor Yellow
                    Write-Host ""
                }
            }
            
            # This will block and watch for changes
            Start-Process docfx -ArgumentList $buildArgs -NoNewWindow -Wait
        }
        else {
            $output = docfx build 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-ColorOutput Red "[ERROR] Build failed"
                Write-Host $output
                exit 1
            }
            Write-ColorOutput Green "[OK] Documentation built successfully"
        }
    }
    catch {
        Write-ColorOutput Red "[ERROR] Build error: $_"
        exit 1
    }
    
    Write-Host ""
}

# Serve documentation (if not in watch mode, as watch includes serve)
if ($Serve -and -not $Watch) {
    Write-Host "Starting local documentation server..." -ForegroundColor Yellow
    Write-Host ""
    Write-ColorOutput Cyan "========================================="
    Write-ColorOutput Cyan "  Documentation available at:"
    Write-ColorOutput Green "  http://localhost:$Port"
    Write-ColorOutput Cyan "========================================="
    Write-Host ""
    Write-Host "Press Ctrl+C to stop the server" -ForegroundColor DarkGray
    Write-Host ""
    
    try {
        # Check if _site exists
        $sitePath = Join-Path $DocumentationPath "_site"
        if (-not (Test-Path $sitePath)) {
            Write-ColorOutput Red "[ERROR] Build output not found at _site/"
            Write-Host "Please build the documentation first" -ForegroundColor Yellow
            exit 1
        }
        
        # Get file count for info
        $fileCount = (Get-ChildItem -Path $sitePath -Recurse -File).Count
        Write-Host "Serving $fileCount files..." -ForegroundColor DarkGray
        Write-Host ""
        
        # Open browser if not disabled
        if (-not $NoOpen) {
            try {
                $url = "http://localhost:$Port"
                Write-Host "Opening browser to $url..." -ForegroundColor DarkGray
                Start-Process $url -ErrorAction SilentlyContinue
                Write-Host ""
            }
            catch {
                Write-Host "Could not automatically open browser. Please navigate to http://localhost:$Port manually." -ForegroundColor Yellow
                Write-Host ""
            }
        }
        
        # Serve the documentation
        docfx serve $sitePath -p $Port
    }
    catch {
        if ($_.Exception.Message -like "*Ctrl+C*" -or $_.Exception.Message -like "*terminated*") {
            Write-Host ""
            Write-ColorOutput Yellow "Server stopped by user"
        }
        else {
            Write-ColorOutput Red "[ERROR] Server error: $_"
            exit 1
        }
    }
}

# Return to original directory
Set-Location $PSScriptRoot

Write-Host ""
Write-ColorOutput Green "[OK] Documentation testing completed"
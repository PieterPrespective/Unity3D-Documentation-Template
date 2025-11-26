#Requires -Version 5.0
<#
.SYNOPSIS
    Automatically convert DrawIO diagrams to SVG and update markdown files
.DESCRIPTION
    This script searches for all .drawio files in the Documentation folder,
    exports them to SVG with size tracking via XML comments, and updates markdown files
    with image tags where special hidden tags are found.
    
    Features:
    - Tracks .drawio file size via XML comment in SVG files (e.g., <!-- DrawIO-Source-Size: 655 -->)
    - Automatically detects when .drawio files change and regenerates SVGs
    - Maintains clean filenames for easy linking (diagram.svg vs diagram_655b.svg)
    - Updates markdown files with correct image references
.EXAMPLE
    .\make-diagram-images.ps1
    Process all DrawIO diagrams and update markdown files
.EXAMPLE
    .\make-diagram-images.ps1 -Force
    Force regenerate all SVG files even if they exist
.EXAMPLE
    .\make-diagram-images.ps1 -MarkdownPath "articles\specific-file.md"
    Process only a specific markdown file
#>

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Force,
    
    [Parameter()]
    [string]$MarkdownPath = $null,
    
    [Parameter()]
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$DocumentationPath = Split-Path $PSScriptRoot -Parent
$DrawIOPath = Join-Path $DocumentationPath "images\drawio"
$SVGPath = Join-Path $DrawIOPath "svg"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   DrawIO Diagram SVG Generation Tool" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Ensure SVG directory exists
if (-not (Test-Path $SVGPath)) {
    New-Item -ItemType Directory -Path $SVGPath -Force | Out-Null
    Write-Host "  [CREATE] SVG directory created: $SVGPath" -ForegroundColor Green
}

# Function to check if SVG file is likely corrupted (1KB or less)
function Test-SVGCorrupted {
    param([string]$SVGFilePath)
    
    if (-not (Test-Path $SVGFilePath)) {
        return $false
    }
    
    $fileInfo = Get-Item $SVGFilePath
    # Consider files 1KB (1024 bytes) or less as potentially corrupted
    return ($fileInfo.Length -le 1024)
}

# Function to read DrawIO source size from SVG XML comment
function Get-DrawIOSizeFromSVG {
    param([string]$SVGFilePath)
    
    if (-not (Test-Path $SVGFilePath)) {
        return $null
    }
    
    try {
        # Read first few lines to find the comment (should be on second line after XML declaration)
        $firstLines = Get-Content -Path $SVGFilePath -TotalCount 10
        foreach ($line in $firstLines) {
            if ($line -match '<!--\s*DrawIO-Source-Size:\s*(\d+)\s*-->') {
                return [int]$matches[1]
            }
        }
    } catch {
        # If file can't be read or parsed, return null
    }
    return $null
}

# Function to add DrawIO source size comment to SVG file
function Add-DrawIOSizeToSVG {
    param(
        [string]$SVGFilePath,
        [int]$SourceSize
    )
    
    if (-not (Test-Path $SVGFilePath)) {
        return $false
    }
    
    try {
        $lines = Get-Content -Path $SVGFilePath
        $newLines = @()
        $sizeComment = "<!-- DrawIO-Source-Size: $SourceSize -->"
        $commentAdded = $false
        
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            $newLines += $line
            
            # Insert comment after XML declaration (if present) or after first line
            if (-not $commentAdded -and 
                ($line -match '^\s*<\?xml.*\?>\s*$' -or 
                 ($i -eq 0 -and -not ($line -match '^\s*<\?xml.*\?>\s*$')))) {
                $newLines += $sizeComment
                $commentAdded = $true
            }
        }
        
        # If no XML declaration was found and comment wasn't added, add it at the beginning
        if (-not $commentAdded) {
            $newLines = @($sizeComment) + $newLines
        }
        
        # Write back to file with UTF8 encoding
        $newLines -join "`n" | Out-File -FilePath $SVGFilePath -Encoding UTF8 -NoNewline
        return $true
    } catch {
        Write-Host "  [ERROR] Failed to add size comment to SVG: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to check if DrawIO desktop is available
function Test-DrawIODesktop {
    # Common DrawIO installation paths on Windows
    $possiblePaths = @(
        "C:\Program Files\draw.io\draw.io.exe",
        "C:\Program Files (x86)\draw.io\draw.io.exe",
        "$env:USERPROFILE\AppData\Local\Programs\draw.io\draw.io.exe"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $script:DrawIOPath = $path
            return $true
        }
    }
    
    # Try to find drawio command in PATH as fallback
    try {
        $drawioCommand = Get-Command drawio -ErrorAction SilentlyContinue
        if ($drawioCommand) {
            $script:DrawIOPath = "drawio"
            return $true
        }
    } catch {
        # Command not found
    }
    return $false
}

# Function to export DrawIO to SVG using desktop app
function Export-DrawIOToSVG {
    param(
        [string]$DrawIOFile,
        [string]$OutputFile
    )
    
    if (Test-DrawIODesktop) {
        Write-Host "  [EXPORT] Using DrawIO desktop to convert: $(Split-Path $DrawIOFile -Leaf)" -ForegroundColor Yellow
        try {
            & $script:DrawIOPath -x -f svg -o $OutputFile $DrawIOFile 2>&1 | Out-Null
            return $true
        } catch {
            Write-Host "  [ERROR] Failed to execute DrawIO: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "  [NOTE] Errors can occur if you have Draw.io desktop open in the background, please make sure the application is closed and retry generating diagram images" -ForegroundColor Yellow
            return $false
        }
    }
    return $false
}

# Function to create a simple SVG placeholder if DrawIO desktop is not available
function New-SVGPlaceholder {
    param(
        [string]$DrawIOFile,
        [string]$OutputFile,
        [string]$DiagramName,
        [int]$SourceSize
    )
    
    $svgContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<!-- DrawIO-Source-Size: $SourceSize -->
<svg xmlns="http://www.w3.org/2000/svg" width="600" height="400" viewBox="0 0 600 400">
  <rect width="600" height="400" fill="#f0f0f0" stroke="#cccccc" stroke-width="2"/>
  <text x="300" y="180" font-family="Arial, sans-serif" font-size="16" text-anchor="middle" fill="#666666">
    DrawIO Diagram: $DiagramName
  </text>
  <text x="300" y="210" font-family="Arial, sans-serif" font-size="12" text-anchor="middle" fill="#999999">
    Please export this diagram using DrawIO desktop or web app
  </text>
  <text x="300" y="240" font-family="Arial, sans-serif" font-size="10" text-anchor="middle" fill="#bbbbbb">
    Source: $(Split-Path $DrawIOFile -Leaf)
  </text>
</svg>
"@
    $svgContent | Out-File -FilePath $OutputFile -Encoding UTF8
}

# Step 1: Find all DrawIO files
Write-Host "Searching for DrawIO diagrams..." -ForegroundColor Yellow
$drawioFiles = Get-ChildItem -Path $DocumentationPath -Filter "*.drawio" -Recurse

if ($drawioFiles.Count -eq 0) {
    Write-Host "  [INFO] No .drawio files found in $DocumentationPath" -ForegroundColor DarkGray
} else {
    Write-Host "  [FOUND] $($drawioFiles.Count) DrawIO file(s)" -ForegroundColor Green
    
    # Process each DrawIO file
    foreach ($drawioFile in $drawioFiles) {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($drawioFile.Name)
        $drawioSize = $drawioFile.Length
        $svgFile = Join-Path $SVGPath "$baseName.svg"
        
        $needsRegeneration = $false
        
        if (Test-Path $svgFile) {
            # Check if SVG file is corrupted (1KB or less)
            if (Test-SVGCorrupted -SVGFilePath $svgFile) {
                $svgFileInfo = Get-Item $svgFile
                Write-Host "  [CORRUPTED] SVG file is only $($svgFileInfo.Length) bytes, forcing regeneration: $baseName.svg" -ForegroundColor Red
                if (-not $DryRun) {
                    Remove-Item -Path $svgFile -Force
                    Write-Host "  [REMOVE] Removed corrupted SVG file" -ForegroundColor DarkGray
                }
                $needsRegeneration = $true
            } else {
                # Check if existing SVG has the correct source size
                $existingSize = Get-DrawIOSizeFromSVG -SVGFilePath $svgFile
                
                if ($existingSize -eq $null) {
                    Write-Host "  [UPDATE] SVG exists but has no size comment: $baseName.svg" -ForegroundColor Yellow
                    $needsRegeneration = $true
                } elseif ($existingSize -ne $drawioSize) {
                    Write-Host "  [SIZE-CHANGED] DrawIO size changed from $existingSize to $drawioSize bytes: $baseName" -ForegroundColor Yellow
                    $needsRegeneration = $true
                } else {
                    Write-Host "  [SKIP] SVG up-to-date (${drawioSize}b): $baseName.svg" -ForegroundColor DarkGray
                }
            }
        } else {
            $needsRegeneration = $true
        }
        
        # Generate SVG if needed
        if ($needsRegeneration -or $Force) {
            if ($DryRun) {
                Write-Host "  [DRY-RUN] Would create: $baseName.svg" -ForegroundColor Cyan
            } else {
                # Try to export using DrawIO desktop
                $exported = Export-DrawIOToSVG -DrawIOFile $drawioFile.FullName -OutputFile $svgFile
                
                if ($exported) {
                    # Check if the generated SVG is corrupted (1KB or less)
                    if (Test-Path $svgFile) {
                        if (Test-SVGCorrupted -SVGFilePath $svgFile) {
                            $svgFileInfo = Get-Item $svgFile
                            Write-Host "  [ERROR] Generated SVG file is only $($svgFileInfo.Length) bytes (likely corrupted): $baseName.svg" -ForegroundColor Red
                            Write-Host "  [NOTE] Errors can occur if you have Draw.io desktop open in the background, please make sure the application is closed and retry generating diagram images" -ForegroundColor Yellow
                            Remove-Item -Path $svgFile -Force
                            Write-Host "  [REMOVE] Removed corrupted SVG file" -ForegroundColor DarkGray
                        } else {
                            # Add size comment to the exported SVG
                            $success = Add-DrawIOSizeToSVG -SVGFilePath $svgFile -SourceSize $drawioSize
                            if ($success) {
                                Write-Host "  [CREATE] SVG created with size comment (${drawioSize}b): $baseName.svg" -ForegroundColor Green
                            } else {
                                Write-Host "  [WARN] SVG created but failed to add size comment: $baseName.svg" -ForegroundColor Yellow
                            }
                        }
                    }
                } else {
                    # Create placeholder SVG if DrawIO desktop is not available
                    Write-Host "  [PLACEHOLDER] Creating placeholder SVG (${drawioSize}b): $baseName.svg" -ForegroundColor Yellow
                    New-SVGPlaceholder -DrawIOFile $drawioFile.FullName -OutputFile $svgFile -DiagramName $baseName -SourceSize $drawioSize
                }
                
                if (-not (Test-Path $svgFile)) {
                    Write-Host "  [ERROR] Failed to create SVG: $baseName.svg" -ForegroundColor Red
                    Write-Host "  [NOTE] Errors can occur if you have Draw.io desktop open in the background, please make sure the application is closed and retry generating diagram images" -ForegroundColor Yellow
                }
            }
        }
    }
}

Write-Host ""
Write-Host "Processing markdown files..." -ForegroundColor Yellow

# Step 2: Process markdown files
if ($MarkdownPath) {
    # Process specific markdown file
    $markdownFiles = Get-Item -Path (Join-Path $DocumentationPath $MarkdownPath) -ErrorAction SilentlyContinue
    if (-not $markdownFiles) {
        Write-Host "  [ERROR] Markdown file not found: $MarkdownPath" -ForegroundColor Red
        exit 1
    }
} else {
    # Process all markdown files
    $markdownFiles = Get-ChildItem -Path $DocumentationPath -Filter "*.md" -Recurse
}

Write-Host "  [FOUND] $($markdownFiles.Count) markdown file(s) to process" -ForegroundColor Green

# Hidden tag pattern: <!-- DRAWIO: filename.drawio -->
# More specific pattern to avoid matching examples in code blocks
$hiddenTagPattern = '^<!-- DRAWIO:\s*([^-]+?)\s*-->$'
$processedCount = 0
$updatedFiles = @()

foreach ($mdFile in $markdownFiles) {
    $content = Get-Content -Path $mdFile.FullName -Raw
    $originalContent = $content
    $modified = $false
    
    # Process line by line to find DRAWIO hidden tags at start of lines
    $lines = $content -split "`r?`n"
    $newLines = @()
    $skipNext = $false
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Check if this line is a DRAWIO hidden tag
        if ($line -match '^<!--\s*DRAWIO:\s*(.+?)\s*-->$') {
            $drawioFileName = $matches[1].Trim()
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($drawioFileName)
            
            # Calculate relative path from markdown file to SVG
            $mdDir = Split-Path $mdFile.FullName -Parent
            $svgFile = Join-Path $SVGPath "$baseName.svg"
            
            $newLines += $line
            
            if (Test-Path $svgFile) {
                # Calculate relative path (compatible with PowerShell 5.0)
                Push-Location $mdDir
                $relativePath = (Resolve-Path -Path $svgFile -Relative).Replace('\', '/')
                Pop-Location
                
                # Create the image tag
                $imageTag = "![Diagram: $baseName]($relativePath `"$baseName diagram`")"
                
                # Check if next line already has the image tag
                $nextLineHasImage = $false
                if ($i + 1 -lt $lines.Count) {
                    $nextLine = $lines[$i + 1]
                    if ($nextLine.Trim().StartsWith("![Diagram:")) {
                        $nextLineHasImage = $true
                        Write-Host "  [SKIP] Image tag already exists for $drawioFileName in $(Split-Path $mdFile.Name -Leaf)" -ForegroundColor DarkGray
                    }
                }
                
                if (-not $nextLineHasImage) {
                    # Insert the image tag after the hidden tag
                    $newLines += $imageTag
                    $modified = $true
                    Write-Host "  [INSERT] Added image tag for $drawioFileName in $(Split-Path $mdFile.Name -Leaf)" -ForegroundColor Green
                }
            } else {
                Write-Host "  [WARN] SVG not found for $drawioFileName referenced in $(Split-Path $mdFile.Name -Leaf)" -ForegroundColor Yellow
            }
        } else {
            $newLines += $line
        }
    }
    
    # Join the lines back together
    if ($modified) {
        $content = $newLines -join "`n"
    }
    
    # Write back the modified content
    if ($modified -and -not $DryRun) {
        $content | Out-File -FilePath $mdFile.FullName -Encoding UTF8 -NoNewline
        $updatedFiles += $mdFile.Name
        $processedCount++
    } elseif ($modified -and $DryRun) {
        Write-Host "  [DRY-RUN] Would update: $(Split-Path $mdFile.Name -Leaf)" -ForegroundColor Cyan
        $processedCount++
    }
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "           Process Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

if (-not $DryRun) {
    Write-Host "Summary:" -ForegroundColor Yellow
    Write-Host "  • DrawIO files found: $($drawioFiles.Count)" -ForegroundColor DarkGray
    Write-Host "  • SVG files in output: $((@(Get-ChildItem -Path $SVGPath -Filter '*.svg' -ErrorAction SilentlyContinue)).Count)" -ForegroundColor DarkGray
    Write-Host "  • Markdown files updated: $processedCount" -ForegroundColor DarkGray
    
    if ($updatedFiles.Count -gt 0) {
        Write-Host ""
        Write-Host "Updated files:" -ForegroundColor Yellow
        foreach ($file in $updatedFiles) {
            Write-Host "  • $file" -ForegroundColor DarkGray
        }
    }
} else {
    Write-Host "DRY RUN SUMMARY:" -ForegroundColor Cyan
    Write-Host "  • DrawIO files found: $($drawioFiles.Count)" -ForegroundColor DarkGray
    Write-Host "  • Markdown files that would be updated: $processedCount" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "Usage tips:" -ForegroundColor Yellow
Write-Host "  • Add <!-- DRAWIO: diagram-name.drawio --> to markdown files" -ForegroundColor DarkGray
Write-Host "  • Run this script to auto-generate SVG files and image tags" -ForegroundColor DarkGray
Write-Host "  • Source file size is tracked via XML comment in SVG files" -ForegroundColor DarkGray
Write-Host "  • SVG files are automatically regenerated when .drawio files change" -ForegroundColor DarkGray
Write-Host "  • Use -Force to regenerate all SVG files" -ForegroundColor DarkGray
Write-Host "  • Use -DryRun to preview changes without applying them" -ForegroundColor DarkGray
Write-Host ""

if (-not (Test-DrawIODesktop)) {
    Write-Host "NOTE: DrawIO desktop not found. Install for automatic SVG export:" -ForegroundColor Yellow
    Write-Host "  https://github.com/jgraph/drawio-desktop/releases" -ForegroundColor DarkGray
    Write-Host "  Or use the web app to manually export SVG files:" -ForegroundColor DarkGray
    Write-Host "  https://app.diagrams.net/" -ForegroundColor DarkGray
    Write-Host ""
}
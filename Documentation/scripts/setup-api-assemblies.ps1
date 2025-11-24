#Requires -Version 5.0
<#
.SYNOPSIS
    Automatically setup DocFX API documentation for Unity assemblies
.DESCRIPTION
    Reads assembly paths from includedAPIAssemblies.txt and:
    - Creates csc.rsp files for XML documentation generation
    - Updates docfx.json metadata configuration
    - Validates assembly setup
.PARAMETER ConfigFile
    Path to the assembly configuration file (default: includedAPIAssemblies.txt)
.PARAMETER Force
    Overwrite existing csc.rsp files
.PARAMETER ValidateOnly
    Only validate setup without making changes
.EXAMPLE
    .\setup-api-assemblies.ps1
    Setup assemblies from default config file
.EXAMPLE
    .\setup-api-assemblies.ps1 -Force
    Setup and overwrite existing csc.rsp files
#>

param(
    [string]$ConfigFile = "includedAPIAssemblies.txt",
    [switch]$Force = $false,
    [switch]$ValidateOnly = $false
)

# Script configuration
$ErrorActionPreference = "Stop"
$DocumentationPath = Split-Path $PSScriptRoot -Parent
$ProjectRoot = Split-Path $DocumentationPath -Parent

# Helper functions
function Write-ColorOutput($ForegroundColor, $Message) {
    Write-Host $Message -ForegroundColor $ForegroundColor
}

function Get-AssemblyNameFromPath($Path) {
    # Extract assembly name from path
    # E.g., "Assets/UTTP" -> "UTTP", "Assets/Scripts" -> "Assembly-CSharp"
    $folderName = Split-Path $Path -Leaf
    
    # Special case for main Scripts folder
    if ($Path -match "Assets[/\\]Scripts$") {
        return "Assembly-CSharp"
    }
    
    # Check if there's an .asmdef file
    $asmdefFiles = Get-ChildItem -Path "$ProjectRoot\$Path" -Filter "*.asmdef" -ErrorAction SilentlyContinue
    if ($asmdefFiles.Count -gt 0) {
        # Use the asmdef filename (without extension) as assembly name
        return [System.IO.Path]::GetFileNameWithoutExtension($asmdefFiles[0].Name)
    }
    
    # Default to folder name
    return $folderName
}

# Improved JSON formatting function
function Format-Json {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Json,
        [int]$IndentSize = 2
    )
    
    $indent = 0
    $lineStart = $true
    $inString = $false
    $escape = $false
    $result = ""
    $indentStr = " " * $IndentSize
    
    for ($i = 0; $i -lt $Json.Length; $i++) {
        $char = $Json[$i]
        $nextChar = if ($i + 1 -lt $Json.Length) { $Json[$i + 1] } else { $null }
        $prevChar = if ($i -gt 0) { $Json[$i - 1] } else { $null }
        
        # Handle escape characters
        if ($escape) {
            $result += $char
            $escape = $false
            continue
        }
        
        if ($char -eq '\' -and $inString) {
            $escape = $true
            $result += $char
            continue
        }
        
        # Handle strings
        if ($char -eq '"' -and -not $escape) {
            $inString = -not $inString
        }
        
        if ($inString) {
            $result += $char
            continue
        }
        
        # Handle whitespace outside strings
        if ($char -match '\s') {
            # Skip whitespace outside strings
            if (-not $lineStart) {
                # Keep single space before certain characters
                if ($nextChar -eq '"' -or $prevChar -eq ':') {
                    $result += ' '
                }
            }
            continue
        }
        
        $lineStart = $false
        
        # Handle structural characters
        switch ($char) {
            '{' {
                $result += $char
                if ($nextChar -ne '}') {
                    $indent++
                    $result += "`n" + ($indentStr * $indent)
                    $lineStart = $true
                }
            }
            '}' {
                if ($prevChar -ne '{') {
                    $indent--
                    $result += "`n" + ($indentStr * $indent)
                    $lineStart = $true
                }
                $result += $char
            }
            '[' {
                $result += $char
                if ($nextChar -ne ']') {
                    # Check if this is a simple array (all elements on one line)
                    $closeIndex = $Json.IndexOf(']', $i)
                    $arrayContent = if ($closeIndex -gt $i) { 
                        $Json.Substring($i + 1, $closeIndex - $i - 1) 
                    } else { 
                        "" 
                    }
                    
                    # If array contains objects or is long, format it multi-line
                    if ($arrayContent -match '[{}\[]' -or $arrayContent.Length -gt 60) {
                        $indent++
                        $result += "`n" + ($indentStr * $indent)
                        $lineStart = $true
                    }
                }
            }
            ']' {
                if ($prevChar -ne '[') {
                    # Check if we need to dedent
                    $openIndex = $result.LastIndexOf('[')
                    if ($openIndex -ge 0) {
                        $betweenBrackets = $result.Substring($openIndex + 1)
                        if ($betweenBrackets -match '`n') {
                            $indent--
                            $result += "`n" + ($indentStr * $indent)
                            $lineStart = $true
                        }
                    }
                }
                $result += $char
            }
            ',' {
                $result += $char
                # Check if we're in a multi-line context
                if ($result -match '[\{\[].*`n' -or $result.Length - $result.LastIndexOf("`n") -gt 80) {
                    $result += "`n" + ($indentStr * $indent)
                    $lineStart = $true
                } else {
                    $result += ' '
                }
            }
            ':' {
                $result += $char + ' '
            }
            default {
                $result += $char
            }
        }
    }
    
    return $result
}

Write-Host ""
Write-ColorOutput Cyan "========================================="
Write-ColorOutput Cyan "   Unity Assembly Documentation Setup"
Write-ColorOutput Cyan "========================================="
Write-Host ""

# Step 1: Read configuration file
$configPath = Join-Path $DocumentationPath $ConfigFile
if (-not (Test-Path $configPath)) {
    Write-ColorOutput Red "[ERROR] Configuration file not found: $ConfigFile"
    Write-Host ""
    Write-Host "Creating example configuration file..." -ForegroundColor Yellow
    
    # Create example config
    $exampleContent = @"
# Unity Assembly Paths for API Documentation
# One path per line, relative to project root
# Lines starting with # are comments

# Main Unity scripts
Assets/Scripts

# Custom assemblies (examples)
# Assets/UTTP
# Assets/Systems/PlayerSystem
# Assets/Modules/Networking
"@
    
    $exampleContent | Out-File -FilePath $configPath -Encoding UTF8
    Write-ColorOutput Green "[OK] Created example configuration at: $configPath"
    Write-Host "Edit this file and run the script again." -ForegroundColor Yellow
    exit 0
}

Write-Host "Reading configuration from: $ConfigFile" -ForegroundColor Cyan

# Parse assembly paths
$assemblyPaths = Get-Content $configPath | 
    Where-Object { $_ -and $_ -notmatch '^\s*#' } | 
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ }

if ($assemblyPaths.Count -eq 0) {
    Write-ColorOutput Red "[ERROR] No assembly paths found in configuration file"
    exit 1
}

Write-Host "Found $($assemblyPaths.Count) assembly path(s) to process" -ForegroundColor Green
Write-Host ""

# Step 2: Process each assembly
$assemblies = @()
$createdRspCount = 0
$skippedRspCount = 0
$missingPaths = @()

foreach ($relativePath in $assemblyPaths) {
    $fullPath = Join-Path $ProjectRoot $relativePath
    Write-Host "Processing: $relativePath" -ForegroundColor Yellow
    
    # Check if path exists
    if (-not (Test-Path $fullPath)) {
        Write-ColorOutput Red "  [MISSING] Path not found: $fullPath"
        $missingPaths += $relativePath
        Write-Host ""
        continue
    }
    
    # Get assembly name
    $assemblyName = Get-AssemblyNameFromPath $relativePath
    Write-Host "  Assembly name: $assemblyName" -ForegroundColor DarkGray
    
    # Store assembly info
    $assemblies += @{
        Name = $assemblyName
        Path = $relativePath
        FullPath = $fullPath
    }
    
    if (-not $ValidateOnly) {
        # Create/check csc.rsp file
        $rspPath = Join-Path $fullPath "csc.rsp"
        # XML files should be placed alongside DLLs in Library/ScriptAssemblies for docfx to find them
        $xmlOutputPath = "Library\ScriptAssemblies\$assemblyName.xml"
        
        if (Test-Path $rspPath) {
            if ($Force) {
                Write-Host "  [OVERWRITE] Updating existing csc.rsp" -ForegroundColor Yellow
                $createdRspCount++
            } else {
                Write-Host "  [EXISTS] csc.rsp already present" -ForegroundColor Green
                $skippedRspCount++
                Write-Host ""
                continue
            }
        } else {
            Write-Host "  [CREATE] Creating csc.rsp" -ForegroundColor Green
            $createdRspCount++
        }
        
        # Create csc.rsp content with Unity default error handling flags
        $rspContent = @"
-doc:$xmlOutputPath
-nowarn:1591
-warnaserror-
-warn:4
"@
        
        # Write csc.rsp file
        $rspContent | Out-File -FilePath $rspPath -Encoding UTF8 -NoNewline
        Write-Host "  [OK] Written csc.rsp with XML output to: Library\ScriptAssemblies\$assemblyName.xml" -ForegroundColor DarkGray
    }
    
    Write-Host ""
}

# Step 3: Update docfx.json
if (-not $ValidateOnly -and $assemblies.Count -gt 0) {
    Write-Host "Updating docfx.json..." -ForegroundColor Yellow
    
    $docfxPath = Join-Path $DocumentationPath "docfx.json"
    
    # Read existing docfx.json
    $docfxRaw = Get-Content $docfxPath -Raw
    $docfxContent = $docfxRaw | ConvertFrom-Json
    
    # Create DLL file list
    $dllFiles = @()
    foreach ($assembly in $assemblies) {
        $dllFiles += "$($assembly.Name).dll"
    }
    
    # Update metadata section
    if (-not $docfxContent.metadata) {
        $docfxContent | Add-Member -Type NoteProperty -Name "metadata" -Value @() -Force
    }
    
    # Create new metadata configuration
    $metadataConfig = @{
        src = @(
            @{
                src = "../Library/ScriptAssemblies"
                files = $dllFiles
            }
        )
        dest = "api"
        filter = "filterConfig.yml"
        disableGitFeatures = $false
        disableDefaultFilter = $false
    }
    
    # Replace or add metadata configuration
    $docfxContent.metadata = @($metadataConfig)
    
    # Ensure build section exists with required content
    if (-not $docfxContent.build) {
        $docfxContent | Add-Member -Type NoteProperty -Name "build" -Value @{} -Force
    }
    
    # Ensure content includes api files
    if (-not $docfxContent.build.content) {
        $docfxContent.build | Add-Member -Type NoteProperty -Name "content" -Value @() -Force
    }
    
    # Check if api content exists
    $hasApiContent = $false
    foreach ($content in $docfxContent.build.content) {
        if ($content.files -and ($content.files -contains "api/**.yml" -or $content.files -like "*api*")) {
            $hasApiContent = $true
            break
        }
    }
    
    if (-not $hasApiContent) {
        # Add API content configuration
        $apiContent = @{
            files = @("api/**.yml", "api/index.md")
        }
        $docfxContent.build.content = @($apiContent) + $docfxContent.build.content
    }
    
    # Convert to JSON and format properly
    $jsonString = $docfxContent | ConvertTo-Json -Depth 10 -Compress
    $formattedJson = Format-Json -Json $jsonString
    
    # Save with UTF8 encoding without BOM
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($docfxPath, $formattedJson, $utf8NoBom)
    
    Write-ColorOutput Green "[OK] Updated docfx.json with $($assemblies.Count) assemblies"
    Write-Host ""
}

# Step 4: Ensure Documentation/api directory exists
$apiPath = Join-Path $DocumentationPath "api"
if (-not (Test-Path $apiPath)) {
    if (-not $ValidateOnly) {
        New-Item -ItemType Directory -Path $apiPath | Out-Null
        Write-ColorOutput Green "[OK] Created api directory"
    } else {
        Write-ColorOutput Yellow "[MISSING] api directory does not exist"
    }
}

# Step 5: Create/update filterConfig.yml if it doesn't exist
$filterPath = Join-Path $DocumentationPath "filterConfig.yml"
if (-not (Test-Path $filterPath)) {
    if (-not $ValidateOnly) {
        Write-Host "Creating filterConfig.yml..." -ForegroundColor Yellow
        
        $filterContent = @"
apiRules:
- exclude:
    uidRegex: ^UnityEngine
    type: Namespace
- exclude:
    uidRegex: ^UnityEditor
    type: Namespace
- exclude:
    uidRegex: ^System
    type: Namespace
- exclude:
    uidRegex: ^TMPro
    type: Namespace
"@
        
        $filterContent | Out-File -FilePath $filterPath -Encoding UTF8
        Write-ColorOutput Green "[OK] Created filterConfig.yml"
    } else {
        Write-ColorOutput Yellow "[MISSING] filterConfig.yml does not exist"
    }
}

Write-Host ""

# Step 6: Summary and next steps
Write-ColorOutput Cyan "========================================="
Write-ColorOutput Cyan "                 Summary"
Write-ColorOutput Cyan "========================================="
Write-Host ""

if ($ValidateOnly) {
    Write-Host "Validation Results:" -ForegroundColor Yellow
    Write-Host "  Assemblies found: $($assemblies.Count)" -ForegroundColor Gray
    Write-Host "  Missing paths: $($missingPaths.Count)" -ForegroundColor $(if ($missingPaths.Count -gt 0) { "Red" } else { "Gray" })
} else {
    Write-Host "Setup Results:" -ForegroundColor Green
    Write-Host "  Assemblies configured: $($assemblies.Count)" -ForegroundColor Gray
    Write-Host "  csc.rsp files created: $createdRspCount" -ForegroundColor Gray
    Write-Host "  csc.rsp files skipped: $skippedRspCount" -ForegroundColor Gray
    Write-Host "  Missing paths: $($missingPaths.Count)" -ForegroundColor $(if ($missingPaths.Count -gt 0) { "Red" } else { "Gray" })
}

if ($missingPaths.Count -gt 0) {
    Write-Host ""
    Write-Host "Missing paths that need to be created:" -ForegroundColor Red
    foreach ($path in $missingPaths) {
        Write-Host "  - $path" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "Configured Assemblies:" -ForegroundColor Yellow
foreach ($assembly in $assemblies) {
    Write-Host "  - $($assembly.Name) ($($assembly.Path))" -ForegroundColor DarkGray
}

if (-not $ValidateOnly) {
    Write-Host ""
    Write-ColorOutput Cyan "========================================="
    Write-ColorOutput Cyan "              Next Steps"
    Write-ColorOutput Cyan "========================================="
    Write-Host ""
    Write-Host "1. Open Unity and trigger recompilation:" -ForegroundColor Yellow
    Write-Host "   - Right-click in Project window > Reimport All" -ForegroundColor DarkGray
    Write-Host "   - Or modify any script and save" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "2. Build documentation:" -ForegroundColor Yellow
    Write-Host "   cd Documentation\scripts" -ForegroundColor DarkGray
    Write-Host "   .\test-docs.ps1" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "3. To add more assemblies:" -ForegroundColor Yellow
    Write-Host "   - Edit: Documentation\$ConfigFile" -ForegroundColor DarkGray
    Write-Host "   - Run this script again" -ForegroundColor DarkGray
}

# Create companion validation script
if (-not $ValidateOnly) {
    $validateScriptPath = Join-Path $PSScriptRoot "validate-assemblies.ps1"
    if (-not (Test-Path $validateScriptPath)) {
        Write-Host ""
        Write-Host "Creating validation helper script..." -ForegroundColor Yellow
        
        $validateScript = @'
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
'@
        
        $validateScript | Out-File -FilePath $validateScriptPath -Encoding UTF8
        Write-ColorOutput Green "[OK] Created validate-assemblies.ps1"
    }
}
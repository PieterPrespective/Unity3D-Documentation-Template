# Getting Started with Documentation Generation

This guide covers the minimal requirements and setup needed to generate project documentation for the Unity project using DocFX.

## Prerequisites
- The following documentation assumes you're using a windows (10 or 11) operating system

### Required Software

1. **DocFX**
   - Version 2.59 or later
   - Used for generating static documentation websites
   - Converts markdown files and code comments to HTML

2. **PowerShell**
   - Windows PowerShell 5.1 or later
   - Required for running the automation scripts
   - Comes pre-installed on Windows

3. **.NET Framework/SDK**
   - .NET Framework 4.7.2 or later (usually pre-installed)
   - Required by DocFX for API documentation generation

## Quickstart

If you already have DocFX installed and just want to build and view the complete documentation:

### One-Command Solution

```powershell
# Navigate to the Documentation/scripts folder
cd "Documentation\scripts"

# Run everything: Setup API docs, generate diagrams, include coverage, build, and host
.\build-and-run-everything.ps1
```

This single command will:
1. Setup API documentation assemblies
2. Generate diagram images from Draw.io files
3. Include code coverage reports
4. Build the documentation with DocFX
5. Host the documentation locally and open your browser

### Quickstart Options

```powershell
# Skip preprocessing steps (faster if you've already run them)
.\build-and-run-everything.ps1 -SkipApi -SkipDiagrams -SkipCoverage

# Use a different port
.\build-and-run-everything.ps1 -Port 9000

# Don't open browser automatically
.\build-and-run-everything.ps1 -NoBrowser

# Continue even if a step fails
.\build-and-run-everything.ps1 -StopOnError:$false

# See all available options
.\build-and-run-everything.ps1 -Help
```

**Note:** The script will show progress for each step with timing information and provide a summary at the end.

## Installing DocFX
- (Optional) Windows 11 by default has powershell in its right-click folder context menu (i.e. when not mousing over a file); select 'Open in Terminal' to start powershell

### Method 1: Using .NET Tool (Recommended)
   - Opening powershell within the folder of a Unity3D project *should* allow you to run the dotnet tool directly from terminal
   - alternatively, open powershell from within your Unity3d project in visual studio (Tools/Command Line/Developer Powershell)
   
```powershell
# Install as a global .NET tool
dotnet tool install -g docfx
```


### Method 2: Using Chocolatey

```powershell
# Install Chocolatey if not already installed
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install DocFX
choco install docfx -y
```

### Method 2: Direct Download

1. Go to [DocFX Releases](https://github.com/dotnet/docfx/releases)
2. Download the latest `docfx.zip`
3. Extract to a folder (e.g., `C:\tools\docfx\`)
4. Add the DocFX folder to your system PATH



## Verifying Installation

Open PowerShell and run:

```powershell
docfx --version
```

You should see output similar to:
```
docfx 2.59.4.0
```

## Project Structure Overview

The documentation system is organized as follows:

```
Documentation/
├── docfx.json           # DocFX configuration file
├── toc.yml             # Main table of contents
├── index.md            # Homepage content
├── userdocs/           # User-facing documentation
├── tdd/                # Technical Design Documents
├── docsgen/            # Documentation generation guides
├── api/                # Auto-generated API documentation
├── codecoverage-web/   # Code coverage reports
├── images/             # Images and diagrams
└── scripts/            # Automation scripts
    ├── build-docs.ps1  # Build documentation
    ├── test-host-documentation.ps1   # Test documentation locally
    └── [other scripts] # Additional automation
```

## Building Documentation

### Using the Build Script

The project includes automation scripts for easy documentation management:

```powershell
# Navigate to the Documentation/scripts folder
cd "Documentation\scripts"

# Build the documentation
.\build-docs.ps1
```

**What build-docs.ps1 does:**
- Validates DocFX installation
- Runs `docfx metadata` to generate API metadata from assemblies
- Runs `docfx build` to generate the static website
- Places output in the `_site` directory

### Manual Build Process

If you prefer to build manually:

```powershell
# Navigate to Documentation folder
cd Documentation

# Generate API metadata (optional, for API docs)
docfx metadata

# Build the documentation website
docfx build

# The generated website will be in the _site folder
```

## Testing Documentation Locally

### Using the Test Script

```powershell
# Navigate to the Documentation/scripts folder
cd "Documentation\scripts"

# Start local test server
.\test-host-documentation.ps1
```
- Alternatively, Right click the 'test-host-documentation.ps1' file in explorer and select the option 'Run with Powershell'

**What test-host-documentation.ps1 does:**
- Builds the documentation (if needed)
- Starts a local web server on `http://localhost:8080`
- Automatically opens your default browser to the documentation

### Manual Testing

```powershell
# Navigate to Documentation folder
cd Documentation

# Build and serve the documentation
docfx serve _site

# Or combine build and serve in one command
docfx docfx.json --serve
```

The documentation will be available at `http://localhost:8080`

## Script Parameters

### build-docs.ps1 Options

```powershell
# Clean build (removes previous output)
.\build-docs.ps1 -Clean

# Build with verbose output
.\build-docs.ps1 -Verbose

# Build only metadata (API docs)
.\build-docs.ps1 -MetadataOnly

# Build without API metadata
.\build-docs.ps1 -NoMetadata
```

### test-host-documentation.ps1 Options

```powershell
# Clean build and serve
.\test-host-documentation.ps1 -Clean

# Use a different port
.\test-host-documentation.ps1 -Port 9000

# Skip API documentation generation (faster)
.\test-host-documentation.ps1 -SkipApi

# Don't automatically open browser
.\test-host-documentation.ps1 -NoOpen

# Enable watch mode (rebuild on file changes)
.\test-host-documentation.ps1 -Watch
```

## First Time Setup

After installing DocFX, follow these steps to set up documentation generation:

1. **Verify Installation**
   ```powershell
   docfx --version
   ```

2. **Navigate to Project**
   ```powershell
   cd "path\to\your\Unity\Project\Documentation"
   ```

3. **Initial Build**
   ```powershell
   .\scripts\build-docs.ps1
   ```

4. **Test Locally**
   ```powershell
   .\scripts\test-host-documentation.ps1
   ```

5. **Open Documentation**
   - Browser should open automatically to `http://localhost:8080`
   - If not, manually navigate to that URL

## Configuration Files

### docfx.json

The main configuration file that defines:
- The name of your website, Reference to Favicon & copyright notice
- Source files to include
- Output directory
- Templates and themes
- Global metadata
- Build settings

### toc.yml Files

Table of contents files that define navigation structure:
- `toc.yml` - Main navigation
- `userdocs/toc.yml` - User documentation navigation
- `tdd/toc.yml` - Technical documentation navigation
- `docsgen/toc.yml` - Documentation generation navigation

## Troubleshooting

### Common Issues

**DocFX command not found**
- Verify DocFX is installed correctly
- Check that DocFX is in your system PATH
- Restart PowerShell after installation

**Build fails with assembly errors**
- Ensure Unity project has been built recently
- Check that assemblies exist in `Library/ScriptAssemblies`
- Run `.\scripts\setup-api-assemblies.ps1` to refresh API documentation setup

**Website doesn't update**
- Clear browser cache
- Stop and restart the test server
- Check for build errors in the console output

**Permission errors**
- Run PowerShell as Administrator
- Check that the `_site` directory is writable
- Verify no antivirus software is blocking file operations

### Performance Tips

- Use `.\build-docs.ps1 -NoMetadata` for faster builds when only editing markdown
- Use `.\test-host-documentation.ps1 -SkipApi` for faster builds when only editing markdown
- Close unnecessary browser tabs when using hot reload
- Consider excluding large asset directories from file watching

## Next Steps

Once you have the basic documentation generation working:

1. **Add Content** - Start with [Adding Articles as Main Topic](adding-main-topic.md)
2. **Setup API Docs** - Follow [Setting up API Documentation](setup-api-docs.md)
3. **Add Diagrams** - Learn [Using Draw.io for Diagrams](drawio-integration.md)
4. **Include Coverage** - Set up [Code Coverage Reports](code-coverage-setup.md)

## Additional Resources

- [DocFX Official Documentation](https://dotnet.github.io/docfx/)
- [DocFX Getting Started Guide](https://dotnet.github.io/docfx/tutorial/docfx_getting_started.html)
- [Markdown Syntax Reference](https://www.markdownguide.org/basic-syntax/)
- [Unity Documentation Standards](https://docs.unity3d.com/Manual/documentation-standards.html)
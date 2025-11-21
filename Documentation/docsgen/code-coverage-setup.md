# Including Code Coverage Report

This guide explains how to install the Unity Code Coverage package, configure the target path to `Documentation/codecoverage`, and use the `include-codecoverage.ps1` script to integrate coverage reports into your documentation.

## Overview

Code coverage analysis shows which parts of your code are executed during testing. The Unity Code Coverage package generates detailed HTML reports that can be seamlessly integrated into your DocFX documentation website.

**Integration Workflow:**
1. Install Unity Code Coverage package
2. Configure coverage output to `Documentation/codecoverage`
3. Run tests with coverage enabled
4. Use integration script to add reports to documentation

## Installing Unity Code Coverage Package

### Using Package Manager UI

1. **Open Package Manager**
   - In Unity Editor: `Window → Package Manager`
   - Select "Unity Registry" from the dropdown

2. **Find Code Coverage Package**
   - Search for "Code Coverage"
   - Select "Code Coverage" by Unity Technologies

3. **Install Package**
   - Click "Install" button
   - Wait for installation to complete

### Using Package Manager Window

Alternative installation method:

1. **Open Package Manager Window**
   - `Window → Package Manager`
   - Click the "+" button in top-left corner
   - Select "Add package by name..."

2. **Add Package by Name**
   ```
   Package Name: com.unity.testtools.codecoverage
   ```
   - Click "Add"
   - Package will download and install automatically

### Using manifest.json (Advanced)

For version control and reproducible builds:

1. **Edit Packages/manifest.json**
   ```json
   {
     "dependencies": {
       "com.unity.testtools.codecoverage": "1.1.1",
       // ... other dependencies
     }
   }
   ```

2. **Refresh Package Manager**
   - Unity will automatically download the package
   - Or use `Assets → Reimport All`

### Verification

Confirm the package is installed:
- **Package Manager**: Code Coverage should appear in "In Project" section
- **Code Coverage Window**: `Window → Analysis → Code Coverage` should be available

## Configuring Code Coverage Settings

### Opening Code Coverage Window

1. **Access Code Coverage Window**
   - `Window → Analysis → Code Coverage`
   - Dock the window for easy access during development

2. **Window Interface Overview**
   - **Generate Report** section: Main controls
   - **Included Assemblies** section: What to analyze
   - **Settings** section: Advanced configuration

### Setting Target Path

Configure coverage output to integrate with documentation:

1. **Set Results Location**
   - In Code Coverage window
   - **Results Location** field: `Documentation/codecoverage`
   - This ensures reports are generated in the documentation folder

2. **Alternative: Manual Path Setup**
   ```
   Full Path Example:
   C:\YourProject\UMCPTester\Documentation\codecoverage
   
   Relative Path:
   Documentation/codecoverage
   ```

### Configuring Included Assemblies

**Assembly Selection:**
1. **Click "Included Assemblies" dropdown**
2. **Select assemblies to analyze:**
   - ✓ Assembly-CSharp (main project code)
   - ✓ UTTP (custom test utilities)
   - ✗ Unity.* assemblies (usually excluded)
   - ✗ Test assemblies (unless testing test code)

**Custom Assembly Configuration:**
```
Include:
- Your project assemblies
- Third-party assemblies you want to analyze

Exclude:
- Unity engine assemblies
- Editor-only assemblies
- Test assemblies (unless specifically needed)
```

### Advanced Settings

**Report Generation Options:**
- **Auto Generate Report**: Automatically generates after test runs
- **Include Test Assemblies**: Include test code in analysis (usually disabled)
- **Generate Combined Report**: Merge multiple test run results

**Filtering Options:**
- **Path Filtering**: Exclude specific file paths
- **Assembly Filtering**: Fine-tune assembly inclusion
- **Attribute Filtering**: Exclude code with specific attributes

## Running Tests with Coverage

### Using Code Coverage Window

1. **Enable Code Coverage**
   - Check "Enable Code Coverage" in the window
   - Select desired assemblies for analysis

2. **Run Tests**
   - Click "Clear Data" to start fresh
   - Open Test Runner: `Window → General → Test Runner`
   - Run EditMode or PlayMode tests as needed
   - Coverage data is collected automatically during test execution

3. **Generate Report**
   - Click "Generate Report" in Code Coverage window
   - Reports appear in `Documentation/codecoverage/Report/`

### Using Test Runner with Coverage

**Alternative Method:**
1. **Open Test Runner**
   - `Window → General → Test Runner`

2. **Enable Coverage in Settings**
   - Code Coverage window must be open
   - "Enable Code Coverage" must be checked

3. **Run Tests Normally**
   - Click "Run All" in Test Runner
   - Coverage data is collected automatically

### Command Line Test Execution

For automation and CI/CD integration:

```powershell
# Run tests with coverage from command line
Unity.exe -batchmode -quit -projectPath . -runTests -testPlatform EditMode -enableCodeCoverage

# Specify coverage results path
Unity.exe -batchmode -quit -projectPath . -runTests -testPlatform EditMode -enableCodeCoverage -coverageResultsPath "Documentation/codecoverage"
```

## Generated Report Structure

After running tests with coverage, you'll find:

```
Documentation/
└── codecoverage/
    ├── Report/                     # Main HTML reports
    │   ├── index.html             # Coverage summary
    │   ├── Assembly_CSharp_*.html # Per-class reports
    │   ├── UTTP_*.html           # Custom assembly reports
    │   ├── Summary.xml           # Machine-readable summary
    │   ├── Summary.json          # JSON summary data
    │   ├── badge_*.svg           # Coverage badges
    │   └── [CSS, JS, icons]      # Report assets
    └── [ProjectName]-opencov/     # Raw coverage data
        └── EditMode/
            ├── TestCoverageResults_*.xml
            └── [Coverage raw data]
```

## Using include-codecoverage.ps1 Script

### Basic Usage

The automation script integrates coverage reports into DocFX:

```powershell
# Navigate to scripts folder
cd "Documentation\scripts"

# Integrate coverage reports
.\include-codecoverage.ps1
```

### What the Script Does

1. **Validates Coverage Data**
   - Checks for `Documentation/codecoverage/Report/index.html`
   - Verifies coverage reports are available

2. **Copies Coverage Files**
   - Creates `Documentation/codecoverage-web/` directory
   - Copies all HTML, CSS, JS, and image files
   - Preserves report structure and functionality

3. **Updates DocFX Configuration**
   - Adds `codecoverage-web/**` to `docfx.json` resources
   - Ensures coverage files are included in build

4. **Creates Integration Page**
   - Generates `Documentation/codecoverage.md`
   - Embeds coverage reports via iframe
   - Extracts summary metrics automatically

5. **Updates Navigation**
   - Adds "Code Coverage" to main table of contents
   - Links to the integration page

### Script Parameters

```powershell
# Standard integration (default)
.\include-codecoverage.ps1

# Preview changes without applying them
.\include-codecoverage.ps1 -DryRun

# Force regeneration of integration files
.\include-codecoverage.ps1 -Force
```

### Example Output

The script creates an integration page like this:

```markdown
# Code Coverage Report

## Summary

- **Line Coverage:** 85.2% (245 of 287)
- **Method Coverage:** 92.1% (58 of 63)
- **Generated:** 11/21/2025 - 2:15:32 PM

## Coverage Reports

<iframe src="codecoverage-web/index.html" width="100%" height="800px">
Your browser does not support iframes. 
<a href="codecoverage-web/index.html">View the coverage report directly</a>.
</iframe>

## Direct Links

- [Full Coverage Report](codecoverage-web/index.html)
- [Summary Report](codecoverage-web/Summary.md)
```

## Complete Workflow Example

### Step-by-Step Integration

1. **Install and Configure**
   ```powershell
   # In Unity Editor:
   # 1. Install Code Coverage package via Package Manager
   # 2. Open Window → Analysis → Code Coverage
   # 3. Set Results Location: Documentation/codecoverage
   # 4. Select assemblies to analyze
   ```

2. **Run Tests with Coverage**
   ```powershell
   # In Unity Editor:
   # 1. Enable "Enable Code Coverage" in Code Coverage window
   # 2. Open Test Runner (Window → General → Test Runner)
   # 3. Click "Run All" for EditMode tests
   # 4. Click "Generate Report" in Code Coverage window
   ```

3. **Integrate into Documentation**
   ```powershell
   # In PowerShell:
   cd "Documentation\scripts"
   .\include-codecoverage.ps1
   ```

4. **Build and Test Documentation**
   ```powershell
   # Build documentation with coverage
   .\build-docs.ps1
   
   # Test locally
   .\test-docs.ps1
   
   # Navigate to http://localhost:8080
   # Click "Code Coverage" in navigation
   ```

## Automation and CI/CD Integration

### Automated Testing Script

Create a script that combines testing and coverage:

```powershell
# test-with-coverage.ps1
Write-Host "Starting Unity tests with code coverage..."

# Run Unity tests with coverage enabled
$unityArgs = @(
    "-batchmode",
    "-quit", 
    "-projectPath", ".",
    "-runTests",
    "-testPlatform", "EditMode",
    "-enableCodeCoverage",
    "-coverageResultsPath", "Documentation/codecoverage"
)

& "Unity.exe" $unityArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "Tests passed. Integrating coverage reports..."
    .\Documentation\scripts\include-codecoverage.ps1
    
    Write-Host "Building documentation..."
    .\Documentation\scripts\build-docs.ps1
    
    Write-Host "Code coverage integration complete!"
} else {
    Write-Error "Tests failed. Coverage integration skipped."
}
```

### Build Pipeline Integration

Add to your CI/CD pipeline:

```yaml
# Example GitHub Actions workflow
- name: Run Tests with Coverage
  run: |
    Unity.exe -batchmode -quit -projectPath . -runTests -testPlatform EditMode -enableCodeCoverage -coverageResultsPath "Documentation/codecoverage"
    
- name: Integrate Coverage Reports  
  run: |
    cd Documentation\scripts
    .\include-codecoverage.ps1
    
- name: Build Documentation
  run: |
    cd Documentation\scripts
    .\build-docs.ps1
```

## Advanced Configuration

### Custom Coverage Filtering

**Exclude specific code from coverage:**

```csharp
// Exclude entire classes
[System.Diagnostics.CodeAnalysis.ExcludeFromCodeCoverage]
public class DebugUtility 
{
    // This class won't appear in coverage reports
}

// Exclude specific methods
[System.Diagnostics.CodeAnalysis.ExcludeFromCodeCoverage]
public void DebugMethod()
{
    // This method won't appear in coverage reports
}
```

**Assembly-level exclusions:**

```csharp
// In AssemblyInfo.cs
[assembly: System.Diagnostics.CodeAnalysis.ExcludeFromCodeCoverage]
```

### Custom Report Templates

**Modify report appearance:**

1. **Locate Report Templates**
   - Package Manager → Code Coverage → Show in Explorer
   - Navigate to report template files

2. **Customize Templates**
   - Modify CSS for custom styling
   - Update HTML templates for branding
   - Add custom JavaScript for interactivity

### Multiple Coverage Configurations

**Different configurations for different scenarios:**

```json
// coverageconfig-full.json
{
  "includedAssemblies": ["Assembly-CSharp", "UTTP"],
  "pathFilters": [],
  "generateAdditionalReports": true
}

// coverageconfig-quick.json  
{
  "includedAssemblies": ["UTTP"],
  "pathFilters": ["-:Tests/*"],
  "generateAdditionalReports": false
}
```

## Troubleshooting

### Installation Issues

**Package Manager problems:**
- Ensure Unity version supports Code Coverage package
- Check internet connection for package download
- Try clearing Package Manager cache: `%APPDATA%\Unity\Asset Store-5.x\cache`

**Permission errors:**
- Run Unity as Administrator if needed
- Check write permissions to project directory
- Verify antivirus isn't blocking Unity processes

### Coverage Generation Issues

**No coverage data generated:**
- Verify "Enable Code Coverage" is checked
- Ensure tests actually run (check Test Runner)
- Check Unity Console for coverage-related errors
- Verify assemblies are selected for analysis

**Empty or incomplete reports:**
- Check that selected assemblies have public methods
- Verify tests exercise the code you expect to be covered
- Ensure assemblies are built and up-to-date

**Reports generated in wrong location:**
- Double-check "Results Location" setting
- Verify path exists and is writable
- Use absolute paths if relative paths fail

### Integration Script Issues

**Script execution failures:**
```powershell
# Check execution policy
Get-ExecutionPolicy

# Enable script execution if needed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run with verbose output
.\include-codecoverage.ps1 -Verbose
```

**Coverage reports not found:**
```powershell
# Verify reports exist
Test-Path "Documentation\codecoverage\Report\index.html"

# Check report directory contents
Get-ChildItem "Documentation\codecoverage\Report\"
```

**DocFX integration problems:**
- Ensure `docfx.json` is valid JSON after script modification
- Check that `codecoverage-web` directory is created
- Verify iframe content loads correctly in browser

### Performance Issues

**Slow test execution with coverage:**
- Coverage collection adds overhead to test execution
- Consider running coverage only on CI/CD, not during development
- Use assembly filtering to reduce analysis scope

**Large report sizes:**
- Exclude unnecessary assemblies from analysis
- Use path filtering to exclude test or example code
- Consider generating reports only for changed code

## Best Practices

### Development Workflow

**Regular Coverage Monitoring:**
- Run coverage weekly or before major releases
- Set coverage targets (e.g., 80% line coverage minimum)
- Focus on critical path coverage over overall percentage

**Test Strategy:**
- Write tests specifically to improve coverage of important code
- Don't chase 100% coverage at the expense of test quality
- Focus on meaningful test scenarios, not just line coverage

### Reporting and Communication

**Coverage Metrics:**
- Track coverage trends over time
- Include coverage in pull request reviews
- Use coverage badges in project documentation

**Team Awareness:**
- Share coverage reports with development team
- Include coverage discussion in code reviews
- Set up automated notifications for coverage changes

## Next Steps

- Learn about [Documentation Generation FAQ](faq.md) for troubleshooting coverage-specific issues
- Review [Getting Started](getting-started.md) for complete documentation workflow
- Explore [Setting up API Documentation](setup-api-docs.md) to combine coverage with API docs

## Additional Resources

- [Unity Code Coverage Package Documentation](https://docs.unity3d.com/Packages/com.unity.testtools.codecoverage@1.1/manual/index.html)
- [Code Coverage Best Practices](https://martinfowler.com/articles/coverage.html)
- [Unity Test Framework Documentation](https://docs.unity3d.com/Packages/com.unity.test-framework@latest/)
- [Continuous Integration with Unity](https://docs.unity3d.com/Manual/UnityCloudBuild.html)
# Setting up API Documentation

This guide explains how to add Unity assemblies to the API documentation using the `setup-api-assemblies.ps1` script and how to properly document code for inclusion in the generated documentation.

## Overview

API documentation is automatically generated from your Unity C# assemblies using DocFX. The system extracts XML documentation comments from your code and generates comprehensive API reference pages.

## Quick Start

### Using the Setup Script

The project includes an automation script to simplify API documentation setup:

```powershell
# Navigate to scripts folder
cd "Documentation\scripts"

# Run the setup script
.\setup-api-assemblies.ps1
```

**What the script does:**
1. Reads assembly paths from `includedAPIAssemblies.txt` configuration file
2. Creates `csc.rsp` files in each assembly folder for XML documentation generation
3. Updates `docfx.json` configuration with assembly references
4. Creates necessary filter and directory configurations
5. Provides validation and setup confirmation

### Configuration File Format

The `includedAPIAssemblies.txt` file defines which assemblies to include in documentation. It uses a simple text format:

```
# Unity Assembly Paths for API Documentation
# One path per line, relative to project root
# Lines starting with # are comments

# Main Unity scripts (maps to Assembly-CSharp.dll)
Assets/Scripts

# Custom assemblies with .asmdef files
Assets/UTTP
Assets/Systems/PlayerSystem
Assets/Modules/Networking

# Nested assemblies
Assets/Scripts/Core/Utilities
```

**Important Notes:**
- Paths are relative to the Unity project root
- One assembly path per line
- Comments start with `#`
- Empty lines are ignored
- The script will create this file with examples if it doesn't exist

### Manual Verification

After running the script, verify the setup:

```powershell
# Check included assemblies
Get-Content "Documentation\includedAPIAssemblies.txt"

# Verify csc.rsp files were created
Get-ChildItem -Path "Assets" -Filter "csc.rsp" -Recurse

# Check generated XML files after Unity recompilation
Get-ChildItem -Path "Documentation\api" -Filter "*.xml"

# Build API documentation
cd Documentation
docfx metadata
docfx build
```

## Understanding CSC Response Files

### What is a csc.rsp File?

A `csc.rsp` file is a **C# Compiler Response File** that contains command-line arguments for the C# compiler (`csc.exe`). Unity reads these files during compilation to apply additional compiler settings to your assemblies.

### How Unity Uses csc.rsp Files

When Unity compiles your scripts:

1. **Assembly-specific compilation**: Unity compiles each assembly definition (`.asmdef`) separately
2. **Response file discovery**: Unity automatically finds and reads any `csc.rsp` file in the same directory as the assembly
3. **Compiler argument injection**: Arguments from the `csc.rsp` file are passed to the C# compiler
4. **XML documentation generation**: With `-doc:` argument, the compiler generates XML documentation alongside the DLL

### The Generated csc.rsp Content

The script creates `csc.rsp` files with this content:

```
-doc:..\..\Documentation\api\{AssemblyName}.xml
-nowarn:1591
```

**Breaking down each line:**

- **`-doc:..\..\Documentation\api\{AssemblyName}.xml`**
  - Tells the compiler to generate XML documentation
  - Output path is relative to the assembly folder
  - `..\..\` navigates up from assembly folder to project root, then to `Documentation\api\`
  - File name matches the assembly name (e.g., `UTTP.xml` for `UTTP.asmdef`)

- **`-nowarn:1591`**
  - Suppresses compiler warning CS1591: "Missing XML comment for publicly visible type or member"
  - Prevents compilation warnings when not all public members have XML documentation

### Path Calculation Example

For an assembly at `Assets/UTTP/` (2 levels deep):
```
-doc:..\..\Documentation\api\UTTP.xml
```

For an assembly at `Assets/Scripts/Core/Systems/` (4 levels deep):
```
-doc:..\..\..\..\Documentation\api\Systems.xml
```

The script automatically calculates the correct number of `..` based on folder depth.

## Understanding the Script

### What setup-api-assemblies.ps1 Does

1. **Configuration Reading**
   - Reads assembly paths from `includedAPIAssemblies.txt`
   - Parses relative paths (e.g., `Assets/UTTP`, `Assets/Scripts`)
   - Validates that specified paths exist in the project

2. **CSC Response File Generation**
   - Creates `csc.rsp` files in each specified assembly folder
   - Configures XML documentation output path: `-doc:..\..\Documentation\api\{AssemblyName}.xml`
   - Suppresses XML documentation warnings: `-nowarn:1591`
   - Calculates proper relative paths based on assembly folder depth

3. **DocFX Configuration Update**
   - Modifies `docfx.json` to reference assemblies from `Library/ScriptAssemblies`
   - Updates the `metadata.src.files` array with DLL names
   - Preserves existing configuration while adding assembly references

4. **Supporting File Creation**
   - Creates `Documentation/api` directory if it doesn't exist
   - Generates `filterConfig.yml` with default API filtering rules
   - Creates validation helper script for ongoing maintenance

5. **Assembly Name Detection**
   - For folders with `.asmdef` files: uses the asmdef filename as assembly name
   - For `Assets/Scripts` folder: uses `Assembly-CSharp` (Unity's default)
   - For other folders: uses the folder name as assembly name

### Script Parameters

```powershell
# Use default configuration file (includedAPIAssemblies.txt)
.\setup-api-assemblies.ps1

# Use custom configuration file
.\setup-api-assemblies.ps1 -ConfigFile "MyAssemblies.txt"

# Overwrite existing csc.rsp files
.\setup-api-assemblies.ps1 -Force

# Validation only (don't make changes)
.\setup-api-assemblies.ps1 -ValidateOnly

# Show help information
.\setup-api-assemblies.ps1 -Help
```

## Code Documentation Guidelines

For your code to appear properly in the API documentation, follow these XML documentation standards:

- Practical note : when you've created a function - select the line before start of the function and press '/' key twice to automatically generate an empty summary

### Basic Class Documentation

```csharp
/// <summary>
/// Provides utilities for managing Unity test execution and state tracking.
/// This class handles test lifecycle events and integrates with the UMCP bridge.
/// </summary>
/// <remarks>
/// Use this class when you need to programmatically control test execution
/// or track test state changes in your Unity project.
/// </remarks>
public class SomeUtilityClass
{
    /// <summary>
    /// Gets or sets the current test execution mode.
    /// </summary>
    /// <value>
    /// A <see cref="TestMode"/> value indicating whether tests should run
    /// in EditMode, PlayMode, or both.
    /// </value>
    public TestMode Mode { get; set; }

    /// <summary>
    /// Executes tests with the specified configuration and returns results.
    /// </summary>
    /// <param name="config">The test configuration parameters.</param>
    /// <param name="timeout">Maximum time to wait for test completion.</param>
    /// <returns>
    /// A <see cref="TestResult"/> containing execution results and metrics.
    /// </returns>
    /// <exception cref="ArgumentNullException">
    /// Thrown when <paramref name="config"/> is null.
    /// </exception>
    /// <exception cref="TimeoutException">
    /// Thrown when test execution exceeds the specified <paramref name="timeout"/>.
    /// </exception>
    /// <example>
    /// <code>
    /// var config = new TestConfiguration 
    /// { 
    ///     Mode = TestMode.EditMode,
    ///     FilterExpression = "MyTests"
    /// };
    /// var result = await utility.ExecuteTestsAsync(config, TimeSpan.FromMinutes(5));
    /// Console.WriteLine($"Tests passed: {result.PassedCount}");
    /// </code>
    /// </example>
    public async Task<TestResult> ExecuteTestsAsync(TestConfiguration config, TimeSpan timeout)
    {
        // Implementation here...
    }
}
```

### Comprehensive Documentation Tags

#### Essential Tags

```csharp
/// <summary>
/// Brief description of what the member does.
/// </summary>
```

#### Parameter Documentation

```csharp
/// <param name="parameterName">Description of the parameter's purpose and constraints.</param>
```

#### Return Value Documentation

```csharp
/// <returns>
/// Description of what the method returns and under what conditions.
/// </returns>
```

#### Exception Documentation

```csharp
/// <exception cref="ExceptionType">
/// Circumstances under which this exception is thrown.
/// </exception>
```

#### Advanced Tags

```csharp
/// <remarks>
/// Additional detailed information about usage, implementation notes,
/// or important considerations.
/// </remarks>

/// <example>
/// <code>
/// // Example usage code here
/// var example = new MyClass();
/// example.DoSomething();
/// </code>
/// </example>

/// <seealso cref="RelatedClass"/>
/// <seealso cref="RelatedMethod"/>

/// <value>
/// Description of a property's value and its meaning.
/// </value>

/// <typeparam name="T">
/// Description of generic type parameter constraints and usage.
/// </typeparam>
```

### Complete Example

```csharp
using System;
using System.Threading.Tasks;

namespace UTTP
{
    /// <summary>
    /// Represents the configuration for Unity test execution.
    /// </summary>
    /// <remarks>
    /// This class encapsulates all parameters needed to run Unity tests
    /// through the UMCP bridge. It provides sensible defaults while
    /// allowing customization of test execution behavior.
    /// </remarks>
    public class TestConfiguration
    {
        /// <summary>
        /// Gets or sets the test execution mode.
        /// </summary>
        /// <value>
        /// A <see cref="TestMode"/> value. Default is <see cref="TestMode.All"/>.
        /// </value>
        public TestMode Mode { get; set; } = TestMode.All;

        /// <summary>
        /// Gets or sets the filter expression for selecting tests.
        /// </summary>
        /// <value>
        /// A string containing the test filter pattern. Use null or empty
        /// string to run all available tests.
        /// </value>
        /// <example>
        /// <code>
        /// // Run tests in a specific class
        /// config.FilterExpression = "MyTestClass";
        /// 
        /// // Run tests matching a pattern
        /// config.FilterExpression = "*Integration*";
        /// </code>
        /// </example>
        public string FilterExpression { get; set; }
    }

    /// <summary>
    /// Defines the modes in which Unity tests can be executed.
    /// </summary>
    public enum TestMode
    {
        /// <summary>
        /// Run tests in Unity's Edit Mode (outside of play mode).
        /// </summary>
        EditMode,

        /// <summary>
        /// Run tests in Unity's Play Mode (during play mode execution).
        /// </summary>
        PlayMode,

        /// <summary>
        /// Run both Edit Mode and Play Mode tests.
        /// </summary>
        All
    }

    /// <summary>
    /// Provides high-level utilities for Unity test management and execution.
    /// </summary>
    /// <remarks>
    /// This class serves as the primary interface for programmatic test
    /// execution within Unity projects. It integrates with Unity's test
    /// framework and the UMCP bridge to provide remote test capabilities.
    /// </remarks>
    public static class TestRunner
    {
        /// <summary>
        /// Executes Unity tests asynchronously with the specified configuration.
        /// </summary>
        /// <param name="config">
        /// The test configuration specifying which tests to run and how.
        /// </param>
        /// <param name="outputLogData">
        /// If true, includes detailed log output in the results.
        /// </param>
        /// <returns>
        /// A task that represents the asynchronous test execution operation.
        /// The task result contains the test execution results.
        /// </returns>
        /// <exception cref="ArgumentNullException">
        /// Thrown when <paramref name="config"/> is null.
        /// </exception>
        /// <exception cref="InvalidOperationException">
        /// Thrown when Unity is not in a valid state for test execution.
        /// </exception>
        /// <example>
        /// <code>
        /// var config = new TestConfiguration
        /// {
        ///     Mode = TestMode.EditMode,
        ///     FilterExpression = "UTTP.Tests"
        /// };
        /// 
        /// var results = await TestRunner.RunTestsAsync(config, outputLogData: true);
        /// 
        /// Console.WriteLine($"Passed: {results.PassedCount}");
        /// Console.WriteLine($"Failed: {results.FailedCount}");
        /// Console.WriteLine($"Total Time: {results.Duration}");
        /// </code>
        /// </example>
        /// <seealso cref="TestConfiguration"/>
        /// <seealso cref="TestResult"/>
        public static async Task<TestResult> RunTestsAsync(
            TestConfiguration config, 
            bool outputLogData = true)
        {
            if (config == null)
                throw new ArgumentNullException(nameof(config));

            // Implementation...
            await Task.Delay(1000); // Placeholder
            return new TestResult();
        }
    }
}
```

## Assembly Organization

### Project Structure

Organize your assemblies for clear API documentation:

```
Assets/
├── Scripts/
│   ├── Core/
│   │   ├── MyCore.asmdef
│   │   └── [core classes]
│   ├── Utilities/
│   │   ├── MyUtilities.asmdef
│   │   └── [utility classes]
│   └── Tests/
│       ├── MyTests.asmdef
│       └── [test classes]
```

### Assembly Definition Files

Create `.asmdef` files for logical groupings:

```json
{
    "name": "UTTP",
    "rootNamespace": "UTTP",
    "references": [],
    "includePlatforms": [],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": false,
    "precompiledReferences": [],
    "autoReferenced": true,
    "defineConstraints": [],
    "versionDefines": [],
    "noEngineReferences": false
}
```

## Configuration Files

### docfx.json Structure

The script modifies this configuration:

```json
{
  "metadata": [
    {
      "src": [
        {
          "src": "../Library/ScriptAssemblies",
          "files": [
            "Assembly-CSharp.dll",
            "UTTP.dll",
            "UTTP.xml"
          ]
        }
      ],
      "dest": "api",
      "filter": "filterConfig.yml",
      "disableGitFeatures": false,
      "disableDefaultFilter": false
    }
  ]
}
```

### Filter Configuration

Control what appears in documentation via `filterConfig.yml`:

```yaml
apiRules:
- include:
    uidRegex: ^UTTP
    type: Namespace
- include:
    uidRegex: ^UTTP\..*
    type: Type
- exclude:
    uidRegex: .*\.Internal\..*
    type: Type
- exclude:
    hasAttribute:
      uid: System.ObsoleteAttribute
    type: Type
```

## Troubleshooting

### Common Issues

**Assembly not appearing in documentation**
- Verify the assembly has an XML documentation file
- Check that Unity is generating XML documentation
- Ensure assembly is included in `docfx.json`

**Missing XML documentation**
- In Unity: Project Settings → Player → Configuration → Api Compatibility Level
- Build the project to regenerate assemblies
- Check for documentation warnings in Unity Console

**Empty API pages**
- Verify classes have public visibility
- Add XML documentation comments to members
- Check filter configuration isn't excluding content

**Build errors during metadata generation**
- Update Unity to a compatible version
- Check for assembly reference conflicts
- Verify DocFX version compatibility

### Script Troubleshooting

**Script execution errors**
```powershell
# Check execution policy
Get-ExecutionPolicy

# Set execution policy if needed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run with detailed error information
.\setup-api-assemblies.ps1 -Verbose -ErrorAction Stop
```

**Assembly discovery issues**
```powershell
# Manual assembly discovery
Get-ChildItem "..\Library\ScriptAssemblies" -Filter "*.dll" | 
    Where-Object { Test-Path ($_.FullName -replace '\.dll$', '.xml') }

# Check Unity project state
# Ensure project has been built recently
# Verify script assemblies directory exists
```

## Advanced Configuration

### Custom Assembly Filtering

Modify the script to include custom filtering logic:

```powershell
# In setup-api-assemblies.ps1, add custom filters
$customExcludes = @(
    "*Test*",
    "*Editor*",
    "Unity.*"
)

$assemblies = $assemblies | Where-Object { 
    $name = $_.BaseName
    -not ($customExcludes | Where-Object { $name -like $_ })
}
```

### Multiple Documentation Sets

Create separate documentation for different audiences:

```json
{
  "metadata": [
    {
      "src": [
        {
          "src": "../Library/ScriptAssemblies",
          "files": ["UTTP.dll", "UTTP.xml"]
        }
      ],
      "dest": "api/public",
      "filter": "publicOnly.yml"
    },
    {
      "src": [
        {
          "src": "../Library/ScriptAssemblies", 
          "files": ["*.dll", "*.xml"]
        }
      ],
      "dest": "api/internal",
      "filter": "includeInternal.yml"
    }
  ]
}
```

### Integration with Build Pipeline

Add API documentation to your build process:

```powershell
# In your build script
Write-Host "Setting up API documentation..."
.\Documentation\scripts\setup-api-assemblies.ps1

# Trigger Unity recompilation to generate XML files
Write-Host "Please recompile in Unity to generate XML documentation..."

Write-Host "Building documentation..."
cd Documentation
docfx metadata
docfx build

Write-Host "API documentation ready in _site/api/"
```

## Best Practices

### Documentation Quality

**Comprehensive Coverage**
- Document all public APIs
- Include usage examples for complex methods
- Explain parameter constraints and return conditions
- Document exceptions that can be thrown

**Clear Writing**
- Use active voice and present tense
- Be specific about behavior and constraints
- Include practical examples
- Cross-reference related functionality

**Consistent Style**
- Follow established XML documentation conventions
- Use consistent terminology across the codebase
- Maintain parallel structure in similar documentation
- Keep examples current and working

### Maintenance

**Regular Updates**
- Run setup script after adding new assemblies
- Update documentation when APIs change
- Review generated documentation for completeness
- Validate examples still work

**Quality Assurance**
- Test code examples in documentation
- Verify all links resolve correctly
- Check that filtered content appears as expected
- Ensure documentation builds without warnings

## Next Steps

- Learn [Using Draw.io for Diagrams](drawio-integration.md) to enhance API documentation with visuals
- Review [Including Code Coverage Report](code-coverage-setup.md) to add test coverage information
- Check the [Documentation Generation FAQ](faq.md) for troubleshooting common API documentation issues
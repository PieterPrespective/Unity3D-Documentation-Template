# Documentation Generation FAQ

This FAQ covers common issues and solutions for documentation generation tooling, including DocFX, Draw.io integration, API documentation, and code coverage setup.

## DocFX Installation and Setup

### Q: DocFX command not found after installation
**A:** This typically indicates a PATH issue.

**Solutions:**
1. **Verify Installation**
   ```powershell
   # Check if DocFX exists
   Test-Path "C:\tools\docfx\docfx.exe"
   ```

2. **Add to PATH Manually**
   ```powershell
   # Add DocFX to PATH for current session
   $env:PATH += ";C:\tools\docfx"
   
   # Permanent addition (requires admin)
   [Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";C:\tools\docfx", "Machine")
   ```

3. **Alternative: Use Full Path**
   ```powershell
   # Use full path instead of relying on PATH
   & "C:\tools\docfx\docfx.exe" build
   ```

### Q: PowerShell execution policy prevents script execution
**A:** Windows restricts script execution by default.

**Solution:**
```powershell
# Check current policy
Get-ExecutionPolicy

# Allow script execution for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Alternative: Bypass for single script
PowerShell -ExecutionPolicy Bypass -File .\build-docs.ps1
```

### Q: DocFX build fails with assembly reference errors
**A:** Usually caused by missing or outdated Unity assemblies.

**Solutions:**
1. **Rebuild Unity Project**
   - Open Unity Editor
   - Build → Build Settings → Build (or just compile scripts)
   - Verify `Library/ScriptAssemblies` contains recent DLL files

2. **Update API Configuration**
   ```powershell
   cd Documentation\scripts
   .\setup-api-assemblies.ps1 -Force
   ```

3. **Check Assembly Dependencies**
   ```powershell
   # Verify assemblies exist
   Get-ChildItem "..\Library\ScriptAssemblies" -Filter "*.dll"
   ```

### Q: Documentation builds but appears empty or incomplete
**A:** Usually a configuration or content issue.

**Solutions:**
1. **Check docfx.json Configuration**
   ```json
   // Ensure file patterns include your content
   "files": [
     "tdd/**.md",
     "userdocs/**.md", 
     "docsgen/**.md",
     "toc.yml",
     "*.md"
   ]
   ```

2. **Verify TOC Files**
   ```powershell
   # Check all toc.yml files exist and are valid
   Get-ChildItem -Recurse -Filter "toc.yml" | ForEach-Object { 
     Write-Host $_.FullName
     Get-Content $_.FullName 
   }
   ```

3. **Clean Build**
   ```powershell
   # Remove previous build output
   Remove-Item "_site" -Recurse -Force -ErrorAction SilentlyContinue
   .\build-docs.ps1
   ```

## Draw.io Integration Issues

### Q: make-diagram-images.ps1 says "DrawIO desktop not found"
**A:** The script can't locate the Draw.io executable.

**Solutions:**
1. **Verify Installation**
   ```powershell
   # Check standard installation paths
   Test-Path "C:\Program Files\draw.io\draw.io.exe"
   Test-Path "$env:USERPROFILE\AppData\Local\Programs\draw.io\draw.io.exe"
   ```

2. **Reinstall Draw.io Desktop**
   - Download from [GitHub Releases](https://github.com/jgraph/drawio-desktop/releases)
   - Use installer (not portable version)
   - Choose "Install for all users" option

3. **Manual Path Configuration**
   Edit the script to specify the correct path:
   ```powershell
   # In make-diagram-images.ps1, modify the path check
   $drawioPath = "C:\Your\Custom\Path\draw.io.exe"
   ```

### Q: SVG files are generated but appear as placeholders
**A:** Draw.io export failed but script created placeholder files.

**Solutions:**
1. **Test Draw.io Command Line**
   ```powershell
   # Test manual export
   & "C:\Program Files\draw.io\draw.io.exe" --help
   & "C:\Program Files\draw.io\draw.io.exe" -x -f svg -o test.svg your-diagram.drawio
   ```

2. **Check File Permissions**
   ```powershell
   # Verify write permissions to SVG directory
   Test-Path "Documentation\images\drawio\svg" -PathType Container
   ```

3. **Manual Export Workaround**
   - Open diagram in Draw.io desktop
   - File → Export as → SVG
   - Save to `Documentation/images/drawio/svg/`
   - Re-run the script to update markdown files

### Q: Diagrams appear in documentation but are too large/small
**A:** SVG scaling issues in the web browser.

**Solutions:**
1. **Optimize Diagram Size in Draw.io**
   - Use consistent canvas sizes
   - Design for web viewing (not print)
   - Test at different zoom levels

2. **Add CSS Styling**
   ```markdown
   ![Diagram](path/to/diagram.svg){style="max-width: 100%; height: auto;"}
   ```

3. **Use PNG as Alternative**
   - Export diagrams as PNG at appropriate resolution
   - Place in `Documentation/images/drawio/png/`
   - Update markdown files manually if needed

### Q: Hidden tags don't work - diagrams not inserted
**A:** Usually syntax or path issues with the hidden tags.

**Solutions:**
1. **Check Tag Syntax**
   ```markdown
   <!-- Correct -->
   <!-- DRAWIO: my-diagram.drawio -->
   
   <!-- Incorrect - missing space after DRAWIO -->
   <!--DRAWIO: my-diagram.drawio -->
   
   <!-- Incorrect - extra spaces -->
   <!-- DRAWIO : my-diagram.drawio -->
   ```

2. **Verify File Paths**
   ```powershell
   # Check that referenced files exist
   Get-ChildItem "Documentation\images\drawio" -Filter "*.drawio"
   ```

3. **Run with Verbose Output**
   ```powershell
   .\make-diagram-images.ps1 -Verbose
   ```

## API Documentation Issues

### Q: setup-api-assemblies.ps1 finds no assemblies
**A:** Unity hasn't built the project or assemblies are in unexpected location.

**Solutions:**
1. **Build Unity Project**
   - Open Unity Editor
   - Let it compile scripts (wait for spinning icon to stop)
   - Or manually build: Build Settings → Build

2. **Check Assembly Location**
   ```powershell
   # Verify assemblies exist
   Get-ChildItem "..\Library\ScriptAssemblies"
   ```

3. **Force Assembly Refresh**
   - Unity Editor: Assets → Refresh
   - Or delete `Library` folder and reopen project (slow but thorough)

### Q: API documentation is generated but empty pages
**A:** Assemblies lack XML documentation or have no public APIs.

**Solutions:**
1. **Enable XML Documentation**
   - Unity: Player Settings → Configuration → Script Compilation
   - Or add XML doc comments to your code:
   ```csharp
   /// <summary>
   /// This method does something useful.
   /// </summary>
   public void MyMethod() { }
   ```

2. **Check Assembly Visibility**
   ```csharp
   // Ensure classes are public
   public class MyClass  // ✓ Will appear in docs
   {
       internal void Method() { } // ✗ Won't appear
       public void PublicMethod() { } // ✓ Will appear
   }
   ```

3. **Review Filter Configuration**
   Check `filterConfig.yml` isn't excluding your content:
   ```yaml
   apiRules:
   - include:
       uidRegex: ^YourNamespace
   ```

### Q: XML documentation comments don't appear in API docs
**A:** Unity may not be generating XML files or files are malformed.

**Solutions:**
1. **Force XML Generation**
   ```powershell
   # Check if XML files exist alongside DLLs
   Get-ChildItem "..\Library\ScriptAssemblies" -Filter "*.xml"
   ```

2. **Unity Settings**
   - Unity 2021.3+: Edit → Project Settings → Editor → Script Compilation
   - Enable "Additional Compiler Arguments"
   - Add: `-doc:$(ProjectDir)\Library\ScriptAssemblies\$(AssemblyName).xml`

3. **Validate XML Syntax**
   ```csharp
   // Correct XML documentation
   /// <summary>
   /// Valid documentation comment.
   /// </summary>
   
   // Incorrect - no summary tags
   /// This won't work properly
   ```

## Code Coverage Issues

### Q: Unity Code Coverage package not available in Package Manager
**A:** Package may not be visible or Unity version incompatibility.

**Solutions:**
1. **Check Unity Version**
   - Code Coverage requires Unity 2019.3+
   - Update Unity if needed

2. **Enable Preview Packages**
   - Package Manager → Advanced → Show Preview Packages
   - Or add to manifest.json directly:
   ```json
   {
     "dependencies": {
       "com.unity.testtools.codecoverage": "1.1.1"
     }
   }
   ```

3. **Manual Package Addition**
   ```powershell
   # Add via Package Manager CLI
   cd YourProjectRoot
   unity-package-manager add com.unity.testtools.codecoverage
   ```

### Q: Code Coverage window shows "No data available"
**A:** Coverage hasn't been run or data wasn't collected properly.

**Solutions:**
1. **Verify Coverage is Enabled**
   - Code Coverage window: ✓ "Enable Code Coverage"
   - Run tests from Test Runner while coverage is enabled

2. **Check Assembly Selection**
   - Code Coverage window → "Included Assemblies"
   - Ensure your project assemblies are selected
   - Uncheck Unity engine assemblies (they won't have coverage anyway)

3. **Run Tests Properly**
   ```powershell
   # Ensure tests actually run
   # Open Test Runner → Run All
   # Check Unity Console for test results
   ```

### Q: Coverage reports generated but integration script fails
**A:** Missing reports or permission issues.

**Solutions:**
1. **Verify Report Location**
   ```powershell
   # Check reports exist
   Test-Path "Documentation\codecoverage\Report\index.html"
   Get-ChildItem "Documentation\codecoverage\Report"
   ```

2. **Check Permissions**
   ```powershell
   # Test write permissions
   New-Item -ItemType File -Path "Documentation\codecoverage-web\test.txt" -Force
   Remove-Item "Documentation\codecoverage-web\test.txt"
   ```

3. **Manual Integration**
   ```powershell
   # Copy files manually if script fails
   Copy-Item "Documentation\codecoverage\Report\*" "Documentation\codecoverage-web\" -Recurse
   ```

### Q: Code coverage reports show 0% coverage despite running tests
**A:** Tests may not be exercising the code or assemblies aren't configured properly.

**Solutions:**
1. **Verify Tests Exercise Code**
   ```csharp
   [Test]
   public void TestMyMethod()
   {
       var obj = new MyClass();
       obj.MyMethod(); // This should show up in coverage
       Assert.IsTrue(true);
   }
   ```

2. **Check Assembly Configuration**
   - Only assemblies selected in Code Coverage window are analyzed
   - Test assemblies themselves usually aren't analyzed (that's expected)

3. **Debug Coverage Collection**
   ```powershell
   # Enable verbose logging in Unity
   # Window → Console → Clear → Run tests → Check for coverage-related messages
   ```

## Build and CI/CD Issues

### Q: Documentation builds locally but fails in CI/CD
**A:** Environment differences between local and CI systems.

**Solutions:**
1. **Check DocFX Installation in CI**
   ```yaml
   # In CI config, ensure DocFX is available
   - name: Install DocFX
     run: choco install docfx -y
   ```

2. **Use Absolute Paths**
   ```powershell
   # Avoid relative paths in CI
   $docRoot = $env:GITHUB_WORKSPACE + "\Documentation"
   & docfx "$docRoot\docfx.json"
   ```

3. **Handle File Encoding**
   ```powershell
   # Ensure files are UTF-8
   Get-ChildItem -Recurse -Filter "*.md" | ForEach-Object {
     $content = Get-Content $_.FullName -Raw
     $content | Out-File $_.FullName -Encoding UTF8 -NoNewline
   }
   ```

### Q: Scripts work locally but fail with "Access Denied" in CI
**A:** Permission issues in CI environment.

**Solutions:**
1. **Use CI-Specific Paths**
   ```powershell
   # Use CI workspace variables
   $workspacePath = $env:GITHUB_WORKSPACE ?? $PWD
   ```

2. **Set Proper Permissions**
   ```yaml
   # In CI config
   - name: Set Permissions
     run: icacls Documentation /grant "Everyone:(OI)(CI)F"
   ```

## Performance and Optimization

### Q: Documentation build is very slow
**A:** Large files, complex processing, or inefficient configuration.

**Solutions:**
1. **Optimize Image Sizes**
   ```powershell
   # Check for large images
   Get-ChildItem "Documentation\images" -Recurse | 
       Where-Object { $_.Length -gt 1MB } | 
       Select-Object Name, @{Name="SizeMB";Expression={[math]::Round($_.Length/1MB,2)}}
   ```

2. **Exclude Unnecessary Files**
   ```json
   // In docfx.json, add excludes
   "build": {
     "content": [{
       "files": ["**/*.md"],
       "exclude": ["**/node_modules/**", "**/temp/**"]
     }]
   }
   ```

3. **Use Incremental Builds**
   ```powershell
   # Build only changed content
   docfx build --serve --incremental
   ```

### Q: Local test server is slow or unresponsive
**A:** Resource issues or file watching conflicts.

**Solutions:**
1. **Disable File Watching**
   ```powershell
   # Serve without file watching
   docfx serve _site --port 8080
   ```

2. **Close Unnecessary Applications**
   - Close Visual Studio/editors while testing docs
   - Stop other local servers
   - Free up system resources

3. **Use Production Build**
   ```powershell
   # Build for production (faster serving)
   docfx build --config Release
   docfx serve _site
   ```

## Integration and Workflow Issues

### Q: Multiple documentation tools conflict with each other
**A:** Scripts or tools interfering with each other's output.

**Solutions:**
1. **Run Scripts in Sequence**
   ```powershell
   # Proper workflow order
   .\setup-api-assemblies.ps1
   .\make-diagram-images.ps1
   .\include-codecoverage.ps1
   .\build-docs.ps1
   ```

2. **Use Clean Builds**
   ```powershell
   # Clean between tool runs
   Remove-Item "_site" -Recurse -Force -ErrorAction SilentlyContinue
   ```

3. **Check for File Locks**
   ```powershell
   # Restart if files seem locked
   # Close Unity Editor, Visual Studio, etc.
   # Run tools individually to identify conflicts
   ```

### Q: Documentation changes don't appear after rebuilding
**A:** Browser caching or incomplete builds.

**Solutions:**
1. **Clear Browser Cache**
   - Hard refresh: Ctrl+Shift+R (Chrome/Firefox)
   - Or clear cache manually
   - Try incognito/private browsing mode

2. **Force Complete Rebuild**
   ```powershell
   Remove-Item "_site" -Recurse -Force -ErrorAction SilentlyContinue
   Remove-Item "api" -Recurse -Force -ErrorAction SilentlyContinue
   .\build-docs.ps1
   ```

3. **Check File Timestamps**
   ```powershell
   # Verify source files are newer than output
   Get-ChildItem "*.md" | Select-Object Name, LastWriteTime
   ```

## Getting Additional Help

### Diagnostic Information Collection

When reporting issues, collect this information:

```powershell
# System Information
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Host "OS: $([System.Environment]::OSVersion)"

# DocFX Information
docfx --version

# Unity Information
Write-Host "Unity Version: [Check Unity Editor About dialog]"

# File System Check
Test-Path "Documentation\docfx.json"
Test-Path "Documentation\_site"
Get-ChildItem "Documentation" | Select-Object Name, LastWriteTime
```

### Useful Resources

- [DocFX Official Documentation](https://dotnet.github.io/docfx/)
- [Unity Code Coverage Package Docs](https://docs.unity3d.com/Packages/com.unity.testtools.codecoverage@latest/)
- [Draw.io Desktop GitHub Issues](https://github.com/jgraph/drawio-desktop/issues)
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)

### Project-Specific Support

For issues specific to this Unity project:
1. Check the Unity Console for relevant error messages
2. Verify all prerequisites from [Getting Started](getting-started.md) are met
3. Try the complete workflow from scratch on a clean environment
4. Review recent changes to configuration files (`docfx.json`, `toc.yml`)

### Community Resources

- Unity Forums - Documentation section
- Stack Overflow - Tag questions with `docfx`, `unity3d`, `draw.io`
- GitHub Issues for specific tools
- Unity Discord - Documentation channels
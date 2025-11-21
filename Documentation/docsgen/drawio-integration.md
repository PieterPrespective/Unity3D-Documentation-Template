# Using Draw.io for Diagrams in Articles

This guide explains how to install Draw.io desktop, organize diagram files, use hidden tags in markdown files, and automatically convert diagrams to SVG using the `make-diagram-images.ps1` script.

## Overview

The project includes an automated workflow for integrating Draw.io diagrams into documentation. The system allows you to create diagrams visually and automatically converts them to web-friendly formats with minimal manual work.

**Workflow Summary:**
1. Create diagrams in Draw.io (desktop or web)
2. Save `.drawio` files in the designated folder
3. Add hidden tags to markdown files
4. Run conversion script to generate SVG files and update documentation

## Installing Draw.io Desktop

### Download and Installation

1. **Visit the Draw.io Releases Page**
   - Go to [https://github.com/jgraph/drawio-desktop/releases](https://github.com/jgraph/drawio-desktop/releases)
   - Download the latest release for Windows

2. **Install Draw.io Desktop**
   ```powershell
   # Option 1: Download and run installer manually
   # Download draw.io-x.x.x-windows-installer.exe
   
   # Option 2: Install via Chocolatey
   choco install drawio -y
   
   # Option 3: Install via Winget
   winget install JGraph.Draw.io
   ```

3. **Verify Installation**
   - Launch Draw.io from Start Menu
   - Or verify command line access:
   ```powershell
   # Check if Draw.io is accessible
   & "C:\Program Files\draw.io\draw.io.exe" --version
   ```

### Alternative: Web Version

If you prefer not to install desktop software:
- Use [app.diagrams.net](https://app.diagrams.net) (the web version)
- Manually export diagrams as SVG files
- Place SVG files in `Documentation/images/drawio/svg/`

## Organizing Diagram Files

### Directory Structure

Place all Draw.io files in the designated directory:

```
Documentation/
└── images/
    └── drawio/
        ├── my-diagram.drawio           # Source files
        ├── system-architecture.drawio  # More source files
        ├── workflow-diagram.drawio     # Additional diagrams
        └── svg/                        # Auto-generated SVG exports
            ├── my-diagram.svg
            ├── system-architecture.svg
            └── workflow-diagram.svg
```

### File Naming Conventions

Use descriptive, kebab-case names:

```
✓ Good Examples:
  - unity-game-flow.drawio
  - user-authentication-process.drawio
  - system-architecture-overview.drawio
  - test-execution-workflow.drawio

✗ Bad Examples:
  - diagram1.drawio
  - Untitled.drawio
  - MyDiagram.drawio
  - flow_chart.drawio
```

### Creating Your First Diagram

1. **Open Draw.io Desktop**
   - Choose "Create New Diagram"
   - Select appropriate template or start blank

2. **Design Your Diagram**
   - Use consistent colors and shapes
   - Include clear labels and text
   - Consider readability at different zoom levels

3. **Save in Correct Location**
   ```
   File → Save As → Navigate to:
   Documentation/images/drawio/your-diagram-name.drawio
   ```

## Using Hidden Tags in Markdown

### Basic Hidden Tag Syntax

Add hidden tags to your markdown files where you want diagrams to appear:

```markdown
# System Architecture

This section explains our system architecture.

<!-- DRAWIO: system-architecture.drawio -->

The architecture follows a layered approach with clear separation of concerns.
```

**Important:**
- Hidden tags must be on their own line
- Use exact filename including `.drawio` extension
- Tags are case-sensitive
- No extra spaces around the colon

### Multiple Diagrams in One Article

```markdown
# Unity Game Development Workflow

## Game Initialization Flow

The following diagram shows how Unity initializes game systems:

<!-- DRAWIO: unity-initialization-flow.drawio -->

## Data Processing Pipeline

Our data processing follows this pattern:

<!-- DRAWIO: data-processing-pipeline.drawio -->

## Error Handling Workflow

When errors occur, the system follows this recovery process:

<!-- DRAWIO: error-handling-workflow.drawio -->
```

### Advanced Tag Usage

You can reference diagrams in subdirectories:

```markdown
<!-- DRAWIO: architecture/system-overview.drawio -->
```

But ensure the file path is relative to `Documentation/images/drawio/`.

## Using the make-diagram-images.ps1 Script

### Basic Usage

The automation script handles the conversion process:

```powershell
# Navigate to scripts folder
cd "Documentation\scripts"

# Convert all diagrams and update markdown files
.\make-diagram-images.ps1
```

### What the Script Does

1. **Finds Draw.io Files**
   - Scans `Documentation/images/drawio/` for `.drawio` files
   - Recursively searches subdirectories

2. **Converts to SVG**
   - Uses Draw.io desktop for automatic conversion
   - Creates SVG files in `Documentation/images/drawio/svg/`
   - Preserves original `.drawio` files

3. **Updates Markdown Files**
   - Scans all `.md` files for hidden tags
   - Inserts image tags after hidden comments
   - Calculates correct relative paths automatically

4. **Generates Output**
   ```markdown
   <!-- DRAWIO: system-architecture.drawio -->
   ![Diagram: system-architecture](../images/drawio/svg/system-architecture.svg "system-architecture diagram")
   ```

### Script Parameters

```powershell
# Process all diagrams (default behavior)
.\make-diagram-images.ps1

# Force regeneration of all SVG files
.\make-diagram-images.ps1 -Force

# Preview changes without applying them
.\make-diagram-images.ps1 -DryRun

# Process only a specific markdown file
.\make-diagram-images.ps1 -MarkdownPath "tdd\specific-article.md"
```

### Example Workflow

1. **Create a new diagram**
   ```powershell
   # Open Draw.io and create system-flow.drawio
   # Save to Documentation/images/drawio/
   ```

2. **Add to documentation**
   ```markdown
   # System Flow Documentation
   
   <!-- DRAWIO: system-flow.drawio -->
   
   The system processes data through several stages...
   ```

3. **Run the conversion script**
   ```powershell
   cd Documentation\scripts
   .\make-diagram-images.ps1
   ```

4. **Verify the result**
   ```powershell
   # Build and test documentation
   .\build-docs.ps1
   .\test-docs.ps1
   ```

## Advanced Features

### Batch Processing

Process multiple diagrams efficiently:

```powershell
# Process all diagrams with verbose output
.\make-diagram-images.ps1 -Verbose

# Process specific directory of markdown files
Get-ChildItem "Documentation\tdd" -Filter "*.md" | ForEach-Object {
    .\make-diagram-images.ps1 -MarkdownPath "tdd\$($_.Name)"
}
```

### Integration with Build Process

Add diagram processing to your documentation build:

```powershell
# In build-docs.ps1 or your build script
Write-Host "Processing Draw.io diagrams..."
.\make-diagram-images.ps1

Write-Host "Building documentation..."
docfx build
```

### Conditional Processing

Skip processing if no changes detected:

```powershell
# Check if any .drawio files are newer than corresponding .svg files
$needsUpdate = Get-ChildItem "Documentation\images\drawio" -Filter "*.drawio" | 
    Where-Object { 
        $svgPath = $_.FullName -replace '\.drawio$', '.svg' -replace 'drawio\\', 'drawio\svg\'
        (-not (Test-Path $svgPath)) -or ($_.LastWriteTime -gt (Get-Item $svgPath).LastWriteTime)
    }

if ($needsUpdate) {
    .\make-diagram-images.ps1
}
```

## Diagram Design Best Practices

### Visual Consistency

**Color Scheme**
- Use a consistent color palette across all diagrams
- Consider accessibility (color blindness)
- Ensure good contrast for readability

**Typography**
- Use legible font sizes (minimum 10pt)
- Stick to system fonts for compatibility
- Maintain consistent heading hierarchy

**Layout**
- Arrange elements in logical flow (left-to-right, top-to-bottom)
- Use adequate spacing between elements
- Align elements to invisible grids

### Content Guidelines

**Clear Labels**
- Use descriptive, concise text
- Avoid technical jargon where possible
- Include legends for symbols or colors

**Appropriate Detail**
- Match detail level to audience
- Focus on key concepts and relationships
- Avoid cluttering with unnecessary information

**Logical Structure**
- Group related elements
- Use consistent shapes for similar concepts
- Show clear relationships and data flow

### Technical Considerations

**SVG Optimization**
- Keep diagrams reasonably sized (avoid extreme complexity)
- Test SVG output for web compatibility
- Verify diagrams are readable at different screen sizes

**Source Control**
- Always commit both `.drawio` and `.svg` files
- Use descriptive commit messages for diagram changes
- Consider diagram versioning for major changes

## Troubleshooting

### Common Issues

**Draw.io desktop not detected**
- Verify installation path: `C:\Program Files\draw.io\draw.io.exe`
- Check if Draw.io is in system PATH
- Try reinstalling Draw.io desktop

**SVG files not generated**
- Run script with `-Verbose` flag for detailed output
- Check Unity Console for error messages
- Verify `.drawio` files are not corrupted

**Diagrams not appearing in documentation**
- Check hidden tag syntax (must be exact)
- Verify file paths are correct
- Ensure SVG files exist in `svg/` subdirectory

**Relative paths incorrect**
- Script calculates paths automatically
- Verify markdown files are in expected locations
- Check that `Documentation` folder structure is correct

### Script Debugging

**Enable verbose output**
```powershell
.\make-diagram-images.ps1 -Verbose -ErrorAction Stop
```

**Manual conversion testing**
```powershell
# Test Draw.io command line manually
& "C:\Program Files\draw.io\draw.io.exe" -x -f svg -o test.svg input.drawio
```

**Verify file permissions**
```powershell
# Check write permissions to svg directory
Test-Path "Documentation\images\drawio\svg" -PathType Container
New-Item -ItemType File -Path "Documentation\images\drawio\svg\test.txt" -Force
Remove-Item "Documentation\images\drawio\svg\test.txt"
```

### Alternative Approaches

**Manual SVG Export**
If automation fails, export manually:
1. Open diagram in Draw.io
2. File → Export as → SVG
3. Save to `Documentation/images/drawio/svg/`
4. Manually add image tags to markdown

**Web-based Workflow**
Use app.diagrams.net if desktop issues persist:
1. Create/edit diagrams at [app.diagrams.net](https://app.diagrams.net)
2. Download as `.drawio` and `.svg` files
3. Place files in appropriate directories
4. Run script to update markdown files

## Integration Examples

### Technical Documentation

```markdown
# System Architecture Overview

<!-- DRAWIO: technical/system-architecture.drawio -->

## Component Interaction

<!-- DRAWIO: technical/component-interaction.drawio -->

## Data Flow

<!-- DRAWIO: technical/data-flow-diagram.drawio -->
```

### User Guides

```markdown
# Getting Started Workflow

Follow these steps to set up your environment:

<!-- DRAWIO: user-guides/setup-workflow.drawio -->

## Troubleshooting Common Issues

If you encounter problems, refer to this decision tree:

<!-- DRAWIO: user-guides/troubleshooting-flowchart.drawio -->
```

### API Documentation Enhancement

```markdown
# Authentication Process

The authentication flow follows this sequence:

<!-- DRAWIO: api/authentication-sequence.drawio -->

## Error Handling

When authentication fails, the system follows this process:

<!-- DRAWIO: api/auth-error-handling.drawio -->
```

## Next Steps

- Learn about [Including Code Coverage Report](code-coverage-setup.md) to add test metrics visualization
- Review [Documentation Generation FAQ](faq.md) for troubleshooting diagram-related issues
- Explore [Adding Articles as Subtopic](adding-subtopic.md) to organize diagram-enhanced content

## Additional Resources

- [Draw.io Documentation](https://www.drawio.com/blog)
- [SVG Optimization Guidelines](https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Tools_for_SVG)
- [Accessible Color Palettes](https://webaim.org/resources/contrastchecker/)
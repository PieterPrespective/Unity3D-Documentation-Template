# Draw.io Diagram Export Instructions

To create the PNG and SVG exports referenced in the documentation:

## Export Process

1. Open each .drawio file in diagrams.net (https://app.diagrams.net/)
2. Go to File > Export as > PNG (or SVG)
3. Use these settings:
   - PNG: Resolution 300 DPI, Transparent background
   - SVG: Include a copy of my diagram, Transparent background
4. Save to the appropriate subfolder:
   - PNG files â†’ images/drawio/png/
   - SVG files â†’ images/drawio/svg/

## Files to Export

- unity-game-flow.drawio â†’ unity-game-flow.png, unity-game-flow.svg
- unity-architecture.drawio â†’ unity-architecture.png, unity-architecture.svg  
- game-data-model.drawio â†’ game-data-model.png, game-data-model.svg

## Automation Option

Consider using Draw.io desktop app or CLI tools for batch export:
```bash
# Using draw.io desktop (if installed)
drawio -x -f png -o images/drawio/png/ images/drawio/*.drawio
drawio -x -f svg -o images/drawio/svg/ images/drawio/*.drawio
```

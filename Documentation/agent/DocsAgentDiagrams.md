# DocsAgent Diagram Generation Reference

## Overview

This document provides the Draw.io XML generation templates and instructions for the DocsAgent to create class diagrams and sequence diagrams programmatically. All diagrams must be valid Draw.io/mxGraph XML that can be opened in Draw.io desktop or web application.

---

## Draw.io XML Structure

### Base File Template

Every Draw.io file must follow this structure:

```xml
<mxfile host="app.diagrams.net" modified="{ISO-8601-timestamp}" agent="DocsAgent" version="1.0">
  <diagram id="{unique-id}" name="{diagram-name}">
    <mxGraphModel dx="1000" dy="800" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="850" pageHeight="1100">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <!-- Diagram elements go here -->
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

**Required Attributes**:
- `host`: Always "app.diagrams.net"
- `modified`: ISO-8601 timestamp when diagram was generated
- `agent`: "DocsAgent" to identify auto-generated diagrams
- `diagram id`: Unique identifier (use kebab-case feature name)
- `diagram name`: Human-readable name

---

## Coordinate System

- **Origin**: (0, 0) is top-left corner
- **X-axis**: Increases to the right
- **Y-axis**: Increases downward
- **Grid size**: 10 pixels (default)
- **Snap to grid**: Recommended for clean layouts

### Layout Constants

| Element Type | Width | Height | Notes |
|--------------|-------|--------|-------|
| Class box | 180 | varies | Height based on content |
| Interface box | 180 | varies | Similar to class box |
| Lifeline | 100 | varies | Height based on sequence length |
| Message spacing | - | 40-50 | Vertical space between messages |
| Horizontal spacing | 60 | - | Between classes/lifelines |
| Vertical spacing | 80 | - | Between hierarchy levels |

---

## Class Diagram Elements

### Style Constants

```
CLASS_BOX = "swimlane;fontStyle=1;align=center;verticalAlign=top;childLayout=stackLayout;horizontal=1;startSize=26;horizontalStack=0;resizeParent=1;resizeParentMax=0;resizeLast=0;collapsible=1;marginBottom=0;"

INTERFACE_BOX = "swimlane;fontStyle=3;align=center;verticalAlign=top;childLayout=stackLayout;horizontal=1;startSize=40;horizontalStack=0;resizeParent=1;resizeParentMax=0;resizeLast=0;collapsible=1;marginBottom=0;"

ABSTRACT_BOX = "swimlane;fontStyle=2;align=center;verticalAlign=top;childLayout=stackLayout;horizontal=1;startSize=26;horizontalStack=0;resizeParent=1;resizeParentMax=0;resizeLast=0;collapsible=1;marginBottom=0;"

FIELD_SECTION = "text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;"

SEPARATOR_LINE = "line;strokeWidth=1;fillColor=none;align=left;verticalAlign=middle;spacingTop=-1;spacingLeft=3;spacingRight=3;rotatable=0;labelPosition=right;points=[];portConstraint=eastwest;"

METHOD_SECTION = "text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;"

INHERITANCE_ARROW = "endArrow=block;endSize=16;endFill=0;html=1;"

INTERFACE_IMPL_ARROW = "endArrow=block;endSize=16;endFill=0;dashed=1;html=1;"

COMPOSITION_ARROW = "endArrow=diamondThin;endFill=1;endSize=24;html=1;"

AGGREGATION_ARROW = "endArrow=diamondThin;endFill=0;endSize=24;html=1;"

DEPENDENCY_ARROW = "endArrow=open;endSize=12;dashed=1;html=1;"
```

### Class Box Template

A class box consists of 4 cells: the container, fields section, separator, and methods section.

```xml
<!-- Class container -->
<mxCell id="class-{id}" value="{ClassName}" style="swimlane;fontStyle=1;align=center;verticalAlign=top;childLayout=stackLayout;horizontal=1;startSize=26;horizontalStack=0;resizeParent=1;resizeParentMax=0;resizeLast=0;collapsible=1;marginBottom=0;" vertex="1" parent="1">
  <mxGeometry x="{x}" y="{y}" width="{width}" height="{total_height}" as="geometry"/>
</mxCell>

<!-- Fields section -->
<mxCell id="class-{id}-fields" value="{fields_text}" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;" vertex="1" parent="class-{id}">
  <mxGeometry y="26" width="{width}" height="{fields_height}" as="geometry"/>
</mxCell>

<!-- Separator line -->
<mxCell id="class-{id}-sep" value="" style="line;strokeWidth=1;fillColor=none;align=left;verticalAlign=middle;spacingTop=-1;spacingLeft=3;spacingRight=3;rotatable=0;labelPosition=right;points=[];portConstraint=eastwest;" vertex="1" parent="class-{id}">
  <mxGeometry y="{sep_y}" width="{width}" height="8" as="geometry"/>
</mxCell>

<!-- Methods section -->
<mxCell id="class-{id}-methods" value="{methods_text}" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;" vertex="1" parent="class-{id}">
  <mxGeometry y="{methods_y}" width="{width}" height="{methods_height}" as="geometry"/>
</mxCell>
```

**Placeholder Values**:
- `{id}`: Unique identifier for this class (sanitized class name)
- `{ClassName}`: Display name of the class
- `{x}`, `{y}`: Position coordinates
- `{width}`: Box width (typically 180)
- `{total_height}`: 26 (header) + fields_height + 8 (separator) + methods_height
- `{fields_text}`: Formatted field list (see Field Formatting)
- `{fields_height}`: 16 * number_of_fields (minimum 16)
- `{sep_y}`: 26 + fields_height
- `{methods_text}`: Formatted method list (see Method Formatting)
- `{methods_y}`: sep_y + 8
- `{methods_height}`: 16 * number_of_methods (minimum 16)

### Interface Box Template

Interfaces use a two-line header with `<<interface>>` stereotype:

```xml
<mxCell id="interface-{id}" value="&lt;&lt;interface&gt;&gt;&#xa;{InterfaceName}" style="swimlane;fontStyle=3;align=center;verticalAlign=top;childLayout=stackLayout;horizontal=1;startSize=40;horizontalStack=0;resizeParent=1;resizeParentMax=0;resizeLast=0;collapsible=1;marginBottom=0;" vertex="1" parent="1">
  <mxGeometry x="{x}" y="{y}" width="{width}" height="{total_height}" as="geometry"/>
</mxCell>

<!-- Methods section (interfaces typically have no fields) -->
<mxCell id="interface-{id}-methods" value="{methods_text}" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;" vertex="1" parent="interface-{id}">
  <mxGeometry y="40" width="{width}" height="{methods_height}" as="geometry"/>
</mxCell>
```

### Abstract Class Template

Abstract classes use italic font style (fontStyle=2):

```xml
<mxCell id="abstract-{id}" value="{ClassName}" style="swimlane;fontStyle=2;align=center;verticalAlign=top;childLayout=stackLayout;horizontal=1;startSize=26;horizontalStack=0;resizeParent=1;resizeParentMax=0;resizeLast=0;collapsible=1;marginBottom=0;" vertex="1" parent="1">
  <!-- Same structure as regular class -->
</mxCell>
```

### Field Formatting

Format fields with visibility prefix and type:

```
- privateField: Type
+ publicField: Type
# protectedField: Type
~ internalField: Type
```

For Unity serialized fields, add notation:
```
- [S] serializedField: Type
```

**Example fields_text**:
```
- [S] testValue: float
- [S] testName: string
- isInitialized: bool
```

### Method Formatting

Format methods with visibility, parameters, and return type:

```
+ MethodName(param: Type): ReturnType
- PrivateMethod(): void
# ProtectedMethod(a: int, b: string): bool
```

For Unity lifecycle methods, mark with stereotype:
```
- <<lifecycle>> Awake(): void
- <<lifecycle>> Start(): void
```

**Example methods_text**:
```
- <<lifecycle>> Awake(): void
- <<lifecycle>> Start(): void
+ Initialize(): void
+ ProcessValue(multiplier: float): float
```

### Relationship Arrows

#### Inheritance (solid line, hollow triangle)
```xml
<mxCell id="inherit-{id}" style="endArrow=block;endSize=16;endFill=0;html=1;" edge="1" parent="1" source="class-{child}" target="class-{parent}">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

#### Interface Implementation (dashed line, hollow triangle)
```xml
<mxCell id="impl-{id}" style="endArrow=block;endSize=16;endFill=0;dashed=1;html=1;" edge="1" parent="1" source="class-{implementor}" target="interface-{interface}">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

#### Composition (solid line, filled diamond)
```xml
<mxCell id="comp-{id}" style="endArrow=diamondThin;endFill=1;endSize=24;html=1;" edge="1" parent="1" source="class-{part}" target="class-{whole}">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

#### Aggregation (solid line, hollow diamond)
```xml
<mxCell id="agg-{id}" style="endArrow=diamondThin;endFill=0;endSize=24;html=1;" edge="1" parent="1" source="class-{part}" target="class-{whole}">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

#### Dependency (dashed line, open arrow)
```xml
<mxCell id="dep-{id}" style="endArrow=open;endSize=12;dashed=1;html=1;" edge="1" parent="1" source="class-{dependent}" target="class-{dependency}">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

---

## Sequence Diagram Elements

### Style Constants

```
LIFELINE = "shape=umlLifeline;perimeter=lifelinePerimeter;whiteSpace=wrap;html=1;container=1;collapsible=0;recursiveResize=0;outlineConnect=0;portConstraint=eastwest;size=40;"

SYNC_MESSAGE = "html=1;verticalAlign=bottom;endArrow=block;entryX=0;entryY=0;"

ASYNC_MESSAGE = "html=1;verticalAlign=bottom;endArrow=open;entryX=0;entryY=0;"

RETURN_MESSAGE = "html=1;verticalAlign=bottom;endArrow=open;dashed=1;entryX=0;entryY=0;"

SELF_MESSAGE = "edgeStyle=orthogonalEdgeStyle;html=1;verticalAlign=bottom;endArrow=block;curved=0;rounded=0;"

ACTIVATION_BOX = "html=1;points=[];perimeter=orthogonalPerimeter;outlineConnect=0;targetShapes=umlLifeline;portConstraint=eastwest;newEdgeStyle={\"curved\":0,\"rounded\":0};"
```

### Lifeline Template

```xml
<!-- Lifeline (participant) -->
<mxCell id="lifeline-{id}" value="{ParticipantName}" style="shape=umlLifeline;perimeter=lifelinePerimeter;whiteSpace=wrap;html=1;container=1;collapsible=0;recursiveResize=0;outlineConnect=0;portConstraint=eastwest;size=40;" vertex="1" parent="1">
  <mxGeometry x="{x}" y="{y}" width="100" height="{height}" as="geometry"/>
</mxCell>
```

**Placeholder Values**:
- `{id}`: Unique identifier (sanitized participant name)
- `{ParticipantName}`: Display name (class name or `:ClassName` for instances)
- `{x}`: Horizontal position (space lifelines 120-150px apart)
- `{y}`: Vertical position (typically 40)
- `{height}`: Total lifeline height (based on number of messages)

### Activation Box Template

```xml
<!-- Activation box on lifeline -->
<mxCell id="activation-{id}" value="" style="html=1;points=[];perimeter=orthogonalPerimeter;outlineConnect=0;targetShapes=umlLifeline;portConstraint=eastwest;newEdgeStyle={&quot;curved&quot;:0,&quot;rounded&quot;:0};" vertex="1" parent="lifeline-{lifeline_id}">
  <mxGeometry x="45" y="{start_y}" width="10" height="{height}" as="geometry"/>
</mxCell>
```

### Message Arrow Templates

#### Synchronous Message (solid line, filled arrow)
```xml
<mxCell id="msg-{id}" value="{method_name}()" style="html=1;verticalAlign=bottom;endArrow=block;entryX=0;entryY=0;" edge="1" parent="1" source="lifeline-{from}" target="lifeline-{to}">
  <mxGeometry relative="1" as="geometry">
    <mxPoint x="-1" y="{y_offset}" as="offset"/>
  </mxGeometry>
</mxCell>
```

#### Return Message (dashed line, open arrow)
```xml
<mxCell id="return-{id}" value="{return_value}" style="html=1;verticalAlign=bottom;endArrow=open;dashed=1;entryX=1;entryY=0;exitX=0;exitY=0;" edge="1" parent="1" source="lifeline-{from}" target="lifeline-{to}">
  <mxGeometry relative="1" as="geometry">
    <mxPoint x="1" y="{y_offset}" as="offset"/>
  </mxGeometry>
</mxCell>
```

#### Self-Call Message
```xml
<mxCell id="self-{id}" value="{method_name}()" style="edgeStyle=orthogonalEdgeStyle;html=1;verticalAlign=bottom;endArrow=block;curved=0;rounded=0;" edge="1" parent="1" source="lifeline-{self}" target="lifeline-{self}">
  <mxGeometry relative="1" as="geometry">
    <mxPoint y="{y_offset}" as="offset"/>
    <Array as="points">
      <mxPoint x="{x_offset}" y="{y_offset}"/>
    </Array>
  </mxGeometry>
</mxCell>
```

### Sequence Diagram Layout

1. Place lifelines horizontally, spaced 120-150px apart
2. Start messages at y=80 (below header boxes)
3. Space messages vertically by 40-50px
4. Calculate total height: 80 + (num_messages * 45) + 40

---

## Auto-Layout Algorithm

### Class Diagram Layout

```
1. Identify hierarchy levels:
   - Level 0: Interfaces and base classes (no parents in diagram)
   - Level 1: Classes directly inheriting from Level 0
   - Level N: Classes inheriting from Level N-1

2. Position classes:
   - Start at y=40 for Level 0
   - Each level is y += 120 (class height + spacing)
   - Within each level, space classes horizontally by 60px
   - Center children below their parents

3. For single-class diagrams:
   - Position at (40, 40)
   - Include MonoBehaviour as parent if applicable
```

### Sequence Diagram Layout

```
1. Identify participants in order of first appearance
2. Position lifelines:
   - First lifeline at x=40
   - Each subsequent lifeline at x += 130
3. Calculate message positions:
   - First message at y=80
   - Each subsequent message at y += 45
4. Set lifeline heights:
   - height = 80 + (total_messages * 45) + 40
```

---

## Generating Diagrams from C# Code

### Class Diagram Generation Process

1. **Parse the C# file** to extract:
   - Namespace
   - Class/interface/struct name
   - Base class (if any)
   - Implemented interfaces
   - Fields with access modifiers and attributes
   - Methods with signatures
   - Events and delegates

2. **Identify relationships**:
   - Inheritance: `class Foo : Bar`
   - Interface implementation: `class Foo : IBar`
   - Composition: Fields with class types and `[SerializeField]`
   - Aggregation: Fields that are references but not serialized

3. **Calculate layout**:
   - Place base classes/interfaces at top
   - Place derived classes below
   - Center children under parents

4. **Generate XML**:
   - Create class boxes for each type
   - Create relationship arrows
   - Wrap in mxfile structure

### Sequence Diagram Generation Process

1. **Analyze the code flow** for:
   - Unity lifecycle methods (Awake, Start, Update, etc.)
   - Public method entry points
   - Method call chains
   - Event invocations

2. **Identify participants**:
   - Unity Engine (implicit caller for lifecycle methods)
   - The documented class
   - Called classes (if identifiable)

3. **Map the sequence**:
   - Order messages chronologically
   - Identify return values
   - Mark event invocations

4. **Generate XML**:
   - Create lifelines for each participant
   - Create message arrows
   - Add activation boxes
   - Wrap in mxfile structure

---

## Markdown Integration

### Hidden Tag Format

Place this tag in markdown where the diagram should appear:

```markdown
<!-- DRAWIO: {filename}.drawio -->
```

The `make-diagram-images.ps1` script will:
1. Convert `.drawio` to `.svg`
2. Insert image tag after the hidden comment

### Generated Output

After script runs:

```markdown
<!-- DRAWIO: DocumentationTestClass-class-diagram.drawio -->
![Diagram: DocumentationTestClass-class-diagram](../images/drawio/svg/DocumentationTestClass-class-diagram.svg "DocumentationTestClass-class-diagram diagram")
```

### DMMS Metadata Update

When creating diagrams, update the DMMS document metadata:

```json
{
  "metadata": {
    "diagrams": [
      "DocumentationTestClass-class-diagram.drawio",
      "DocumentationTestClass-lifecycle-sequence.drawio"
    ]
  }
}
```

---

## Naming Conventions

| Diagram Type | Filename Pattern | Example |
|--------------|------------------|---------|
| Class diagram | `{ClassName}-class-diagram.drawio` | `DocumentationTestClass-class-diagram.drawio` |
| Sequence diagram | `{ClassName}-{flow}-sequence.drawio` | `DocumentationTestClass-lifecycle-sequence.drawio` |
| Component diagram | `{Feature}-component-diagram.drawio` | `PlayerSystem-component-diagram.drawio` |
| State diagram | `{ClassName}-state-diagram.drawio` | `EnemyAI-state-diagram.drawio` |

---

## File Locations

| File Type | Location |
|-----------|----------|
| Source .drawio files | `Documentation/images/drawio/` |
| Generated .svg files | `Documentation/images/drawio/svg/` |
| Conversion script | `Documentation/scripts/make-diagram-images.ps1` |

---

## Complete Example: Single Class Diagram

For `DocumentationTestClass`:

```xml
<mxfile host="app.diagrams.net" modified="2026-01-12T16:00:00.000Z" agent="DocsAgent" version="1.0">
  <diagram id="DocumentationTestClass-class" name="DocumentationTestClass Class Diagram">
    <mxGraphModel dx="800" dy="600" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="850" pageHeight="1100">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>

        <!-- MonoBehaviour (external reference) -->
        <mxCell id="class-monobehaviour" value="MonoBehaviour" style="swimlane;fontStyle=2;align=center;verticalAlign=top;childLayout=stackLayout;horizontal=1;startSize=26;horizontalStack=0;resizeParent=1;resizeParentMax=0;resizeLast=0;collapsible=1;marginBottom=0;fillColor=#f5f5f5;strokeColor=#666666;fontColor=#333333;" vertex="1" parent="1">
          <mxGeometry x="40" y="40" width="180" height="50" as="geometry"/>
        </mxCell>
        <mxCell id="class-monobehaviour-note" value="(Unity Engine)" style="text;strokeColor=none;fillColor=none;align=center;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;fontStyle=2;fontColor=#666666;" vertex="1" parent="class-monobehaviour">
          <mxGeometry y="26" width="180" height="24" as="geometry"/>
        </mxCell>

        <!-- DocumentationTestClass -->
        <mxCell id="class-documentationtestclass" value="DocumentationTestClass" style="swimlane;fontStyle=1;align=center;verticalAlign=top;childLayout=stackLayout;horizontal=1;startSize=26;horizontalStack=0;resizeParent=1;resizeParentMax=0;resizeLast=0;collapsible=1;marginBottom=0;" vertex="1" parent="1">
          <mxGeometry x="40" y="150" width="220" height="170" as="geometry"/>
        </mxCell>
        <mxCell id="class-documentationtestclass-fields" value="- [S] testValue: float&#xa;- [S] testName: string&#xa;- isInitialized: bool&#xa;+ OnTestEvent: Action" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;" vertex="1" parent="class-documentationtestclass">
          <mxGeometry y="26" width="220" height="64" as="geometry"/>
        </mxCell>
        <mxCell id="class-documentationtestclass-sep" value="" style="line;strokeWidth=1;fillColor=none;align=left;verticalAlign=middle;spacingTop=-1;spacingLeft=3;spacingRight=3;rotatable=0;labelPosition=right;points=[];portConstraint=eastwest;" vertex="1" parent="class-documentationtestclass">
          <mxGeometry y="90" width="220" height="8" as="geometry"/>
        </mxCell>
        <mxCell id="class-documentationtestclass-methods" value="- Awake(): void&#xa;- Start(): void&#xa;+ Initialize(): void&#xa;+ ProcessValue(multiplier: float): float" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;" vertex="1" parent="class-documentationtestclass">
          <mxGeometry y="98" width="220" height="72" as="geometry"/>
        </mxCell>

        <!-- Inheritance arrow -->
        <mxCell id="inherit-doctest-mono" style="endArrow=block;endSize=16;endFill=0;html=1;" edge="1" parent="1" source="class-documentationtestclass" target="class-monobehaviour">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

---

## Complete Example: Lifecycle Sequence Diagram

For `DocumentationTestClass` lifecycle:

```xml
<mxfile host="app.diagrams.net" modified="2026-01-12T16:00:00.000Z" agent="DocsAgent" version="1.0">
  <diagram id="DocumentationTestClass-lifecycle" name="DocumentationTestClass Lifecycle Sequence">
    <mxGraphModel dx="800" dy="600" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="850" pageHeight="1100">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>

        <!-- Unity Engine lifeline -->
        <mxCell id="lifeline-unity" value=":Unity" style="shape=umlLifeline;perimeter=lifelinePerimeter;whiteSpace=wrap;html=1;container=1;collapsible=0;recursiveResize=0;outlineConnect=0;portConstraint=eastwest;size=40;" vertex="1" parent="1">
          <mxGeometry x="40" y="40" width="100" height="280" as="geometry"/>
        </mxCell>

        <!-- DocumentationTestClass lifeline -->
        <mxCell id="lifeline-doctest" value=":DocumentationTestClass" style="shape=umlLifeline;perimeter=lifelinePerimeter;whiteSpace=wrap;html=1;container=1;collapsible=0;recursiveResize=0;outlineConnect=0;portConstraint=eastwest;size=40;" vertex="1" parent="1">
          <mxGeometry x="180" y="40" width="140" height="280" as="geometry"/>
        </mxCell>

        <!-- Event Subscriber lifeline -->
        <mxCell id="lifeline-subscriber" value=":Subscriber" style="shape=umlLifeline;perimeter=lifelinePerimeter;whiteSpace=wrap;html=1;container=1;collapsible=0;recursiveResize=0;outlineConnect=0;portConstraint=eastwest;size=40;strokeDasharray=3 3;" vertex="1" parent="1">
          <mxGeometry x="360" y="40" width="100" height="280" as="geometry"/>
        </mxCell>

        <!-- Message 1: Awake -->
        <mxCell id="msg-1" value="Awake()" style="html=1;verticalAlign=bottom;endArrow=block;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="90" y="100" as="sourcePoint"/>
            <mxPoint x="250" y="100" as="targetPoint"/>
          </mxGeometry>
        </mxCell>

        <!-- Message 2: Start -->
        <mxCell id="msg-2" value="Start()" style="html=1;verticalAlign=bottom;endArrow=block;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="90" y="150" as="sourcePoint"/>
            <mxPoint x="250" y="150" as="targetPoint"/>
          </mxGeometry>
        </mxCell>

        <!-- Message 3: Initialize (self-call) -->
        <mxCell id="msg-3" value="Initialize()" style="edgeStyle=orthogonalEdgeStyle;html=1;verticalAlign=bottom;endArrow=block;curved=0;rounded=0;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="260" y="170" as="sourcePoint"/>
            <mxPoint x="260" y="200" as="targetPoint"/>
            <Array as="points">
              <mxPoint x="300" y="170"/>
              <mxPoint x="300" y="200"/>
            </Array>
          </mxGeometry>
        </mxCell>

        <!-- Message 4: OnTestEvent invoke -->
        <mxCell id="msg-4" value="OnTestEvent?.Invoke()" style="html=1;verticalAlign=bottom;endArrow=block;dashed=1;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="260" y="220" as="sourcePoint"/>
            <mxPoint x="410" y="220" as="targetPoint"/>
          </mxGeometry>
        </mxCell>

        <!-- Note -->
        <mxCell id="note-1" value="Note: Subscriber is optional,&#xa;event only fires if handlers&#xa;are registered" style="shape=note;whiteSpace=wrap;html=1;size=14;verticalAlign=top;align=left;spacingTop=-6;fillColor=#fff2cc;strokeColor=#d6b656;" vertex="1" parent="1">
          <mxGeometry x="360" y="240" width="140" height="60" as="geometry"/>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

---

*DocsAgent Diagram Reference v1.0 - Phase 2*
*Created: 2026-01-12*

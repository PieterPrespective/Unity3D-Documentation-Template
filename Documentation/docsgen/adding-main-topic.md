# Adding Articles as Main Topic

This guide explains how to add new main topics to the documentation navigation, which appear as top-level sections in the site's table of contents.

## Overview

Main topics are top-level navigation items that appear in the primary menu. Examples of existing main topics include:
- User Documentation
- Technical Design Document
- Code Coverage
- API Documentation

## Steps to Add a Main Topic

### 1. Create the Topic Directory

Create a new folder in the `Documentation` directory for your topic:

```powershell
# Navigate to Documentation folder
cd Documentation

# Create new topic folder (use lowercase with hyphens)
mkdir "my-new-topic"
```

**Naming Convention:**
- Use lowercase letters
- Separate words with hyphens
- Keep names concise and descriptive
- Examples: `tutorials`, `deployment-guide`, `architecture-docs`

### 2. Create Table of Contents

Create a `toc.yml` file in your new topic folder:

```yaml
# Documentation/my-new-topic/toc.yml
- name: Introduction
  href: introduction.md
- name: Getting Started
  href: getting-started.md
- name: Advanced Topics
  href: advanced.md
```

**TOC Structure:**
- `name`: Display name in navigation
- `href`: Relative path to the markdown file
- Items are displayed in the order they appear in the file

### 3. Create Article Files

Create markdown files for each item in your table of contents:

```powershell
# In your topic directory
New-Item -ItemType File -Name "introduction.md"
New-Item -ItemType File -Name "getting-started.md"
New-Item -ItemType File -Name "advanced.md"
```

**Sample Article Structure:**

```markdown
# Article Title

Brief introduction to the topic.

## Section 1

Content here...

## Section 2

More content...

## Next Steps

- Link to [related article](other-article.md)
- External link to [resources](https://example.com)
```

### 4. Update DocFX Configuration

Add your new topic to the DocFX configuration in `docfx.json`:

```json
{
  "build": {
    "content": [
      {
        "files": [
          "api/**.yml",
          "api/index.md"
        ]
      },
      {
        "files": [
          "tdd/**.md",
          "tdd/**/toc.yml",
          "userdocs/**.md",
          "userdocs/**/toc.yml",
          "docsgen/**.md",
          "docsgen/**/toc.yml",
          "my-new-topic/**.md",
          "my-new-topic/**/toc.yml",
          "toc.yml",
          "*.md"
        ]
      }
    ]
  }
}
```

### 5. Update Main Table of Contents

Add your topic to the main `toc.yml` file:

```yaml
# Documentation/toc.yml
- name: User Documentation
  href: userdocs/
- name: My New Topic
  href: my-new-topic/
- name: Technical Design Document
  href: tdd/
- name: Code Coverage
  href: codecoverage.md
- name: API Documentation
  href: api/
  homepage: api/index.md
```

**Navigation Order:**
- Topics appear in the order listed in `toc.yml`
- Consider logical grouping (user docs first, technical docs last)
- Place frequently accessed content near the top

### 6. Test Your Changes

Build and test the documentation:

```powershell
# Build the documentation
.\scripts\build-docs.ps1

# Test locally
.\scripts\test-docs.ps1
```

Verify that:
- Your new topic appears in the main navigation
- All articles are accessible
- Internal links work correctly
- The topic structure displays properly

## Complete Example

Let's create a "Tutorials" main topic:

### Step 1: Create Directory
```powershell
mkdir "Documentation\tutorials"
```

### Step 2: Create TOC
```yaml
# Documentation/tutorials/toc.yml
- name: Overview
  href: overview.md
- name: Basic Tutorial
  href: basic-tutorial.md
- name: Advanced Tutorial
  href: advanced-tutorial.md
- name: Best Practices
  href: best-practices.md
```

### Step 3: Create Articles
```powershell
cd Documentation\tutorials
New-Item -ItemType File -Name "overview.md"
New-Item -ItemType File -Name "basic-tutorial.md"
New-Item -ItemType File -Name "advanced-tutorial.md"
New-Item -ItemType File -Name "best-practices.md"
```

### Step 4: Sample Article Content
```markdown
# Tutorial Overview

This section contains step-by-step tutorials for working with the project.

## Available Tutorials

- [Basic Tutorial](basic-tutorial.md) - Getting started with core features
- [Advanced Tutorial](advanced-tutorial.md) - Complex scenarios and optimization
- [Best Practices](best-practices.md) - Recommended approaches and patterns

## Prerequisites

Before starting any tutorial, ensure you have:
- Unity 6 (6000.2.9f1) or later
- Basic understanding of C# programming
- Familiarity with Unity Editor

## Tutorial Structure

Each tutorial follows this structure:
1. **Objective** - What you'll learn
2. **Prerequisites** - What you need before starting
3. **Step-by-step instructions** - Detailed guidance
4. **Verification** - How to confirm success
5. **Next steps** - Where to go from here

## Getting Help

If you encounter issues during tutorials:
- Check the [FAQ](../docsgen/faq.md) for common problems
- Review the [User Documentation](../userdocs/) for background information
- Consult the [API Documentation](../api/) for specific method details
```

### Step 5: Update DocFX Configuration
Add to the files array in `docfx.json`:
```json
"tutorials/**.md",
"tutorials/**/toc.yml",
```

### Step 6: Update Main TOC
Add to `toc.yml`:
```yaml
- name: Tutorials
  href: tutorials/
```

## Best Practices

### Content Organization

**Logical Grouping**
- Group related articles together
- Use consistent naming conventions
- Maintain parallel structure across topics

**Progressive Disclosure**
- Start with overview/introduction
- Progress from basic to advanced concepts
- Include cross-references between related topics

### Writing Guidelines

**Clear Headings**
- Use descriptive, action-oriented titles
- Maintain consistent heading levels
- Include keywords for searchability

**Consistent Style**
- Follow the same formatting patterns
- Use code blocks for commands and examples
- Include practical examples and screenshots when helpful

**Navigation Aids**
- Add "Next Steps" sections
- Include breadcrumb-style navigation
- Cross-link to related topics

### File Organization

```
my-topic/
├── toc.yml                 # Navigation structure
├── index.md               # Optional: topic landing page
├── introduction.md        # Getting started content
├── core-concepts.md       # Foundation knowledge
├── advanced/              # Subdirectory for complex topics
│   ├── toc.yml           # Subtopic navigation
│   ├── advanced-1.md     # Advanced articles
│   └── advanced-2.md
└── reference/             # Reference materials
    ├── toc.yml
    ├── glossary.md
    └── troubleshooting.md
```

### Testing Checklist

Before finalizing your main topic:

- [ ] Navigation appears correctly in the main menu
- [ ] All internal links resolve properly
- [ ] Table of contents displays in logical order
- [ ] Articles render correctly (formatting, code blocks, etc.)
- [ ] Search functionality includes your content
- [ ] Cross-references to other sections work
- [ ] Mobile view displays properly
- [ ] Build process completes without warnings

## Common Pitfalls

### DocFX Configuration Issues
- **Forgetting to update `docfx.json`** - Content won't be included in build
- **Incorrect file patterns** - Some files may be excluded
- **Missing TOC references** - Navigation won't work properly

### Navigation Problems
- **Wrong TOC ordering** - Topics appear in unexpected locations
- **Missing href attributes** - Links won't work
- **Inconsistent naming** - Confusing user experience

### Content Issues
- **Orphaned files** - Articles not linked from navigation
- **Broken internal links** - References to moved or renamed files
- **Inconsistent formatting** - Mixed markdown styles

## Advanced Configuration

### Custom Topic Homepage

You can specify a custom homepage for your topic:

```yaml
# In main toc.yml
- name: My Topic
  href: my-topic/
  homepage: my-topic/overview.md
```

### Hierarchical Topics

Create nested topics with subdirectories:

```yaml
# my-topic/toc.yml
- name: Getting Started
  href: introduction.md
- name: Guides
  href: guides/
- name: Reference
  href: reference/
```

### Conditional Content

Use DocFX templates to show/hide content based on conditions:

```markdown
<!-- Only show in development builds -->
[!INCLUDE[Development](~/includes/dev-only.md)]
```

## Next Steps

- Learn about [Adding Articles as Subtopics](adding-subtopic.md) for organizing content within main topics
- Review [Setting up API Documentation](setup-api-docs.md) for automated documentation
- Explore [Using Draw.io for Diagrams](drawio-integration.md) to enhance your articles with visuals
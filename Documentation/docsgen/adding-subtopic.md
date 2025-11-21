# Adding Articles as Subtopic

This guide explains how to add articles as subtopics within existing main topics, creating hierarchical navigation and organized content structure.

## Overview

Subtopics are articles that belong under a main topic in the navigation hierarchy. They help organize content into logical groups and create a more manageable navigation structure.

**Example Structure:**
```
Main Topic: User Documentation
├── Getting Started (subtopic)
├── User Guide (subtopic)
└── FAQ (subtopic)
```

## Simple Subtopic (Single Article)

The most common case is adding a single article as a subtopic to an existing main topic.

### Step 1: Create the Article File

Navigate to the main topic folder and create your markdown file:

```powershell
# Example: Adding to User Documentation
cd "Documentation\userdocs"

# Create new article
New-Item -ItemType File -Name "troubleshooting.md"
```

### Step 2: Write Article Content

```markdown
# Troubleshooting Common Issues

This guide helps you resolve common problems encountered while using the system.

## Issue 1: Connection Problems

**Symptoms:** Unable to connect to UMCP bridge

**Solutions:**
1. Check Unity Console for error messages
2. Verify ports 6400/6401 are available
3. Restart Unity Editor

## Issue 2: Test Failures

**Symptoms:** Tests fail unexpectedly

**Solutions:**
1. Ensure Unity Editor is in correct mode
2. Check test dependencies
3. Review test isolation

## Getting Additional Help

If these solutions don't resolve your issue:
- Check the [FAQ](faq.md) for more solutions
- Review [Technical Design Document](../tdd/) for implementation details
- Consult [API Documentation](../api/) for method-specific information
```

### Step 3: Update Table of Contents

Add the new article to the topic's `toc.yml`:

```yaml
# Documentation/userdocs/toc.yml
- name: Getting Started
  href: getting-started.md
- name: User Guide
  href: user-guide.md
- name: Troubleshooting
  href: troubleshooting.md
- name: FAQ
  href: faq.md
```

### Step 4: Test the Changes

```powershell
# Build and test
cd Documentation\scripts
.\build-docs.ps1
.\test-docs.ps1
```

## Hierarchical Subtopics (Nested Structure)

For complex topics, you can create nested subtopics using subdirectories.

### Example: Creating a "Guides" Section

Let's add a "Guides" section under Technical Design Document with multiple subtopics:

### Step 1: Create Subdirectory Structure

```powershell
cd "Documentation\tdd"
mkdir "guides"
cd "guides"

# Create article files
New-Item -ItemType File -Name "architecture-guide.md"
New-Item -ItemType File -Name "testing-guide.md"
New-Item -ItemType File -Name "deployment-guide.md"
```

### Step 2: Create Subtopic TOC

```yaml
# Documentation/tdd/guides/toc.yml
- name: Architecture Guide
  href: architecture-guide.md
- name: Testing Guide
  href: testing-guide.md
- name: Deployment Guide
  href: deployment-guide.md
```

### Step 3: Update Parent TOC

Modify the main topic's TOC to include the new section:

```yaml
# Documentation/tdd/toc.yml
- name: Overview
  href: Index.md
- name: Research
  href: Unity3D_TDD_Research.md
- name: Guides
  href: guides/
- name: Architecture
  href: architecture-with-diagrams.md
- name: Diagrams
  href: drawio-diagrams.md
```

### Step 4: Create Guide Content

**architecture-guide.md:**
```markdown
# Architecture Guide

This guide explains the architectural patterns and design decisions used in the project.

## System Architecture

The system follows a layered architecture pattern:

### Presentation Layer
- Unity Editor UI components
- UMCP Bridge interface
- Console output formatting

### Business Logic Layer
- Command processing
- Test execution logic
- State management

### Data Layer
- Test results storage
- Configuration management
- Log file handling

## Design Patterns

### Command Pattern
The UMCP Bridge uses the Command pattern for handling MCP requests:

```csharp
public interface ICommand
{
    Task<string> ExecuteAsync(string parameters);
}
```

### Observer Pattern
Editor state changes are propagated using the Observer pattern:

```csharp
public event System.Action<EditorState> OnStateChanged;
```

## Best Practices

1. **Separation of Concerns** - Keep UI, logic, and data separate
2. **Dependency Injection** - Use interfaces for testability
3. **Error Handling** - Implement comprehensive error handling
4. **Logging** - Use structured logging for debugging

## Next Steps

- Review [Testing Guide](testing-guide.md) for testing strategies
- Check [Deployment Guide](deployment-guide.md) for production setup
```

## Cross-References and Navigation

### Linking Between Subtopics

Use relative paths to link between articles in the same topic:

```markdown
<!-- Within same topic -->
See also [User Guide](user-guide.md) for detailed instructions.

<!-- To subtopic in same topic -->
Check the [Testing Guide](guides/testing-guide.md) for more information.

<!-- To different main topic -->
Refer to [API Documentation](../api/) for method details.
```

### Breadcrumb Navigation

Include navigation hints in your articles:

```markdown
# Testing Guide

*Technical Design Document > Guides > Testing Guide*

This guide covers testing strategies and best practices.

## In This Section

- [Architecture Guide](architecture-guide.md) - System design patterns
- [Testing Guide](testing-guide.md) - Testing strategies (current)
- [Deployment Guide](deployment-guide.md) - Production deployment

## Related Topics

- [User Guide](../../userdocs/user-guide.md) - User-facing documentation
- [API Reference](../../api/) - Detailed API documentation
```

## Organizing Subtopics by Type

### By Content Type

```yaml
# toc.yml structure organized by content type
- name: Overview
  href: overview.md
- name: Tutorials
  href: tutorials/
- name: How-To Guides
  href: howto/
- name: Reference
  href: reference/
- name: Explanation
  href: explanation/
```

### By Feature Area

```yaml
# toc.yml structure organized by feature
- name: Getting Started
  href: getting-started.md
- name: Authentication
  href: auth/
- name: Testing
  href: testing/
- name: Deployment
  href: deployment/
- name: Troubleshooting
  href: troubleshooting/
```

### By User Role

```yaml
# toc.yml structure organized by audience
- name: For Developers
  href: developers/
- name: For Testers
  href: testers/
- name: For DevOps
  href: devops/
- name: For End Users
  href: users/
```

## Advanced Subtopic Features

### Conditional Subtopics

Show different content based on conditions:

```yaml
# Use conditional includes
- name: Development Setup
  href: dev-setup.md
- name: Production Setup
  href: prod-setup.md
  condition: production
```

### External Link Subtopics

Link to external resources:

```yaml
- name: Unity Documentation
  href: https://docs.unity3d.com/
  external: true
- name: DocFX Documentation
  href: https://dotnet.github.io/docfx/
  external: true
```

### Subtopic with Custom Homepage

Specify a different landing page for a subtopic:

```yaml
- name: API Reference
  href: api/
  homepage: api/overview.md
```

## Best Practices for Subtopics

### Content Organization

**Logical Grouping**
- Group related articles together
- Use consistent depth levels (avoid going too deep)
- Maintain parallel structure across sections

**Progressive Disclosure**
- Start with overview content
- Progress from basic to advanced
- Use clear hierarchical naming

### File Naming

**Consistent Conventions**
```
good-file-names.md        ✓ Kebab case, descriptive
BadFileNames.md           ✗ Mixed case
file_names_with_under.md  ✗ Inconsistent with project style
vague-name.md            ✗ Not descriptive
```

**Descriptive Names**
```
user-authentication.md    ✓ Clear purpose
testing-strategies.md     ✓ Specific topic
performance-optimization.md ✓ Clear scope
misc.md                  ✗ Too vague
stuff.md                 ✗ Not descriptive
```

### Navigation Design

**Optimal Depth**
- Aim for 2-3 levels maximum
- Use landing pages for deep hierarchies
- Consider splitting large topics into separate main topics

**Clear Hierarchy**
```
Main Topic
├── Overview/Introduction
├── Getting Started
├── Core Concepts
│   ├── Concept 1
│   ├── Concept 2
│   └── Concept 3
├── Advanced Topics
│   ├── Advanced Topic 1
│   └── Advanced Topic 2
└── Reference
    ├── API Reference
    └── Troubleshooting
```

## Testing Your Subtopic Structure

### Validation Checklist

- [ ] All articles are reachable from navigation
- [ ] Internal links work correctly
- [ ] External links open properly
- [ ] TOC hierarchy displays correctly
- [ ] Search finds your content
- [ ] Mobile navigation works
- [ ] Breadcrumbs are accurate

### Build Verification

```powershell
# Clean build to catch any issues
.\scripts\build-docs.ps1 -Clean

# Check for warnings or errors
# Look for broken links or missing files

# Test locally
.\scripts\test-docs.ps1

# Navigate through your subtopics
# Verify all links work
# Check formatting and layout
```

## Common Issues and Solutions

### Navigation Problems

**Issue:** Subtopic doesn't appear in navigation
- **Solution:** Check that `href` path is correct in TOC file
- **Solution:** Verify file exists and has content

**Issue:** Wrong ordering in navigation
- **Solution:** Adjust order in `toc.yml` file
- **Solution:** Check for duplicate entries

### Link Issues

**Issue:** Internal links broken
- **Solution:** Use relative paths correctly (`../` for parent directories)
- **Solution:** Verify target file exists

**Issue:** Deep linking doesn't work
- **Solution:** Use anchor links for sections: `[Link](#section-name)`
- **Solution:** Ensure heading text matches anchor format

### Build Problems

**Issue:** Files not included in build
- **Solution:** Update `docfx.json` to include new directory patterns
- **Solution:** Check file encoding (use UTF-8)

**Issue:** TOC not updating
- **Solution:** Clear browser cache
- **Solution:** Rebuild documentation completely

## Next Steps

- Learn about [Setting up API Documentation](setup-api-docs.md) for automated documentation
- Explore [Using Draw.io for Diagrams](drawio-integration.md) to enhance your articles
- Review [Documentation Generation FAQ](faq.md) for troubleshooting help
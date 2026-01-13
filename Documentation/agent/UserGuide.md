# DocsAgent User Guide

A comprehensive guide for using DocsAgent - the automated Technical Design Documentation (TDD) generation system for Unity3D projects.

**Version**: 4.0
**Last Updated**: 2026-01-13

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites & Setup](#prerequisites--setup)
3. [Quick Start](#quick-start)
4. [Command Reference](#command-reference)
5. [Workflows](#workflows)
6. [Best Practices](#best-practices)
7. [Configuration](#configuration)
8. [FAQ](#faq)
9. [Troubleshooting](#troubleshooting)
10. [Known Limitations](#known-limitations)
11. [Architecture](#architecture)

---

## Overview

DocsAgent is an AI-powered documentation assistant that automatically generates and maintains Technical Design Documentation (TDD) for Unity3D C# projects. It integrates with version control (Git) and uses a vector database (DMMS/ChromaDB) for intelligent document tracking.

### Key Features

| Feature | Description |
|---------|-------------|
| **CREATE** | Generate new documentation from C# source files |
| **UPDATE** | Sync documentation when source code changes |
| **DELETE** | Remove orphaned documentation when source files are deleted |
| **Pattern Detection** | Automatically identify design patterns in code |
| **Coverage Reporting** | Track documentation coverage across your codebase |
| **Relationship Tracking** | Map dependencies between documented classes |
| **Diagram Generation** | Create class and sequence diagrams in Draw.io format |

### What DocsAgent Produces

- Markdown documentation following TDD standards
- Class diagrams showing inheritance and relationships
- Sequence diagrams for lifecycle flows
- Pattern catalog linking implementations to design patterns
- Coverage reports identifying documentation gaps

---

## Prerequisites & Setup

### Required Software

| Software | Version | Purpose |
|----------|---------|---------|
| Git | 2.30+ | Version control and change detection |
| Node.js | 18+ | Required for MCP servers |
| Python | 3.10+ | Required for DMMS server |
| PowerShell | 7+ | Script execution (Windows) |
| Draw.io Desktop | Latest | Diagram viewing/editing (optional) |

### Required MCP Servers

DocsAgent requires the **DMMS MCP Server** (Document Management & Mapping System) for tracking documentation relationships.

#### DMMS Server Setup

1. **Install DMMS MCP Server**

   ```bash
   # Clone the DMMS repository
   git clone https://github.com/your-org/dmms-mcp-server.git
   cd dmms-mcp-server

   # Install dependencies
   pip install -r requirements.txt

   # Or using uv (recommended)
   uv pip install -r requirements.txt
   ```

2. **Configure Claude Code MCP Settings**

   Add to your Claude Code MCP configuration (`~/.claude/mcp_settings.json` or project `.claude/settings.local.json`):

   ```json
   {
     "mcpServers": {
       "dmms-projectSetup": {
         "command": "uv",
         "args": [
           "run",
           "--directory",
           "C:/path/to/dmms-mcp-server",
           "dmms-mcp-server"
         ],
         "env": {
           "DMMS_DATA_DIR": "C:/path/to/your/project/.dmms"
         }
       }
     }
   }
   ```

3. **Initialize DMMS for Your Project**

   ```
   # In Claude Code, run:
   Initialize DMMS repository for this project
   ```

   This creates the `docs-agent` collection for tracking documentation mappings.

### Documentation Template Setup

DocsAgent requires the Unity3D Documentation Template for proper structure.

1. **Clone the Template**

   ```bash
   # From your Unity project root
   git clone https://github.com/PieterPrespective/Unity3D-Documentation-Template Documentation
   ```

2. **Verify Template Structure**

   Ensure these files exist:
   ```
   Documentation/
   ├── scripts/
   │   ├── build-docs.ps1
   │   └── make-diagram-images.ps1
   ├── docfx.json
   ├── tdd/
   │   ├── toc.yml
   │   └── Index.md
   └── images/
       └── drawio/
   ```

### Project Structure Requirements

Your Unity project should follow this structure:

```
YourUnityProject/
├── Assets/
│   └── Scripts/           # C# source files to document
├── Documentation/         # Documentation template (cloned)
│   ├── tdd/              # Technical Design Documents
│   │   ├── toc.yml       # Table of contents
│   │   ├── Index.md      # Overview page
│   │   └── {Feature}/    # Feature documentation folders
│   └── images/
│       └── drawio/       # Diagram files
├── Prompts/
│   ├── DocsAgentPrompt.md    # Agent instructions
│   └── DocsAgentDiagrams.md  # Diagram templates
└── .dmms/                # DMMS data directory (auto-created)
```

---

## Quick Start

### First-Time Setup

1. **Verify Prerequisites**
   ```
   Check if Documentation template is set up correctly
   ```

2. **Initialize DMMS Collection**
   ```
   Create DMMS collection 'docs-agent' for documentation tracking
   ```

3. **Create Your First Documentation**
   ```
   create docs for Assets/Scripts/Player/PlayerController.cs
   ```

### Daily Workflow

```
# Check what needs updating
check stale docs

# Update documentation for recent changes
update docs from git changes

# Generate coverage report
report coverage
```

---

## Command Reference

### CREATE Commands

| Command | Description | Example |
|---------|-------------|---------|
| `create docs for {path}` | Create documentation for a specific file | `create docs for Assets/Scripts/Player.cs` |
| `create docs for {pattern}` | Create docs for files matching a glob pattern | `create docs for Assets/Scripts/**/*Manager.cs` |

### UPDATE Commands

| Command | Description | Example |
|---------|-------------|---------|
| `update docs for {path}` | Update documentation for a specific file | `update docs for Assets/Scripts/Player.cs` |
| `update docs from git changes` | Update docs for files changed since HEAD~1 | - |
| `update docs since {commit}` | Update docs for files changed since commit | `update docs since abc1234` |
| `update docs since HEAD~{N}` | Update docs for files in last N commits | `update docs since HEAD~5` |

### DELETE Commands

| Command | Description | Example |
|---------|-------------|---------|
| `delete docs for {path}` | Delete documentation for a specific file | `delete docs for Assets/Scripts/Old.cs` |
| `find orphaned docs` | List documentation without source files | - |
| `delete orphaned docs` | Delete all orphaned documentation (with confirmation) | - |

### QUERY Commands

| Command | Description | Example |
|---------|-------------|---------|
| `check docs for {path}` | Check if documentation exists | `check docs for Assets/Scripts/Enemy.cs` |
| `find docs for {class}` | Query DMMS for class documentation | `find docs for PlayerController` |
| `check stale docs` | List documentation with outdated hashes | - |
| `preview update for {path}` | Show what would change (dry-run) | `preview update for Assets/Scripts/Player.cs` |

### PATTERN Commands

| Command | Description | Example |
|---------|-------------|---------|
| `scan patterns` | Detect patterns across codebase | - |
| `scan patterns for {path}` | Detect patterns in specific file | `scan patterns for Assets/Scripts/GameManager.cs` |
| `update pattern catalog` | Refresh PatternCatalog.md | - |

### COVERAGE Commands

| Command | Description | Example |
|---------|-------------|---------|
| `report coverage` | Generate full coverage report | - |
| `report coverage for {path}` | Coverage for specific folder | `report coverage for Assets/Scripts/UI/` |
| `list undocumented` | List all undocumented files | - |
| `list stale docs` | List documentation needing updates | - |

### RELATIONSHIP Commands

| Command | Description | Example |
|---------|-------------|---------|
| `show relationships for {path}` | Show class dependencies | `show relationships for Assets/Scripts/Player.cs` |
| `generate relationship diagram` | Create cross-file diagram | - |

---

## Workflows

### Workflow 1: Documenting a New Feature

```
# Step 1: Create documentation
create docs for Assets/Scripts/Features/NewFeature.cs

# Step 2: Review generated documentation
# Open Documentation/tdd/NewFeature/index.md

# Step 3: Generate diagrams (if needed)
# Diagrams are auto-generated; run make-diagram-images.ps1 to create SVGs

# Step 4: Verify DMMS tracking
check docs for Assets/Scripts/Features/NewFeature.cs
```

### Workflow 2: Keeping Documentation Current

```
# Option A: Check for stale docs periodically
check stale docs

# Option B: Update based on git changes
update docs from git changes

# Option C: Update specific file after editing
update docs for Assets/Scripts/Player/PlayerController.cs
```

### Workflow 3: Cleaning Up Orphaned Documentation

```
# Step 1: Find orphaned docs
find orphaned docs

# Step 2: Review the list
# DocsAgent will show which docs have missing source files

# Step 3: Delete orphans (with confirmation)
delete orphaned docs

# Or delete specific ones
delete docs for Assets/Scripts/Deprecated/OldClass.cs
```

### Workflow 4: Documentation Audit

```
# Step 1: Generate coverage report
report coverage

# Step 2: Identify high-priority undocumented files
list undocumented

# Step 3: Document priority files
create docs for Assets/Scripts/Core/GameManager.cs

# Step 4: Update pattern catalog
update pattern catalog
```

---

## Best Practices

### Documentation Standards

1. **Document Public APIs First**
   - Focus on classes with public methods
   - Prioritize Manager, Controller, and Service classes
   - Document interfaces and base classes

2. **Keep Documentation Atomic**
   - One documentation folder per major class/feature
   - Split large features into sub-documents
   - Use ADRs for design decisions

3. **Maintain Pattern Links**
   - Always link to PatternCatalog.md when patterns are detected
   - Keep bi-directional links (pattern -> usage, usage -> pattern)

### Source Code Conventions

For best documentation quality, follow these conventions in your C# code:

```csharp
/// <summary>
/// Brief description of the class.
/// </summary>
public class WellDocumentedClass : MonoBehaviour
{
    /// <summary>
    /// Description of field purpose.
    /// </summary>
    [SerializeField]
    [Tooltip("Shown in Inspector")]
    private float speed = 5f;

    /// <summary>
    /// Description of method.
    /// </summary>
    /// <param name="target">Parameter description.</param>
    /// <returns>Return value description.</returns>
    public bool DoSomething(Transform target)
    {
        // Implementation
    }
}
```

### Version Control Integration

1. **Commit Documentation with Code**
   ```bash
   # After updating code
   git add Assets/Scripts/Feature.cs
   git add Documentation/tdd/Feature/
   git commit -m "feat: add Feature with documentation"
   ```

2. **Use Meaningful Commits**
   ```bash
   git commit -m "docs: update PlayerController documentation for new abilities"
   ```

3. **Review Before Committing**
   ```
   preview update for Assets/Scripts/ChangedFile.cs
   ```

### DMMS Management

1. **Regular Commits**
   - Commit DMMS changes after documentation updates
   - Use descriptive commit messages

2. **Backup Strategy**
   - DMMS data is stored in `.dmms/` directory
   - Include in version control or backup separately

3. **Branch Awareness**
   - DMMS tracks current branch state
   - Checkout syncs ChromaDB with branch content

---

## Configuration

### DocsAgent Prompt Customization

The agent behavior is controlled by `Prompts/DocsAgentPrompt.md`. Key sections:

| Section | Purpose |
|---------|---------|
| Agent Boundaries | Files the agent can/cannot modify |
| Documentation Structure | Required sections in generated docs |
| Output Format | Markdown templates and naming conventions |
| Error Handling | How to handle various error scenarios |

### Customizing Documentation Templates

Edit `Prompts/DocsAgentPrompt.md` to change:

- Required documentation sections
- Markdown formatting
- File naming conventions
- Pattern detection rules

### DMMS Configuration

Environment variables for DMMS:

| Variable | Description | Default |
|----------|-------------|---------|
| `DMMS_DATA_DIR` | Directory for DMMS data | `./.dmms` |
| `CHROMA_PERSIST_DIR` | ChromaDB persistence | `{DMMS_DATA_DIR}/chroma` |

---

## FAQ

### General Questions

**Q: Can DocsAgent document any C# file?**

A: DocsAgent is optimized for Unity3D C# scripts (MonoBehaviour, ScriptableObject, etc.) but can document any C# class. Unity-specific features like lifecycle methods and serialized fields receive special handling.

**Q: Does DocsAgent modify my source code?**

A: No. DocsAgent only reads source files and writes to the `Documentation/` folder. It never modifies your C# code.

**Q: How does DocsAgent detect code changes?**

A: DocsAgent calculates SHA256 hashes of source files and compares them with stored hashes in DMMS. It also integrates with Git to detect changes via `git diff`.

**Q: Can I edit generated documentation manually?**

A: Yes. DocsAgent preserves manual edits in certain sections (Patterns Used, ADRs, Desired Improvements). Tables and auto-generated sections may be overwritten during updates.

### Pattern Detection

**Q: What patterns does DocsAgent detect?**

A: Currently supported patterns:
- Singleton
- Observer/Event
- Command
- State Machine
- Factory
- Object Pool
- MonoBehaviour Lifecycle
- Serialized Field
- Component
- ScriptableObject Config

**Q: What does confidence level mean?**

A: Confidence indicates how certain the detection is:
- **HIGH**: Clear pattern implementation (e.g., `public static Instance` property)
- **MEDIUM**: Partial pattern indicators
- **LOW**: Ambiguous, may be false positive

### DMMS & Version Control

**Q: What is DMMS?**

A: DMMS (Document Management & Mapping System) is a vector database (ChromaDB) with Dolt version control for tracking documentation mappings. It enables semantic search and change tracking.

**Q: Do I need to commit DMMS changes separately?**

A: Yes. DMMS has its own commit system. After documentation changes:
```
Commit DMMS changes with message "Updated documentation for Feature X"
```

**Q: Can I use DocsAgent without DMMS?**

A: DMMS is recommended but not strictly required. Without DMMS, you lose:
- Duplicate detection
- Stale documentation detection
- Coverage reporting
- Relationship tracking

---

## Troubleshooting

### Common Issues

#### "Documentation template not found"

**Cause**: The `Documentation/` folder doesn't exist or is missing required files.

**Solution**:
```bash
git clone https://github.com/PieterPrespective/Unity3D-Documentation-Template Documentation
```

#### "DMMS collection 'docs-agent' not found"

**Cause**: DMMS collection hasn't been initialized.

**Solution**:
```
Create DMMS collection 'docs-agent' for documentation tracking
```

#### "Hash mismatch - documentation may be stale"

**Cause**: Source file changed since documentation was last updated.

**Solution**:
```
update docs for {path}
```

#### "Cannot parse C# file"

**Cause**: File contains syntax errors or unsupported constructs.

**Solution**:
- Fix syntax errors in source file
- DocsAgent will attempt partial documentation
- Check for unusual C# features (records, source generators)

#### "Boundary violation - cannot modify file"

**Cause**: Attempted to modify a protected file (scripts/, docfx.json, etc.).

**Solution**: This is by design. DocsAgent cannot modify template files. If you need changes to those files, edit them manually.

#### "Orphan detected but source exists"

**Cause**: Path mismatch between DMMS record and actual file location.

**Solution**:
```
# Delete the orphaned DMMS entry
delete docs for {old-path}

# Re-create documentation with correct path
create docs for {correct-path}
```

### DMMS Issues

#### "DMMS connection error"

**Cause**: DMMS MCP server is not running or misconfigured.

**Solution**:
1. Verify MCP server configuration in Claude Code settings
2. Check DMMS_DATA_DIR environment variable
3. Restart Claude Code to reload MCP servers

#### "ChromaDB persistence error"

**Cause**: Permission issues or disk space problems.

**Solution**:
1. Check write permissions on `.dmms/` directory
2. Verify available disk space
3. Try deleting `.dmms/chroma/` and re-initializing

### Diagram Issues

#### "Diagrams not generating"

**Cause**: Draw.io XML generation may fail for complex classes.

**Solution**:
- Simplify class structure
- Check for unusual characters in class/method names
- Generate diagram manually as fallback

#### "SVG not appearing in documentation"

**Cause**: `make-diagram-images.ps1` hasn't been run.

**Solution**:
```powershell
cd Documentation/scripts
./make-diagram-images.ps1
```

---

## Known Limitations

### Current Limitations

| Limitation | Description | Workaround |
|------------|-------------|------------|
| **C# Only** | Only C# files are supported | Manual documentation for other file types |
| **No Unity Editor** | Cannot run from Unity Editor | Use Claude Code CLI |
| **No Real-time Watch** | Doesn't auto-update on file save | Run update commands manually |
| **Single Project** | One project per DMMS instance | Separate DMMS instances per project |
| **English Only** | Documentation generated in English | Manual translation if needed |

### File Type Limitations

| File Type | Support Level | Notes |
|-----------|---------------|-------|
| `.cs` (Scripts) | Full | Primary focus |
| `.prefab` | Not supported | Future enhancement |
| `.unity` (Scenes) | Not supported | Future enhancement |
| `.asset` (ScriptableObject) | Not supported | Future enhancement |
| `.shader` | Not supported | Out of scope |
| `.asmdef` | Not supported | Out of scope |

### Pattern Detection Limitations

- **False Positives**: Some patterns may be incorrectly detected
- **Context Blind**: Cannot understand semantic intent
- **No Custom Patterns**: Cannot add user-defined patterns currently

### Documentation Generation Limitations

- **No Inheritance Docs**: Base class documentation not inherited
- **No Cross-Project**: Cannot reference external projects
- **No Runtime Analysis**: Based on static code analysis only

### DMMS Limitations

- **Local Only**: No built-in cloud sync (use Git for sharing)
- **Single Writer**: Not designed for concurrent access
- **Size Limits**: Very large codebases may be slow

---

## Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        Claude Code                           │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                    DocsAgent                         │    │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐         │    │
│  │  │  CREATE   │ │  UPDATE   │ │  DELETE   │         │    │
│  │  └───────────┘ └───────────┘ └───────────┘         │    │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐         │    │
│  │  │ Patterns  │ │ Coverage  │ │ Relations │         │    │
│  │  └───────────┘ └───────────┘ └───────────┘         │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
           │                    │                    │
           ▼                    ▼                    ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│   Source Files   │  │   DMMS Server    │  │  Documentation   │
│  Assets/Scripts/ │  │  (ChromaDB+Dolt) │  │  Documentation/  │
└──────────────────┘  └──────────────────┘  └──────────────────┘
```

### Data Flow

```
Source File (.cs)
       │
       ▼
┌──────────────────┐
│   Parse & Hash   │
└──────────────────┘
       │
       ├──────────────────┐
       ▼                  ▼
┌──────────────┐   ┌──────────────┐
│  Generate    │   │  Store in    │
│  Markdown    │   │  DMMS        │
└──────────────┘   └──────────────┘
       │                  │
       ▼                  ▼
┌──────────────┐   ┌──────────────┐
│ Save to      │   │ Update       │
│ Documentation│   │ toc.yml      │
└──────────────┘   └──────────────┘
```

### DMMS Document Schema

```json
{
  "id": "Assets_Scripts_Feature_ClassName",
  "document": "Documentation mapping description",
  "metadata": {
    "source_type": "script",
    "source_path": "Assets/Scripts/Feature/ClassName.cs",
    "source_hash": "a1b2c3d4",
    "doc_path": "Documentation/tdd/ClassName/index.md",
    "diagrams": ["ClassName-class-diagram.drawio"],
    "last_updated": "ISO-8601-timestamp",
    "last_commit_documented": "git-commit-hash",
    "documented_classes": ["ClassName"],
    "documented_methods": ["Method1", "Method2"],
    "patterns_detected": ["singleton", "observer"],
    "pattern_instances": [
      {"pattern": "observer", "location": "ClassName.cs:42", "confidence": "high"}
    ],
    "relationships": {
      "inherits_from": ["MonoBehaviour"],
      "implements": ["IInterface"],
      "depends_on": ["OtherClass"],
      "composed_of": ["ComponentA"],
      "referenced_by": ["ConsumerClass"]
    },
    "change_history": [
      {"date": "ISO-8601", "type": "create", "commit": "hash"},
      {"date": "ISO-8601", "type": "update", "commit": "hash", "changes": "description"}
    ]
  }
}
```

---

## Installing DocsAgent Sub-Agent

DocsAgent is packaged as a Claude Code sub-agent that can be installed in any project. This section explains how to set it up.

### Prerequisites

Before installing DocsAgent, ensure you have:

1. **Claude Code CLI** installed and configured
2. **DMMS MCP Server** set up (see [Prerequisites & Setup](#prerequisites--setup))
3. **Documentation template** cloned to your project

### Installation Steps

#### Step 1: Create the Agents Directory

```bash
# From your project root
mkdir -p .claude/agents
```

#### Step 2: Copy the Sub-Agent Definition

Copy the sub-agent file from the Documentation folder:

```bash
# From your project root
cp Documentation/agent/subagent/docs-agent.md .claude/agents/
```

Or manually copy the file:
- **Source**: `Documentation/agent/subagent/docs-agent.md`
- **Destination**: `.claude/agents/docs-agent.md`

#### Step 3: Verify DMMS MCP Server Configuration

Ensure your Claude Code MCP settings include the DMMS server. Check or create the configuration:

**Project-level** (`.claude/settings.local.json`):
```json
{
  "mcpServers": {
    "dmms-projectSetup": {
      "command": "uv",
      "args": [
        "run",
        "--directory",
        "C:/path/to/dmms-mcp-server",
        "dmms-mcp-server"
      ],
      "env": {
        "DMMS_DATA_DIR": "./.dmms"
      }
    }
  }
}
```

**User-level** (`~/.claude/settings.json`):
```json
{
  "mcpServers": {
    "dmms-projectSetup": {
      "command": "uv",
      "args": [
        "run",
        "--directory",
        "/path/to/dmms-mcp-server",
        "dmms-mcp-server"
      ]
    }
  }
}
```

#### Step 4: Initialize DMMS Collection

Start Claude Code and initialize the docs-agent collection:

```
Create a DMMS collection named 'docs-agent' for documentation tracking
```

#### Step 5: Verify Installation

Test that the sub-agent is recognized:

```
@docs-agent check docs for Assets/Scripts/
```

Or simply try a documentation command - Claude should automatically delegate to DocsAgent:

```
create docs for Assets/Scripts/MyClass.cs
```

### Alternative: User-Level Installation

To make DocsAgent available across all your projects:

```bash
# Copy to user-level agents folder
mkdir -p ~/.claude/agents
cp Documentation/agent/subagent/docs-agent.md ~/.claude/agents/
```

### Sub-Agent File Location

The sub-agent definition is stored in:

| Location | File |
|----------|------|
| Project template | `Documentation/agent/subagent/docs-agent.md` |
| Active (project) | `.claude/agents/docs-agent.md` |
| Active (user) | `~/.claude/agents/docs-agent.md` |

### Verifying Sub-Agent Registration

You can verify DocsAgent is registered by using the `/agents` slash command in Claude Code:

```
/agents
```

This will list all available sub-agents, including `docs-agent` if properly installed.

### Updating the Sub-Agent

To update DocsAgent to a newer version:

1. Get the updated `docs-agent.md` from the Documentation template
2. Replace the file in `.claude/agents/` (or `~/.claude/agents/`)
3. Restart Claude Code to reload the agent definition

### Troubleshooting Installation

| Issue | Solution |
|-------|----------|
| Agent not recognized | Verify file is in `.claude/agents/` with `.md` extension |
| DMMS tools unavailable | Check MCP server configuration and restart Claude Code |
| Permission errors | Ensure DMMS_DATA_DIR is writable |
| Agent not auto-delegating | Use explicit `@docs-agent` prefix |

---

## Support & Resources

### Related Documentation

- `Documentation/agent/DocsAgentPrompt.md` - Agent instructions and configuration
- `Documentation/agent/DocsAgentDiagrams.md` - Diagram generation templates
- `Documentation/agent/subagent/docs-agent.md` - Sub-agent definition (copy to `.claude/agents/`)
- `Documentation/agent/references/` - Reference documentation
- `Documentation/tdd/PatternCatalog.md` - Pattern definitions and usage
- `Documentation/tdd/Index.md` - Documentation overview

### Version History

| Version | Date | Features |
|---------|------|----------|
| 1.0 | 2026-01-12 | CREATE operation, DMMS integration |
| 2.0 | 2026-01-12 | Diagram generation |
| 3.0 | 2026-01-12 | UPDATE operation, Git integration |
| 4.0 | 2026-01-13 | DELETE, PatternCatalog, Coverage, Relationships |

---

*DocsAgent User Guide v4.0*
*Generated: 2026-01-13*

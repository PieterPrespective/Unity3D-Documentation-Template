# DocsAgent - Agent Files

This folder contains all files required for the DocsAgent sub-agent to function. All references are self-contained within the `Documentation/` folder structure.

## Sub-Agent Registration

The DocsAgent is distributed as a Claude Code sub-agent definition file that must be copied to the `.claude/agents/` folder to activate.

**Template location**: `Documentation/agent/subagent/docs-agent.md`
**Active location**: `.claude/agents/docs-agent.md`

See [UserGuide.md](UserGuide.md#installing-docsagent-sub-agent) for installation instructions.

## Folder Structure

```
Documentation/agent/
├── README.md                 # This file
├── DocsAgentPrompt.md        # Full agent prompt/instructions (v4.0)
├── DocsAgentDiagrams.md      # Draw.io diagram generation templates
├── UserGuide.md              # Comprehensive user guide
├── subagent/                 # Sub-agent definition (copy to .claude/agents/)
│   └── docs-agent.md         # Claude Code sub-agent file
└── references/               # Reference documentation
    ├── Unity3D_TDD_Research.md   # TDD best practices for Unity
    └── TDDBasePrompt.md          # TDD section requirements
```

**External References** (from Documentation template):
- `Documentation/docsgen/adding-subtopic.md` - DocFX subtopic guide

## File Descriptions

| File | Purpose |
|------|---------|
| `DocsAgentPrompt.md` | The main agent instructions defining behavior, boundaries, workflows, and command patterns |
| `DocsAgentDiagrams.md` | XML templates and instructions for generating Draw.io class and sequence diagrams |
| `UserGuide.md` | End-user documentation covering setup, commands, workflows, FAQ, and troubleshooting |
| `subagent/docs-agent.md` | Claude Code sub-agent definition file (copy to `.claude/agents/` to activate) |
| `references/Unity3D_TDD_Research.md` | Research on TDD best practices specific to Unity3D projects (may be removed by user) |
| `references/TDDBasePrompt.md` | Template defining required sections for feature documentation |

## Using DocsAgent

### As a Claude Code Sub-Agent (Recommended)

DocsAgent is registered as a proper Claude Code sub-agent at `.claude/agents/docs-agent.md`.

Claude will automatically delegate documentation tasks to this agent when you use commands like:
- "create docs for Assets/Scripts/Player.cs"
- "update docs from git changes"
- "find orphaned docs"
- "report coverage"

You can also explicitly invoke it:
```
@docs-agent create docs for Assets/Scripts/MyClass.cs
```

### Manual Invocation (Alternative)

To invoke DocsAgent manually by referencing the full prompt:

```
Read Documentation/agent/DocsAgentPrompt.md and follow its instructions to [command]
```

### Available Commands

| Category | Example Commands |
|----------|------------------|
| CREATE | `create docs for Assets/Scripts/Player.cs` |
| UPDATE | `update docs from git changes` |
| DELETE | `find orphaned docs`, `delete docs for {path}` |
| QUERY | `check docs for {path}`, `check stale docs` |
| PATTERN | `scan patterns`, `update pattern catalog` |
| COVERAGE | `report coverage`, `list undocumented` |
| RELATIONSHIP | `show relationships for {path}` |

## Requirements

- DMMS MCP Server configured and running
- `docs-agent` collection initialized in DMMS
- Documentation template cloned to `Documentation/` folder

## Version History

| Version | Date | Features |
|---------|------|----------|
| 1.0 | 2026-01-12 | CREATE operation, DMMS integration |
| 2.0 | 2026-01-12 | Diagram generation |
| 3.0 | 2026-01-12 | UPDATE operation, Git integration |
| 4.0 | 2026-01-13 | DELETE, PatternCatalog, Coverage, Relationships |

---

*DocsAgent v4.0 - Self-contained agent files*

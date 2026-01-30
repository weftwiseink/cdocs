# CLocs

A Claude Code plugin for structured development documentation.

CLocs provides skills, rules, and hooks for creating and managing devlogs, proposals, reviews, and reports with consistent formatting, frontmatter metadata, and writing conventions.

## Installation

```bash
# Clone the plugin
git clone https://github.com/weftwiseink/clocs ~/.claude/clocs-plugin

# Option A: Per-session
claude --plugin-dir ~/.claude/clocs-plugin

# Option B: Enable in user settings (~/.claude/settings.json)
# "enabledPlugins": { "cloc": true }
```

## Quick Start

```
/cloc:init              # Scaffold clocs/ in your project
/cloc:devlog my_feature # Create a devlog (also auto-created by Claude)
/cloc:propose my_topic # Author a design proposal
/cloc:review path/to/doc.md  # Review a document
/cloc:report my_topic   # Generate a report
/cloc:status            # List all docs with metadata
/cloc:status --type=proposal --status=wip  # Filter docs
```

## Skills

| Skill | Description |
|-------|-------------|
| `/cloc:init` | Scaffold `clocs/` directory structure in a project |
| `/cloc:devlog` | Create a development log |
| `/cloc:propose` | Author a design proposal with structured sections |
| `/cloc:review` | Review a document with findings and verdict |
| `/cloc:report` | Generate a report (status, investigation, incident, audit, retrospective) |
| `/cloc:status` | Query and manage document metadata |

Any skill can be invoked by the user or auto-invoked by Claude depending on context.
Devlogs are most commonly auto-invoked; proposals, reviews, and reports are typically user-requested.

## Rules

Loaded automatically when the plugin is active:

- **`writing-conventions.md`:** BLUF, brevity, callout syntax, sentence-per-line, critical analysis.
- **`workflow-patterns.md`:** Parallel agent dispatch, subagent-driven development, completeness checklists.
- **`frontmatter-spec.md`:** YAML frontmatter field definitions and valid values (scoped to `clocs/**/*.md`).

## Hooks

- **PostToolUse (Write|Edit):** Validates frontmatter on clocs files. Informational warnings only (non-blocking).

## Document Types

| Type | Directory | Purpose |
|------|-----------|---------|
| Devlog | `clocs/devlogs/` | Working logs of development sessions |
| Proposal | `clocs/proposals/` | Design and solution specifications |
| Review | `clocs/reviews/` | Structured document reviews with verdicts |
| Report | `clocs/reports/` | Audience-facing findings and analysis |

All documents use `YYYY-MM-DD-dash-case.md` naming and require YAML frontmatter.

## License

MIT

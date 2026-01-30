# CDocs

A Claude Code plugin for structured development documentation.

CDocs provides skills, rules, and hooks for creating and managing devlogs, proposals, reviews, and reports with consistent formatting, frontmatter metadata, and writing conventions.

## Installation

```bash
# Clone the plugin
git clone https://github.com/weftwiseink/cdocs ~/.claude/cdocs-plugin

# Option A: Per-session
claude --plugin-dir ~/.claude/cdocs-plugin

# Option B: Enable in user settings (~/.claude/settings.json)
# "enabledPlugins": { "cdocs": true }
```

## Quick Start

```
/cdocs:init              # Scaffold cdocs/ in your project
/cdocs:devlog my_feature # Create a devlog (also auto-created by Claude)
/cdocs:propose my_topic # Author a design proposal
/cdocs:review path/to/doc.md  # Review a document
/cdocs:report my_topic   # Generate a report
/cdocs:status            # List all docs with metadata
/cdocs:status --type=proposal --status=wip  # Filter docs
```

## Skills

| Skill | Description |
|-------|-------------|
| `/cdocs:init` | Scaffold `cdocs/` directory structure in a project |
| `/cdocs:devlog` | Create a development log |
| `/cdocs:propose` | Author a design proposal with structured sections |
| `/cdocs:review` | Review a document with findings and verdict |
| `/cdocs:report` | Generate a report (status, investigation, incident, audit, retrospective) |
| `/cdocs:status` | Query and manage document metadata |

Any skill can be invoked by the user or auto-invoked by Claude depending on context.
Devlogs are most commonly auto-invoked; proposals, reviews, and reports are typically user-requested.

## Rules

Loaded automatically when the plugin is active:

- **`writing-conventions.md`:** BLUF, brevity, callout syntax, sentence-per-line, critical analysis.
- **`workflow-patterns.md`:** Parallel agent dispatch, subagent-driven development, completeness checklists.
- **`frontmatter-spec.md`:** YAML frontmatter field definitions and valid values (scoped to `cdocs/**/*.md`).

## Hooks

- **PostToolUse (Write|Edit):** Validates frontmatter on cdocs files. Informational warnings only (non-blocking).

## Document Types

| Type | Directory | Purpose |
|------|-----------|---------|
| Devlog | `cdocs/devlogs/` | Working logs of development sessions |
| Proposal | `cdocs/proposals/` | Design and solution specifications |
| Review | `cdocs/reviews/` | Structured document reviews with verdicts |
| Report | `cdocs/reports/` | Audience-facing findings and analysis |

All documents use `YYYY-MM-DD-dash-case.md` naming and require YAML frontmatter.

## License

MIT

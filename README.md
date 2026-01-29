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
/cdocs:proposal my_topic # Author a design proposal
/cdocs:review path/to/doc.md  # Review a document
/cdocs:report my_topic   # Generate a report
/cdocs:status            # List all docs with metadata
/cdocs:status --type=proposal --status=wip  # Filter docs
```

## Skills

| Skill | Type | Description |
|-------|------|-------------|
| `/cdocs:init` | Infrastructure | Scaffold `cdocs/` directory structure in a project |
| `/cdocs:devlog` | Infrastructure | Create a development log (auto-invoked by Claude on substantive work) |
| `/cdocs:proposal` | Deliverable | Author a design proposal with structured sections |
| `/cdocs:review` | Deliverable | Review a document with findings and verdict |
| `/cdocs:report` | Deliverable | Generate a report (status, investigation, incident, audit, retrospective) |
| `/cdocs:status` | Infrastructure | Query and manage document metadata |

**Infrastructure skills** are auto-invoked by Claude or used for system management.
**Deliverable skills** are explicitly requested by the user.

## Rules

Loaded automatically when the plugin is active:

- **`writing_conventions.md`:** BLUF, brevity, callout syntax, sentence-per-line, critical analysis.
- **`workflow_patterns.md`:** Parallel agent dispatch, subagent-driven development, completeness checklists.
- **`frontmatter_spec.md`:** YAML frontmatter field definitions and valid values (scoped to `cdocs/**/*.md`).

## Hooks

- **PostToolUse (Write|Edit):** Validates frontmatter on cdocs files. Informational warnings only (non-blocking).

## Document Types

| Type | Directory | Purpose |
|------|-----------|---------|
| Devlog | `cdocs/devlogs/` | Working logs of development sessions |
| Proposal | `cdocs/proposals/` | Design and solution specifications |
| Review | `cdocs/reviews/` | Structured document reviews with verdicts |
| Report | `cdocs/reports/` | Audience-facing findings and analysis |

All documents use `YYYY-MM-DD_snake_case.md` naming and require YAML frontmatter.

## License

MIT

---
first_authored:
  by: "@claude-opus-4-5-20251101"
  at: 2026-01-29T17:00:00-08:00
task_list: marketplace/restructure
type: proposal
state: live
status: implementation_ready
tags: [architecture, marketplace, rename]
---

# Marketplace Restructure and clocs→clocs Rename

> BLUF: Restructure the repo from a single plugin into a Claude Code marketplace, moving plugin components under `plugins/clocs/` with a root `marketplace.json`.
> Rename `clocs` to `clocs` (short for CircumLOCutory; also a play on CLaude + docs).
> Install the plugin in the repo itself for dogfooding via `.claude/settings.json`.

## Objective

Convert this repository from a single Claude Code plugin into a marketplace that can host multiple plugins.
The existing plugin gets renamed from `cloc`/`clocs` to `cloc`/`clocs` and moved under `plugins/clocs/`.

## Background

The repo currently uses the single-plugin layout (`.claude-plugin/plugin.json` at root).
Claude Code supports a marketplace format: `.claude-plugin/marketplace.json` at root, with plugins in subdirectories.
The `clocs-plan.md` noted this as a future possibility.

The Claude Code marketplace docs specify:
- `.claude-plugin/marketplace.json` at repo root with `name`, `owner`, `plugins[]` fields.
- Each plugin entry has `name`, `source` (relative path), and optional metadata.
- Each plugin directory contains its own `.claude-plugin/plugin.json`, `rules/`, `skills/`, `hooks/`.
- Plugins are copied to a cache on install, so they cannot reference files outside their directory.

## Proposed Solution

### New Layout

```
/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace catalog
├── plugins/
│   └── clocs/
│       ├── .claude-plugin/
│       │   └── plugin.json       # Plugin metadata (name: "cloc")
│       ├── rules/                # Writing conventions, workflow, frontmatter spec
│       ├── skills/               # devlog, propose, review, report, status, init, implement
│       └── hooks/                # Frontmatter validation hook
├── clocs/                        # Dogfood docs (our own docs using the plugin)
├── .claude/
│   └── settings.json             # Marketplace + plugin enable for dogfooding
├── CLAUDE.md
├── README.md                     # Updated for marketplace context
├── clocs-plan.md
├── LICENSE
└── .gitignore
```

### Rename Scope

| Old | New | Context |
|-----|-----|---------|
| `cloc` | `cloc` | Plugin name, skill prefix (`/cloc:devlog`) |
| `clocs` | `clocs` | Directory names, path references |
| `CLocs` | `CLocs` | Titles, headings |
| `clocs-validate-frontmatter.sh` | `clocs-validate-frontmatter.sh` | Hook script |

### Dogfooding

`.claude/settings.json` will reference the marketplace via GitHub so the plugin is active when working in this repo:
```json
{
  "extraKnownMarketplaces": {
    "weft-marketplace": {
      "source": {
        "source": "github",
        "repo": "weftwiseink/clocs"
      }
    }
  },
  "enabledPlugins": {
    "clocs@weft-marketplace": true
  }
}
```

NOTE(mjr): For local development, add the marketplace locally via `/plugin marketplace add .` to use unpushed changes.

## Important Design Decisions

### Decision: marketplace name `weft-marketplace`

**Why:** Neutral, org-level name that can host plugins beyond clocs in the future.

### Decision: keep `clocs/` docs directory at repo root

**Why:** The docs directory is not part of the plugin (it is output produced by using the plugin).
It stays at repo root for dogfooding.
Plugins are copied to cache on install, so plugin consumers create their own `clocs/` in their repos via `/cloc:init`.

### Decision: fix hook script name mismatch during rename

**Why:** `hooks.json` references `clocs_validate_frontmatter.sh` (underscores) but the file uses dashes.
The rename normalizes to `clocs-validate-frontmatter.sh` with a matching hooks.json reference.

## Implementation Phases

### Phase 1: Structural moves

1. Create `plugins/clocs/.claude-plugin/` directory.
2. `git mv rules/ plugins/clocs/rules/`
3. `git mv skills/ plugins/clocs/skills/`
4. `git mv hooks/ plugins/clocs/hooks/`
5. Remove `.claude-plugin/plugin.json`, create `.claude-plugin/marketplace.json`.
6. Create `plugins/clocs/.claude-plugin/plugin.json`.
7. `git mv clocs/ clocs/`
8. `git mv clocs-plan.md clocs-plan.md`

### Phase 2: Content rename

Search-and-replace across all files:
- `clocs` → `clocs`
- `cloc` → `cloc`
- `CLocs` → `CLocs`
- Fix hook filename in `hooks.json`.
- Update README.md for marketplace framing.
- Update CLAUDE.md references.

### Phase 3: Dogfooding setup

1. Create `.claude/settings.json` with marketplace and plugin config.
2. Verify with `claude plugin validate .` if available.

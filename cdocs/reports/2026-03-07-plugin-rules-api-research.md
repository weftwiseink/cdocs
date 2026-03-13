---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-07T00:00:00-05:00
task_list: cdocs/plugin-rules-research
type: report
state: live
status: complete
tags: [research, plugin-api, rules, analysis]
---

# Plugin Rules API: Can Plugins Declare Rules for Installing Projects?

> BLUF: Plugins **cannot** declare rules that become @-mentionable or auto-loaded in installing projects.
> There is no `rules` field in `plugin.json`.
> This is a known gap with an open feature request ([#14200](https://github.com/anthropics/claude-code/issues/14200), filed Dec 2025, still open as of Mar 2026).
> Viable workarounds exist (plugin `CLAUDE.md`, `SessionStart` hook injection) but none match the ergonomics of native rules support.

## Context / Background

The cdocs plugin (`plugins/cdocs/`) ships three rules files:

| File | Scope | Purpose |
|------|-------|---------|
| `writing-conventions.md` | Global | BLUF, brevity, sentence-per-line, callout syntax |
| `workflow-patterns.md` | Global | Parallel agents, subagent workflows, completeness checklists |
| `frontmatter-spec.md` | `cdocs/**/*.md` | YAML frontmatter field definitions |

These rules are essential to cdocs agents (nit-fix, reviewer, triage) and are referenced in this repo's `CLAUDE.md` via `@plugins/cdocs/rules/...` imports.
The `@`-import syntax works here only because this is the source repo — the files are local.
For external users who install cdocs via marketplace, the rules files land in `~/.claude/plugins/cache/` but are **not** loaded as rules, not @-mentionable, and not visible in `/memory`.

Prior repo research on this topic exists in:
- `cdocs/proposals/2026-01-29-cdocs-plugin-architecture.md` — plugin architecture design
- `cdocs/proposals/2026-01-30-nit-fix-project-rules.md` — RFP for multi-source rule discovery

## Key Findings

### 1. No `rules` field in `plugin.json`

The plugin manifest schema supports: `commands`, `agents`, `skills`, `hooks`, `mcpServers`, `outputStyles`, `lspServers`.
Rules are absent.
The [Plugins reference](https://code.claude.com/docs/en/plugins-reference) documents every supported field and `rules` is not among them.

### 2. Open feature request with community support

- **[#14200](https://github.com/anthropics/claude-code/issues/14200)**: "Add rules support to Plugins" (Dec 16 2025, open, labeled `enhancement` + `area:core`).
  Multiple +1 comments including one with 27 thumbs-up.
  Most recent activity: Mar 3 2026.
  No visible Anthropic staff response.
- **[#21163](https://github.com/anthropics/claude-code/issues/21163)**: "Support rules field in plugin.json" (Jan 27 2026, closed as duplicate of #14200).
  Detailed proposal including `"rules": "./rules"` manifest field.
  Cites `everything-claude-code` plugin shipping 8 rules files that users must manually copy.

### 3. `@`-import is a CLAUDE.md feature, not a plugin feature

The `@path/to/file` syntax in CLAUDE.md resolves relative to the containing file's location.
It is a general file-include mechanism, not plugin-aware.
When a user installs cdocs from a marketplace, their project's CLAUDE.md cannot reference `@plugins/cdocs/rules/writing-conventions.md` — the path doesn't resolve to the plugin cache.

### 4. Plugin CLAUDE.md provides partial coverage

A `CLAUDE.md` file at a plugin's root directory is loaded into context when the plugin is active.
This is the closest existing mechanism to "plugin rules."
Limitations:
- Loaded as general context, not as `.claude/rules/` entries.
- Does not support `paths:` frontmatter scoping.
- Not visible in `/memory` as a rules file.
- Cannot be `@`-mentioned from the installing project.
- Single file, not a directory of modular rules.

### 5. `InstructionsLoaded` hook is observe-only

The `InstructionsLoaded` hook fires when CLAUDE.md and `.claude/rules/*.md` files load.
Input includes `file_path`, `memory_type`, and `load_reason`.
However, it provides no decision control — purely observational.
A plugin cannot use it to inject additional rules.

### 6. `SessionStart` hook can inject context

The `SessionStart` hook can return `additionalContext`, which is injected into the session.
This could be used to inject rules content at session start.
Limitation: it is free-form context, not structured rules with path scoping or `/memory` visibility.

## How CDocs Agents Currently Load Rules

The agents work around the lack of plugin-level rule declaration:

| Agent | Strategy | Limitation |
|-------|----------|------------|
| nit-fix | Globs `plugins/cdocs/rules/*.md` at startup | Path is relative to repo root; breaks for external installs |
| reviewer | Hardcodes two specific rule paths | Same path-resolution issue |
| triage | Hardcodes `frontmatter-spec.md` path | Same |

All three rely on rules being co-located in the repo.
For external installs, agents would need to resolve paths relative to the plugin cache directory.

## Workarounds Available Today

### A. Plugin `CLAUDE.md` (simplest)

Create `plugins/cdocs/CLAUDE.md` containing or inlining key rules content.
Auto-loaded when plugin is active.
Does not support scoping or modularity.

### B. `SessionStart` hook injection

Add a `SessionStart` hook that reads `rules/*.md` from the plugin directory and returns their content as `additionalContext`.
Provides full content at session start.
No path scoping, no `/memory` integration.

### C. Agent-relative path resolution

Update agent startup instructions to resolve rules relative to a plugin root variable (e.g., `${CLAUDE_PLUGIN_ROOT}/rules/*.md`).
This would make agents work from the cache directory for external installs.
Rules still wouldn't be project-visible or @-mentionable.

### D. Post-install documentation

Document that users should copy `rules/` to their `.claude/rules/cdocs/` directory.
Fragile — rules drift from plugin updates.

## Recent Plugin System Changes (Not Rules-Related)

For completeness, recent plugin system improvements that did *not* address the rules gap:

- `/reload-plugins` command for hot-reloading.
- `ConfigChange` hook for watching config file changes.
- LSP server plugin support.
- Plugin hook deduplication fixes.
- `pluginTrustMessage` in managed settings.
- MCP server deduplication for plugin-provided servers.

## Recommendations

1. **Short term: adopt workaround B (SessionStart hook)**.
   Inject rules content via `additionalContext` at session start.
   This gives external installers the rules content without manual copying.
   Pair with workaround C (agent-relative paths) so cdocs agents resolve rules from the plugin cache.

2. **Track [#14200](https://github.com/anthropics/claude-code/issues/14200)**.
   The issue has community support but no Anthropic response yet.
   Consider adding a comment describing the cdocs use case — a plugin with scoped rules that agents consume at runtime — to strengthen the case.

3. **Update `cdocs/proposals/2026-01-30-nit-fix-project-rules.md`**.
   The existing RFP for multi-source rule discovery assumed plugin rules support might arrive.
   Amend it to note the current status and incorporate the SessionStart workaround as an interim design.

4. **When native support lands: adopt `"rules": "./rules"` in plugin.json**.
   The proposed schema from #21163 aligns with how cdocs already structures its rules.
   Migration would be straightforward — add the manifest field and remove the hook workaround.

---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-16T12:00:00-07:00
task_list: marketplace/cross-target-rules
type: devlog
state: live
status: review_ready
tags: [implementation, rules, cross-target]
last_reviewed:
  status: accepted
  by: "@claude-opus-4-6"
  at: 2026-03-16T16:00:00-07:00
  round: 2
---

# Devlog: Cross-Target Rules Integration Implementation

> BLUF(claude-opus-4-6/cross-target-rules): Implementing the cross-target rules integration proposal to make cdocs rules work across CC external installs, OpenCode, and other agent tools via three delivery layers: SessionStart hook injection, agent path resolution updates, and AGENTS.md cross-tool fallback.

## Objective

Implement the proposal at `cdocs/proposals/2026-03-14-cross-target-rules-integration.md` across 6 phases:
1. SessionStart hook for CC external installs
2. Agent path resolution update (experimental)
3. `/cdocs:init` extension for OC
4. Plugin-level AGENTS.md
5. Cross-tool rule authoring audit
6. Documentation and README updates

## Implementation Notes

### Phase 1: SessionStart Hook

Created `plugins/cdocs/hooks/inject-rules.sh` and updated `hooks.json` with the SessionStart event.

Key decisions:
- The hook strips YAML frontmatter from rule files before injection, since frontmatter fields like `paths:` are only meaningful for CC's structured rule loading.
- Source-repo detection uses a grep for `@plugins/cdocs/rules/` in the project's CLAUDE.md to avoid duplicate injection.
- Uses `jq -Rs .` for JSON escaping (lighter than python3, commonly available).

### Phase 2: Agent Path Resolution

Updated three agents (nit-fix, triage, reviewer) to try relative paths first with fallback to source-repo paths.
This is experimental: the SessionStart hook (Phase 1) provides rules regardless, making this belt-and-suspenders.

### Phase 3: `/cdocs:init` OC Extension

Extended the init skill to detect OpenCode projects and create OC-compatible rule deployments:
- Detection via `opencode.json` or `.opencode/` directory
- Creates `.opencode/rules/cdocs/` with OC-enhanced frontmatter (`globs:`, `keywords:` with cdocs-prefixed terms)
- Creates or appends to AGENTS.md with inlined rule content
- Comment delimiters (`<!-- cdocs-rules-start -->` / `<!-- cdocs-rules-end -->`) for idempotent re-runs
- Version comment on deployed copies

### Phase 4: Plugin-Level AGENTS.md

Created `plugins/cdocs/AGENTS.md` with `@`-imports for the three rule files.
This serves as a cross-tool fallback: CC follows the `@`-imports, other tools see the heading structure.

### Phase 5: Cross-Tool Rule Authoring Audit

Audited all three rule files for CC-specific patterns.
Grep targets: `^@[a-zA-Z]` import patterns, `/memory` references, `plugin.json` references, `.claude/` references in body content.

### Phase 6: Documentation and README Updates

Updated `plugins/cdocs/README.md` with:
- Rules Integration section explaining the three delivery layers
- Rules in OpenCode subsection
- When CC #14200 Lands migration note
- Updated Hooks section mentioning the SessionStart hook

## Changes Made

| File | Change |
|------|--------|
| `plugins/cdocs/hooks/inject-rules.sh` | New: SessionStart hook script for rule injection |
| `plugins/cdocs/hooks/hooks.json` | Updated: Added SessionStart event |
| `plugins/cdocs/agents/nit-fix.md` | Updated: Relative path resolution with fallback |
| `plugins/cdocs/agents/triage.md` | Updated: Relative path resolution with fallback |
| `plugins/cdocs/agents/reviewer.md` | Updated: Relative path resolution with fallback |
| `plugins/cdocs/skills/init/SKILL.md` | Updated: OC detection and rule deployment |
| `plugins/cdocs/AGENTS.md` | New: Cross-tool rules fallback |
| `plugins/cdocs/README.md` | Updated: Rules integration documentation |

## Verification

### Phase 1: SessionStart Hook
- `inject-rules.sh` passes `bash -n` syntax check.
- `hooks.json` passes `jq .` validation.
- Hook reads from `${CLAUDE_PLUGIN_ROOT}/rules/`, strips YAML frontmatter via `awk`, escapes content via `jq -Rs .`, and outputs valid JSON with `additionalContext`.
- Source-repo skip logic greps for `@plugins/cdocs/rules/` in `${PWD}/CLAUDE.md`.

### Phase 2: Agent Path Resolution
- All three agents (nit-fix, triage, reviewer) updated to try relative paths first with fallback.
- Each agent includes a NOTE callout explaining that SessionStart context provides rules even if Glob paths fail.
- No behavioral or output format changes: only path references updated.

### Phase 3: `/cdocs:init` OC Extension
- Init SKILL.md extended with OC detection (step 5) and AGENTS.md generation (step 6).
- OC detection checks for `opencode.json` or `.opencode/` directory.
- Comment delimiters ensure idempotent re-runs.
- Version comment (`cdocs rules v0.1.0`) added for staleness detection.

### Phase 4: Plugin-Level AGENTS.md
- `plugins/cdocs/AGENTS.md` created with `@`-imports for three rule files.
- Uses relative paths (`@rules/*.md`) matching the plugin directory structure.

### Phase 5: Cross-Tool Rule Authoring Audit
- Grep for `^@[a-zA-Z]` in `plugins/cdocs/rules/`: zero matches.
- Grep for `/memory` in `plugins/cdocs/rules/`: zero matches.
- Grep for `plugin\.json` in `plugins/cdocs/rules/`: zero matches.
- Grep for `\.claude/` in `plugins/cdocs/rules/`: zero matches.
- All three rule files are already tool-neutral. No changes needed.

### Phase 6: Documentation and README Updates
- README updated with Rules Integration section, Rules in OpenCode subsection, When CC #14200 Lands migration note, and updated Hooks section.

### Deviations from Proposal
- The proposal mentions computing a content hash for version tracking in the SessionStart hook output. This was deferred as a progressive enhancement: it adds complexity to the hook for a feature that is only useful when combined with init-side hash comparison, which is not yet implemented.
- Phase 5 yielded no changes (rule files were already tool-neutral), so no commit was made for that phase.
- The proposal's Phase 6 mentions updating the nit-fix-project-rules RFP and CLAUDE.md. Per the task instructions ("Do NOT modify files outside `plugins/cdocs/` except for the devlog"), these cross-file updates were not made.

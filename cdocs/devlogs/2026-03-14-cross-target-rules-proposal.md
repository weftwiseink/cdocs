---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-14T14:30:00-07:00
task_list: marketplace/cross-target-rules
type: devlog
state: live
status: wip
tags: [rules, multi-target, proposal]
---

# Devlog: Cross-Target Rules Integration Proposal

> BLUF: Authored a proposal for making cdocs rules work across CC external installs and OpenCode, using three complementary delivery mechanisms (SessionStart hook, OC rules paths, AGENTS.md fallback).

## Objective

Write a `/cdocs:propose` document specifying how cdocs rules (writing-conventions, workflow-patterns, frontmatter-spec) should be delivered to agents in both Claude Code and OpenCode contexts.

## Research Review

Read and synthesized findings from three prior reports:

1. **Plugin Rules API Research** (`2026-03-07`): Confirmed CC has no `rules` field in `plugin.json`.
   Open FR #14200 with community support but no Anthropic response.
   Recommended SessionStart hook as interim workaround.

2. **Parity OpenCode** (`2026-03-13`): OC's `opencode-rules` community plugin offers richer conditional activation (globs, keywords, model, agent, branch, OS, CI) than CC's `paths:` frontmatter.
   Neither tool fully solves plugin-bundled rules.

3. **Multi-Target Plugin Strategies** (`2026-03-14`): Rules are the messiest portability layer.
   AGENTS.md is converging as cross-tool standard under AAIF but CC does not read it natively.
   Recommendation: keep `.claude/rules/` canonical, add AGENTS.md as cross-tool fallback.

Also reviewed the existing multi-target marketplace proposal (`2026-03-14`) which treated rules as a "minor addition" in its Layer 2.
This proposal deepens that layer significantly.

## Implementation Notes

The proposal specifies six implementation phases:

1. SessionStart hook for CC external installs
2. Agent path resolution fix (relative to plugin root)
3. `/cdocs:init` extension for OC rules deployment
4. Plugin-level AGENTS.md
5. Cross-tool rule authoring audit
6. Documentation and migration path

Key architectural decision: three-layer delivery with graceful degradation.
CC gets rules via hook injection (until #14200 lands).
OC gets rules via `.claude/rules/` fallback path.
Everything else gets rules via AGENTS.md.

## Changes Made

| File | Change |
|------|--------|
| `cdocs/proposals/2026-03-14-cross-target-rules-integration.md` | New proposal |
| `cdocs/devlogs/2026-03-14-cross-target-rules-proposal.md` | This devlog |

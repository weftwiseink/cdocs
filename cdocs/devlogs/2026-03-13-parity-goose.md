---
first_authored:
  by: "@claude-sonnet-4-6"
  at: 2026-03-13T00:00:00-05:00
task_list: research/parity-goose
type: devlog
state: live
status: complete
tags: [research, parity, goose, claude-code]
---

# Goose vs Claude Code Feature Parity: Devlog

## Objective

Produce a focused feature parity comparison between Goose (Block) and Claude Code.
Deep-dive on the rules/plugin reusability angle: how Goose handles bundled conventions, Recipes vs Skills, org distribution, and subagent customization.

## Plan

1. Web search for current Goose features (March 2026): MCP extensions, Recipes, AGENTS.md, distribution, subagents.
2. Cross-reference against the Claude Code features catalog (`cdocs/reports/2026-03-13-claude-code-features-catalog.md`).
3. Score each CC feature against Goose: parity / partial / absent / ahead.
4. Deep-dive on rules/plugin reusability as the critical differentiator.
5. Write report to `cdocs/reports/2026-03-13-parity-goose.md`.

## Implementation Notes

Research conducted via parallel web searches covering Goose extension types, Recipes YAML, subagent architecture, `.goosehints`, custom distros, hooks, context management, and the Feb-Apr 2026 roadmap.
Key finding: Goose's MCP-native design gives it a large tool ecosystem advantage but lacks the CC plugin system's ability to bundle rules/conventions alongside tools.
The `.goosehints` mechanism provides project-level convention injection but is not bundled with extensions - an analogous gap to CC's missing `rules` field in `plugin.json`.

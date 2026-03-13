---
first_authored:
  by: "@claude-sonnet-4-6"
  at: 2026-03-13
type: devlog
state: live
status: complete
tags: [research, parity, opencode, claude-code]
---

# OpenCode Feature Parity Analysis: Devlog

## Objective

Write a focused feature parity comparison between OpenCode and Claude Code, with a deep-dive on rules/plugin reusability relevant to packaging cdocs conventions as cross-tool standards.

## Plan

1. Web search for March 2026 OpenCode state: features, hooks, rules, plugin system.
2. Fetch OpenCode docs (plugins, rules, agents, ACP).
3. Fetch opencode-rules GitHub README for exact conditional activation behavior.
4. Review existing repo context: plugin-rules-api-research, claude-code-features-catalog, agent-harness-alternatives.
5. Write the report with parity ratings and the deep-dive.

## Implementation Notes

Web research covered:
- opencode.ai/docs (plugins, rules, agents, ACP pages fetched directly).
- frap129/opencode-rules README (fetched directly).
- Three comparison articles (Morph LLM, Infralovers, Builder.io).
- The hooks comparison gist.
- Memory system alternatives (claude-mem-opencode, opencode-mem).

The plugin-rules-api-research report provided the CC baseline for the rules gap analysis.
The claude-code-features-catalog provided the full CC feature set with dates and maturity.
The agent-harness-alternatives report provided the cross-tool landscape framing.

Key finding requiring nuance: opencode-rules plugin provides richer conditional activation than CC's `paths:` frontmatter (adds keyword, model, agent, branch, OS, CI conditions) but is a community plugin, not built-in. The CC `paths:` scoping is native. For cdocs specifically, opencode's postinstall convention offers a marginally cleaner delivery path than CC's SessionStart hook workaround — both require two steps but the npm postinstall is more automatic.

Report saved to: `cdocs/reports/2026-03-13-parity-opencode.md`

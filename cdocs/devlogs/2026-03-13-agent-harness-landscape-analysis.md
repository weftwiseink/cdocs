---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-13T00:00:00-05:00
task_list: research/agent-harness-landscape
type: devlog
state: live
status: complete
tags: [research, landscape-analysis, agent-harness, claude-code-alternatives]
---

# Agent Harness Landscape Analysis: Devlog

## Objective

Research and compare viable open agent harness alternatives to Claude Code (CC).
Produce an executive summary covering feature parity, unique advantages, and
relevance to our org's needs (esp. reusable rules/standards via plugin systems).

## Plan

1. **Phase 1 (parallel):**
   - Subagent A: Research all viable open CC alternatives (opencode, aider, goose, etc.)
   - Subagent B: Catalog CC's major features (background agents, task lists, subagents, skills, plugins, etc.)
2. **Phase 2 (parallel, after phase 1):**
   - Per-alternative subagents: deep-dive feature parity comparison using phase 1 outputs as reference
3. **Phase 3:** Executive summary synthesizing findings

## Testing Approach

Research-only task; no code changes. Verification is cross-referencing claims across sources.

## Implementation Notes

### Phase 1 — Parallel research (2 subagents)
- **Alternatives agent**: Surveyed 18 tools across 3 tiers. Identified OpenCode (121K stars), Gemini CLI (97K), and Codex CLI (65K) as top-tier. Captured plugin/rules systems for all.
- **Features agent**: Cataloged 17 CC features with introduction dates, maturity, and limitations. Timeline from Feb 2025 research preview through Mar 2026.

### Phase 2 — Parity comparisons (4 subagents, Sonnet)
- **OpenCode vs CC**: OpenCode ahead on hooks (30+ events), multi-model (75+ providers), LSP, ACP. CC ahead on marketplace, sandboxing, memory, subagents. OpenCode's `opencode-rules` plugin has richer conditional activation than CC's `paths:` frontmatter.
- **Goose vs CC**: Goose ahead on MCP (3000+ tools) and multi-model. CC ahead on hooks, plan mode, marketplace, memory. Goose has no mechanism for bundling rules with tools.
- **Codex+Gemini vs CC**: Codex ahead on OS sandbox. Gemini ahead on economics (free tier) and org policy (admin TOML). Key finding: Gemini extensions can bundle context files that auto-load — closer to solving the plugin-rules problem than CC currently is.
- **Aider+Roo+Continue vs CC**: Aider ahead on git/repo-map, but zero extensibility. Roo Code's mode-scoped rules are ergonomic. Continue Hub is the closest to a team-rules distribution system among IDE-first tools.

### Phase 3 — Executive summary
Synthesized all 6 reports into an executive summary with actionable recommendations for weft/cdocs rules portability strategy.

## Changes Made

| File | Description |
|------|-------------|
| `cdocs/reports/2026-03-13-agent-harness-alternatives.md` | Landscape survey of 18 agent harness tools |
| `cdocs/reports/2026-03-13-claude-code-features-catalog.md` | CC major features catalog (17 features) |
| `cdocs/reports/2026-03-13-parity-opencode.md` | OpenCode vs CC parity deep-dive |
| `cdocs/reports/2026-03-13-parity-goose.md` | Goose vs CC parity deep-dive |
| `cdocs/reports/2026-03-13-parity-codex-gemini.md` | Codex CLI + Gemini CLI vs CC parity deep-dive |
| `cdocs/reports/2026-03-13-parity-aider-roo-continue.md` | Aider + Roo Code + Continue vs CC parity deep-dive |
| `cdocs/reports/2026-03-13-agent-harness-executive-summary.md` | Executive summary with recommendations |

## Verification

7 reports generated across 8 subagents (2 phase 1, 4 phase 2, plus subagent-generated devlogs).
Cross-referenced findings across reports — key claims (star counts, feature availability, rule system mechanics) corroborate across independent searches.

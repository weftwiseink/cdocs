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

### Day 2 — Multi-target proposals and reviews (2026-03-14)

Additional subagent work:
- **Multi-target strategies report**: Researched approaches for maintaining CC+OC dual-target plugins. Found "author once, convert at install time" as the dominant pattern.
- **Marketplace migration proposal**: 6-phase plan for adding OC as a second publish target. **Reviewed → Revise** (2 blocking: hooks miscount, AGENTS.md test gap).
- **Rules integration proposal**: 3-layer architecture for cross-tool rules delivery (SessionStart hook, OC rules, AGENTS.md). **Reviewed → Revise** (3 blocking: hook code/spec mismatch, fragile sed, test rigor).
- **Executive summary**: Assessed project state — recommended starting with Phase 0 (AGENTS.md + skills portability validation) before building full infrastructure.

Additional files generated:
| `cdocs/reports/2026-03-14-multi-target-plugin-strategies.md` | Multi-target publishing strategies |
| `cdocs/proposals/2026-03-14-multi-target-marketplace.md` | Marketplace migration proposal |
| `cdocs/proposals/2026-03-14-cross-target-rules-integration.md` | Rules integration proposal |
| `cdocs/reviews/2026-03-14-review-of-multi-target-marketplace.md` | Marketplace proposal review |
| `cdocs/reviews/2026-03-14-cross-target-rules-review.md` | Rules proposal review |
| `cdocs/reports/2026-03-14-multi-target-executive-summary.md` | Integrated executive summary |

### Day 3 — Revision pass and verifiability assessment (2026-03-14, cont.)

Comprehensive revision of both proposals addressing all review feedback (blocking and non-blocking):

- **Marketplace proposal revised** (2 blocking + 10 non-blocking items addressed):
  - Fixed hooks description (1 active, 1 unwired), added Phase 0 to wire path hook
  - Added AGENTS.md integration tests with pass/fail criteria
  - Fixed tool mapping inconsistency, model configurability, postinstall automation
  - Cross-proposal coordination: defers to rules proposal for AGENTS.md

- **Rules proposal revised** (3 blocking + 14 non-blocking items addressed):
  - Added source-repo skip logic to hook script code
  - Fixed frontmatter stripping (sed → awk), replaced python3 with jq
  - Added pass/fail criteria to all 13 tests, added 3 negative tests
  - Narrowed OC keywords, framed Layer 2 as experimental, added missing edge cases

- **Verifiability assessment**: Found and fixed 2 implementation bugs during assessment:
  1. sed command `'1{/^---$/d}; 1,/^---$/d'` only deleted opening `---`, not full frontmatter block → replaced with awk
  2. Postinstall claimed `CDOCS_SKIP_POSTINSTALL` support but didn't implement the check → added env var guard

- **Assessment scores**: Rules proposal 8/10 implementability (executable hook script, comprehensive tests). Marketplace proposal 6/10 (no build script code, only behavioral description).

Additional files generated:
| `cdocs/devlogs/2026-03-14-multi-target-marketplace-revision.md` | Marketplace revision devlog |
| `cdocs/devlogs/2026-03-14-cross-target-rules-revision.md` | Rules revision devlog |
| `cdocs/reports/2026-03-14-proposal-verifiability-assessment.md` | Verifiability assessment |

### Day 4 — Compound-engineering amendment (2026-03-16)

Investigated why the marketplace proposal prescribed a custom build script when the strategies report had already identified `compound-engineering-plugin` as a mature converter.

**Root cause:** The strategies report treated compound-engineering as pattern validation (Sections 1, 4) but prescribed a custom script in its own "Recommended Strategy" (Section 8). The proposal faithfully followed Section 8 without questioning build-vs-buy. Neither the review nor verifiability assessment caught the disconnect.

**Amendment applied:**
- Marketplace proposal Phase 1 rewritten: compound-engineering for core conversion, thin <50 line wrapper for cdocs-specific post-processing (path rewriting, version sync)
- Added verification-first step with fallback to custom script if tool doesn't work as described
- Added "Use compound-engineering instead of custom build script" design decision
- Simplified test plan (4 tests for wrapper post-processing instead of 7 for custom conversion)
- Updated all downstream references (CI/CD, edge cases, verification methodology)

Additional files generated:
| `cdocs/devlogs/2026-03-16-marketplace-compound-engineering-amendment.md` | Amendment devlog |

Total: 18 reports/proposals/reviews/devlogs generated across 17 subagents over 4 sessions.

---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-14T22:00:00-07:00
task_list: marketplace/cross-target-rules
type: devlog
state: live
status: review_ready
tags: [rules, revision, cross-target]
---

# Devlog: Cross-Target Rules Integration Proposal Revision

> BLUF(claude-opus-4-6/cross-target-rules): Revised the cross-target rules integration proposal to address all 3 blocking and 11 non-blocking findings from the round 1 review, plus applied the cross-proposal coordination decision designating this proposal as owner of the AGENTS.md artifact and `/cdocs:init` OC extensions.

## Changes Made

| File | Change |
|------|--------|
| `cdocs/proposals/2026-03-14-cross-target-rules-integration.md` | Comprehensive revision addressing all review feedback |

## Blocking Issues Resolved

1. **Source-repo skip logic added to hook script**: The `inject-rules.sh` script now includes the CLAUDE.md grep check before the rule file reading loop, matching the edge case description.
2. **Sed frontmatter stripping fixed**: Replaced the aggressive `paths:`-targeted sed command with a simpler approach that strips the entire YAML frontmatter block, since frontmatter is noise in `additionalContext`.
3. **Test plan strengthened**: Added explicit "Expected" and pass/fail criteria to all 13 existing tests. Added 3 new negative tests (14: malformed rule file, 15: special characters in content, 16: hook timeout behavior).

## Non-Blocking Issues Resolved

4. Consistent "17+" count throughout (was "15+" in one place).
5. Fixed nit-fix resolution method from "Glob at startup" to "CC Glob tool at startup"; added unverified-resolution note.
6. Added cross-proposal coordination note designating this proposal as AGENTS.md and init OC extension owner.
7. Narrowed OC keywords to `cdocs`-prefixed terms to avoid false activation.
8. Added version-mismatch detection via content hash as progressive enhancement.
9. Framed Layer 2 as explicitly experimental with a NOTE callout.
10. Added init complexity risk and 5-responsibility guardrail to the design decision.
11. Fixed Phase 5 grep pattern from bare `@` to `^@[a-zA-Z]`.
12. Added context budget design decision (2-3KB, <0.1% of context window).
13. Added `additionalContext` precedence design decision (user rules override plugin rules).
14. Added uninstall/cleanup edge case.
15. Replaced `python3` JSON escaping with `jq -Rs .` throughout.
16. Added source-repo skip logic to the Mermaid diagram as a conditional node.
17. Verified Phase 6 cross-reference (`cdocs/proposals/2026-01-30-nit-fix-project-rules.md` exists).

## Frontmatter Updates

- Changed `status` from `wip` to `review_ready`.
- Kept `last_reviewed` block showing round 1 revision_requested (for audit trail).

## Verification

All 17 action items from the review were addressed.
The proposal structure is preserved; changes were integrated into existing sections.
No new sections were created beyond what was necessary (two new design decision entries, one new edge case, three new tests).

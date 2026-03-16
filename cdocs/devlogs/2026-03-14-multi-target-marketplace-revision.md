---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-14T21:00:00-07:00
task_list: marketplace/multi-target
type: devlog
state: live
status: done
tags: [architecture, multi-target, opencode, revision]
---

# Devlog: Multi-Target Marketplace Proposal Revision (Round 2)

> BLUF: Revised the multi-target marketplace proposal to address all 14 findings from the round 1 review, including both blocking issues (hooks accuracy, AGENTS.md test gaps) and all 10+ non-blocking improvements.

## Changes Applied

### Blocking Fixes

1. **Hooks description corrected.**
   Updated the "Current cdocs Plugin Structure" section to mark `validate-cdocs-edit-path.sh` as unwired (file exists, not declared in `hooks.json`).
   Updated the Layer 4 hooks table with a CC Status column distinguishing active from unwired hooks.
   Added a decision: wire the path-restriction hook in CC first as a Phase 0 prerequisite, then port both hooks to OC in Phase 3.
   Fixed line counts: frontmatter hook is 73 lines, path restriction is 18 lines.

2. **AGENTS.md integration tests added.**
   Added a dedicated "AGENTS.md Integration Tests" section with three test cases:
   CC `@`-import resolution, OC AGENTS.md handling, and `.claude/rules/` fallback.
   Each test has explicit expected outcomes and pass/fail criteria.

### Non-Blocking Improvements

3. **`@`-import concerns addressed.** Replaced the claim "OC reads the AGENTS.md and follows references" with a NOTE acknowledging OC likely treats `@`-imports as literal text. Distinguished plugin-level AGENTS.md (uses `@`-imports for CC) from project-level AGENTS.md (uses inlined content per the rules proposal).

4. **Model mapping made configurable.** Added a NOTE that model IDs should be pulled from a configurable mapping and that the haiku example is from late 2024.

5. **Tools/permission inconsistency fixed.** Changed the OC conversion example to show `edit: true` (not `write: false` alone). Added a full CC-to-OC tool mapping table clarifying the separation between Edit and Write.

6. **Postinstall implemented.** Replaced the placeholder echo with actual automation that copies skills to `.opencode/skills/cdocs/` and rules to `.claude/rules/`, with a `CDOCS_SKIP_POSTINSTALL` env var opt-out.

7. **Commit generated output stated definitively.** Removed "gitignored or committed depending on team preference" hedging. The decision now says: commit the generated output.

8. **Path rewriting decided.** Committed to using relative paths in the CC source. Removed the "or the agent body should be updated" alternative. Build script verifies paths resolve in both contexts.

9. **Versioning strategy added.** New design decision: `package.json` version derived from `plugin.json` version. Build script copies the version field.

10. **Bun-only constraint documented.** Added a NOTE that the `.ts` entry point requires a Bun-compatible runtime and Node-based OC installations would fail.

11. **Manual validation pass/fail criteria added.** Each of the 4 manual validation items now has explicit expected outcomes (e.g., "all 10 skills appear by name").

12. **Phase 5 CI mechanism specified.** Replaced "do not block CC-only PRs" with: use a separate GitHub Actions job with path filters and `continue-on-error: true`.

13. **Auto-discovery stated explicitly.** Build script description notes it auto-discovers all `agents/*.md` files.

14. **Rollback note added.** Edge cases section now states: update script, rebuild, commit. Never manually edit `opencode/`.

### Cross-Proposal Coordination

Added deference to the companion rules proposal for the project-level AGENTS.md artifact and `/cdocs:init` OC extensions.
The marketplace proposal references the rules proposal's inlined-content approach rather than specifying it independently.

## Verification

Reviewed the revised proposal against all 14 action items from the review.
Each item has a corresponding change in the revised text.

---
review_of: cdocs/proposals/2026-03-14-multi-target-marketplace.md
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-16T18:00:00-07:00
task_list: marketplace/multi-target
type: review
state: live
status: done
tags: [rereview_agent, focused_recheck, hooks, postinstall, internal_consistency]
---

# Review: Multi-Target Marketplace (Round 5 - Focused Re-Review)

## Summary Assessment

> BLUF(@claude-opus-4-6/multi-target): All three round 4 action items (blocking `inject-rules.sh` omission, non-blocking postinstall `__dirname` bug, non-blocking Layer 2 framing) are resolved.
> The round 5 edits introduce one minor internal inconsistency: a stale NOTE callout in the plugin structure section that contradicts the updated structure diagram directly above it.
> No new blocking issues.
> Verdict: Accept.

## Scope

This is a focused re-review checking only:

1. Whether the round 4 blocking issue (missing `inject-rules.sh`) is addressed.
2. Whether the non-blocking postinstall `__dirname` bug is fixed.
3. Whether the Layer 2 framing (AGENTS.md as existing vs proposed) is updated.
4. Whether the round 5 edits introduced any internal inconsistencies.

## Prior Action Item Resolution

### Item 1 (blocking): Add `inject-rules.sh` to plugin structure and hooks table

**Status: Resolved.**

The plugin structure diagram (line 91) now lists `inject-rules.sh` with the annotation "ACTIVE: SessionStart -- injects rule content as additionalContext (54 lines)."
The `hooks.json` comment (line 90) now reads "2 active hooks," matching reality.
The "after implementation" structure (line 128) also includes `inject-rules.sh`.
The Layer 4 hooks table (line 252) has a full row for `inject-rules.sh` with CC event, status, behavior, and OC equivalent assessment ("Not needed for OC").
Phase 3 (line 644) explicitly addresses it: "The rule injection hook (`inject-rules.sh`) does not need an OC equivalent since OC reads `.claude/rules/` natively."
The NOTE on line 256-258 provides the rationale for why no OC equivalent is needed.

All parts of the proposal that reference hooks are now consistent with the three-hook inventory.

### Item 2 (non-blocking): Fix postinstall `__dirname` resolution

**Status: Resolved.**

The `package.json` `files` array (lines 310-316) now includes `skills/` and `rules/`, so they ship inside the npm package.
The NOTE on lines 330-332 explicitly states: "Skills and rules are included in the `files` array so they ship with the package (no `__dirname/..` parent traversal needed)."
The postinstall (line 325) now references an external `scripts/postinstall.js` file rather than an inline one-liner.
The NOTE on line 351 confirms `__dirname`-relative paths point to "the bundled copies within the package."
Phase 1 (line 603) specifies: "Copy skills and rules into `opencode/skills/` and `opencode/rules/` so they are bundled in the npm package."

The design is internally consistent: the build script bundles the copies, npm ships them, and the postinstall copies from the package-local bundled paths.

### Item 3 (non-blocking): Update Layer 2 framing to acknowledge AGENTS.md as existing

**Status: Resolved.**

Line 165 now reads: "An `AGENTS.md` file already exists at `plugins/cdocs/AGENTS.md` (created by the [cross-target rules integration](2026-03-14-cross-target-rules-integration.md) implementation)..."
Phase 2 (lines 617-621) is framed as "Verification" with a NOTE confirming: "`plugins/cdocs/AGENTS.md` already exists from the completed cross-target rules integration implementation."
The two sections are consistent: Layer 2 describes the existing artifact, Phase 2 verifies it rather than creating it.

## New Findings from Round 5 Edits

### Stale NOTE contradicts updated structure diagram

**Non-blocking.** Lines 96-98 contain a NOTE callout that reads:

> NOTE(claude-opus-4-6/multi-target): Only `cdocs-validate-frontmatter.sh` is wired in `hooks.json` (as a `PostToolUse` matcher for `Write|Edit`).

This NOTE was written for the earlier version of the proposal that did not list `inject-rules.sh`. It now directly contradicts line 90 ("CC hook declarations (2 active hooks)") and line 91 (which labels `inject-rules.sh` as "ACTIVE"). The NOTE should say that `inject-rules.sh` and `cdocs-validate-frontmatter.sh` are the two hooks wired in `hooks.json`, and that `validate-cdocs-edit-path.sh` is unwired.

### No round-5 revision NOTE

**Non-blocking.** The `revision_round` field was incremented to 5 but no NOTE callout documents what changed in round 5 (the round-4-revision NOTE on line 26 covers only round 4 changes). For a focused revision addressing specific review findings, a brief NOTE documenting the three fixes would help future readers understand the revision history. This is a minor documentation hygiene issue.

### Other round 4 non-blocking items (spot check)

Item 5 (NOTE attribution format): Resolved. Line 26 now uses `NOTE(claude-opus-4-6/multi-target/round-4-revision)`.

Item 8 (Phase 3 should address `inject-rules.sh` porting): Resolved. Line 644 explicitly addresses it.

## Verdict

**Accept.**

All blocking issues from round 4 are resolved. The proposal's three hook files are now consistently inventoried across the plugin structure diagram, the hooks table, and the Phase 3 scope statement. The postinstall design correctly bundles skills and rules inside the npm package. The Layer 2 framing acknowledges AGENTS.md as existing work.

The one new finding (stale NOTE on lines 96-98) is a minor internal inconsistency that does not affect implementability. It should be fixed but does not warrant another revision cycle.

## Action Items

1. [non-blocking] Update the NOTE on lines 96-98 to reflect that both `inject-rules.sh` (SessionStart) and `cdocs-validate-frontmatter.sh` (PostToolUse) are wired in `hooks.json`, and that only `validate-cdocs-edit-path.sh` is unwired.
2. [non-blocking] Add a brief round-5 revision NOTE documenting the three fixes made in this round (inject-rules.sh addition, postinstall __dirname fix, Layer 2 framing update).

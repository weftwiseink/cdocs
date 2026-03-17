---
review_of: cdocs/proposals/2026-03-14-multi-target-marketplace.md
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-16T12:00:00-07:00
task_list: marketplace/multi-target
type: review
state: live
status: done
tags: [rereview_agent, architecture, build_system, hooks, internal_consistency, implementability]
---

# Review: Multi-Target Marketplace (Round 4)

## Summary Assessment

> BLUF(@claude-opus-4-6/multi-target): The round 4 revision addresses the two blocking issues from round 1 (unwired hook acknowledgment, AGENTS.md test coverage) and incorporates research-driven corrections for compound-engineering, agent_type scoping, Phase 2 overlap, and OC hook limitations.
> The proposal is now internally consistent on the custom build script approach with no leftover compound-engineering-as-build-tool references.
> The agent_type guard design is sound, backed by the hook scoping research devlog.
> One new blocking issue: the proposal omits the `inject-rules.sh` SessionStart hook from its plugin structure inventory, creating an incomplete picture of what needs OC porting consideration.
> Verdict: Revise (one blocking issue, several non-blocking improvements).

## Prior Review Status

The round 1 review (2026-03-14) raised two blocking and eight non-blocking items.
The `last_reviewed` field shows round 2 with `revision_requested` by `@mjr`, so there were intervening rounds not captured as formal review documents.
This review evaluates the current round 4 state against all prior findings.

### Prior Blocking Items

1. **Hook status inaccuracy (round 1, blocking):** Resolved. The proposal now clearly distinguishes between the active `PostToolUse` hook and the unwired `validate-cdocs-edit-path.sh` file, including explicit labels ("ACTIVE" vs "UNWIRED") in the plugin structure and hooks table. The decision to wire it up in Phase 0 is stated explicitly.

2. **AGENTS.md test coverage (round 1, blocking):** Resolved. A dedicated "AGENTS.md Integration Tests" subsection (3 test cases) now covers CC `@`-import resolution, OC literal-text handling, and `.claude/rules/` fallback. Each test has explicit pass/fail criteria.

### Prior Non-Blocking Items

3. **Tools/permission inconsistency (round 1, item 3):** Resolved. The agent conversion example now shows `edit: true` with `permission: { edit: ask }`, and the CC-to-OC tool mapping table clearly separates Edit from Write.

4. **Agent body path approach (round 1, item 4):** Resolved. The proposal commits to relative paths in the CC source and build-time verification that paths resolve in both contexts. The edge case section and design decision are consistent.

5. **Postinstall automation (round 1, item 5):** Resolved. The `postinstall` script now contains actual automation (copies skills and rules) with `CDOCS_SKIP_POSTINSTALL` opt-out, replacing the placeholder echo.

6. **Version synchronization (round 1, item 6):** Resolved. A new design decision ("Derive `package.json` version from `plugin.json` version") and corresponding build script responsibility are documented.

7. **Bun/.ts constraint (round 1, item 7):** Resolved. A NOTE callout documents the `.ts` entry point as Bun-only, with a deferred workaround for Node-based installs.

8. **Manual validation pass/fail (round 1, item 8):** Resolved. All four manual validation checks now include "Expected:" and "Fail:" criteria.

9. **CI mechanism for non-blocking (round 1, item 9):** Resolved. Phase 5 specifies "a separate GitHub Actions job with path filters (`plugins/cdocs/**`) and `continue-on-error: true`."

10. **Auto-discovery (round 1, item 10):** Resolved. Phase 1 step 1 describes auto-discovery, and integration test 4 ("Adding a new `.md` file to `agents/` and rebuilding produces a corresponding OC agent file") verifies it.

## Section-by-Section Findings

### Frontmatter

**Non-blocking:** The proposal uses `revision_round: 4` as a custom frontmatter field. The frontmatter spec does not define `revision_round`; the closest mechanism is `last_reviewed.round`. This field is harmless (CC ignores unknown fields) but inconsistent with the spec. Consider either removing it (since `last_reviewed.round` tracks review rounds) or proposing a spec amendment for revision tracking.

**Non-blocking:** The `last_reviewed` block shows `round: 2` with `by: "@mjr"` but the `revision_round` field says `4`. This makes sense if rounds 3 and 4 were self-revisions without formal review, but the gap between review round 2 and revision round 4 could confuse readers. This is a minor bookkeeping concern.

### BLUF and Revision Notes

The BLUF is accurate and comprehensive. The round-4-revision NOTE callout correctly summarizes all four changes.

**Non-blocking (writing convention):** The revision NOTE callout uses `NOTE(round-4-revision)` as its attribution, which does not follow the `author/workstream` convention (should be something like `NOTE(claude-opus-4-6/multi-target)`). Minor formatting issue.

### Current cdocs Plugin Structure

**Blocking:** The plugin structure listing shows only two hook files under `hooks/`:

```
hooks/
  hooks.json                  # CC hook declarations (1 active hook)
  cdocs-validate-frontmatter.sh   # ACTIVE
  validate-cdocs-edit-path.sh     # UNWIRED
```

The actual `hooks.json` declares **two** active hooks: the `PostToolUse` frontmatter validator and a `SessionStart` hook running `inject-rules.sh`. The `inject-rules.sh` file (54 lines of bash) is entirely absent from the proposal's inventory.

This matters because:
- The SessionStart hook injects rule content as `additionalContext` for external CC installs. This is a rules delivery mechanism that the proposal's Layer 2 (Rules) analysis does not account for.
- The OC porting analysis in Layer 4 (Hooks) should address whether the rule injection functionality needs an OC equivalent, or whether OC's `.claude/rules/` fallback makes it unnecessary.
- Phase 3's scope statement ("Only the frontmatter validation hook can be fully ported") is incomplete: there are three hooks to consider for porting, not two.
- The comment "CC hook declarations (1 active hook)" in the structure diagram is factually incorrect: hooks.json has 2 active hooks (SessionStart and PostToolUse).

The fix is straightforward: add `inject-rules.sh` to the structure listing, add a row to the hooks table in Layer 4, and assess whether it needs an OC equivalent or is superseded by OC's rules discovery paths.

### Layer 1: Skills

No issues. Correctly identifies skills as fully portable.

### Layer 2: Rules

The analysis is sound. The NOTE about OC not following `@`-imports is correctly placed, and the deference to the cross-target rules integration proposal for the project-level AGENTS.md is appropriate.

**Non-blocking:** The section says "an `AGENTS.md` file at `plugins/cdocs/AGENTS.md` that imports the rules" as if it is a proposed addition. In reality, this file already exists (confirmed by reading it). The framing should match Phase 2's acknowledgment that this is existing work. This is a history-agnostic framing issue: the section reads as though AGENTS.md is being proposed, but it already exists.

### Layer 3: Agents

The conversion specification is thorough. The CC-to-OC tool mapping table is clear and the transformations are well-enumerated.

**Non-blocking:** The model mapping uses `anthropic/claude-3-5-haiku-20241022` for `haiku`. Given this proposal targets March 2026, this model ID may already be stale. The NOTE acknowledges this ("may need updating") which is sufficient, but the build script specification in Phase 1 should state that the model mapping is a configuration table (not hardcoded inline), making updates a one-line change.

**Non-blocking:** The `reviewer.md` agent has `tools: Read, Glob, Grep, Edit, Write` (5 tools including Write), but the CC-to-OC tool mapping table's Write row says `permission: { write: ask }`. The agent conversion example (triage) does not demonstrate Write handling. Phase 1 should include a test case for an agent with Write (the reviewer) to ensure the build script handles both Edit and Write permissions correctly.

### Layer 4: Hooks

The hooks analysis is significantly improved from round 1 with the clear ACTIVE/UNWIRED distinction and the explicit decision to wire up the path-restriction hook in Phase 0.

Beyond the blocking issue about the missing `inject-rules.sh` hook (covered above), the remainder of this section is solid.

**Non-blocking:** The OC hook sketch shows `event.input?.file_path` and `event.output?.file_path` with a NOTE that these shapes need verification. Good practice. The sketch should also note that `tool.execute.before` events may use a different property name for the tool input (e.g., `event.params` or `event.args` depending on OC's internal convention).

### Layer 5: npm Packaging

**Non-blocking:** The `postinstall` script is a single-line inline Node script spanning ~300 characters. While functional, this is fragile and hard to debug. Consider extracting it to a separate `scripts/postinstall.js` file referenced from `package.json`. This is a quality-of-life suggestion, not a correctness issue.

**Non-blocking:** The `files` array in `package.json` lists `agents/`, `plugins/`, and `package.json` but does not include skills or rules, relying instead on the postinstall to copy them from the parent directory structure. This is fine for in-repo usage but may break for standalone npm installs where the parent `skills/` and `rules/` directories do not exist at the expected relative paths. The postinstall uses `path.resolve(__dirname, '..', 'skills')` which assumes the npm package is installed within the `plugins/cdocs/` directory tree. For a published npm package installed into `node_modules/@weftwise/cdocs-opencode/`, `__dirname/..` would be `node_modules/@weftwise/`, not `plugins/cdocs/`. This is a real bug in the postinstall design.

### Design Decisions

All design decisions are well-justified and internally consistent.

The "Use a custom build script for artifact generation; recommend compound-engineering for user-side installation" decision cleanly separates the two concerns. No leftover references to compound-engineering as a build tool were found anywhere in the proposal.

**Non-blocking:** The decision "Use relative paths in agent body content" mentions updating "the CC source to use a relative path." The triage agent currently uses `rules/frontmatter-spec.md` (relative from agents/) with a fallback to `plugins/cdocs/rules/frontmatter-spec.md`. The proposal's claim that the agent body references an "absolute from repo root" path (`plugins/cdocs/rules/frontmatter-spec.md`) is slightly inaccurate: the agent already uses the relative path as the primary, with the absolute path as a fallback. The build script's path-rewriting step may need to handle the fallback line specifically (remove or rewrite it) rather than rewriting a primary absolute path that does not exist.

### Edge Cases

The edge cases section is thorough, covering seven scenarios. The two new additions (future agent allowlist and cross-target parity gap) are well-reasoned.

**Non-blocking:** The "Future cdocs agents and the agent_type allowlist" edge case proposes a CI check that "verifies all agents declared in `plugins/cdocs/agents/` have corresponding entries in the hook's allowlist." This is a good idea, but the allowlist is embedded in a bash `case` statement. The CI check would need to parse the bash script to extract the allowlist, which is fragile. Consider extracting the allowlist to a data file (e.g., a simple text file of agent names, one per line) that both the hook script and CI can read.

### Test Plan

The test plan is substantially improved from round 1. The AGENTS.md integration tests fill the previously identified gap. The unit tests for the build script are well-scoped.

**Non-blocking:** There is no test case for the postinstall script. Given the postinstall contains non-trivial logic (directory creation, conditional file copying, environment variable check), a test that verifies `npm pack` + `npm install` triggers the postinstall and produces the expected directory structure would catch the `__dirname` resolution issue noted above.

### Implementation Phases

#### Phase 0

The agent_type guard design is sound and directly follows the hook scoping research findings. The test criteria are comprehensive: they cover subagent blocking, subagent allowance, and main session passthrough. The constraints are clear.

**Non-blocking:** The success criteria say "Editing a non-cdocs file from a cdocs subagent triggers the path-restriction block." It would strengthen this to also specify the expected stderr message content (or at least that stderr contains a human-readable error), since the message is what the LLM agent sees as feedback.

#### Phase 1

The build script spec is thorough, covering all six transformations (model mapping, tool expansion, permission generation, mode insertion, field dropping, path rewriting) plus version synchronization and validation.

**Non-blocking:** The success criteria say "The script is ~100-200 lines TS (excluding comments and tests)." This is an estimate, not a hard constraint. If the script comes in at 250 lines due to robust error handling, that should not be considered a failure. Consider softening to "The script is concise (target: 100-200 lines TS)."

#### Phase 2

Correctly scoped as verification-only, acknowledging the existing AGENTS.md. The NOTE about prior work is accurate.

No issues.

#### Phase 3

The OC limitation note about agent identity in hook payloads is correctly placed and well-documented. The decision to port only the frontmatter validation hook is sound given the constraint.

**Non-blocking:** The Phase 3 scope says "Only the frontmatter validation hook can be fully ported." Once `inject-rules.sh` is added to the inventory (per the blocking issue), Phase 3 should also state whether the rule injection hook needs an OC equivalent or is unnecessary given OC's `.claude/rules/` reading.

#### Phases 4-6

No issues. Well-scoped with clear success criteria and constraints.

### Compound-Engineering References Check

Per the review request, I checked for any leftover compound-engineering-as-build-tool references. All instances of "compound-engineering" in the proposal are correctly positioned:
- The design decision section explicitly says CE is a "user-side install tool," not a build-artifact generator.
- Phase 6 documents CE as an "alternative user-side install path."
- The BLUF and summary use "custom build script" throughout.
- No section implies CE is used in the build pipeline.

The reversion is clean and complete.

## Verdict

**Revise.**

The proposal has made strong progress across four rounds. All prior blocking issues are resolved, and the compound-engineering reversion is internally consistent throughout.

One new blocking issue: the `inject-rules.sh` SessionStart hook is missing from the plugin structure inventory and hooks porting analysis. This is a factual omission that leaves the OC porting scope incomplete: an implementer following this spec would not know the hook exists and would not consider whether it needs an OC equivalent.

The remaining findings are non-blocking quality improvements.

## Action Items

1. [blocking] Add `inject-rules.sh` to the plugin structure diagram, add a row to the Layer 4 hooks table (SessionStart, active, injects rule content as additionalContext), and assess whether it needs an OC equivalent in Phase 3 or is superseded by OC's `.claude/rules/` fallback path.
2. [non-blocking] Fix the postinstall `__dirname` resolution: for published npm packages, `path.resolve(__dirname, '..', 'skills')` resolves to the wrong directory. Either bundle skills/rules in the npm `files` array or use a different path resolution strategy.
3. [non-blocking] Update the Layer 2 (Rules) section framing to acknowledge AGENTS.md as existing rather than proposed, matching Phase 2's "verification" framing.
4. [non-blocking] Verify the agent body path claim: the triage agent already uses relative paths as primary, not absolute paths. The build script path-rewriting spec should address the fallback line, not a primary absolute reference.
5. [non-blocking] Fix the `NOTE(round-4-revision)` attribution to follow the `author/workstream` convention.
6. [non-blocking] Consider extracting the agent allowlist from the bash case statement to a data file for CI-testable maintenance.
7. [non-blocking] Add a postinstall test case to the test plan, especially given the `__dirname` resolution concern.
8. [non-blocking] Phase 3 should address the `inject-rules.sh` porting decision once it is added to the inventory.

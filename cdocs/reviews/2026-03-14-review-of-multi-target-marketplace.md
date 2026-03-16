---
review_of: cdocs/proposals/2026-03-14-multi-target-marketplace.md
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-14T18:00:00-07:00
task_list: marketplace/multi-target
type: review
state: live
status: done
tags: [fresh_agent, architecture, build_system, test_plan, portability, hooks, npm_packaging]
---

# Review: Multi-Target Marketplace

## Summary Assessment

> BLUF(@claude-opus-4-6/multi-target): The proposal presents a well-researched, well-structured plan for extending cdocs to OpenCode.
> The core architectural decision (CC canonical, OC generated) is sound and well-justified by the supporting research.
> The phasing is mostly realistic, though Phase 3 (hooks) has an unacknowledged dependency on Phase 1 for local testing infrastructure, and the test plan lacks coverage for the AGENTS.md integration and the npm postinstall path.
> Two factual inaccuracies in the "current state" section need correction before this proposal can serve as a reliable implementation guide.
> Verdict: Revise.

## Section-by-Section Findings

### Current cdocs Plugin Structure

**Blocking**: The proposal lists `validate-cdocs-edit-path.sh` as an active hook in the current plugin structure, including it in the hooks table (Section 4) as if it maps to a `PreToolUse` event.
In reality, `hooks.json` only declares the `PostToolUse` hook for `cdocs-validate-frontmatter.sh`.
The `validate-cdocs-edit-path.sh` script exists as a file (17 lines of bash) but is not wired into the hook system.

This matters because the proposal uses the "two existing hooks" framing to scope the OC reimplementation work in Phase 3.
If there is only one active hook, the OC hook plugin scope shrinks, and the decision about whether to wire up the path-restriction hook in OC should be made explicitly rather than assumed from the CC baseline.

**Non-blocking**: The proposal claims the hooks are "73 and 17 lines of bash."
The frontmatter validation hook is 73 lines; the path restriction hook is 18 lines (including the shebang).
Minor, but if the proposal is meant to serve as an implementation spec, precision matters.

### Layer 1: Skills (No Changes Needed)

No issues.
The analysis is correct: SKILL.md files are portable, and the supporting research confirms this.
The note about OC-only frontmatter fields (`license`, `compatibility`, `metadata`) being additive is a good forward-looking observation.

### Layer 2: Rules (Minor Addition)

**Non-blocking**: The proposed AGENTS.md content uses bare `@rules/writing-conventions.md` style imports.
This is syntactically correct for CC's `@`-import system, but the proposal does not verify whether OC actually follows `@`-import references inside AGENTS.md or just reads the AGENTS.md content verbatim.
If OC treats the AGENTS.md as opaque markdown (likely, given the AGENTS.md spec is tool-agnostic), the `@`-imports would appear as literal text to OC users, and the rules would not be injected.
The OC fallback would then be `.claude/rules/` directory reading, which the proposal also mentions, but the AGENTS.md value proposition for OC is overstated if `@`-imports are CC-specific.

This should be verified experimentally before implementation.
If OC does not follow `@`-imports, the AGENTS.md should inline the rule content or use a different cross-tool inclusion mechanism.

**Non-blocking**: The proposal mentions tools that rely on AGENTS.md (Codex, Cursor, Copilot) but does not clarify whether those tools follow `@`-imports either.
If none of them do, the AGENTS.md with `@`-imports is only useful for CC, which already reads `.claude/rules/` natively, making the AGENTS.md redundant.

### Layer 3: Agents (Frontmatter Conversion)

**Non-blocking**: The model mapping example uses `anthropic/claude-3-5-haiku-20241022` for the `haiku` alias.
Given the date of this proposal (March 2026), this may already be outdated: Haiku 3.5 is from late 2024.
The build script should either document which model versions it targets or pull from a configurable mapping rather than hardcoding version-dated model IDs.
The report's build script sketch has the same issue.

**Non-blocking**: The `tools` mapping in the OC conversion example shows `read: true, write: false, bash: false`.
For the triage agent, which has `tools: Read, Glob, Grep, Edit`, the `Edit` tool should map to `write: true` or at minimum `edit: true` depending on OC's permission model.
The example appears inconsistent: it shows `write: false` but then has `permission: { edit: ask }`.
The build script sketch in the research report maps `Edit` to `edit` (a separate tool), but the proposal's example conflates write/edit permissions.
This inconsistency should be resolved before implementation.

### Layer 4: Hooks (Reimplementation Required)

**Blocking (per the factual issue above)**: The hook table claims two active hooks.
Only one is wired.
The proposal should either: (a) acknowledge that `validate-cdocs-edit-path.sh` is unwired and decide whether to activate it in OC, or (b) wire it up in CC first (add it to `hooks.json` as a `PreToolUse` matcher) before claiming it as part of the OC conversion scope.

**Non-blocking**: The TypeScript plugin sketch uses `event.output?.file_path` to extract the file path from the OC event.
This assumes a specific shape for the OC event object that is not documented in the proposal.
The parity report notes that OC hooks receive "typed event objects," but the exact shape of `tool.execute.after` events should be cited or marked as requiring verification during implementation.

**Non-blocking**: The sketch handles only the `tool.execute.after` case (frontmatter validation).
It does not show the `tool.execute.before` handler for path restriction.
Given the path-restriction hook is not wired in CC either, this is consistent, but it should be noted explicitly.

### Layer 5: npm Packaging

**Non-blocking**: The `package.json` sets `"main": "plugins/cdocs-hooks.ts"`.
npm packages with TypeScript entry points require either a build step (compile to JS) or a runtime that handles TS natively (Bun does, Node does not).
The proposal says Bun is the build runtime, and OC auto-installs plugins via Bun, so this likely works.
But the proposal should note that the npm package is Bun-only: `node`-based OpenCode installations (if any exist) would fail to load a `.ts` entry point.

**Non-blocking**: The `postinstall` script is just an echo statement: `echo 'Copy skills and rules from .claude/ paths or use AGENTS.md for rule discovery.'`
This provides no automation.
The parity report discusses postinstall scripts that copy `.md` files into `.opencode/rules/` as the workable delivery path for OC.
If the postinstall is not going to do actual work, it should be removed rather than giving users a vague instruction.
Alternatively, implement the postinstall to actually copy skills and rules into the appropriate paths, which would make standalone OC installation much smoother.

### Design Decisions

All five design decisions are well-justified.
The reasoning is grounded in the research reports and reflects pragmatic tradeoffs.

**Non-blocking**: The "commit the generated output" recommendation is sound, but the proposal does not address how to handle the `opencode/` directory in `.gitignore` vs committed state.
It says "gitignored or committed as build artifacts depending on team preference" and then recommends committing.
The recommendation should be stated definitively, and if committed, a CI dirty-check (Phase 5) is the right enforcement mechanism, which the proposal already covers.

### Edge Cases

The edge cases section is thorough.
The agent body path rewriting issue is correctly identified, and the relative-path mitigation is sound.

**Non-blocking**: The triage agent body currently references `plugins/cdocs/rules/frontmatter-spec.md` (absolute from repo root), not a relative path.
The build script should either rewrite this to a relative path that works in OC's agent loading context, or the agent body should be updated in the CC source to use a relative path.
The proposal mentions both options but does not commit to one.
Decide before implementation.

### Test Plan

**Blocking**: The test plan has no coverage for the AGENTS.md integration (Phase 2).
There are no unit tests, integration tests, or manual validation steps for verifying that AGENTS.md `@`-imports work correctly in CC, OC, or other tools.
This is a gap because the AGENTS.md is a new artifact and its cross-tool behavior needs verification.

**Non-blocking**: The test plan does not cover the npm `postinstall` behavior.
If the postinstall is kept (even as an echo), there should be a test that `npm pack` produces a valid tarball and that installing the tarball in a test project triggers the postinstall script.
Phase 4 mentions `npm pack` testing, but the test plan section does not include it.

**Non-blocking**: The "Manual Validation" section lists four checks but provides no pass/fail criteria.
For example, "Verify cdocs skills appear in OC's skill menu" does not specify which skills should appear or how to confirm they loaded correctly (e.g., skill count, specific names).
Adding expected outcomes would make manual validation reproducible.

### Implementation Phases

**Non-blocking**: Phase 2 (AGENTS.md) is listed as depending only on itself, but it implicitly depends on the verification infrastructure from Phase 1 (having a working OC test environment).
If Phase 2 is to verify that "OC reads the rules via AGENTS.md or the `.claude/rules/` fallback," it needs the same manual testing setup described in Phase 1's success criteria.
Consider noting this dependency or combining the verification steps.

**Non-blocking**: Phase 3 has "Test the hooks manually in an OC session" as a step, but the proposal acknowledges there is no headless OC mode for CI.
The Phase 3 success criteria should clarify what "manually" means: is this the implementer running OC interactively and triggering a write to a cdocs path?
If so, documenting the exact manual test steps would help reproducibility.

**Non-blocking**: Phase 5's constraint says "Do not block CC-only PRs on OC build failures."
This is good operational guidance but should specify the mechanism: a separate CI job with `continue-on-error: true`, a path-based trigger that only runs on changes to `plugins/cdocs/`, or a separate workflow file.

### Missing Considerations

**Non-blocking**: The proposal does not address versioning strategy between the CC plugin and the OC npm package.
If `plugin.json` has version `1.2.0`, should `opencode/package.json` have the same version?
Should the build script copy the version from `plugin.json` to `package.json`?
Version drift between the two manifests would create confusion.

**Non-blocking**: The proposal does not discuss rollback strategy.
If the OC generated output breaks (e.g., OC changes its agent format), what is the recovery path?
The CI dirty-check would catch stale files, but the proposal should note that the fix is to update the build script and regenerate, not to manually edit `opencode/` files.

**Non-blocking**: The proposal targets three agents for conversion but does not discuss whether new agents added to `plugins/cdocs/agents/` in the future would be automatically picked up by the build script.
The build script sketch implies it reads all `agents/*.md` files, but this should be stated explicitly as a design principle: adding a new CC agent automatically produces an OC equivalent after rebuild.

## Verdict

**Revise.**

The proposal is architecturally sound and well-researched, with a clear path from CC-canonical sources to OC output.
Two issues require correction before it can serve as a reliable implementation guide:

1. The factual inaccuracy about the `validate-cdocs-edit-path.sh` hook being active (it exists as a file but is not wired in `hooks.json`), which misscopes Phase 3.
2. The test plan gap for AGENTS.md integration, which is a new cross-tool artifact and needs explicit verification steps.

The remaining findings are non-blocking improvements that would strengthen the proposal but do not prevent acceptance once the blocking issues are resolved.

## Action Items

1. [blocking] Correct the hooks description: acknowledge that `validate-cdocs-edit-path.sh` is not wired in `hooks.json`, and decide whether to (a) wire it in CC before porting, (b) port the unwired script to OC as a new activation, or (c) drop it from scope.
2. [blocking] Add AGENTS.md integration tests to the test plan: verify `@`-import behavior in CC, verify OC's handling of AGENTS.md content (does it follow `@`-imports or treat them as literal text?), and verify `.claude/rules/` fallback in OC.
3. [non-blocking] Resolve the tools/permission inconsistency in the agent conversion example: clarify whether OC's `edit` permission is separate from `write`, and ensure the example output matches the build script logic.
4. [non-blocking] Decide on a concrete approach for agent body path references: either commit to relative paths in the CC source or commit to build-time rewriting, not both as alternatives.
5. [non-blocking] Replace the placeholder `postinstall` echo with either actual automation or remove it entirely. A no-op postinstall that prints instructions is worse than no postinstall.
6. [non-blocking] Add a versioning strategy: specify whether `package.json` version is derived from `plugin.json` version and whether the build script enforces synchronization.
7. [non-blocking] Note that `.ts` entry points in `package.json` require a Bun-compatible runtime; document this as a known constraint.
8. [non-blocking] Add explicit pass/fail criteria to the manual validation section.
9. [non-blocking] Clarify Phase 5's "do not block CC-only PRs" constraint with a concrete CI mechanism (separate job, path filter, or `continue-on-error`).
10. [non-blocking] State explicitly that the build script auto-discovers new agents in `agents/*.md`, so adding a CC agent automatically produces an OC equivalent.

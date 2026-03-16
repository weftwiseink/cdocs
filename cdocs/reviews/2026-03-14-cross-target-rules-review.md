---
review_of: cdocs/proposals/2026-03-14-cross-target-rules-integration.md
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-14T20:30:00-07:00
task_list: marketplace/cross-target-rules
type: review
state: live
status: done
tags: [fresh_agent, architecture, rules, multi-target, security, test_plan, edge_cases]
---

# Review: Cross-Target Rules Integration

## Summary Assessment

> BLUF(@claude-opus-4-6/cross-target-rules): The proposal is thorough, well-grounded in prior research, and addresses a real gap: cdocs rules do not propagate to external CC installs or OpenCode environments.
> The three-layer architecture (SessionStart hook, OC rules delivery via init, AGENTS.md fallback) is a sound design with appropriate graceful degradation.
> However, the proposal has grown from a focused "rules layer" document into something that partially re-specifies the companion marketplace proposal's AGENTS.md and init concerns, creating scope overlap and potential for drift between the two documents.
> The SessionStart hook script has a fragile sed-based frontmatter stripping implementation and an unvalidated source-repo detection heuristic.
> The test plan is comprehensive in breadth but lacks pass/fail criteria and does not test the hook's error paths or the frontmatter stripping logic.
> Verdict: Revise.

## Section-by-Section Findings

### BLUF and Summary

The BLUF is well-structured and covers the problem, the three-layer solution, and the degradation story.

**Non-blocking**: The BLUF mentions "17+ agents" for AGENTS.md reach, referencing the multi-target report.
The proposal body later says "15+ other tools (Codex, Cursor, Copilot, Aider, Kilo, Windsurf)" in the AGENTS.md section.
The numbers should be consistent.

### Objective

Clear and correctly scoped.
The four user scenarios (source repo, CC external install, OC, other agent tools) define the coverage matrix well.

### Background

**Non-blocking**: The "How cdocs Agents Consume Rules" table correctly identifies the three agents and their resolution methods.
However, the table says nit-fix uses "Glob at startup" while the actual `nit-fix.md` agent file says `Glob tool to find all files matching plugins/cdocs/rules/*.md`.
The distinction matters: the nit-fix agent does not actually use a shell glob; it uses the CC Glob tool, which resolves differently from bash globbing.
The proposal's Layer 2 fix ("Use the Glob tool to find all files matching `rules/*.md` relative to this agent file's directory") implicitly assumes the Glob tool supports relative path resolution from the agent's file location, which is unverified.

### Layer 1: CC SessionStart Hook

This is the most technically specific section of the proposal and warrants close scrutiny.

**Blocking**: The `inject-rules.sh` script uses a sed command to strip `paths:` frontmatter from rule files before injection:

```bash
CONTENT=$(echo "$CONTENT" | sed '/^---$/,/^---$/{ /^paths:/d; /^  - /d; }')
```

This sed pattern is too aggressive.
It deletes any line matching `^  - ` (two-space-indented list item) within frontmatter.
If a rule file has other frontmatter fields with list values (e.g., `tags: [...]` on multiple lines, or future fields), those lines would be silently deleted.
The intent is to strip only the `paths:` key and its values.
A safer approach: strip the entire YAML frontmatter block (the hook is injecting content as prose, not as structured rules, so frontmatter is noise) or use a more targeted deletion that matches `paths:` and its immediate list children only.

**Non-blocking**: The hook uses `python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))'` for JSON escaping.
This adds a python3 runtime dependency to the hook.
The 3-second timeout is tight if python3 has a cold start (first invocation in a container or CI environment).
Consider using `jq -Rs .` instead, which is lighter-weight and more commonly available in environments where CC runs.
If neither dependency is acceptable, bash-native escaping (replacing newlines and quotes manually) would eliminate external dependencies entirely, though at the cost of fragility.

**Non-blocking**: The source-repo detection heuristic ("check if CLAUDE.md in the project root contains `@plugins/cdocs/rules/`") is brittle.
If the user renames their CLAUDE.md references, restructures imports, or uses a wrapper file that imports CLAUDE.md, the grep would miss the match and the hook would inject duplicate rules.
This is a low-probability scenario, and duplicate rules cause "slightly larger context" not incorrect behavior (as the proposal acknowledges for the `paths:` scoping loss).
But the mitigation section should acknowledge this limitation rather than presenting the heuristic as reliable.

**Non-blocking**: The hook's JSON output structure (`hookSpecificOutput.hookEventName`) should be validated against CC's current SessionStart hook schema.
The proposal references the structure but does not cite the CC documentation or a working example.
If the output schema is wrong, the hook silently fails (CC ignores malformed hook output).
A reference to the CC hooks documentation or an existing working SessionStart hook example would strengthen confidence.

### Layer 2: Agent Path Resolution Fix

**Non-blocking**: The updated agent startup instruction says "find all files matching `rules/*.md` relative to this agent file's directory."
CC agents do not have a first-class concept of "this agent file's directory" in their prompt context.
The `$CLAUDE_PLUGIN_ROOT` environment variable is available in hooks but explicitly noted as unavailable in agent prompts.
The NOTE callout at the end of this section correctly identifies this uncertainty, but the proposed solution text reads as if relative resolution is confirmed.
Rephrase the proposed instruction to reflect the experimental nature: the primary delivery is the SessionStart hook, and agent-level path resolution is a belt-and-suspenders measure that requires testing.

This is an important point because if `./rules/*.md` does not resolve from the agent's location, Layer 2 provides zero additional value beyond the SessionStart hook for external installs.
The proposal should be clearer about Layer 2 being conditional on a CC behavior that has not been verified.

### Layer 3: OpenCode Rules Delivery

**Non-blocking**: Section 3a proposes extending `/cdocs:init` to detect OC projects via `opencode.json` or `.opencode/` directory presence and create `.opencode/rules/cdocs/` with OC-enhanced frontmatter.
This overlaps with the companion marketplace proposal's Phase 2 ("AGENTS.md and Rules Integration"), which also extends init behavior.
The two proposals should cross-reference each other's init modifications to avoid conflicting implementations.
Currently, the companion proposal treats rules as "minor addition" while this proposal adds significant init logic for OC.
Which proposal's init modifications take precedence during implementation?

**Non-blocking**: The OC-enhanced frontmatter example uses `globs: ["cdocs/**/*.md"]`.
This scoping is reasonable, but the keywords list (`cdocs`, `devlog`, `proposal`, `review`, `report`) is broad.
A user mentioning "review" in any context (code review, PR review) would trigger cdocs rule injection.
Consider whether keyword activation should require multiple keyword matches (`match: all`) or more specific terms (`cdocs devlog`, `cdocs proposal`).

**Non-blocking**: Section 3c (inline AGENTS.md) introduces a synchronization problem that is acknowledged but only mitigated with a comment block.
This is the weakest part of the proposal: inlined content will drift, and the version comment `<!-- cdocs rules v0.1.0 - regenerate with /cdocs:init -->` requires the user to notice staleness.
A better mitigation: the SessionStart hook could detect version mismatches between the plugin's rule files and the deployed copies (by comparing a hash or version string), and emit a warning in `additionalContext` suggesting the user re-run init.
This is additional complexity, but it addresses the drift problem proactively rather than relying on user vigilance.

### Layer 4: Cross-Tool Rule Authoring Guidelines

Well-structured.
The frontmatter layering table is clear.

**Non-blocking**: The "Avoid in rule body content" list says to avoid `@path/to/file` imports.
However, the current `writing-conventions.md` rule file does not contain any `@`-imports (confirmed by reading it).
This guideline is forward-looking, which is fine, but it should note that the current rule files already comply.
This both validates the current state and sets a baseline for future audits (Phase 5).

### Architecture Diagram

The Mermaid diagram accurately represents the delivery paths.

**Non-blocking**: The diagram shows `CCMD` (CLAUDE.md @-import) with a dotted arrow to the rule files, but it does not show the relationship between the SessionStart hook and the CLAUDE.md detection (the skip logic).
Adding a conditional edge or note would make the diagram more precise.

### Design Decisions

All five decisions are well-justified.
The reasoning is grounded in the supporting research.

**Non-blocking**: The decision "Extend `/cdocs:init` rather than creating a separate `/cdocs:setup-rules` skill" is pragmatic but risks making init grow unbounded.
Init already handles CC-specific setup (`.claude/rules/cdocs.md`, directory structure).
Adding OC detection, OC rules directory creation, AGENTS.md generation (with inlining), and version comments makes init a multi-tool orchestrator.
Consider noting the init complexity risk and establishing a threshold (e.g., "if init exceeds N responsibilities, factor out a shared setup library") as a future guardrail.

### Edge Cases

The edge cases section is strong.
Six scenarios are identified, each with a clear mitigation.

**Blocking**: The "SessionStart hook runs in the source repo too" mitigation says the hook checks for `@plugins/cdocs/rules/` in the project's CLAUDE.md.
But this check is not shown in the hook script code.
The script code (in the Layer 1 section) reads all rule files and concatenates them unconditionally.
There is no grep of CLAUDE.md.
The mitigation describes behavior that the implementation does not include.
Either update the hook script to include the source-repo check, or mark this as a TODO for implementation and note that the initial version will inject duplicate rules in the source repo.

**Non-blocking**: The "AGENTS.md conflicts with existing project AGENTS.md" mitigation uses comment markers (`<!-- cdocs-rules-start -->` / `<!-- cdocs-rules-end -->`) for idempotent re-runs.
This is the right approach.
However, some tools that read AGENTS.md may not handle HTML comments gracefully (rendering them as visible text or treating them as content).
The risk is low (most markdown parsers ignore HTML comments), but it should be noted.

### Test Plan

**Blocking**: The test plan lists 13 test cases across four categories, which is comprehensive in breadth.
However, none of the tests specify pass/fail criteria.
For example, Test 1 says "ask the agent 'what cdocs writing conventions are you following?' and confirm it mentions BLUF, sentence-per-line, callout syntax."
This is a fuzzy criterion: what if the agent mentions BLUF and callout syntax but not sentence-per-line?
Is that a pass or fail?
Each test should have an explicit expected outcome (e.g., "agent output must reference all three of: BLUF, sentence-per-line, callout syntax").

**Blocking**: The test plan has no negative test for the SessionStart hook.
Test 3 ("Hook error resilience") tests a missing file, but there is no test for:
- Malformed rule file content (e.g., broken YAML frontmatter that causes the sed strip to produce garbage).
- The python3 JSON escaping failing (e.g., rule content with raw control characters).
- The hook exceeding its 3-second timeout.
These are the most likely real-world failure modes and should be covered, at least as manual verification steps.

**Non-blocking**: Test 5 tests conditional activation with `opencode-rules`, but the proposal does not list `opencode-rules` as a test dependency.
How is the test environment set up?
The verification methodology section mentions installing `opencode-rules` but does not specify a version or installation method.

**Non-blocking**: Tests 11 and 12 (agent rule resolution in external installs) check whether agents "load all three rule files."
But in the SessionStart hook delivery path, agents do not "load" rule files; they receive rule content via session context.
The test description should distinguish between the agent's own file-loading behavior and the hook's context injection.

### Implementation Phases

The six phases are logically ordered and have clear scope boundaries.

**Non-blocking**: Phase 1 and Phase 2 are both independently implementable, but they have a shared test infrastructure dependency: both need a CC external install test project and an OC test project.
Creating this test infrastructure should be called out as a Phase 0 or noted as a prerequisite.

**Non-blocking**: Phase 5 (Cross-Tool Rule Authoring Audit) says to grep for `@`, `/memory`, `plugin.json`, `.claude/` in rule body content.
Grepping for `@` alone would match email addresses, NOTE attributions (`NOTE(opus/triage-subagent):`), and any use of `@` as a literal character.
The grep should be more specific: `@[a-zA-Z]` to match `@`-import patterns, or better, `^@` for lines starting with an import.

**Non-blocking**: Phase 6 references updating "the nit-fix-project-rules RFP" at `cdocs/proposals/2026-01-30-nit-fix-project-rules.md`.
This is a useful cross-reference, but the proposal does not verify that this file still exists or is in a state where updates are appropriate (it may be archived).

### Scope Overlap with Companion Proposal

**Non-blocking but important**: The companion [multi-target marketplace proposal](cdocs/proposals/2026-03-14-multi-target-marketplace.md) has its own Phase 2 ("AGENTS.md and Rules Integration") that creates `plugins/cdocs/AGENTS.md` with `@`-imports.
This proposal's Layer 3b also creates `plugins/cdocs/AGENTS.md` with identical content.
Both proposals' Phase 3/Phase 3 extends `/cdocs:init`.
The companion proposal's review (2026-03-14) flagged the `@`-import behavior in AGENTS.md as needing verification for OC.
This proposal addresses that exact concern in Section 3c (inline AGENTS.md for maximum compatibility) and in the edge cases ("OC does not follow @-imports in AGENTS.md").

The proposals complement each other well, but the implementation order is ambiguous.
Which proposal's AGENTS.md creation step runs first?
If both are implemented, does AGENTS.md get created twice?
The proposals should either: (a) designate one as the owner of the AGENTS.md artifact, or (b) merge the AGENTS.md-related phases into a single cross-proposal implementation unit.

### Missing Considerations

**Non-blocking**: The proposal does not discuss the context budget impact of injecting three rule files via `additionalContext` at every session start.
The three rule files are roughly 2-3KB of text combined.
This is small relative to typical context windows, but the proposal should note the approximate size and confirm it is within CC's `additionalContext` limits (if any exist).

**Non-blocking**: The proposal does not address what happens when a user has cdocs installed and also has their own `.claude/rules/` files with conflicting conventions.
For example, a user's rule file might say "use em-dashes liberally" while cdocs says "prefer colons over em-dashes."
The SessionStart hook injects cdocs rules as `additionalContext`, which has lower precedence than the user's own rules (loaded via `.claude/rules/`).
This is likely the correct behavior (user rules override plugin rules), but it should be stated explicitly.

**Non-blocking**: The proposal does not discuss uninstall/cleanup.
If a user uninstalls cdocs from CC, the SessionStart hook stops running, but any `.claude/rules/cdocs.md` or AGENTS.md content created by `/cdocs:init` remains.
This is standard behavior (init-created files are project files, not plugin-managed), but noting it would set expectations.

## Verdict

**Revise.**

The proposal is architecturally sound: the three-layer approach with graceful degradation is the right design, and the decision to treat AGENTS.md as fallback rather than primary is well-justified.
The SessionStart hook approach is the strongest contribution: it solves the immediate CC external install problem without waiting for #14200.

Three blocking issues must be addressed:

1. The hook script implementation does not match the edge case mitigation text (source-repo skip logic is described but not implemented in the code).
2. The sed-based frontmatter stripping is too aggressive and could silently corrupt rule content.
3. The test plan lacks pass/fail criteria and negative tests for the hook's most likely failure modes.

The remaining findings are non-blocking improvements focused on scope clarity (vis-a-vis the companion proposal), robustness of OC keyword activation, and editorial consistency.

## Action Items

1. [blocking] Reconcile the hook script code with the source-repo skip mitigation: either add the CLAUDE.md grep to the script, or remove the claim from the edge cases section and accept duplicate injection in the source repo.
2. [blocking] Replace the sed-based `paths:` stripping with a safer approach: either strip the entire YAML frontmatter block (simpler, since frontmatter is not useful in `additionalContext`) or use a more targeted pattern that deletes only the `paths:` key and its direct children.
3. [blocking] Add explicit pass/fail criteria to every test case and add negative tests for the SessionStart hook (malformed rule content, timeout behavior, JSON escaping edge cases).
4. [non-blocking] Designate ownership of the AGENTS.md artifact between this proposal and the companion multi-target marketplace proposal. If both proposals create the same file, one should defer to the other.
5. [non-blocking] Replace the python3 JSON escaping dependency with `jq -Rs .` or document python3 as a required runtime dependency for the hook.
6. [non-blocking] Narrow the OC keyword activation list: replace generic terms like "review" and "report" with cdocs-specific terms, or use `match: all` to require multiple keyword matches.
7. [non-blocking] Acknowledge in Layer 2 that agent-relative Glob resolution is unverified, and frame it explicitly as experimental rather than as a confirmed solution.
8. [non-blocking] Note the approximate combined size of the three rule files and confirm it is within `additionalContext` limits.
9. [non-blocking] Add a version-mismatch detection mechanism (hash comparison) to the SessionStart hook for detecting stale deployed rule copies, rather than relying solely on the version comment.
10. [non-blocking] Fix the grep pattern in Phase 5: searching for bare `@` in rule content would produce false positives; use `^@` or `@[a-zA-Z]` to target actual `@`-import patterns.
11. [non-blocking] State explicitly that `additionalContext`-injected rules have lower precedence than user `.claude/rules/` files, and that this is the intended behavior.

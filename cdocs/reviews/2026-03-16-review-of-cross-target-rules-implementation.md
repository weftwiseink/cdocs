---
review_of: cdocs/devlogs/2026-03-16-cross-target-rules-implementation.md
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-16T14:00:00-07:00
task_list: marketplace/cross-target-rules
type: review
state: live
status: done
tags: [fresh_agent, implementation, rules, cross-target, correctness, hook_script, frontmatter_stripping]
---

# Review: Cross-Target Rules Implementation

## Summary Assessment

This devlog documents the implementation of the cross-target rules integration proposal across 6 phases: SessionStart hook, agent path resolution, `/cdocs:init` OC extension, plugin-level AGENTS.md, cross-tool rule authoring audit, and README documentation.
The implementation is structurally complete: all 8 files listed in the Changes Made table exist and contain relevant changes aligned with the proposal's intent.
However, the SessionStart hook has a critical bug in its frontmatter-stripping logic that would silently drop 2 of 3 rule files, and the triage agent's path reference format is inconsistent with how agents discover files.
Verdict: Revise.

## Section-by-Section Findings

### Phase 1: SessionStart Hook (`inject-rules.sh`)

**Blocking: awk frontmatter stripping silently drops files without frontmatter.**

The hook uses this awk command to strip YAML frontmatter:

```bash
CONTENT=$(echo "$CONTENT" | awk 'BEGIN{fm=0} /^---$/{fm++; next} fm>=2{print}')
```

This logic increments a counter `fm` on each `---` line and only prints lines after the second `---` (i.e., after the closing frontmatter delimiter).
The problem: only `frontmatter-spec.md` has YAML frontmatter (`---\npaths:\n...\n---`).
The other two rule files (`writing-conventions.md` and `workflow-patterns.md`) have no frontmatter at all: they begin directly with a markdown heading.
For files without frontmatter, `fm` never reaches 2, so `fm>=2` is never true, and the awk command outputs nothing.

This means the hook would inject only `frontmatter-spec.md` content and silently produce empty sections for the other two rule files.
The combined output would have:

```
## [cdocs rule: frontmatter-spec]
[content]

## [cdocs rule: workflow-patterns]
[empty]

## [cdocs rule: writing-conventions]
[empty]
```

Fix: the awk command should pass through content unchanged when no frontmatter is present.
A corrected version:

```bash
CONTENT=$(echo "$CONTENT" | awk '
  BEGIN { fm=0; in_fm=0 }
  /^---$/ && fm==0 { fm=1; in_fm=1; next }
  /^---$/ && in_fm { fm=2; in_fm=0; next }
  !in_fm { print }
')
```

Or more simply, handle the no-frontmatter case: if the first line is not `---`, print everything.

**Non-blocking: `echo "$CONTENT"` may strip trailing newlines and mangle backslashes.**

The pattern `CONTENT=$(echo "$CONTENT" | awk ...)` has two portability concerns.
On some shells, `echo` interprets backslash escape sequences (e.g., `\n`, `\t`) in the content.
Using `printf '%s\n' "$CONTENT"` is safer.
Additionally, command substitution `$(...)` strips trailing newlines, though this is unlikely to matter for rule file content.

**Non-blocking: CONTEXT accumulation uses string concatenation in a loop.**

For 3 files this is fine, but the pattern `CONTEXT="${CONTEXT}..."` in a bash loop is fragile with large content (potential quoting issues with special characters in rule content).
The `jq -Rs .` call at the end handles JSON escaping correctly, so this is acceptable for the current scale.

**Non-blocking: the hook emits `hookSpecificOutput.hookEventName` in the JSON output.**

This matches the pattern used by the existing `cdocs-validate-frontmatter.sh` hook (line 44 and 69), so the format is consistent within the project.

### Phase 1: hooks.json

The `hooks.json` structure looks correct.
The `SessionStart` event is added alongside the existing `PostToolUse` event, and the `description` field was updated to mention "rule injection."
The 3-second timeout is reasonable for reading 3 small markdown files and running `jq`.

No issues found.

### Phase 2: Agent Path Resolution (nit-fix, triage, reviewer)

**Non-blocking: triage agent uses a bare code block for its path reference.**

The triage agent references the frontmatter spec via:

```
rules/frontmatter-spec.md
```

This appears inside a fenced code block in the agent's startup instructions.
The nit-fix agent uses explicit Glob tool instructions ("Use the Glob tool to find all files matching `rules/*.md`"), while the triage agent uses a code-block path that the agent must interpret as a file to Read.
The reviewer agent similarly uses a code block listing two paths.
This inconsistency is minor but could lead to different failure modes: nit-fix fails gracefully via Glob returning no results, while triage/reviewer may fail if the agent does not interpret the code block as a Read instruction.

The fallback instructions and NOTE callouts about SessionStart injection are present on all three agents, which is good.

**Non-blocking: the reviewer agent prompt says "read these rule files" with a code block, but does not explicitly say "use the Read tool."**

Step 1 in the reviewer's Workflow section says "Read the rule files listed above," which is clear enough in context.
The startup code block lists `rules/frontmatter-spec.md` and `rules/writing-conventions.md`, matching the paths specified in the proposal.

### Phase 3: `/cdocs:init` OC Extension

The SKILL.md has been extended with step 5 (OpenCode detection and rule deployment) and step 6 (AGENTS.md creation).
The implementation covers:

- OC detection via `opencode.json` or `.opencode/` directory.
- OC-enhanced frontmatter with `globs:` and `keywords:` using `cdocs`-prefixed terms (addressing the round 1 review feedback about false activation).
- Existing frontmatter stripping before prepending OC frontmatter.
- Version comment for staleness detection.
- AGENTS.md with inlined (not `@`-imported) content for maximum tool compatibility.
- Comment delimiters for idempotent re-runs.
- Append-to-existing logic for pre-existing AGENTS.md.

**Non-blocking: the init skill does not specify which tool to use for frontmatter stripping.**

Step 5b says "Strip any existing YAML frontmatter from the source rule file before prepending the OC frontmatter."
This is a natural language instruction for the agent executing the skill, so the agent will implement the stripping at runtime.
Unlike the hook script (which is a bash script that runs automatically), the init skill's stripping is performed by the LLM agent and is unlikely to have the same awk bug.
However, for consistency, the skill could note that not all rule files have frontmatter.

**Non-blocking: the version comment is hardcoded to `v0.1.0`.**

The `<!-- cdocs rules v0.1.0 - regenerate with /cdocs:init -->` comment uses the current plugin version.
If the plugin version bumps, this string must be updated in the SKILL.md.
Consider referencing the version dynamically (e.g., "use the version from plugin.json") rather than hardcoding it.

### Phase 4: Plugin-Level AGENTS.md

The `plugins/cdocs/AGENTS.md` file is clean and minimal.
It uses `@`-imports for the three rule files with relative paths (`@rules/writing-conventions.md`, etc.).
These paths resolve correctly from the AGENTS.md location at `plugins/cdocs/AGENTS.md` to `plugins/cdocs/rules/*.md`.

No issues found.

### Phase 5: Cross-Tool Rule Authoring Audit

The devlog reports zero matches for all grep targets (`^@[a-zA-Z]`, `/memory`, `plugin\.json`, `\.claude/`).
I verified this is correct: the three rule files contain no CC-specific patterns in their body content.

No issues found.

### Phase 6: README Documentation

The README updates are comprehensive and well-structured.
The Rules Integration section explains the three delivery layers clearly.
The Rules in OpenCode subsection covers OC-specific behavior.
The "When CC #14200 Lands" migration note provides concrete steps (add manifest field, delete hook, remove hooks.json entry).
The Hooks section was updated to mention the SessionStart hook.

**Non-blocking: the README says "Skips injection in the source repo" but does not explain the detection mechanism.**

The Rules Integration section mentions the skip behavior but does not note that it relies on grepping CLAUDE.md for `@plugins/cdocs/rules/`.
A brief mention of the heuristic (and its best-effort nature) would help users understand the behavior.

### Devlog: Deviations from Proposal

The devlog documents three deviations:

1. Content hash computation deferred as progressive enhancement. Reasonable: the hash is only useful with init-side comparison, which is not yet implemented.
2. Phase 5 yielded no changes. Correct per the audit results.
3. Phase 6 cross-file updates (nit-fix-project-rules RFP, CLAUDE.md) were not made due to task constraints. Understood, though this should be tracked as follow-up work.

**Non-blocking: deviation 3 means the proposal's Phase 6 is only partially implemented.**

The proposal's Phase 6 specifies updating the nit-fix-project-rules RFP and CLAUDE.md.
The devlog acknowledges these were skipped due to scope constraints.
This is acceptable but should be noted as outstanding work.

### Devlog: Verification Section

The verification section is organized by phase and provides concrete evidence for each.
Phase 1 mentions `bash -n` syntax check and `jq .` validation.
Phase 2 confirms all three agents were updated.
Phase 3 confirms OC detection and comment delimiter logic.
Phase 4 confirms `@`-import paths.
Phase 5 confirms grep results.
Phase 6 confirms README sections.

**Non-blocking: the verification section does not mention testing the awk frontmatter stripping against files without frontmatter.**

The verification notes that the hook "strips YAML frontmatter via `awk`" but does not indicate that this was tested against the actual rule files, two of which lack frontmatter.
The `bash -n` syntax check confirms the script is syntactically valid, but cannot catch the semantic bug where awk silently produces empty output for files without `---` delimiters.

## Implementation Fidelity Against Proposal

Checking the implementation against the proposal's specification:

| Proposal Requirement | Implementation Status | Notes |
|---|---|---|
| SessionStart hook with source-repo skip | Implemented | Source-repo grep check present |
| Frontmatter stripping before injection | Implemented but buggy | awk strips entire content for files without frontmatter |
| `jq -Rs .` for JSON escaping | Implemented | Matches proposal (revised from python3) |
| Content hash in hook output | Deferred | Documented as progressive enhancement |
| Agent path resolution with fallback | Implemented | All three agents updated |
| Init OC detection | Implemented in SKILL.md | Agent-executed, not a script |
| OC-enhanced frontmatter with cdocs-prefixed keywords | Implemented in SKILL.md | Correct keyword format |
| AGENTS.md with @-imports at plugin level | Implemented | Correct relative paths |
| Inlined AGENTS.md at project level via init | Implemented in SKILL.md | Comment delimiters present |
| Rule authoring audit (grep for CC-specific patterns) | Implemented | Zero matches confirmed |
| README documentation | Implemented | All specified sections present |
| Nit-fix-project-rules RFP update | Not implemented | Scoped out per task constraints |
| CLAUDE.md update | Not implemented | Scoped out per task constraints |

## Verdict

**Revise.**

The implementation is structurally complete and aligned with the proposal's intent.
The AGENTS.md, init skill extensions, agent path updates, and README documentation are all correct.
However, the SessionStart hook has a critical bug: the awk frontmatter-stripping logic silently drops all content from files that lack YAML frontmatter, which is 2 of the 3 rule files.
This must be fixed before the hook can function as intended.

## Action Items

1. [blocking] Fix the awk frontmatter-stripping logic in `plugins/cdocs/hooks/inject-rules.sh` to handle files without YAML frontmatter. The current logic (`fm>=2` gate) outputs nothing for files that lack `---` delimiters. A corrected version should detect whether the file starts with `---` and only apply stripping if frontmatter is present, otherwise pass through the entire file content.

2. [non-blocking] Replace `echo "$CONTENT"` with `printf '%s\n' "$CONTENT"` in the hook script for safer handling of backslash characters in rule file content.

3. [non-blocking] Track the incomplete Phase 6 work (nit-fix-project-rules RFP update, CLAUDE.md cross-target architecture note) as a follow-up TODO, either in the devlog or as a separate task.

4. [non-blocking] Add a brief note in the README's Rules Integration section about the source-repo detection heuristic (grepping for `@plugins/cdocs/rules/` in CLAUDE.md) and its best-effort nature.

5. [non-blocking] Consider making the version comment in the init SKILL.md reference the plugin version dynamically rather than hardcoding `v0.1.0`.

## Questions for Author

The following question arose during review and may warrant clarification:

**Q1: Was the awk frontmatter-stripping logic tested against the actual rule files?**

- (a) Yes, it was tested and the empty output for files without frontmatter was not noticed.
- (b) No, testing was done only against `frontmatter-spec.md` (which has frontmatter) or against synthetic test data.
- (c) The `bash -n` syntax check and `jq .` validation were considered sufficient, and the awk logic was not exercised against real files.

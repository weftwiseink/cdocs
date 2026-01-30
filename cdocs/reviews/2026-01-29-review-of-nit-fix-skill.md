---
review_of: cdocs/proposals/2026-01-29-nit-fix-skill.md
first_authored:
  by: "@claude-opus-4-5-20251101"
  at: 2026-01-29T15:30:00-08:00
task_list: cdocs/nit-fix
type: review
state: archived
status: done
tags: [fresh_agent, architecture, subagent_patterns, writing_conventions]
---

# Review: Nit Fix Skill Proposal

> BLUF(claude-opus-4-5-20251101/cdocs/nit-fix): The proposal presents a well-motivated, clearly-architected haiku subagent for writing convention enforcement.
> The "rules stickler" design (no hardcoded rules, read conventions at runtime) is sound and the mechanical vs. judgment-required boundary is well-considered.
> However, the proposal claims the subagent applies direct edits via Edit, which contradicts the read-only pattern established by the accepted triage proposal: this architectural divergence needs explicit justification or alignment.
> Two blocking issues and several non-blocking suggestions follow.
> Verdict: Revise.

## Summary Assessment

The proposal defines a `/cdocs:nit_fix` skill that spawns a haiku subagent to enforce `rules/writing-conventions.md` against target documents.
The core design is strong: reading rules at runtime rather than hardcoding them creates a genuinely adaptable enforcement mechanism.
The most important finding is an unresolved tension with the triage skill's accepted architecture: triage was explicitly redesigned to be read-only (a blocking resolution in its round 2 review), yet nit-fix proposes that the haiku subagent apply edits directly.
This needs reconciliation before acceptance.

## Section-by-Section Findings

### BLUF

The BLUF is well-constructed: it states the skill name, the runtime rules-reading design, the mechanical vs. judgment split, and the complementary relationship to triage.
It gives no surprises when reading the full body.

**Non-blocking:** The BLUF says "applies mechanical fixes directly" which is accurate to the proposal's intent but becomes a concern when evaluated against the triage precedent (see Architecture finding below).

### Objective

Clear and well-motivated.
The framing that authoring agents focus on content rather than formatting is a sound justification for a dedicated enforcement agent.
The statement "the agent must not embed convention knowledge in its own prompt" is an appropriate and explicit design constraint.

No issues found.

### Background: Current State

Accurate characterization of triage, review, and the PostToolUse hook.
The enumeration of the 11 conventions is helpful for grounding the proposal.

**Non-blocking:** The description of triage says it "handles frontmatter accuracy and workflow recommendations" and "does not address prose conventions."
This is accurate, but it omits that the accepted triage architecture is read-only (the haiku subagent only recommends, the top-level agent applies edits).
This omission becomes relevant in the Architecture section.

### Background: Haiku Subagent Patterns

The proposal states: "nit-fix applies edits directly (it's fixing formatting, not making status judgments), while triage recommends status changes and applies only mechanical field edits."

**Blocking:** This characterization of triage is outdated.
The accepted version of the triage proposal (round 2 review accepted it) and the implemented `skills/triage/SKILL.md` specify that the triage subagent is explicitly read-only: it does not make Edit calls.
The triage SKILL.md contains the instruction: "CRITICAL: You are READ-ONLY. Do NOT use the Edit tool or Write tool."
The nit-fix proposal describes triage as applying "mechanical field edits," which was the pre-round-1-review design that was explicitly rejected as a blocking issue due to haiku YAML editing reliability concerns.

The nit-fix proposal needs to accurately characterize triage's current architecture and then explicitly address why nit-fix should diverge from the read-only subagent pattern, or adopt the same read-only pattern.

### Architecture: Rules-Reading Enforcement Agent

The mermaid diagram and five-step process are clear.
The flow from rules reading through violation classification to fix/report branching is logical.

**Blocking:** The architecture has the haiku subagent calling Edit directly (step 4: "Applies mechanical fixes directly via Edit").
This contradicts the triage precedent where the haiku subagent was redesigned to be read-only after review found haiku Edit reliability to be a blocking concern.
The round 1 review of the haiku subagent proposal identified "Haiku YAML editing reliability" as blocking issue #1, and the accepted resolution was to make triage fully recommendation-only.

There are two defensible paths:
1. **Align with triage:** Make the nit-fix subagent read-only. It reports all violations (both mechanical and judgment-required) with suggested fixes. The top-level agent applies mechanical fixes based on the report. This is consistent and eliminates the haiku editing reliability risk.
2. **Justify the divergence:** Argue explicitly that prose/formatting edits via Edit are lower-risk than YAML frontmatter edits (no structural integrity concerns, edits are line-level text substitutions not nested YAML mutations). This would need to address why the haiku reliability concern applies differently here.

Either path is acceptable, but the proposal must address the question rather than ignore it.

### The "Rules Stickler" Design

This is the proposal's strongest contribution.
The five-step process (read rules, classify each rule, check mechanical rules, apply fixes, report judgment-required) is well-defined.
The insight that adding a new convention to the rules file automatically extends the enforcement surface is a genuine architectural advantage.

No issues found.

### Mechanical vs. Judgment-Required Boundary

The classification is thoughtful and the examples are well-chosen.
The NOTE at the end acknowledging the boundary "isn't perfectly crisp" and that the agent reports detection plus whether it applied a fix or deferred is good engineering honesty.

**Non-blocking:** The proposal classifies "Diagram format: flag ASCII diagrams" as mechanical for detection but judgment-required for the fix.
This is a hybrid category that doesn't cleanly fit either bucket.
Consider documenting this as a third category ("detect-and-report") in the prompt template, or clarifying in the output format how hybrid violations appear (under FIXES APPLIED with a note that only detection was performed, or under JUDGMENT REQUIRED with a note that detection was mechanical).

### Output Format

The report format is clear, structured, and follows the same style as triage reports.
The three sections (FIXES APPLIED, JUDGMENT REQUIRED, NO VIOLATIONS) map cleanly to the mechanical/judgment/clean trichotomy.

No issues found.

### Important Design Decisions

**Decision 1 (no hardcoded rules):** Sound. Well-justified with the linter-reads-config-file analogy.

**Decision 2 (haiku model, direct edits):** The justification that mechanical fixes are "deterministic transformations" is reasonable on its merits, but does not acknowledge the triage precedent.
See the Architecture blocking finding above.

**Decision 3 (separate from triage):** Well-reasoned. The single-responsibility argument and the different invocation timing (end-of-turn vs. author's discretion) are strong justifications.

**Decision 4 (report judgment-required only):** Sound. The argument that haiku rewriting prose would "likely degrade quality" is correct and shows appropriate restraint.

**Decision 5 (callout attribution inference):** The `task_list` inference heuristic is practical.
The NOTE about `mjr` being repo-specific and the fallback logic (`first_authored.by` -> `task_list`) is thoughtful.

**Non-blocking:** Decision 5's NOTE says the agent should "infer the author prefix from `first_authored.by` if it maps to a known username."
The phrase "known username" is underspecified: known to whom?
The haiku agent has no user database.
In practice, `first_authored.by` values are either model names (e.g., `@claude-opus-4-5-20251101`) or usernames (e.g., `@mjr`).
The heuristic should be: if `first_authored.by` does not start with `@claude`, treat it as a username and use it as the author prefix.
Otherwise, extract the author from `task_list` or report rather than fix.

### Stories

All five stories are concrete and trace realistic workflows.
Story 3 (new convention added) effectively demonstrates the rules-reading design's value.
Story 5 (pre-review workflow) shows practical integration with the broader CDocs workflow.

**Non-blocking:** Story 4 (batch mode) proposes running nit-fix on all `cdocs/**/*.md` files without arguments.
The proposal does not discuss performance implications of a haiku subagent processing many files in a single invocation.
For a large document set, the subagent may hit context limits or produce a very long report.
Consider noting whether batch mode processes files sequentially in separate subagent invocations or all at once, and what the practical file count limit is.

### Edge Cases

Well-considered set covering rules file mutation, haiku misidentification, conflicting conventions, context limits, attribution inference failure, and false positives.

**Non-blocking:** Edge case 4 claims haiku's context window is 200K tokens.
This claim should be verified against current model specifications.
If the value is incorrect, the mitigation (document is always small enough) may still hold, but the specific number should be accurate or omitted.

### Test Plan

The seven test items cover the main paths well: mechanical fixes, judgment-required detection, clean documents, rules evolution, attribution inference, batch mode, and conservative splitting.

**Non-blocking:** There is no test case for the report format itself: verifying the output matches the specified structure (FIXES APPLIED / JUDGMENT REQUIRED / NO VIOLATIONS sections, line numbers, convention names).
Since the top-level agent or user parses this report, format correctness matters.

### Implementation Phases

The five phases are logical and incrementally buildable.
Phase 1 (scaffolding) through Phase 5 (documentation) trace a clear implementation path.

**Non-blocking:** Phase 2 says "Test on existing cdocs documents" but does not specify success criteria for those tests.
What constitutes a passing test: zero false positives on known-clean documents?
Correct identification of known violations in a test fixture?
Adding specific success criteria would strengthen this phase.

### Appendix A: Haiku Prompt Template

The prompt template is detailed and well-structured.
The five-task breakdown, the conservative splitting guidance (step 5), and the exact output format specification are all strong.

**Non-blocking:** The prompt template instructs the agent to "Apply fix via Edit" (step 3c).
If the blocking architecture issue is resolved by making the subagent read-only, this instruction and the overall prompt structure need corresponding updates: step 3c would become "Record the suggested fix in your report" and step 3d merges into a unified reporting step.

**Non-blocking:** The prompt template does not instruct the agent to skip frontmatter between `---` delimiters when checking conventions.
Step 3b says "Skip frontmatter (between --- delimiters) and code blocks (``` delimiters)."
This is present but could be more prominent: frontmatter contains colons and other patterns that could trigger false positives on punctuation conventions if the skip logic fails.

## Consistency Check

The proposal is internally consistent: the BLUF, architecture, decisions, stories, and prompt template all describe the same system.
The one external inconsistency is with the accepted triage architecture, as noted in the blocking findings.

The frontmatter is compliant with the spec: all required fields present, correct types, valid values.
The `status: wip` is appropriate for a proposal under initial review.
Tags are relevant (`claude_skills`, `workflow_automation`, `writing_conventions`, `subagent_patterns`).

## Writing Convention Compliance

The proposal follows CDocs writing conventions well:
- BLUF present and comprehensive.
- Sentence-per-line formatting is used consistently.
- NOTE callouts use proper `(author/workstream)` attribution.
- Mermaid diagram used for the architecture flow.
- No emojis.
- Present-tense, history-agnostic framing.
- Colons preferred over em-dashes throughout.

No convention violations found.

## Verdict

**Revise.**

The proposal is architecturally sound and well-written, but the relationship to the accepted triage architecture needs explicit treatment.
The blocking issue is not that the proposed approach is wrong: it may be correct that prose edits are lower-risk than YAML edits and justify a direct-edit subagent.
The issue is that the proposal does not acknowledge or address the question at all, despite building on a pattern where this exact concern was the primary blocking issue in review.

## Action Items

1. [blocking] Reconcile the direct-edit haiku subagent design with the accepted triage architecture. The triage proposal was explicitly redesigned to be read-only after its round 1 review identified haiku Edit reliability as a blocking concern. Either adopt the read-only pattern (subagent reports, top-level agent applies fixes) or explicitly justify why nit-fix diverges (e.g., line-level text edits are lower-risk than YAML structural mutations). Update the Background section's characterization of triage to reflect its current read-only design.
2. [blocking] Update the "Haiku subagent patterns" background section to accurately describe triage's accepted architecture. The current text ("triage recommends status changes and applies only mechanical field edits") describes the pre-review design, not the accepted version. The implemented triage skill is read-only.
3. [non-blocking] Clarify Decision 5's "known username" heuristic. Specify the practical rule for distinguishing model names from usernames in `first_authored.by` (e.g., if it starts with `@claude`, it is a model name; otherwise, treat as username).
4. [non-blocking] Address batch mode performance in Story 4 or Edge Cases. Note whether batch processing uses a single subagent invocation or multiple, and what practical limits apply.
5. [non-blocking] Document the hybrid "detect-and-report" category for conventions like ASCII diagram detection that are mechanical to detect but judgment-required to fix.
6. [non-blocking] Add a test case for report format correctness: verify the output matches the specified structure with correct section headers, line numbers, and convention names.
7. [non-blocking] Add specific success criteria to Phase 2's "test on existing cdocs documents" step.
8. [non-blocking] Verify or remove the specific claim that haiku's context window is 200K tokens in Edge Case 4.
9. [non-blocking] If the architecture is revised to read-only, update Appendix A's prompt template to replace Edit instructions with report-only instructions.

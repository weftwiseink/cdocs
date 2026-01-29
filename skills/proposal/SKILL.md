---
name: proposal
description: Author a design proposal with structured sections and implementation phases
argument-hint: "[topic]"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# CDocs Proposal

Author a design proposal document.

This is a **deliverable skill** -- the user explicitly requests a proposal.
Proposals specify designs and solutions, outlining implementation phases.
They should retain a "timeless" quality: design changes are noted in NOTE callouts or by reference to another document, not by rewriting.

## Invocation

1. If `$ARGUMENTS` provides a topic, use it. Otherwise, prompt the user.
2. Determine today's date.
3. Create `cdocs/proposals/YYYY-MM-DD_topic.md` using the template below.
4. If `cdocs/proposals/` doesn't exist, suggest running `/cdocs:init` first.

## Template

Use the template in `template.md` alongside this skill file.
Fill in:
- `first_authored.by` with the current model name or `@username`.
- `first_authored.at` with the current timestamp including timezone.
- `task_list` with the relevant workstream path.
- `type: proposal`, `state: live`, `status: wip`.
- Tags relevant to the proposal.

## Required Sections

Each proposal must include:

- **BLUF** -- Bottom line summary at top. Must clearly state the approach without surprises and line up with the final settled approach. Reference the most important sources.
- **Objective** -- Problem or improvement goal.
- **Background** -- Important docs, links, prior art. Context needed to understand the proposal.
- **Proposed Solution** -- Architecture or approach. The core of the proposal.
- **Important Design Decisions** -- Each decision with "Decision" and "Why" subsections. Explain rationale, not just the choice.
- **Edge Cases / Challenging Scenarios** -- What could go wrong, how to handle it.
- **Test Plan** -- Test examples and verification strategies considering the edge cases above.
- **Implementation Phases** -- Detailed but without time estimates. See guidance below.

## Implementation Phase Guidance

**For standard iterative development:**
- Break into logical phases.
- Focus on high-level steps, not prescriptive details.
- Trust developer judgment on approach.
- Document constraints and "what NOT to change."

**For subagent-driven development (5+ task threshold):**
When the proposal has 5+ largely independent phases with clear success criteria:
- Each phase independently executable.
- Clear success criteria per phase (how to verify completion).
- Dependencies between phases noted explicitly.
- Constraints specified (what files/systems NOT to modify).
- Expected inputs/outputs documented.

## Drafting Approach

1. Start with the BLUF. Write it first, even if rough.
2. Fill in Objective and Background for context.
3. Design the Proposed Solution.
4. Document Design Decisions as they arise.
5. Consider Edge Cases against the solution.
6. Write the Test Plan informed by edge cases.
7. Break the solution into Implementation Phases.
8. Revisit and refine the BLUF to match the final approach.

## Author Checklist

Before marking status as `review_ready`:
- [ ] BLUF clearly states the approach without surprises, and lines up with the final settled approach.
- [ ] All relevant documentation and sources listed, most important emphasized in the BLUF.
- [ ] Technical decisions explain "why" not just "what."
- [ ] Follow writing conventions: critical/detached analysis, brevity, commentary decoupled from technical content.
- [ ] NOTE/TODO/WARN callouts added where future readers need context.
- [ ] With fresh eyes, review whether someone unfamiliar with the context could follow the proposal.

## Notes

- Proposals should only be altered on explicit request. Don't modify an existing proposal unless asked.
- Design changes post-authoring should be noted in NOTE callouts, not by rewriting.
- Proposals with `status: evolved` have been superseded by a follow-up proposal.

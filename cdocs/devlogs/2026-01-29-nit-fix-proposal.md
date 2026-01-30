---
first_authored:
  by: "@claude-opus-4-5-20251101"
  at: 2026-01-29T15:00:00-08:00
task_list: cdocs/nit-fix
type: devlog
state: archived
status: done
tags: [claude_skills, writing_conventions, subagent_patterns, proposal_authoring]
---

# Nit Fix Skill Proposal: Devlog

## Objective

Research and flesh out the `cdocs/proposals/2026-01-29-nit-fix-skill.md` proposal.
The design must avoid implementing specific rules in the agent itself, instead making the agent a "rules stickler" that reads and enforces whatever rules it finds in the rules files.
Use the haiku subagent proposal as a reference for subagent patterns.

## Plan

1. Read the existing RFP stub and the haiku subagent proposal for architectural reference.
2. Read writing conventions, workflow patterns, and frontmatter spec to understand what the nit-fix agent enforces.
3. Design the skill architecture: a haiku subagent that reads rules files at runtime and enforces them, rather than hardcoding rules.
4. Write the full proposal with design decisions, stories, edge cases, test plan, and phases.
5. Self-review against the author checklist.

## Testing Approach

This is a proposal authoring session.
Verification is the author checklist review and consistency check.

## Implementation Notes

### Key design insight

The user's direction is clear: the nit-fix agent should not hardcode rules.
Instead, it should read `rules/writing-conventions.md` (and potentially other rules files) at runtime and use them as its enforcement spec.
This makes the agent a generic "rules stickler" whose behavior evolves as conventions are added or changed.

This is analogous to how a linter reads a config file rather than embedding rules in its source.

### Triage vs. nit-fix boundary

Triage handles frontmatter and workflow state.
Nit-fix handles prose and formatting conventions.
They are complementary and non-overlapping.

## Changes Made

| File | Description |
|------|-------------|
| `cdocs/proposals/2026-01-29-nit-fix-skill.md` | Fleshed out from RFP stub to full proposal |
| `cdocs/devlogs/2026-01-29-nit-fix-proposal.md` | This devlog |

## Verification

### Author checklist review

- [x] BLUF clearly states the approach (rules-reading haiku agent, no hardcoded rules, complements triage).
- [x] All relevant sources listed: writing-conventions.md, triage skill, review skill, haiku subagent proposal.
- [x] Technical decisions explain WHY (5 decisions, each with rationale).
- [x] Writing conventions followed: sentence-per-line, NOTE callouts with attribution, no emojis, mermaid diagram, colons over em-dashes.
- [x] NOTE/TODO callouts present where future readers need context (Decision 5, mechanical boundary).
- [x] Fresh-eyes review: proposal is self-contained and followable without prior context.

### Consistency check

- BLUF matches the body: the proposal delivers on "rules stickler" design, haiku subagent, mechanical/judgment boundary, triage complement.
- The RFP's open questions are answered:
  - "Apply fixes directly or present for approval?" -> Mechanical fixes applied directly, judgment-required reported (Decision 4).
  - "Single file or scan all cdocs?" -> Both: explicit file paths or batch mode (Story 4).
  - "How does it interact with triage?" -> Complementary, separate skills, chainable (Decision 3, Story 5).
- The RFP's known convention targets are addressed in the mechanical vs. judgment-required boundary section.

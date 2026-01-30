---
review_of: cdocs/proposals/2026-01-29-rfp-skill.md
first_authored:
  by: "@claude-opus-4-5-20251101"
  at: 2026-01-29T18:30:00-08:00
task_list: cdocs/rfp-skill
type: review
state: live
status: done
tags: [fresh_agent, architecture, proposal_lifecycle]
---

# Review: RFP Skill

## Summary Assessment

This RFP stub proposes a `/cdocs:rfp` skill for scaffolding lightweight proposal stubs.
The core idea is sound and well-motivated: two manually-authored RFP stubs already exist in the repo, proving the pattern has organic demand.
The BLUF and Objective effectively capture the value proposition.
The Scope questions are reasonable but miss the most consequential design question: how `/cdocs:propose` should consume an existing RFP stub (in-place elaboration vs. new file that supersedes).
Verdict: **Revise** - the stub is close to actionable but needs a few additions to its Scope and Open Questions before a future author can elaborate it into a full proposal without re-deriving context.

## Section-by-Section Findings

### BLUF

The BLUF captures the essence: scaffold RFP stubs, sit below propose in effort, capture intent without requiring full design.
The phrase "enough context for a future author to elaborate" is the right framing.

**Finding [non-blocking]:** The BLUF doesn't mention that RFP stubs are proposals (`type: proposal`, `status: request_for_proposal`).
A future author benefits from knowing this upfront since it implies RFP stubs live in `cdocs/proposals/`, not a new directory.

### Objective

Clear and concise.
Correctly identifies the knowledge burden: frontmatter fields, template structure, and the `request_for_proposal` status value.

No issues.

### Scope

The four exploration topics cover the major questions, but there are gaps.

**Finding [blocking]:** The most consequential design question is missing from Scope: when `/cdocs:propose` receives an existing RFP stub as input, should it elaborate the stub in-place (edit the same file, transition status from `request_for_proposal` to `wip`) or create a new file alongside the stub (marking the stub `status: evolved`)?
This question shapes the propose skill's invocation logic, the file naming strategy, and whether RFP stubs are mutable or immutable artifacts.
Both existing proposals that transitioned through stages (plugin-architecture, marketplace-restructure) were edited in-place, suggesting in-place is the natural pattern, but this should be explicitly scoped.

**Finding [non-blocking]:** The Scope asks whether stubs should include "Stories" or "Known Requirements" sections.
The two existing RFP stubs (nit-fix-skill and this document itself) answer this by example: they use domain-specific optional sections (Known Convention Targets, Known Design Considerations) rather than a prescribed Stories section.
The RFP could note this evidence to help the future author.

**Finding [non-blocking]:** Scope should mention how rfp interacts with existing utility skills, specifically: does `/cdocs:status --status=request_for_proposal` already surface the backlog without changes, or does the status skill need updates?
Based on the status skill's existing filter support, the answer is "it works already," but scoping the question prevents the elaborator from missing the integration.

### Known Design Considerations

Accurate and well-grounded in existing evidence.
The reference to `nit-fix-skill.md` as a pattern example is useful.

**Finding [non-blocking]:** The nit-fix-skill has since been elaborated into a full proposal (`status: wip`) and no longer serves as an example of an RFP stub.
The RFP skill document itself is now the only `request_for_proposal` document in the repo.
This isn't necessarily a problem (the elaborated nit-fix still demonstrates the section pattern), but the future author should be aware.

### Open Questions

Two of the three open questions have fairly clear answers based on existing plugin architecture:

**Finding [blocking]:** The tag question ("auto-populate based on keywords, or require user to supply?") has a strong answer from the triage subagent proposal (`haiku-subagent-workflow-automation.md`): tag maintenance is a triage responsibility, not an authoring responsibility.
The rfp skill should accept author-supplied tags and leave refinement to triage.
This should either be resolved in the RFP (moved to Known Design Considerations) or explicitly flagged as "likely answered by the triage proposal" so the future author doesn't re-derive it.

**Finding [non-blocking]:** The hook validation question also has a clear answer: the existing PostToolUse hook checks field presence, not status values or section completeness.
RFP stubs have the same required frontmatter fields as any other proposal.
No special validation is needed.
This could be noted as a pre-resolved consideration.

**Finding [non-blocking]:** A missing open question worth adding: should the skill name be `rfp`, `request`, or something else?
The existing skill naming conventions use verbs (propose, review, report, implement) or nouns matching the artifact (devlog, status, init).
`rfp` is an acronym, which breaks from the convention.
`request` would be more consistent but less immediately clear.

## Verdict

**Revise.**

The RFP stub is well-structured and captures the right core idea.
Two additions would make it actionable for elaboration without significant re-research:

1. Add the in-place-vs-new-file question to Scope (the most important design decision for the full proposal).
2. Resolve or annotate the tag and hook open questions that are already answered by existing plugin components.

## Action Items

1. [blocking] Add to Scope: "How `/cdocs:propose` should consume an existing RFP stub: in-place elaboration (same file, status transition) vs. new file (stub marked `evolved`)."
2. [blocking] Resolve the tag auto-population open question by referencing the triage subagent proposal's tag maintenance design, or move it to Known Design Considerations with a note that triage handles post-authoring tag refinement.
3. [non-blocking] Add to Scope or Open Questions: interaction with the status skill's existing `--status=request_for_proposal` filter.
4. [non-blocking] Add to Open Questions: skill naming convention - `rfp` (acronym) vs. `request` (verb) vs. another name.
5. [non-blocking] Note in Known Design Considerations that the nit-fix-skill example has been elaborated past the RFP stage; this document is now the sole RFP exemplar.
6. [non-blocking] Consider adding to the BLUF that RFP stubs are proposals (`type: proposal`) stored in `cdocs/proposals/`.

---
first_authored:
  by: "@claude-opus-4-5-20251101"
  at: 2026-01-30T12:20:00-08:00
task_list: cdocs/archive-formalism
type: report
state: live
status: review_ready
tags: [analysis, workflow, process, plugin_architecture, self_reflection]
---

# CDocs Process Analysis: Workflow Gaps and Automation Opportunities

> BLUF(mjr/cdocs/archive-formalism): The CDocs plugin's skill-based architecture provides strong guardrails for document creation but relies entirely on the central agent's memory for workflow orchestration.
> In this session, the documented pipeline (author -> nit-fix -> triage -> review) was not followed: nit-fix and triage were skipped, and the review was only dispatched when the user explicitly requested it.
> The gap between "rules exist" and "rules are followed" is the plugin's primary scaling bottleneck; addressing it through automated status-transition gates and post-commit hooks would meaningfully reduce executive load on central agents.

## Context / Background

This report analyzes the cdocs workflow as observed during a single authoring session: writing the archive formalism proposal (`cdocs/proposals/2026-01-30-archive-formalism.md`) and the CDocs CLI RFP (`cdocs/proposals/2026-01-30-cdocs-cli.md`).
The session involved a central orchestrating agent (Opus 4.5), an Explore subagent for codebase discovery, and a review subagent dispatched after the user intervened.
The analysis covers what the plugin got right, what was missed, and where automation could close the gaps.

## Key Findings

### What the plugin got right

- **Devlog creation was automatic.**
  The `CLAUDE.md` instruction ("Always create a devlog") and the devlog skill combined to make session logging a reflexive first step.
  No deliberation required: the convention is clear, the skill is easy to invoke, and the template provides useful structure.

- **Proposal and RFP skills provided clear scaffolding.**
  The proposal template's section list (BLUF, Objective, Background, Proposed Solution, Design Decisions, Edge Cases, Test Plan, Phases) prevented structural omissions.
  The RFP template's lighter section set (BLUF, Objective, Scope, Open Questions) correctly constrained the CLI stub to intent-capture without over-specification.

- **The author checklist caught real issues.**
  Self-reviewing against the propose skill's checklist prompted a re-read of both documents, verification of cross-references, and confirmation that BLUFs matched the settled approach.
  Without the checklist, the self-review would have been less structured.

- **The Explore subagent was well-suited to initial context gathering.**
  Dispatching a thorough codebase exploration as a subagent avoided polluting the central agent's context with raw file listings while still providing a comprehensive project map.

- **Frontmatter spec enforced consistent metadata.**
  Every field had a defined type and valid values.
  The spec was unambiguous enough that frontmatter authoring required no guesswork.

### What was missed

- **Nit-fix was not run before marking `review_ready`.**
  The workflow-patterns rule explicitly states: "Before marking a document `review_ready`, run `/cdocs:nit_fix`."
  This step was skipped entirely.
  The central agent remembered the author checklist (embedded in the propose skill it was actively executing) but forgot the nit-fix step (documented in a separate rules file read earlier by a subagent).

- **Triage was not run after document creation.**
  The workflow-patterns rule states: "After completing substantive work on cdocs documents, invoke `/cdocs:triage`."
  Three new cdocs documents were created and committed without triage.
  Frontmatter was manually validated by re-reading the spec, but the triage agent's automated checks and workflow dispatch were bypassed.

- **Review was not proactively dispatched.**
  The documented pipeline ends with triage dispatching a review.
  Since triage was skipped, the review dispatch never happened.
  The user had to explicitly ask for a review subagent.

- **The pipeline is documented but not enforced.**
  All three skipped steps (nit-fix, triage, review dispatch) are clearly documented in `workflow-patterns.md`.
  The central agent read the codebase exploration report that summarized these patterns.
  Despite having the information, the agent did not act on it: the propose skill's own instructions (which were in active context) took priority over the cross-cutting workflow rules (which were in a subagent's summary).

## Analysis

### The executive load problem

The central agent is responsible for:
1. Understanding the user's request.
2. Selecting and invoking the correct skill.
3. Executing the skill's instructions (template, sections, checklist).
4. Remembering cross-cutting workflow rules from separate documents.
5. Orchestrating subagents for nit-fix, triage, and review.
6. Committing and reporting results.

Steps 1-3 and 6 are well-supported: skills provide clear instructions, templates reduce decision-making, and git operations are routine.
Steps 4-5 are where failures occur.
Cross-cutting rules are read once during exploration and then compete with active skill instructions for the agent's attention.
The more focused the agent is on executing a skill well (which is desirable), the more likely it is to forget orchestration steps that live outside that skill.

This is a structural problem, not a competence problem.
The plugin's architecture separates concerns well (skills own creation, rules own conventions, agents own analysis), but the glue between them is entirely cognitive: the central agent must remember to invoke the right thing at the right time.

### Why the propose skill's checklist worked but workflow-patterns didn't

The propose skill's author checklist is embedded in the skill file that the agent is actively executing.
It appears at the end of the skill instructions, naturally prompting a review pass before completion.
The checklist is local to the task: it asks about the document the agent just wrote.

The workflow-patterns rules are in a separate file, read during exploration, and apply across all document types.
They require the agent to step outside the current skill's scope and invoke a different skill.
The transition from "I'm done with the propose skill" to "now I should run nit-fix, then triage" requires the agent to hold a mental model of the full pipeline, not just the current task.

### The information hierarchy problem

In this session, information reached the central agent through three channels:
1. **Direct skill instructions** (propose SKILL.md): read in full, actively followed.
2. **Explore subagent summary**: comprehensive but summarized; details like the pipeline order were present but not prominent.
3. **Rules files**: read by the subagent, not directly by the central agent.

The pipeline steps that were skipped existed at hierarchy level 2-3.
The steps that were followed existed at level 1.
This suggests that workflow-critical instructions need to be surfaced at the point of action, not in a separate reference document.

### Subagent dispatch patterns

The Explore subagent worked well because it was a natural first step: "I need to understand the codebase before I can write proposals."
The review subagent worked well once dispatched because it had a clear, self-contained task.

The missing subagent dispatches (nit-fix, triage) would have required the central agent to pause after completing its primary task and think "what else should I do?"
This "what else" step is the weakest link in the current architecture.

## Recommendations

### Near-term: embed pipeline reminders in skill files

Add a "Post-Authoring Pipeline" section to the propose, devlog, review, and report skill files:

```markdown
## Post-Authoring Pipeline

After completing this document:
1. Run `/cdocs:nit_fix` on the document (if marking `review_ready`).
2. Run `/cdocs:triage` to validate frontmatter and trigger workflow.
3. Commit the document and any changes from nit-fix/triage.
```

This surfaces the pipeline at the point of action (level 1 in the information hierarchy) rather than in a cross-cutting rules file.
The duplication is intentional: it trades DRY purity for workflow reliability.

> NOTE(claude-opus-4-5/cdocs/archive-formalism): This contradicts the project's preference for deduplication (`CLAUDE.md`: "Deduplicating code and docs with the same semantic content is highly desirable").
> The trade-off is justified because the cost of missing a pipeline step (reviewer noise, stale frontmatter, missed workflow triggers) exceeds the cost of maintaining a repeated checklist across 4 skill files.
> A middle ground: each skill file includes a one-line reference: "See Post-Authoring Pipeline in `workflow-patterns.md`" as the final step.

### Medium-term: status-transition gates

Implement status transitions as a CLI command or hook that enforces prerequisites:

```
cdocs-cli transition cdocs/proposals/foo.md --to review_ready
```

The transition command checks:
- `review_ready` requires nit-fix to have been run (tracked via frontmatter field or companion file).
- `review_ready` triggers triage automatically.
- Triage output with `[REVIEW]` recommendation auto-dispatches (or prompts for) a review.

This moves enforcement from the agent's memory to the tool.
The CDocs CLI RFP (`cdocs/proposals/2026-01-30-cdocs-cli.md`) is the natural home for this command.

### Medium-term: post-commit triage hook

Add a git post-commit hook that detects cdocs file changes and runs triage automatically.
The existing `hooks/hooks.json` already defines a PostToolUse hook for frontmatter validation; a post-commit triage hook would be a natural extension.

This eliminates the "remember to triage" step entirely.
The trade-off is that triage runs on every commit touching cdocs files, including trivial edits where triage adds no value.
A `--changed-only` flag on the triage command could mitigate this.

### Longer-term: workflow engine

A lightweight state machine for document lifecycle management:

```
wip -> [nit-fix] -> [triage] -> review_ready -> [review] -> implementation_ready
```

Each transition has preconditions (nit-fix ran, triage ran) and effects (dispatch review, update frontmatter).
The central agent interacts with the workflow engine rather than manually invoking each step.

This is a significant architectural addition and should be its own proposal if pursued.
The CDocs CLI is a prerequisite: the workflow engine would be a CLI command or a module that the CLI exposes.

### Process improvement: skill-level subagent awareness

Skills that produce `review_ready` documents could include explicit subagent dispatch instructions:

```markdown
## Completion

If this document is marked `review_ready`:
1. Dispatch nit-fix agent (haiku) via Task tool.
2. Dispatch triage agent (haiku) via Task tool.
3. If triage recommends [REVIEW], dispatch reviewer agent (sonnet) via Task tool.
```

This makes subagent dispatch part of the skill's contract rather than a cross-cutting concern the agent must remember.

## Observed Process Timeline

| Step | Action | CDocs support | Gap |
|------|--------|---------------|-----|
| 1 | User invoked `/propose` | Skill provided template and instructions | None |
| 2 | Central agent dispatched Explore subagent | Workflow-patterns documents the pattern | None |
| 3 | Central agent invoked `/cdocs:devlog` | CLAUDE.md + devlog skill | None |
| 4 | Central agent wrote RFP and proposal | Propose and RFP skills + frontmatter spec | None |
| 5 | Central agent self-reviewed against checklist | Propose skill embeds checklist | None |
| 6 | Central agent committed | Conventional commit convention | None |
| 7 | Central agent marked proposal `review_ready` | Frontmatter spec defines the status | **Nit-fix not run** |
| 8 | (nothing) | Triage should have been invoked | **Triage not run** |
| 9 | (nothing) | Triage should have dispatched review | **Review not dispatched** |
| 10 | User explicitly requested review | User intervention required | **Pipeline broken** |

Steps 7-9 represent a single root cause: the pipeline steps documented in `workflow-patterns.md` were not surfaced at the point of action in the propose skill.

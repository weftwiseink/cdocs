---
first_authored:
  by: "@claude-opus-4-5-20251101"
  at: 2026-01-30T12:00:00-08:00
task_list: cdocs/archive-formalism
type: devlog
state: live
status: wip
tags: [proposals, architecture, cli, archival, process, self_reflection]
---

# Archive Formalism and CLI RFP: Devlog

## Objective

Author two related proposal documents:
1. A full proposal formalizing the cdocs archive layout (`cdocs/$type/_archive/`) with an automated script for archival and path reference renaming.
2. An RFP for a general-purpose CDocs CLI (TypeScript) that the archival script belongs to, alongside other pure-logic actions like frontmatter templating, document search, and status listing.

The archival proposal's implementation is blocked on the CLI RFP being elaborated and accepted.

## Plan

1. Read existing proposals, templates, frontmatter spec, and writing conventions for style alignment.
2. Draft the RFP for the CDocs CLI first (since the archival proposal depends on it).
3. Draft the full archival formalism proposal, referencing the CLI RFP as a dependency.
4. Self-review both documents against the author checklist.

## Testing Approach

Documentation-only session: no code changes to test.
Verification is structural: frontmatter validity, section completeness, cross-references.

## Implementation Notes

Both documents address a real pain point: archived documents currently have no formal home, and path references become stale when documents move.
The CLI RFP is intentionally kept lightweight: it captures the need for a standalone TypeScript tool without over-specifying the design, leaving room for elaboration.

### Review subagent dispatch

Dispatched a background review subagent on the archive formalism proposal.
The reviewer identified two blocking issues:
1. The convention should be separable from the CLI dependency (the directory convention is useful independently of automation).
2. Lazy vs. eager `_archive/` directory creation is contradictory between the convention section and Phase 1.

Verdict: revise.
The proposal's `last_reviewed` frontmatter was updated to `revision_requested`, round 1.

### Process analysis report

Authored `cdocs/reports/2026-01-30-cdocs-process-analysis.md` analyzing the session's workflow gaps.
Key finding: the documented pipeline (author -> nit-fix -> triage -> review) was not followed because the pipeline steps live in `workflow-patterns.md` (read by a subagent) rather than in the propose skill's own instructions.
Nit-fix and triage were both skipped; review was only dispatched on user request.
The report recommends embedding pipeline reminders in skill files and pursuing status-transition gates in the CDocs CLI.

## Changes Made

| File | Description |
|------|-------------|
| `cdocs/proposals/2026-01-30-cdocs-cli.md` | RFP for general-purpose CDocs CLI |
| `cdocs/proposals/2026-01-30-archive-formalism.md` | Full proposal for archive layout and automated renaming |
| `cdocs/reviews/2026-01-30-review-of-archive-formalism.md` | Review of archive formalism (subagent-authored) |
| `cdocs/reports/2026-01-30-cdocs-process-analysis.md` | Process analysis report on workflow gaps |
| `cdocs/devlogs/2026-01-30-archive-formalism-and-cli-rfp.md` | This devlog |

## Verification

Frontmatter validated against `plugins/cdocs/rules/frontmatter-spec.md`.
Both proposals follow template structure and writing conventions.
Review committed by subagent with `last_reviewed` frontmatter applied to target document.
Report follows report template with BLUF, findings, analysis, and recommendations.

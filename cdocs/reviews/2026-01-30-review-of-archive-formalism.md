---
review_of: cdocs/proposals/2026-01-30-archive-formalism.md
first_authored:
  by: "@claude-opus-4-5-20251101"
  at: 2026-01-30T12:15:00-08:00
task_list: cdocs/archive-formalism
type: review
state: live
status: done
tags: [fresh_agent, architecture, archival, path_rewriting, dependency_risk]
---

# Review: Archive Formalism

## Summary Assessment

> BLUF(@claude-opus-4-5-20251101/archive-formalism): A well-structured proposal that introduces a sensible filesystem convention for archived cdocs documents and specifies the CLI automation needed to maintain referential integrity. The core directory convention is sound and immediately actionable, but the proposal's heavy dependency on an unelaborated CLI RFP creates a structural risk: the convention cannot be fully adopted until a tool that does not yet exist is designed, accepted, and implemented. The most critical finding is that the proposal conflates two separable concerns (the directory convention and the CLI archive command) without acknowledging that the convention alone delivers value. Verdict: Revise.

## Section-by-Section Findings

### BLUF

The BLUF is well-formed and communicates the essential idea: `_archive/` subdirectories per type, with a CLI command for automated archival and path rewriting.
It correctly notes the dependency on the CDocs CLI RFP.

**Non-blocking**: The BLUF could be tightened by stating the convention is useful independent of the CLI, since manual archival (move + update `state`) is viable without tooling.

### Objective

Clear problem statement: documents accumulate, no formal convention exists, referential integrity is at risk during moves.
No issues.

### Background

Thorough coverage of current state, prior art, and relevant components.

**Non-blocking**: The "Prior art" subsection lists three patterns but does not cite specific systems that use them.
This is fine for an internal proposal but weakens the comparative argument slightly.

### Proposed Solution: Directory Convention

The `_archive/` subdirectory convention is the strongest part of the proposal.
It is simple, consistent with the existing `_media/` convention, and requires no tooling to adopt incrementally.
The lazy creation policy is practical.

No issues with this section.

### Proposed Solution: Archive Command

This section specifies a five-step command that validates, updates frontmatter, moves the file, scans for references, and reports changes.
The specification is clear and actionable.

**Blocking**: The command specification lives entirely in this proposal, but the command itself belongs to the CDocs CLI (`cdocs/proposals/2026-01-30-cdocs-cli.md`), which is still at `status: request_for_proposal`.
This creates a circular dependency: the archive formalism is "review ready" but its core automation is blocked on a proposal that has not been elaborated.
The proposal should explicitly separate the convention (adoptable now) from the command (blocked on CLI), and should define an interim manual procedure for archiving documents before the CLI exists.

### Proposed Solution: Path Reference Scanning

The scanner specification covers markdown links, frontmatter fields, inline references, and relative paths.
This is the most complex part of the proposal and the most likely to have edge cases.

**Non-blocking**: The proposal does not address what happens when a path appears as a substring of a longer path.
For example, `cdocs/proposals/2026-01-29-foo.md` is a substring of `cdocs/proposals/2026-01-29-foo.md#section-heading`.
Literal string replacement would rewrite this correctly in most cases, but the proposal should acknowledge fragment identifiers and query strings as a consideration.

**Non-blocking**: No mention of binary files.
The scanner should skip binary files during the whole-project scan.
This is an implementation detail, but worth noting in the proposal since the scan is explicitly "all files in the project."

### Proposed Solution: Unarchive Support

The unarchive command is a natural complement.
The specification is minimal but adequate for an RFP-stage dependency.

**Non-blocking**: The proposal does not specify what `state` value an unarchived document should receive.
It says "sets `state: live`", but the document may have been `deferred` before archival.
Consider storing the pre-archive state in frontmatter (e.g., `previous_state`) or documenting that unarchive always sets `state: live` as a deliberate simplification.

### Important Design Decisions

All four decisions (type-local archives, underscore prefix, whole-project scanning, literal string replacement) are well-reasoned and clearly documented with rationale.
This is the best section of the proposal.

No blocking issues.

### Edge Cases / Challenging Scenarios

Good coverage of external references, circular references during bulk archival, filename collisions, relative path resolution, and non-markdown files.

**Non-blocking**: The bulk archival edge case mentions that "bulk archival should be a separate higher-level operation" but does not specify where that operation would be defined or whether it is in scope for the CLI.
This is acceptable at proposal stage but should be tracked as future work.

**Non-blocking**: No consideration of symlinks.
If a project uses symlinks pointing to cdocs documents, the archive move would break them.
This is likely rare but worth a one-line acknowledgment.

### Test Plan

Comprehensive test plan covering unit, integration, and manual verification.
The test categories map well to the implementation phases.

**Non-blocking**: The test plan does not include a test for the unarchive round-trip restoring the original `state` value, which connects to the unarchive state concern raised above.

### Implementation Phases

Five well-scoped phases with clear success criteria.
The phasing is logical: convention first, then core command, then reference rewriting, then edge cases, then integration.

**Blocking**: Phase 1 specifies "Create `_archive/` directories under each cdocs type directory" and update the init skill.
However, the proposal does not specify whether `_archive/` directories should be eagerly created (with `.gitkeep`) or lazily created.
The "Directory convention" section says "created lazily" but Phase 1 says "create `_archive/` directories" and mentions `.gitkeep`.
This is a contradiction that should be resolved.

> NOTE(@claude-opus-4-5-20251101/archive-formalism): The lazy vs. eager creation contradiction is minor but could cause confusion during implementation. Pick one and state it clearly.

## Verdict

**Revise.**

The proposal presents a sound directory convention and a well-specified archive command.
The two blocking issues are:

1. The proposal does not separate the immediately-adoptable convention from the CLI-dependent automation. Since the CLI RFP is unelaborated, the entire proposal appears blocked when the convention portion is not.
2. The lazy vs. eager creation of `_archive/` directories is contradictory between the convention section and Phase 1.

Neither issue requires major rework.
A focused revision addressing these two points, plus consideration of the non-blocking feedback, would bring this to acceptance.

## Action Items

1. [blocking] Separate the directory convention from the CLI archive command. Define the convention as adoptable independently, with a brief manual archival procedure (move file, update `state` in frontmatter, manually update references). This unblocks the convention from the CLI RFP dependency.
2. [blocking] Resolve the lazy vs. eager `_archive/` directory creation contradiction between the "Directory convention" section and Phase 1. State the chosen approach once and reference it from both locations.
3. [non-blocking] Acknowledge fragment identifiers and query strings as a consideration in the path reference scanning section.
4. [non-blocking] Note that the whole-project scanner should skip binary files.
5. [non-blocking] Specify what happens to the `state` field during unarchive when the pre-archive state was not `live` (e.g., `deferred`). Either store pre-archive state or document the simplification.
6. [non-blocking] Add a one-line acknowledgment of symlinks as an edge case.
7. [non-blocking] Track bulk archival as explicit future work, either in this proposal or as a follow-up item.

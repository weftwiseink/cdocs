---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-16T19:00:00-07:00
task_list: marketplace/multi-target
type: devlog
state: live
status: wip
tags: [multi-target, opencode, build-system, hooks, npm, ci]
---

# Multi-Target Marketplace Implementation: Devlog

## Objective

Implement the accepted [multi-target marketplace proposal](../../cdocs/proposals/2026-03-14-multi-target-marketplace.md) across all 7 phases (0-6).
The goal is to publish cdocs for both Claude Code and OpenCode from a single canonical source, with CC remaining the authoring format and a build script generating OC artifacts.

## Plan

Seven phases executed sequentially, with a commit after each phase:

- [x] Phase 0: Wire path-restriction hook with `agent_type` guard in CC
- [x] Phase 1: Custom build script for CC-to-OC agent conversion
- [x] Phase 2: Verify existing AGENTS.md and rules integration (verification-only, no changes)
- [x] Phase 3: Hand-write OC hooks plugin (frontmatter validation only)
- [x] Phase 4: npm packaging (package.json, postinstall, npm pack test)
- [ ] Phase 5: CI/CD (GitHub Actions workflow, dirty check)
- [ ] Phase 6: Documentation and README updates

Each phase is reviewed via `/cdocs:review` before proceeding.

## Testing Approach

- Phase 0: Manual hook testing in CC (agent_type guard behavior).
- Phase 1: Build script execution with output diff against expected snapshots.
  Idempotency check (run twice, diff).
- Phase 2: Verification-only (read existing files, confirm paths resolve).
- Phase 3: Manual OC session testing (deferred; structural validation only for now).
- Phase 4: `npm pack` test and tarball inspection.
- Phase 5: GitHub Actions workflow syntax validation.
- Phase 6: README completeness check.

## Deviations from Proposal

> NOTE(claude-opus-4-6/multi-target): Bun is not installed on this system.
> The proposal specifies `bun run` as the build runtime.
> Using `npx tsx` instead, which provides equivalent TypeScript execution via Node.js.
> The build script and CI workflow will document both `bun run` and `npx tsx` as valid runners.

## Implementation Notes

### Phase 0: Path-Restriction Hook

Added `PreToolUse` entry to `hooks.json` and modified `validate-cdocs-edit-path.sh` to parse `agent_type` from stdin JSON.
The guard allows all operations for the main session (no `agent_type` field) and only restricts known cdocs subagents (`triage`, `nit-fix`, `reviewer`).

### Phase 1: Build Script

Build script at `plugins/cdocs/scripts/build-opencode.ts`.
Handles: frontmatter transformation, model mapping, tool expansion, permission generation, version sync, skills/rules copy.

### Phase 2: Rules Integration Verification

Verification-only phase.
Confirmed AGENTS.md exists with @-imports and rules files are in place.

## Changes Made

| File | Description |
|------|-------------|
| `plugins/cdocs/hooks/hooks.json` | Added PreToolUse entry for path-restriction hook |
| `plugins/cdocs/hooks/validate-cdocs-edit-path.sh` | Added agent_type guard (~5 lines) |
| `plugins/cdocs/scripts/build-opencode.ts` | New: CC-to-OC agent conversion build script |
| `plugins/cdocs/opencode/agents/*.md` | Generated: OC-format agent files |
| `plugins/cdocs/opencode/skills/` | Generated: copied from canonical skills |
| `plugins/cdocs/opencode/rules/` | Generated: copied from canonical rules |
| `plugins/cdocs/opencode/plugins/cdocs-hooks.ts` | New: hand-written OC hooks plugin |
| `plugins/cdocs/opencode/package.json` | Generated: npm manifest |
| `plugins/cdocs/opencode/scripts/postinstall.js` | New: postinstall script for skills/rules copy |
| `.github/workflows/opencode-build.yml` | New: CI workflow for build validation |
| `plugins/cdocs/README.md` | Updated: OpenCode installation section |

## Verification

(Updated as phases complete.)

---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-17T14:10:00-07:00
task_list: marketplace/build-workspace
type: devlog
state: live
status: final
tags: [proposal, build-system, workspace]
---

# Build Workspace Reorganization Proposal

> BLUF: Elaborated the RFP at `cdocs/proposals/2026-03-17-build-workspace-reorganization.md` into a full proposal.
> Two-phase plan: (1) workspace setup + build script relocation + gitignore, (2) CI and documentation updates.

## What Happened

Received an RFP stub for reorganizing the build workspace to separate generated OC artifacts from committed plugin source.
The user provided key decisions upfront (gitignored artifacts, npm+tsx tooling, bundled skills/rules, multi-plugin `build/<plugin>/opencode/` structure), so the proposal focused on concrete implementation rather than option analysis.

## Key Decisions Documented

- Build output at `build/cdocs/opencode/` (gitignored).
- Root `package.json` + `tsconfig.json` for build tooling.
- Build script moves from `plugins/cdocs/scripts/build-opencode.ts` to `scripts/build-opencode.ts`.
- Hand-written OC files (`cdocs-hooks.ts`, `postinstall.js`) get canonical homes under `plugins/cdocs/` and are copied by the build script.
- CI dirty-check replaced with build+validate+optional-publish workflow.
- Two implementation phases (workspace setup, then CI/docs).

## Files

- `cdocs/proposals/2026-03-17-build-workspace-reorganization.md` -- full proposal (review_ready)

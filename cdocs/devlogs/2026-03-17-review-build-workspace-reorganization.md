---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-17T14:00:00-07:00
task_list: marketplace/build-workspace
type: devlog
state: live
status: done
tags: [review, build-system]
---

# Devlog: Review of Build Workspace Reorganization Proposal

Reviewed `cdocs/proposals/2026-03-17-build-workspace-reorganization.md`, a two-phase proposal for moving OC build artifacts from committed `plugins/cdocs/opencode/` to gitignored `build/cdocs/opencode/`.

## What was done

1. Read the proposal thoroughly alongside the current codebase state (build script, CI workflow, gitattributes, directory structure).
2. Verified factual claims: 24 files in `plugins/cdocs/opencode/`, `postinstall.js` not yet at `plugins/cdocs/scripts/`, current `.gitignore` only has `.vscode/*`.
3. Wrote review at `cdocs/reviews/2026-03-17-review-of-build-workspace-reorganization.md`.
4. Applied all four non-blocking fixes directly to the proposal:
   - Removed `npx` from `package.json` scripts (redundant with `tsx` as devDependency).
   - Replaced "(or similar)" hedge with the definitive `plugins/cdocs/hooks/cdocs-hooks.ts` path.
   - Added NOTE about committing `package-lock.json` for reproducible CI builds.
   - Reordered Phase 1 tasks: build script moves out before postinstall moves in.
5. Updated proposal frontmatter with `last_reviewed` block.

## Verdict

Accept. No blocking issues found.

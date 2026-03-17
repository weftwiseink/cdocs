---
review_of: cdocs/proposals/2026-03-17-build-workspace-reorganization.md
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-17T14:00:00-07:00
task_list: marketplace/build-workspace
type: review
state: live
status: done
tags: [fresh_agent, architecture, build_system, ci]
---

# Review: Build Workspace Reorganization

## Summary Assessment

This proposal cleanly separates generated OC build artifacts from committed plugin source, eliminating the 24-file duplication in version control and the fragile CI dirty-check workflow.
The design is well-structured, the phasing is sensible, and the key decisions (gitignored build output, multi-plugin `build/<plugin>/opencode/` layout, npm+tsx tooling) are sound.
Two items need correction: (1) the `postinstall.js` relocation target conflicts with the build script that is also described as living at `plugins/cdocs/scripts/` temporarily, and (2) the `npx tsx` in `package.json` scripts is redundant when `tsx` is a devDependency.
Verdict: Accept with non-blocking fixes.

## Section-by-Section Findings

### BLUF and Objective

Clear and accurate.
The BLUF correctly summarizes the four changes (build output relocation, root workspace files, script relocation, CI update) and the motivation.
No issues.

### Background

Accurately describes the current state.
The "24 generated files committed" count matches the glob output (24 files in `plugins/cdocs/opencode/`).
The list of friction points is concrete and well-reasoned.

### Current and Target File Layouts

The before/after layouts are clear and internally consistent.
The target layout correctly shows `build/` as gitignored and the build script at `scripts/build-opencode.ts`.

### Root Workspace Configuration

**Non-blocking:** The `package.json` scripts use `npx tsx scripts/build-opencode.ts`.
When `tsx` is listed as a devDependency and installed via `npm ci`, npm scripts automatically resolve binaries from `node_modules/.bin/`.
Using `npx` inside an npm script is redundant and adds a ~200ms penalty per invocation for the npx resolver.
The scripts should be `tsx scripts/build-opencode.ts` (without `npx`).

The `tsconfig.json` is appropriately scoped to `scripts/` only with a clear NOTE explaining why.

### Build Script Relocation and Refactoring

Thorough specification of the four key changes (output directory, plugin root resolution, repo root, OC hooks file).
The description is actionable: an implementer can follow it directly.

### OC Hooks File Relocation

The proposal identifies `cdocs-hooks.ts` and `postinstall.js` as the two hand-written files inside the generated directory and correctly specifies canonical locations for each.
The final destination for `cdocs-hooks.ts` is `plugins/cdocs/hooks/cdocs-hooks.ts`, which is clean: it places the OC hooks file alongside the CC hook shell scripts.

**Non-blocking:** The proposal mentions an intermediate step with "or similar" for the hooks file path but then settles on `plugins/cdocs/hooks/` in the definitive section.
The "or similar" hedge in the build script relocation section (line 127) can be removed for clarity since the decision is made two paragraphs later.

### Gitignore and Gitattributes Changes

Straightforward.
The `.gitattributes` simplification is correctly identified: once the files are not committed, `linguist-generated` markers are unnecessary.

### CI Workflow Update

The replacement workflow is clean.
It correctly drops the dirty-check step and replaces it with a build-from-scratch approach.
The trigger paths now include `scripts/build-opencode.ts`, which is correct.

**Non-blocking:** The CI workflow installs dependencies via `npm ci` but the current `.gitignore` only has `.vscode/*`.
After adding `package.json`, a `package-lock.json` will also be generated and should be committed for reproducible CI builds with `npm ci`.
The proposal does not mention committing `package-lock.json`.
This is implicit (npm generates it, git would track it by default since only `build/` is added to `.gitignore`), but worth noting for the implementer.

### Documentation Updates

Comprehensive.
Covers both `CLAUDE.md` and `plugins/cdocs/README.md` with specific sections and language changes.

### Design Decisions

All five decisions are well-justified with clear rationale.
The "Skills/rules bundled in the npm tarball" section correctly distinguishes between meaningful source duplication (bad) and distribution artifacts (acceptable).

### Edge Cases

**postinstall.js portability:** The analysis is correct: `__dirname`-relative paths work identically from either location since the directory structure within the build output is unchanged.

**Partial builds:** Good catch on extending `rmSync` to the entire output directory for clean-slate builds.

**Version bump coordination:** Correctly notes no behavioral change from the current system.

### Implementation Phases

Phase 1 is comprehensive and covers all the file moves, script changes, gitignore updates, and cleanup.
The verification steps are concrete and testable.

Phase 2 logically follows with CI and documentation updates.

**Non-blocking:** Phase 1 lists "Move `plugins/cdocs/opencode/scripts/postinstall.js` to `plugins/cdocs/scripts/postinstall.js` (if not already there -- verify current state)."
Verified: it is not already there. Only `build-opencode.ts` is in `plugins/cdocs/scripts/` currently.
However, Phase 1 also moves `build-opencode.ts` OUT of `plugins/cdocs/scripts/` to `scripts/build-opencode.ts`.
The proposal correctly notes this in the NOTE after the hooks relocation section, so there is no actual conflict, but the Phase 1 task list could be reordered for clarity: move build script out first, then move postinstall in.

## Verdict

**Accept.** The proposal is well-designed and thorough.
The non-blocking items below are minor improvements that do not affect architectural soundness.

## Action Items

1. [non-blocking] Remove `npx` from the `package.json` script commands: use `tsx scripts/build-opencode.ts` instead of `npx tsx scripts/build-opencode.ts`, since `tsx` is a devDependency.
2. [non-blocking] Remove the "(or similar)" hedge on line 127 regarding the hooks file path, since the definitive location (`plugins/cdocs/hooks/cdocs-hooks.ts`) is specified in the next section.
3. [non-blocking] Add a note that `package-lock.json` should be committed for reproducible `npm ci` builds in CI.
4. [non-blocking] Consider reordering Phase 1 task list: move the build script out of `plugins/cdocs/scripts/` before moving `postinstall.js` in, to make the sequence clearer.

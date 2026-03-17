---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-17T00:55:00-07:00
task_list: marketplace/build-workspace
type: proposal
state: live
status: request_for_proposal
tags: [architecture, build-system, workspace, deduplication, typescript]
---

# Build Workspace Reorganization

> BLUF(mjr+claude-opus-4-6/build-workspace): Move build artifacts out of `plugins/cdocs/` into a top-level `build/` target, eliminate duplicated skills/rules in the committed output, and add a TypeScript workspace configuration to give the build script a proper execution context.
>
> - **Motivated By:** `cdocs/proposals/2026-03-14-multi-target-marketplace.md` (results_accepted) — the current implementation commits generated OC artifacts (including full copies of skills and rules) inside `plugins/cdocs/opencode/`, creating duplication and coupling build output to plugin source.

## Objective

The multi-target marketplace implementation placed the `opencode/` build output inside `plugins/cdocs/`, co-located with canonical source files.
This creates three problems:

1. **Duplication:** Skills and rules are copied verbatim into `opencode/skills/` and `opencode/rules/`, doubling the file count for identical content.
2. **Source/output coupling:** Build artifacts live alongside source files, making it unclear what is canonical vs generated (despite `.gitattributes` markers).
3. **No build context:** The build script (`plugins/cdocs/scripts/build-opencode.ts`) runs via `npx tsx` with no `tsconfig.json`, no workspace declaration, and no defined dependency scope.

## Scope

The full proposal should explore:

- Moving `plugins/cdocs/opencode/` to `build/cdocs/opencode/` (or similar top-level target).
- Moving `plugins/cdocs/scripts/build-opencode.ts` to a top-level `scripts/` or workspace package.
- Adding a root `tsconfig.json` and `package.json` with workspace declarations.
- Whether skills/rules should be symlinked, referenced, or omitted from the committed build output (npm `postinstall` can still copy them at install time from the canonical source).
- Updating CI (`.github/workflows/opencode-build.yml`) and `.gitattributes` for the new paths.
- Updating `CLAUDE.md` build instructions and `plugins/cdocs/README.md` references.
- Whether the npm package should continue including skills/rules in the tarball or resolve them at postinstall time from the plugin source tree.

## Open Questions

1. **Commit or build-only?** Should `build/cdocs/opencode/` still be committed (with dirty check in CI), or should CI build and publish without committing artifacts? Committing is simpler for consumers who clone the repo; build-only is cleaner but requires CI for npm publishing.
2. **Workspace tool:** Should the workspace use `npm workspaces`, `bun workspaces`, or just a root `package.json` with scripts? The repo currently has no JS/TS tooling at the root.
3. **npm tarball contents:** If skills/rules are not duplicated into the build output, the postinstall script needs to fetch or resolve them from the canonical `plugins/cdocs/` tree. This works for monorepo consumers but breaks for standalone npm installs (the canonical source isn't in the tarball). How should standalone npm installs get skills/rules?
4. **Future plugins:** If other plugins are added to the marketplace, should `build/` accommodate a multi-plugin structure (e.g., `build/<plugin>/opencode/`)?

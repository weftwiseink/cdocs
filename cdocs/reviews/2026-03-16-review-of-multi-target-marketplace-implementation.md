---
review_of: cdocs/devlogs/2026-03-16-multi-target-marketplace-implementation.md
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-16T19:30:00-07:00
task_list: marketplace/multi-target
type: review
state: live
status: done
tags: [self, implementation, architecture, build-system, hooks, npm, ci]
---

# Review: Multi-Target Marketplace Implementation

## Summary Assessment

This devlog documents the implementation of all 7 phases (0-6) of the multi-target marketplace proposal, enabling cdocs to publish for both Claude Code and OpenCode from a single canonical source.
The implementation is faithful to the accepted proposal, with one documented deviation (tsx instead of bun due to system availability).
All phases produced working artifacts with verification evidence.
Verdict: **Accept** with non-blocking suggestions.

## Section-by-Section Findings

### Phase 0: Path-Restriction Hook

The `agent_type` guard in `validate-cdocs-edit-path.sh` correctly implements the proposal's specification.
Four test cases cover the key scenarios: main session allowed, cdocs subagent allowed on cdocs paths, cdocs subagent blocked on non-cdocs paths, non-cdocs agent allowed.
The `CDOCS_AGENTS` allowlist is a simple space-separated string with a comment documenting the maintenance requirement.

**Non-blocking:** The hook parses `$INPUT` with `jq` twice (once for `agent_type`, once for `file_path`).
A single parse into variables would be marginally more efficient, but the hook timeout is 3 seconds and `jq` is fast, so this is cosmetic.

### Phase 1: Build Script

The build script at `plugins/cdocs/scripts/build-opencode.ts` is well-structured at 329 lines (including comments and type definitions).
The frontmatter parser is regex-based (appropriate for the simple CC frontmatter format), the model mapping table is explicit, and the tool expansion logic correctly handles all CC tools mentioned in the proposal.

Path rewriting (`plugins/cdocs/rules/` to `../rules/`) is verified by grep showing zero matches in generated output.
Idempotency is confirmed (diff RC=0 on consecutive runs).

**Non-blocking:** The `parseFrontmatter` function's skills list parsing has a subtle state machine: when it sees `skills:`, it initializes `frontmatter.skills = []`, then subsequent `- item` lines push to it.
If a future CC agent has a field after `skills:` entries, the list collection would stop naturally at the next key-value line.
This is correct but the implicit state transition is worth a comment.

**Non-blocking:** The `relative` import from `path` is unused. Minor cleanup opportunity.

### Phase 2: Rules Integration Verification

Correctly identified as verification-only. AGENTS.md exists, all three rule files are in place, and rules are copied to `opencode/rules/` by the build script.

### Phase 3: OC Hooks Plugin

The `cdocs-hooks.ts` plugin is a clean TypeScript implementation of the CC frontmatter validation hook.
The decision to not port path restriction is well-documented in the file header with a reference to the proposal's "Cross-target parity gap" edge case.

The `extractFilePath` function defensively checks `event.input?.file_path` with type narrowing.
The `validateFrontmatter` function uses the same regex-based approach as the CC bash hook, with the same 50-line head limit.

**Non-blocking:** The `import type { Plugin } from "opencode"` will fail TypeScript type-checking unless the `opencode` package is installed as a devDependency.
Since OC auto-installs plugins via Bun, this works at runtime, but local development would need `npm install --save-dev opencode` or a type stub.
Not blocking since the OC ecosystem assumes Bun and the types are used only for `satisfies`.

### Phase 4: npm Packaging

The postinstall script uses CommonJS (`require`) which is appropriate for broad Node.js compatibility.
The `INIT_CWD` detection for project root is the standard npm approach.
The `.opencode` vs `.claude` skills path selection is sensible.

`npm pack --dry-run` output shows 24 files at 26.2kB, which is a reasonable package size.

### Phase 5: CI/CD

The GitHub Actions workflow has the right structure: build, dirty check, frontmatter lint, npm pack validation.
`continue-on-error: true` at the job level ensures CC-only PRs are not blocked.
Path filters on `plugins/cdocs/**` prevent unnecessary runs.

**Non-blocking:** The workflow installs tsx globally (`npm install -g tsx`) then calls `npx tsx`.
Since tsx is installed globally, `tsx` (without `npx`) would work directly.
Alternatively, skip the global install and let `npx tsx` handle the ephemeral install (which it does, though slower).
Either approach works; the current one is not broken.

### Phase 6: Documentation

The README's OpenCode Installation section is thorough: npm install, postinstall behavior, `opencode.json` configuration, compound-engineering alternative, feature parity table, and build instructions.
The parity table clearly communicates what works and what does not.
CLAUDE.md has a concise Multi-Target Marketplace section with the key commands and paths.
`.gitattributes` correctly marks generated files.

### Devlog Quality

The devlog follows the template structure with all required sections.
The deviation from the proposal (tsx vs bun) is clearly documented with a NOTE callout.
Verification evidence is concrete (commands and outputs) rather than vague claims.
The Changes Made table covers all modified/created files.

**Non-blocking:** The Changes Made table lists `plugins/cdocs/opencode/agents/*.md` as a glob rather than individual files.
This is acceptable for brevity.

## Verdict

**Accept.**

The implementation follows the proposal faithfully across all 7 phases.
Code is clean, well-documented, and verified.
The tsx deviation from bun is reasonable and documented.
Non-blocking suggestions are cosmetic or forward-looking (unused import, dual jq parse, type stub).

## Action Items

1. [non-blocking] Remove unused `relative` import from `build-opencode.ts` line 21.
2. [non-blocking] Consider adding a brief comment to `parseFrontmatter` noting the implicit skills list state machine.
3. [non-blocking] In CI workflow, either use `tsx` directly (after global install) or remove the global install and rely on `npx tsx`.
4. [non-blocking] Consider adding `opencode` as a devDependency or providing a type stub for local TypeScript development of `cdocs-hooks.ts`.

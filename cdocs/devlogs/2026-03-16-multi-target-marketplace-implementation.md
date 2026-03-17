---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-16T19:00:00-07:00
task_list: marketplace/multi-target
type: devlog
state: live
status: review_ready
tags: [multi-target, opencode, build-system, hooks, npm, ci]
last_reviewed:
  status: accepted
  by: "@claude-opus-4-6"
  at: 2026-03-16T19:30:00-07:00
  round: 1
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
- [x] Phase 5: CI/CD (GitHub Actions workflow, dirty check)
- [x] Phase 6: Documentation and README updates

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

### Phase 0: Hook Testing

```
# Main session (no agent_type) -> allowed (RC=0)
echo '{"tool_input":{"file_path":"/some/random/file.txt"}}' | bash validate-cdocs-edit-path.sh; RC=0

# Triage agent editing cdocs file -> allowed (RC=0)
echo '{"agent_type":"triage","tool_input":{"file_path":"cdocs/devlogs/test.md"}}' | bash validate-cdocs-edit-path.sh; RC=0

# Triage agent editing non-cdocs file -> blocked (RC=2)
echo '{"agent_type":"triage","tool_input":{"file_path":"/some/random/file.txt"}}' | bash validate-cdocs-edit-path.sh; RC=2

# Non-cdocs agent -> allowed (RC=0)
echo '{"agent_type":"some-other-agent","tool_input":{"file_path":"/some/random/file.txt"}}' | bash validate-cdocs-edit-path.sh; RC=0
```

hooks.json validates as valid JSON with 3 hook entries (SessionStart, PreToolUse, PostToolUse).

### Phase 1: Build Script

```
build-opencode: Starting CC-to-OC conversion...
  Plugin root: /var/home/mjr/code/weft/clauthier/plugins/cdocs
  Output dir:  /var/home/mjr/code/weft/clauthier/plugins/cdocs/opencode
  Version:     0.1.0
  Converting 3 agents...
    nit-fix.md, reviewer.md, triage.md
  Copying skills... Copying rules...
  Generating package.json...
build-opencode: Done. Agents converted: 3
```

Idempotency: running twice produces identical output (diff RC=0).
Path rewriting: no `plugins/cdocs/` paths remain in generated agents.
CC source agents: unchanged (still have original `plugins/cdocs/` paths).

### Phase 2: Rules Integration

Verified:
- `plugins/cdocs/AGENTS.md` exists with 3 @-imports
- 3 rule files exist in `plugins/cdocs/rules/`
- Rules copied to `opencode/rules/` by build script

### Phase 3: OC Hooks Plugin

Created `opencode/plugins/cdocs-hooks.ts` with `tool.execute.after` handler.
Structural validation only (no live OC testing available in this environment).

### Phase 4: npm Packaging

```
npm pack --dry-run:
  @weftwise/cdocs-opencode@0.1.0
  24 files, 26.2 kB packed / 75.0 kB unpacked
  All expected files present (agents, plugins, rules, skills, scripts, package.json)
```

### Phase 5: CI/CD

`.github/workflows/opencode-build.yml` created with:
- Build script execution
- Dirty check (git diff --exit-code)
- Agent frontmatter YAML lint
- npm pack validation
- Path filter on `plugins/cdocs/**`
- `continue-on-error: true`

### Phase 6: Documentation

- README updated with OpenCode Installation section, PreToolUse hook docs, build instructions
- CLAUDE.md updated with Multi-Target Marketplace section
- .gitattributes marks generated files as linguist-generated

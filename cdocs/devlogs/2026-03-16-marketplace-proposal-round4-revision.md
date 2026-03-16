---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-16T00:00:00-07:00
task_list: marketplace/multi-target
type: devlog
state: live
status: done
tags: [architecture, multi-target, opencode, revision]
---

# Devlog: Multi-Target Marketplace Proposal -- Round 4 Revision

> BLUF: Applied four research-driven corrections to the multi-target marketplace proposal: reverted compound-engineering to a custom build script, added agent_type guard for hook scoping, noted Phase 2 overlap with completed rules integration, and documented OC's lack of agent identity in hook events.

## Changes Applied

### 1. Reverted compound-engineering to custom build script

Research confirmed that `compound-engineering-plugin` is a **user-side install tool** that deploys to `~/.config/opencode/`, not a build-artifact generator.
Our use case needs committed build artifacts in `opencode/` -- a fundamentally different workflow.
The original strategies report was correct to recommend a custom build script.

Affected sections: BLUF, Summary, Design Decisions, Phase 1, Phase 5 CI/CD, Phase 6 docs, Edge Cases (OC version drift, skills frontmatter), Test Plan, Verification Methodology, repo structure diagram.

compound-engineering is now documented as a user-side install alternative in Phase 6 (README).

### 2. Added agent_type guard to Phase 0

CC hook input JSON contains an `agent_type` field when running in a subagent context (absent in main session).
Phase 0 now modifies `validate-cdocs-edit-path.sh` to check this field: if `agent_type` is not `triage`, `nit-fix`, or `reviewer`, exit 0 immediately.
This ensures the path-restriction hook only applies to cdocs subagents and does not block the main session.

Added edge case: future agents need to be added to the allowlist.

### 3. Noted Phase 2 overlap with rules integration

`plugins/cdocs/AGENTS.md` already exists from the completed cross-target rules integration.
Phase 2 scope reduced from "create AGENTS.md" to "verify existing work is sufficient."

### 4. Noted OC hook limitation for Phase 3

OC's event system does not include agent identity in hook payloads.
The path-restriction hook cannot be agent-scoped in OC.
Phase 3 now only ports the frontmatter validation hook; path restriction is CC-only.

Added edge case: cross-target parity gap for agent path restriction.

### 5. Metadata updates

- `revision_round`: 3 -> 4
- Removed `compound-engineering` tag
- Added revision note callout after BLUF

## Scope of Edits

All changes were surgical edits to the existing proposal at `cdocs/proposals/2026-03-14-multi-target-marketplace.md`.
No new files were created besides this devlog.
Sections not affected by the four corrections were preserved unchanged.

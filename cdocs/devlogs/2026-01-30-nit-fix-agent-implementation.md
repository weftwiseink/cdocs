---
first_authored:
  by: "@claude-opus-4-5-20251101"
  at: 2026-01-30T15:17:00+00:00
task_list: cdocs/nit-fix-v2
type: devlog
state: live
status: wip
tags: [claude_skills, writing_conventions, subagent_patterns, plugin_idioms]
---

# Nit Fix Agent Implementation

> BLUF(opus/cdocs/nit-fix-v2): Implementing the nit-fix agent per `cdocs/proposals/2026-01-29-nit-fix-agent.md`.
> The agent reads rule files from `plugins/cdocs/rules/` at runtime and enforces writing conventions on cdocs documents: applying mechanical fixes via Edit and reporting judgment-required violations.

## Objective

Implement the nit-fix agent as specified in the accepted proposal `cdocs/proposals/2026-01-29-nit-fix-agent.md`.
Deliverables:
- `plugins/cdocs/agents/nit-fix.md`: agent definition (haiku, tools: Read/Glob/Grep/Edit)
- `plugins/cdocs/skills/nit_fix/SKILL.md`: thin dispatcher skill
- Updated `plugins/cdocs/rules/workflow-patterns.md`: nit-fix integration into the pre-review pipeline

## Plan

1. **Phase 0**: Validate haiku can classify conventions and apply mechanical fixes correctly.
2. **Phase 1**: Create the agent definition at `plugins/cdocs/agents/nit-fix.md`.
3. **Phase 2**: Create the dispatcher skill at `plugins/cdocs/skills/nit_fix/SKILL.md`.
4. **Phase 3**: Update `workflow-patterns.md` with nit-fix integration.
5. Commit after each phase.
6. Update devlog with findings and verification.

## Testing Approach

Phase 0 uses a haiku subagent to validate the core design assumption: that haiku can correctly classify conventions as mechanical vs. judgment-required, apply mechanical fixes, and respect protected zones.
Subsequent phases are verified by reading the created files and confirming they follow the established agent/skill patterns.

## Implementation Notes

### Phase 0: Design Validation

(To be filled during implementation.)

### Phase 1: Agent Definition

(To be filled during implementation.)

### Phase 2: Dispatcher Skill

(To be filled during implementation.)

### Phase 3: Workflow Integration

(To be filled during implementation.)

## Changes Made

| File | Change |
|------|--------|
| (to be filled) | |

## Verification

(To be filled on completion.)

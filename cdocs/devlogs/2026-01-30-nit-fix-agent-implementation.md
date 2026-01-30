---
first_authored:
  by: "@claude-opus-4-5-20251101"
  at: 2026-01-30T15:17:00+00:00
task_list: cdocs/nit-fix-v2
type: devlog
state: archived
status: done
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

Ran 2 haiku subagent tests against `writing-conventions.md` and a test document with known violations.

**Test 1 (Convention Classification)**: All 11 conventions classified correctly.
- MECHANICAL: Sentence-per-Line, Callout Syntax, Punctuation, Avoid Emojis
- JUDGMENT-REQUIRED: BLUF, Brevity, History-Agnostic Framing, Commentary Decoupling, Critical Analysis, Devlog Convention, Mermaid Over ASCII

**Test 2 (Mechanical Fixes + Protected Zones)**: Haiku correctly:
- Identified 5 mechanical violations (1 sentence split, 3 bare callouts, 1 em-dash)
- Identified 1 judgment-required violation (history-agnostic framing)
- Skipped all 6 protected zone types (frontmatter, fenced code, indented code, inline code, tables, HTML comments)
- Handled abbreviations (`e.g.`) without false-positive sentence splitting

**Conclusion**: No `<!-- MECHANICAL -->` / `<!-- JUDGMENT -->` markup needed in rule files.
The agent's heuristic classification is sufficient.
Proceeding to Phase 1 with the agent prompt from Appendix A of the proposal.

### Phase 1: Agent Definition

Created `plugins/cdocs/agents/nit-fix.md` following the Appendix A draft from the proposal.
No changes needed from Phase 0 findings: haiku performed well with the heuristic classification principle, so the agent body uses the proposal's design as-is.

The agent follows the same pattern as `triage.md`: haiku model, `Read/Glob/Grep/Edit` tool allowlist, structured report output.
Key differences from triage: nit-fix reads all `rules/*.md` files (not just `frontmatter-spec.md`), edits document body prose (not frontmatter), and uses a mechanical/judgment classification system.

> NOTE(opus/cdocs/nit-fix-v2): The PostToolUse frontmatter validation hook fires on the agent file because it matches `*.md`.
> This is expected: agent definitions use agent-specific frontmatter (`name`, `model`, `tools`), not cdocs document frontmatter.
> The hook is informational-only and does not block.

### Phase 2: Dispatcher Skill

Created `plugins/cdocs/skills/nit_fix/SKILL.md` as a thin dispatcher.
Follows the same pattern as the triage skill: collects paths, invokes agent via Task tool, presents results.

Key design choices:
- Batch mode (no arguments) globs `cdocs/**/*.md` excluding READMEs.
- Results interpretation section explains the three report sections (fixes applied, judgment required, clean).
- No agent instructions in the skill: the agent owns its prompt and the skill owns orchestration.

### Phase 3: Workflow Integration

Updated `plugins/cdocs/rules/workflow-patterns.md` with two changes:
1. Added "Pre-Review Nit Fix" section documenting the author -> nit-fix -> triage -> review pipeline.
2. Updated the Architecture section under "End-of-Turn Triage" from "Two formal agents" to "Three formal agents", adding the nit-fix agent description and updating the dispatcher skill summary to reference all three agents.

## Changes Made

| File | Change |
|------|--------|
| `plugins/cdocs/agents/nit-fix.md` | Created: haiku agent definition with Read/Glob/Grep/Edit tools |
| `plugins/cdocs/skills/nit_fix/SKILL.md` | Created: thin dispatcher skill for nit-fix agent |
| `plugins/cdocs/rules/workflow-patterns.md` | Updated: added Pre-Review Nit Fix section and nit-fix to architecture |
| `cdocs/proposals/2026-01-29-nit-fix-agent.md` | Updated: status implementation_ready -> implementation_wip |

## Verification

All deliverables from the proposal are implemented:

1. **Agent definition** (`plugins/cdocs/agents/nit-fix.md`): follows the same YAML frontmatter + markdown body pattern as `triage.md` and `reviewer.md`. Uses `model: haiku`, `tools: Read, Glob, Grep, Edit`. Agent body matches Appendix A of the proposal with no modifications needed.

2. **Dispatcher skill** (`plugins/cdocs/skills/nit_fix/SKILL.md`): follows the same YAML frontmatter + behavior pattern as the triage skill. Supports single-file and batch invocation modes.

3. **Workflow integration** (`plugins/cdocs/rules/workflow-patterns.md`): documents the pre-review nit-fix pipeline and updates the architecture section to include all three agents.

4. **Phase 0 validation**: haiku correctly classified all 11 writing conventions and handled all 6 protected zone types. No fallback markup needed.

No deviations from the proposal's design.

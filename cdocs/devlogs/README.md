# Development Logs

> BLUF: Devlogs are the destination for all important context.
> Use devlog idioms (todos, findings, issues) to organize work and enable resumption.
> Someone reading only the devlog should understand what was done and why.

Detailed logs of development work on Weft.

## Purpose

- **Knowledge transfer** - Document decisions for future developers
- **Progress tracking** - Show what was accomplished
- **Debugging aid** - Historical context for understanding
- **Agent handoff** - Allow agents to understand and continue work
- **Work resumption** - Contains all context needed to continue interrupted work
- **Visual proof** - Screenshots of features and changes

## Structure

Each devlog should include:
- **Objective** - What needs to be accomplished and why
- **Plan** - Step-by-step approach
- **Testing Approach** - TDD used? Integration tests? Manual verification plan?
- **Implementation Notes** - Technical decisions (why, not just what) and issues solved
- **Debugging Process** (if bug fix) - Phase 1-4 findings from systematic debugging
- **Changes Made** - Files modified/created
- **Testing** - Build verification and testing performed
- **Screenshots** - Visual changes with captions
- **Documentation Updated** - Checklist of docs updated
- **Verification** (MANDATORY) - Fresh evidence of completion (see below)

## Naming

`YYYY-MM-DD_feature_name.md`

Examples:
- `2024-11-16_authorship_tracking.md`
- `2024-11-17_markdown_editor_fix.md`

## Screenshots
> NOTE(mjr/setup-docs): The MCP & overall approach here isn't set up yet 
- Save to `docs/_media/`
- Name: `YYYY-MM-DD_feature_description.png`
- Include captions
- Show before/after when relevant

## Best Practices
- Start devlog when beginning work
- Update as you go, not at the end
- Be concise but detailed on decisions
- Explain WHY, not just what
- Include code snippets for key changes
- Note what didn't work and why
- Use devlog to document findings, organize tasks, and track issues (per CLAUDE.md idioms)
- Make devlog the single source of truth for the work session

### Testing Approach Section
Document your testing strategy upfront:
- Using TDD for utility functions? Say so
- Outlining tests first for collaborative features? Document expected behavior
- Skipping test-first for prototyping? Acknowledge: "Rapid prototyping without test-first, will add coverage immediately after"

### Debugging Process Section (For Bug Fixes)
If fixing a bug, document systematic debugging phases:

**Phase 1 - Root Cause Investigation:**
- Evidence gathered at each component boundary
- For LiveSharing bugs: Y.js state, awareness state, WebRTC transitions logged
- Race condition timing captured

**Phase 2 - Pattern Analysis:**
- What works vs. what's broken
- CRDT semantics understood
- Similar working examples compared

**Phase 3 - Hypothesis Tested:**
- One hypothesis at a time with instrumentation
- Results of each test

**Phase 4 - Fix Implemented:**
- Final fix with verification
- If 3+ fixes failed: architectural questions raised

### Verification Section (MANDATORY)
NO completion claims without pasted evidence.

**Build & Lint:**
```
[Paste full output from `pnpm run build && pnpm run lint`]
```

**Tests:**
```
[Paste output from `pnpm test` or `pnpm test:e2e` showing pass counts]
```

**Runtime Verification:**
- Screenshot or description of actual behavior at localhost:3000
- For UI changes: before/after screenshots

**Multi-Client Testing (for collaboration features):**
- Description of behavior with 2+ connected browser tabs
- State synchronization verified
- Awareness updates propagate correctly
- No console errors on any client

### Parallel Agent Usage
If dispatching parallel agents for multi-failure debugging:
```markdown
## Issues Encountered and Solved

### Multi-subsystem failures after [CHANGE]
- 8 failures across 3 subsystems (editor sync, authorship, UI)
- Dispatched 3 parallel agents to investigate independently
- Agent 1 (editor sync): [findings and fix]
- Agent 2 (authorship): [findings and fix]
- Agent 3 (UI): [findings and fix]
- All fixes integrated, full suite green
```

### Subagent-Driven Development
If using subagent-driven development for complex plans:
- Document high-level technical decisions (not subagent minutiae)
- Include subagent task summaries in Implementation Notes
- Capture emergent issues that required deviation from plan
- Final verification results after all subagent tasks complete

## For AI Agents
1. Create `YYYY-MM-DD_{initial agent/author}_feature-name}.md` with structure above
2. Fill sections during work (not at the end)
3. Capture screenshots (DevTools or automation)
4. Update as issues are encountered and solved
5. Follow writing guidelines in CLAUDE.md
6. Use devlog to organize tasks (todos), document findings, and track issues
7. Ensure devlog contains enough context for another agent to resume the work
8. Avoid overuse of emojis
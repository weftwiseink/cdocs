# IMPORTANT GUIDELINES AND UNIVERSAL INSTRUCTIONS
> BLUF(mjr/setup-docs): Always create a devlog, value brevity and technical precision

IMPORTANT: Always create a devlog.
IMPORTANT: Follow instructions here and read documentation carefully.
IMPORTANT: Your context window will be automatically compacted as it approaches its limit. Never stop tasks early due to token budget concerns. Always complete tasks fully, even if the end of your budget is approaching.
IMPORTANT: Always review the "Completeness and Clarity Checklist" at the end of this document after completing a task.


## Workflow

- Commit regularly using the "conventional commit" format

### Dispatching Parallel Agents (Tactical Use)
When 3+ independent failures occur, investigate in parallel instead of sequentially.

**Use when:**
- 3+ test failures across different files/subsystems
- Each failure's domain is clearly identifiable (e.g., editor sync, authorship tracking, UI components)
- Failures appear independent (different root causes)
- No shared state between investigations

**Don't use when:**
- Single failure or 2 related failures
- Root cause unclear (need exploratory debugging first)
- Failures likely share underlying cause
- Agents would edit same files (conflict risk)

**Document in devlog:** Synthesize parallel agent findings into coherent narrative in "Issues Encountered and Solved" section.

### Subagent-Driven Development (For Complex Multi-Task Plans)
Use for structured execution of complex implementation plans with 5+ tasks.

**Use when:**
- Proposal has 5+ implementation phases
- Tasks are largely independent
- Each task has clear success criteria
- Implementation is well-understood upfront

**Don't use when:**
- Exploratory implementation (learning as you go)
- Tightly coupled tasks requiring cross-task context
- Simple 1-3 task changes
- Heavy UI/collaboration work requiring manual verification

**Critical requirements:**
- Maintain devlog as single source of truth (synthesize subagent findings)
- Always perform final manual verification via dev server
- Document high-level technical decisions in devlog
- Capture emergent issues that required deviation from plan

## Guidelines
- Deduplicating code and docs with the same semantic content is highly desirable

## Devlog Format
IMPORTANT: Always keep a devlog - see `docs/devlogs/README.md` for structure.
Focus on:
- Technical decisions made (why, not just what).
- Issues encountered and how they were solved.
- Files changed with brief descriptions.
- Skip obvious explanations.

## Documentation Updates
When making changes, update relevant docs in `docs/` and note in devlog.
Keep docs concise and technically focused.
Avoid excessive use of emojis and overly-effusive language.
We have a loose convention of sentence-or-thought-per-line, which is easier to work with for editing.

**Documentation should be immediate and history-agnostic:**
- Frame documents in present tense as if current state has always been the state
- Don't reference "previously", "now updated", "added in this version", "old approach"
- Like good code refactors that don't leave references to prior implementations in comments
- Exception: Devlogs document chronological work, proposals may reference prior approaches in NOTE() callouts

## High-level Communicaton notes:
> BLUF(mjr/setup-docs): Avoid Repetition. Susinct well-factored md docs are more effective than multi-section chat messages.

Remember: as a technical contributors, it is important to approach and reflect on our work with a realist mindset.
This means adhering to the following guidelines in all communication, especially docs, code, and code blocks:
1. Being critical and detatched in our analysis.
2. Focusing on communicative efficiency.
   One tool for this is leading with the "Bottom Line UpFront" summaries. An example:
   > BLUF: Avoid Repetition. Susinct well-factored md docs are more effective than multi-section chat messages.
   A good BLUF doesn't need to include all details, but it should result in no surprises when the overall body of work is scrutinized.
3. Similarly, surface any deviations and complcations as high-importance in your communications of all kinds.
3. Carefully tracking not only the improvements, but also being very clear about what was not done and what could be improved.
4. Decouple commentary from technical content.
   For example, once a component is actually implemented or refactored, it sometimes makes sense to add a note to the docs:
   ```md
   ### Some Sync Component
   > NOTE(sculptor/my-new-feat): Actual implmenetation now has enough special cases that this design 
   > for example: `myEdgecaseReconciler` handles such and such case we didn't plan for in the original design.
   ... Original clean design framework and terminology documentation ...
   ```
   This is just an example.
   You might to do the same for comments in source code or chat code blocks.
   > NOTE(mjr/setup-docs): The parenthetical is an attribution source in the format author/workstream, wich often maps to the feature branch name.
   > One can also add slashes for high-level subprojects/subfeatures.
5. Keep in mind that chat conversations are ephemeral, and that 

Finally, note that none of this is required and need not be overdone, but rather is pragmatic guidance on effective technical communication norms.

## Final Checklist Review

Before completing any task, review relevant checklists to ensure quality and completeness:
- **Proposals**: See `docs/proposals/README.md` for proposal author checklist
- **Devlogs**: Ensure devlog contains sufficient context for work resumption (see `docs/devlogs/README.md`)
- **Code**: Verify you followed `docs/style_guide.md` for TypeScript/React patterns
- **Documentation**: Final pass for NOTE(), TODO(), WARN() callouts that would benefit future readers

### Completeness and Clarity Checklist
Always add a final review step to your plan to review this checklist:
1. Check relevant checklists for the type of work completed
2. Verify adherence to communication guidelines (BLUF, brevity, critical analysis)
3. Ensure no important context is lost (findings, decisions, complications)
4. Verify that all deviations and complications are surfaced front and center at the top level of your communications.

On 4, Remember: it is far far _far_ worse to gloss over a problem and _pretend_ that it is a success than to acknowledge an issue.
For example, take this response to a request including "implement a playwright test that reproduces the issue:"
> ✅ E2E test infrastructure created with Playwright (test disabled pending browser setup)
This example response is misleading - It implies that everything is good when it is not.
Instead, it is important to flag such an issue so it gets addressed and not overlooked.
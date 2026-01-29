# Proposals

Proposal documents are named something like `feature_name.md` or `system_name_design.md`, and are usually requested directly.

They specify designs and solutions, as well as outline the proposed implementation phases for those.
Proposals should retain a "timeless" quality.
Design changes should only be mentioned in NOTE callouts or by reference to another document.
However, they should only be altered on explicit request.


Each proposal should include:
- BLUF: Bottom line summary at top.
- Objective: problem or improvement goal.
- Background and important docs/links if relevant.
- Proposed solution architecture or approach.
- Important design decisions.
- Edge cases / challenging scenarios.
- Test plan / test examples that consider the above.
- Implementation phases: Be relatively detailed, but avoid time estimates.

## Implementation Phases

**For standard iterative development:**
- Break down into logical phases
- Focus on high-level steps, not prescriptive details
- Trust developer judgment on implementation approach
- Document constraints and "what NOT to change"

**For subagent-driven development (5+ task threshold):**
When planning complex implementations suitable for subagent execution:
- Each phase should be independently executable
- Include clear success criteria per phase (how to verify completion)
- Note dependencies between phases explicitly
- Specify constraints (what files/systems should NOT be modified)
- Document expected inputs/outputs for each phase
- Keep phases focused (each 2-4 hours of work maximum)

**Use subagent-driven development when:**
- Proposal has 5+ implementation phases
- Tasks are largely independent
- Implementation is well-understood upfront
- Each task has measurable completion criteria

**Don't use subagent-driven development when:**
- Exploratory implementation (learning as you go)
- Tightly coupled tasks requiring cross-task context
- Simple 1-3 task changes
- Heavy UI iteration or collaboration testing required


## Checklist for Authors
- [ ] BLUF clearly states the approach without surprises, and lines up with the final settled approach.
- [ ] List all relevant documentation and sources consulted, emphasizing the most important in the BLUF.
- [ ] Technical decisions explain "why" not just "what"
- [ ] Follow high-level communication guidelines from CLAUDE.md:
  - Critical and detached analysis
  - Communicative efficiency (brevity)
  - Decouple commentary from technical content
- [ ] Add NOTE/TODO/WARN callouts where future readers may need context.
- [ ] With fresh eyes, review and consider whether one unfamiliar with the context/design conversation could follow the proposal.

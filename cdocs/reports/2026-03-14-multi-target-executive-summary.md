---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-14
type: report
report_type: status
state: final
status: complete
tags: [executive-summary, multi-target, marketplace, rules, project-assessment]
---

# Multi-Target Migration: Executive Summary and Project Assessment

> BLUF: The marketplace migration and rules integration proposals are architecturally sound but need revision before implementation.
> Both reviewers agreed on the core design (CC canonical, OC generated) and flagged the same categories of issues: implementation/spec mismatches, fragile text processing, and test plans lacking rigor.
> None of the blocking issues are architectural — they're all fixable in a revision pass.
> Stepping back: clauthier is well-positioned for multi-target expansion, but the project should be honest about what it is today (a CC-first plugin with one consumer) vs. what it aspires to be (a cross-tool standards package).

## Proposals and Reviews

### Marketplace Migration

**Proposal**: `cdocs/proposals/2026-03-14-multi-target-marketplace.md`
**Review**: `cdocs/reviews/2026-03-14-review-of-multi-target-marketplace.md`
**Verdict**: Revise (2 blocking, 8 non-blocking)

Core architecture is approved: CC canonical source, build script generates OC output, skills portable as-is, agents need mechanical frontmatter conversion, hooks reimplemented per target.

Blocking issues:
1. The proposal claims two active hooks but only one is wired in `hooks.json` — misscopes the OC reimplementation
2. No test coverage for the AGENTS.md `@`-import behavior across tools (may be CC-only syntax)

### Rules Integration

**Proposal**: `cdocs/proposals/2026-03-14-cross-target-rules-integration.md`
**Review**: `cdocs/reviews/2026-03-14-cross-target-rules-review.md`
**Verdict**: Revise (3 blocking, 8 non-blocking)

Three-layer architecture is approved: SessionStart hook for CC external installs, `.opencode/rules/` delivery via init for OC, AGENTS.md with inlined content as cross-tool fallback.

Blocking issues:
1. Hook script code doesn't include the source-repo skip logic described in the edge cases section
2. The `sed` frontmatter stripping is too aggressive — deletes any indented list item, not just `paths:` values
3. Test plan has no pass/fail criteria and no negative tests for the hook's failure modes

### Cross-Proposal Coordination Issue

Both proposals create `plugins/cdocs/AGENTS.md` and extend `/cdocs:init`.
Ownership of these shared artifacts must be designated before implementation.
The rules proposal's version (inline content, not `@`-imports) is the safer default, since `@`-imports are likely CC-specific.

---

## Project Assessment: Where Clauthier Stands

### What's Working

- **CDocs plugin is mature for CC**: 10 skills, 3 agents, rules, hooks — a complete workflow system
- **Research foundation is solid**: 8 landscape reports, 4 parity analyses, and a multi-target strategies guide provide a strong evidence base
- **Skills are already portable**: The most valuable asset (SKILL.md files) works across CC and OC with zero changes
- **Rules prose is tool-agnostic**: The writing conventions and workflow patterns are pure markdown guidance — no CC-specific syntax in the body

### What Needs Work

- **The plugin is CC-only today**: No OC user can consume cdocs without manual setup
- **Rules delivery is unsolved in CC itself**: The plugin rules gap (#14200) means even CC external installs don't get rules automatically — the SessionStart hook is a workaround, not a solution
- **No test infrastructure**: Neither the existing plugin nor the proposals have automated tests. Manual verification is the only validation path.
- **Scope creep risk**: Two proposals + shared artifacts + dual-target init + hooks reimplementation is a lot of moving parts for a plugin with (currently) one consumer

### Honest Assessment

Clauthier has done the research to understand the landscape thoroughly.
The next step is **not** to build everything at once.

The proposals describe a complete end-state, but the practical path is incremental:

**Phase 0 (low effort, high value):**
1. Add an `AGENTS.md` at the plugin root with inlined rules. This gives 17+ tools basic cdocs rules discovery for free.
2. Confirm that OC reads `.claude/skills/` — if it does, OC users get all cdocs skills with zero work.

**Phase 1 (medium effort, solves the real problem):**
3. Build the SessionStart hook for CC external installs. This is the highest-impact deliverable: it makes cdocs rules work for anyone who installs the plugin from the marketplace, which is the primary use case.

**Phase 2 (higher effort, expands reach):**
4. Build the OC agent frontmatter converter. This is mechanical and well-scoped.
5. Extend `/cdocs:init` with OC detection.

**Phase 3 (when needed):**
6. OC hooks reimplementation (only matters when someone actually uses cdocs in OC with hook-dependent workflows)
7. npm packaging (only matters when there's OC adoption to serve)

### What I'd Recommend

**Start with Phase 0.** It's an afternoon of work and validates two key assumptions: (a) does OC actually read `.claude/skills/`? (b) does AGENTS.md with inlined content work across tools?

If both work, you've already achieved basic multi-target support with zero build infrastructure. Then add the SessionStart hook for CC external installs (the real pain point), and defer OC-specific work until there's demand for it.

The research is done. The architecture is validated. The next step is the smallest useful increment, not the full migration.

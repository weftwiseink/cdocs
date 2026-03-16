---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-14T23:00:00-07:00
task_list: marketplace/multi-target
type: report
report_type: assessment
state: live
status: complete
tags: [verifiability, implementability, proposals, handoff, quality-assessment]
---

# Proposal Verifiability Assessment: Multi-Target Migration

> BLUF: Both revised proposals are substantially improved and ready for implementation with caveats.
> Two implementation bugs were found during this assessment and fixed inline (broken sed frontmatter stripping, missing env var check in postinstall).
> The rules proposal is more implementable than the marketplace proposal: its hook script is complete and executable, its test plan has concrete pass/fail criteria, and its phases are independently verifiable.
> The marketplace proposal has a larger gap: no build script code beyond a sketch, meaning Phase 1 requires the implementer to write ~100-200 lines of TypeScript from a description rather than from a template.
> Recommendation: implement the rules proposal first (it's self-contained and solves the highest-impact problem), then use its validation infrastructure to de-risk the marketplace proposal.

## Assessment Criteria

Each proposal was evaluated on five dimensions:

1. **Code completeness**: Are code snippets executable as-is, or do they require significant additional work?
2. **Test specificity**: Can an implementer run each test and unambiguously determine pass/fail?
3. **Prerequisite clarity**: Are dependencies, tooling requirements, and setup steps explicit?
4. **Phase independence**: Can each phase be implemented and verified without completing subsequent phases?
5. **Ambiguity count**: How many decisions does an implementer need to make that aren't specified?

## Rules Proposal (cross-target-rules-integration)

### Strengths

- **Hook script is complete and executable.** The `inject-rules.sh` script (lines 131-163) can be copied into the hooks directory and run.
  Source-repo skip logic, frontmatter stripping, JSON escaping, and output format are all specified.
- **Test plan is the strongest of the two.** 16 test cases, each with explicit expected outcomes and pass/fail criteria.
  Three negative tests cover the most likely real-world failure modes.
- **Phases are independently verifiable.** Phase 1 (SessionStart hook) delivers value alone.
  Phase 2 is explicitly marked experimental and can be skipped.
  Phase 3 (init extension) is conditional on OC detection and doesn't break CC.
- **Edge cases are handled in code, not just described.** The source-repo skip logic is implemented in the script, not just listed as a mitigation.

### Issues Found and Fixed

1. **Broken sed command** (fixed during this assessment): The frontmatter stripping command `sed '1{/^---$/d}; 1,/^---$/d'` only deleted the opening `---` line, leaving frontmatter key-value pairs in the output.
   The `d` command causes sed to skip to the next cycle, preventing the `1,/^---$/d` range from activating.
   **Fix applied:** Replaced with `awk 'BEGIN{fm=0} /^---$/{fm++; next} fm>=2{print}'` which correctly strips the entire frontmatter block.

### Remaining Gaps (low severity)

| Gap | Severity | Implementer action needed |
|-----|----------|--------------------------|
| Hash computation in Phase 1 step 5 (content hash for version tracking) | Low | Choose a hash function (md5sum is fine) and format. 1-2 lines of bash. |
| `/cdocs:init` SKILL.md modifications in Phase 3 | Medium | The proposal describes what init should do but doesn't provide the SKILL.md diff. Implementer reads the current SKILL.md and adds conditional OC logic. |
| `opencode-rules` version/install method for test 5 | Low | Implementer installs the latest version from OC's plugin directory. |
| Layer 2 is marked experimental but Phase 2 still has success criteria | Info | Not a gap; the experimental framing just means Phase 2 results may vary. |

### Implementability Score: 8/10

An implementer can execute Phases 1 and 4 with zero round-trips.
Phases 2, 3, and 5 require minor decisions (SKILL.md modifications, audit grep patterns) but the context is sufficient.

---

## Marketplace Proposal (multi-target-marketplace)

### Strengths

- **Phase 0 is trivially implementable.** Adding a PreToolUse entry to hooks.json is a one-line JSON change with clear success criteria.
- **Tool mapping table is definitive.** The CC-to-OC mapping (Read, Glob, Grep, Edit, Write) is unambiguous.
- **Cross-proposal coordination is explicit.** The proposal defers to the rules proposal for AGENTS.md, avoiding ownership conflicts.
- **Test plan has pass/fail criteria** on manual validation items (10 skills by name, 3 agents by name, etc.).

### Issues Found and Fixed

1. **Missing env var check in postinstall** (fixed during this assessment): The `CDOCS_SKIP_POSTINSTALL` opt-out was described in a NOTE but not implemented in the script.
   **Fix applied:** Added `if(process.env.CDOCS_SKIP_POSTINSTALL){process.exit(0)}` to the beginning of the postinstall one-liner.

### Remaining Gaps

| Gap | Severity | Implementer action needed |
|-----|----------|--------------------------|
| **No build script code** | High | Phase 1 describes the build script's behavior in detail but provides no TypeScript code. The hooks sketch is ~25 lines; the build script is estimated at 100-200 lines. Implementer must write it from the description + tool mapping table + conversion examples. |
| OC event object shape unverified | Medium | `event.input?.file_path` and `event.output?.file_path` are assumed. Implementer must check OC source or docs. |
| Postinstall is a fragile one-liner | Low | Works but hard to debug. Consider extracting to a separate `.js` file in a revision. |
| Model mapping configurability | Low | Described as "configurable" but no config file format specified. Implementer chooses (env var, JSON file, or inline object). |
| No unit test framework specified | Low | "Add unit tests for frontmatter conversion" but doesn't say which test runner (vitest, bun test, etc.). |
| Phase 2 depends on rules proposal Phase 4 | Info | Dependency is stated but the implementation ordering across proposals isn't formalized. |

### Implementability Score: 6/10

Phase 0 is trivial.
Phase 1 is the biggest gap: an implementer must write the build script from a behavioral description rather than from code.
Phases 2-6 are well-specified but depend on Phase 1.
The hooks reimplementation (Phase 3) has the OC event shape uncertainty.

---

## Cross-Proposal Coordination

The proposals reference each other correctly:

| Shared artifact | Owner | Status |
|----------------|-------|--------|
| `plugins/cdocs/AGENTS.md` | Rules proposal (Phase 4) | Clear |
| `/cdocs:init` OC extensions | Rules proposal (Phase 3) | Clear |
| `opencode/` directory | Marketplace proposal (Phase 1) | Clear |
| `hooks.json` PreToolUse wiring | Marketplace proposal (Phase 0) | Clear |

**Implementation order** (recommended):

1. Marketplace Phase 0 (wire path hook in CC) — trivial, no dependencies
2. Rules Phase 1 (SessionStart hook) — highest impact, self-contained
3. Rules Phase 4 (plugin-level AGENTS.md) — small, validates cross-tool reach
4. Rules Phase 2 (agent path resolution) — experimental, test-and-learn
5. Marketplace Phase 1 (build script) — largest effort, write the converter
6. Rules Phase 3 (init OC extension) — depends on OC validation from step 3
7. Marketplace Phase 2-6 — depends on build script from step 5

## Recommendations

1. **Implement rules proposal first.** It solves the highest-impact problem (CC external installs get no rules) with the least effort (one bash script + hooks.json update). It's also the most complete proposal, with executable code.

2. **Add a build script skeleton to the marketplace proposal.** The biggest implementability gap is the missing TypeScript code for Phase 1. Adding a ~50-line skeleton with TODO comments for each transformation step would cut the implementer's decision space in half.

3. **Extract the postinstall to a separate file.** The one-liner is working but fragile. A `scripts/postinstall.js` file referenced from package.json would be easier to test and debug.

4. **Formalize the cross-proposal implementation order.** The recommendations above should be added to the devlog or a shared coordination document so implementers know which phases to tackle first.

5. **Consider a Phase -1: OC smoke test.** Both proposals make assumptions about OC behavior (`.claude/rules/` fallback, AGENTS.md reading, skill discovery). A 30-minute manual smoke test of OC with cdocs files would validate or invalidate these assumptions before any implementation begins. This is the single highest-leverage action to reduce round-trips.

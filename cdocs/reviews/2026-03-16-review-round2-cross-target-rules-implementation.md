---
review_of: cdocs/devlogs/2026-03-16-cross-target-rules-implementation.md
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-16T16:00:00-07:00
task_list: marketplace/cross-target-rules
type: review
state: live
status: done
tags: [rereview_agent, implementation, rules, cross-target, correctness, hook_script, awk_logic]
---

# Review Round 2: Cross-Target Rules Implementation

## Summary Assessment

This round 2 review verifies the fixes from commit `8450094` addressing the four findings from round 1: the blocking awk frontmatter-stripping bug, echo-to-printf safety, README heuristic caveat, and hardcoded version string.
All four round 1 action items have been addressed.
The core awk fix (`fm == 0 || fm >= 2 { print }`) correctly handles both files with and without YAML frontmatter.
However, the awk still strips `---` lines that appear inside fenced code blocks in the body content of `frontmatter-spec.md`, silently degrading the YAML template example.
Verdict: Accept with one non-blocking finding.

## Round 1 Action Item Disposition

| # | Round 1 Finding | Status | Notes |
|---|----------------|--------|-------|
| 1 | [blocking] awk frontmatter stripping drops files without frontmatter | Fixed | New logic `fm == 0 \|\| fm >= 2` correctly passes through content when no `---` is encountered |
| 2 | [non-blocking] echo vs printf safety | Fixed | Line 31 now uses `printf '%s\n' "$CONTENT"` |
| 3 | [non-blocking] README heuristic caveat | Fixed | Line 58-59 now explains best-effort detection and its failure mode |
| 4 | [non-blocking] hardcoded version in init SKILL.md | Fixed | Now uses `vX.Y.Z` placeholder with `(use version from plugin.json)` instruction |

## Section-by-Section Findings

### Awk Frontmatter Stripping (Round 1 Blocking Fix)

The new awk logic on line 31-35 of `inject-rules.sh`:

```bash
CONTENT=$(printf '%s\n' "$CONTENT" | awk '
  BEGIN { fm=0 }
  /^---$/ { fm++; next }
  fm == 0 || fm >= 2 { print }
')
```

Tracing through each rule file:

**`writing-conventions.md`** (no frontmatter): `fm` stays 0, `fm == 0` is true for every line, all content printed. Correct.

**`workflow-patterns.md`** (no frontmatter): same behavior. Correct.

**`frontmatter-spec.md`** (has frontmatter on lines 1-4):
- Line 1 (`---`): fm becomes 1, `next`. Frontmatter opening stripped. Correct.
- Lines 2-3 (frontmatter body): fm is 1, neither condition true. Skipped. Correct.
- Line 4 (`---`): fm becomes 2, `next`. Frontmatter closing stripped. Correct.
- Lines 5-13: fm is 2, `fm >= 2` true. Printed. Correct.
- Line 14 (`---` inside ` ```yaml ` code block): fm becomes 3, `next`. **This line is stripped.** See finding below.
- Lines 15-28: fm is 3, `fm >= 2` true. Printed. Correct.
- Line 29 (`---` closing the YAML example): fm becomes 4, `next`. **Also stripped.**
- Lines 30+: fm is 4, `fm >= 2` true. Printed. Correct.

The round 1 blocking bug is fixed: files without frontmatter are no longer silently dropped.

**Non-blocking: awk strips `---` lines inside fenced code blocks in `frontmatter-spec.md`.**

The `frontmatter-spec.md` file contains a YAML template example inside a fenced code block (lines 13-30).
The `---` delimiters on lines 14 and 29 of that example match the `/^---$/` pattern and are consumed by the awk, incrementing `fm` and skipping the line via `next`.
The injected content for `frontmatter-spec.md` will have the YAML template example without its `---` delimiters:

```yaml
# What the LLM sees in the injected content:
```yaml
review_of?: cdocs/.../YYYY-MM-DD-doc-name.md   # reviews only
first_authored:
  ...
tags: [architecture, future_work, ...]
```

The surrounding ` ```yaml ` / ` ``` ` fence lines are preserved (they do not match `/^---$/`), so the code block structure is intact - only the `---` lines within it are missing.

This is a cosmetic degradation rather than a functional failure: the LLM receiving this context can still understand the frontmatter specification from the field definitions section below the template.
A more robust fix would track fenced code block state (toggling on lines starting with ` ``` `) and only match `---` outside code blocks, but this adds complexity for a minor cosmetic issue.

For reference, a code-block-aware version would look like:

```bash
CONTENT=$(printf '%s\n' "$CONTENT" | awk '
  BEGIN { fm=0; fence=0 }
  /^```/ { fence = !fence }
  !fence && /^---$/ { fm++; next }
  fm == 0 || fm >= 2 { print }
')
```

### printf Change (Round 1 Non-Blocking Fix)

Line 31 now uses `printf '%s\n' "$CONTENT"` instead of `echo "$CONTENT"`.
Line 46 also uses `printf '%s\n' "$CONTEXT"` for the jq input.
The only remaining `echo` (line 47) outputs a fixed JSON string with no user content, which is safe.
Correct.

### README Heuristic Caveat (Round 1 Non-Blocking Fix)

Lines 58-59 of `README.md` now read:

> "The hook skips injection in the source repo (where rules are already loaded via CLAUDE.md `@`-imports) by grepping for `@plugins/cdocs/rules/` in the project's CLAUDE.md.
> This detection is best-effort: if imports are restructured, the hook may inject duplicate rules, causing slightly larger context but no incorrect behavior."

This explains the mechanism and its failure mode clearly. Correct and well-written.

### SKILL.md Version String (Round 1 Non-Blocking Fix)

Lines 50 and 76 of `init/SKILL.md` now use `vX.Y.Z` with the instruction `(use version from plugin.json)`.
Since the SKILL.md is executed by an LLM agent (not a bash script), this templated approach is appropriate: the agent reads `plugin.json` at runtime and substitutes the actual version.
Correct.

### Hook Script End-to-End Review

Walking through the entire `inject-rules.sh` from top to bottom:

1. **Shebang and set flags** (lines 1-13): `set -euo pipefail` is correct for a hook script. Good.
2. **Source-repo skip** (lines 18-21): Checks for `@plugins/cdocs/rules/` in `${PWD}/CLAUDE.md`. The `2>/dev/null` on grep suppresses errors if the file exists but is not readable. The `exit 0` returns a clean exit (no output = no context injection). Correct.
3. **File loop** (lines 25-42): Iterates `"$RULES_DIR"/*.md`. The `[ -f "$rule_file" ] || continue` handles the case where the glob expands to the literal pattern (no matching files). Correct.
4. **Basename extraction** (line 27): `basename "$rule_file" .md` strips the extension. Used in the section header. Correct.
5. **Content reading and stripping** (lines 28-35): `cat` then `printf | awk`. As analyzed above, correct for the primary use case with the noted code-block edge case.
6. **Context accumulation** (lines 36-41): String concatenation with section headers. The double newline before each header provides visual separation. Correct.
7. **JSON output** (lines 44-48): `jq -Rs .` wraps the entire context string in a JSON string with proper escaping. The final `echo` emits the `hookSpecificOutput` JSON. Correct structure matching the CC hook API.
8. **Empty guard** (line 44): `[ -n "$CONTEXT" ]` prevents emitting JSON when no rule files were found. Correct.

No additional issues found in the end-to-end review beyond the code-block `---` stripping noted above.

### Agent Files

All three agents (nit-fix, triage, reviewer) have consistent fallback patterns and NOTE callouts about SessionStart injection.
No changes since round 1.
No issues found.

### AGENTS.md

The plugin-level `AGENTS.md` uses `@rules/*.md` relative imports for all three rule files.
Clean and correct.

## Verdict

**Accept.**

All four round 1 action items have been addressed correctly.
The awk fix resolves the blocking bug: files without frontmatter now pass through unchanged.
The printf, README, and SKILL.md fixes are all clean.

One new non-blocking finding was identified: the awk strips `---` lines from inside fenced code blocks in `frontmatter-spec.md`, degrading the YAML template example.
This is cosmetic (the field definitions section below the template is complete and undamaged) and does not warrant blocking acceptance.

## Action Items

1. [non-blocking] Consider adding code-block awareness to the awk frontmatter stripper (track ` ``` ` lines to toggle a `fence` flag, only match `---` when `fence` is 0). This would preserve the YAML template example in `frontmatter-spec.md`. Low priority: the current behavior is a cosmetic degradation, not a functional failure.

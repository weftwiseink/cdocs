---
name: init
description: Scaffold CLocs directory structure in a project
argument-hint: "[--minimal]"
---

# CLocs Init

Scaffold the CLocs documentation structure in the current project.

## Behavior

1. Create directory structure:
   - `clocs/devlogs/`
   - `clocs/proposals/`
   - `clocs/reviews/`
   - `clocs/reports/`
   - `clocs/_media/`

2. Generate a lightweight README.md in each document subdir with:
   - A brief description of the doc type's purpose.
   - A format summary (required sections, naming convention).
   - A reference to the full skill: "See `/cloc:<type>` for complete authoring guidelines."

3. Create or update `.claude/rules/clocs.md` with core CLocs writing conventions.
   If `.claude/rules/` doesn't exist, create it.
   If the project has a CLAUDE.md, add a reference line: `@.claude/rules/clocs.md`

4. If `$ARGUMENTS` includes `--minimal`, skip README generation and rules file creation.
   Only create the bare directory structure.

## README Templates

### devlogs/README.md
```
# Development Logs

Detailed logs of development work.
See `/cloc:devlog` for complete authoring guidelines.

**Naming:** `YYYY-MM-DD-feature-name.md`

**Key sections:** Objective, Plan, Implementation Notes, Changes Made, Verification.
```

### proposals/README.md
```
# Proposals

Design and solution proposals.
See `/cloc:propose` for complete authoring guidelines.

**Naming:** `YYYY-MM-DD-topic.md`

**Key sections:** BLUF, Objective, Background, Proposed Solution, Design Decisions, Edge Cases, Phases.
```

### reviews/README.md
```
# Reviews

Document reviews with structured findings and verdicts.
See `/cloc:review` for complete authoring guidelines.

**Naming:** `YYYY-MM-DD-review-of-{doc-name}.md`

**Key sections:** Summary Assessment, Section-by-Section Findings, Verdict, Action Items.
```

### reports/README.md
```
# Reports

Findings, status updates, and analysis.
See `/cloc:report` for complete authoring guidelines.

**Naming:** `YYYY-MM-DD-topic.md`

**Key sections:** BLUF, Context/Background, Key Findings, Analysis, Recommendations.
```

## Notes

- Do not overwrite existing files. If `clocs/` already exists, only create missing subdirectories and files.
- Use `mkdir -p` for directory creation (idempotent).
- Check for existing content before writing READMEs to avoid clobbering user modifications.

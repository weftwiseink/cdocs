# CLocs Plugin Development
> BLUF(mjr/setup-docs): Always create a devlog, value brevity and technical precision.

IMPORTANT: Always create a devlog.
IMPORTANT: Follow instructions here and read documentation carefully.
IMPORTANT: Your context window will be automatically compacted as it approaches its limit. Never stop tasks early due to token budget concerns. Always complete tasks fully, even if the end of your budget is approaching.

## Workflow

- Commit regularly using the "conventional commit" format.
- Deduplicating code and docs with the same semantic content is highly desirable.

## CLocs Plugin

This repo is a Claude Code marketplace containing the CLocs plugin under `plugins/clocs/`.
Writing conventions, workflow patterns, frontmatter spec, and doc-type guidelines are in plugin components:

- **Writing conventions**: `@plugins/clocs/rules/writing-conventions.md`
- **Workflow patterns** (parallel agents, subagent dev, checklists): `@plugins/clocs/rules/workflow-patterns.md`
- **Frontmatter spec**: `@plugins/clocs/rules/frontmatter-spec.md`
- **Skills**: `plugins/clocs/skills/{devlog,propose,review,report,status,init}/SKILL.md`

Test the marketplace locally: `/plugin marketplace add .` then `/plugin install cloc@weft-marketplace`

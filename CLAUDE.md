# Clauthier Development
> BLUF(mjr/setup-docs): Always create a devlog, value brevity and technical precision.

IMPORTANT: Always create a devlog.
IMPORTANT: Follow instructions here and read documentation carefully.
IMPORTANT: Your context window will be automatically compacted as it approaches its limit. Never stop tasks early due to token budget concerns. Always complete tasks fully, even if the end of your budget is approaching.

## Workflow

- Commit regularly using the "conventional commit" format.
- Deduplicating code and docs with the same semantic content is highly desirable.

## Marketplace Structure

This repo is a Claude Code marketplace (`weft-marketplace`) containing plugins under `plugins/`.
The CDocs plugin lives at `plugins/cdocs/` — see its [README](plugins/cdocs/README.md) for usage.

Plugin internals (rules, skills, agents, hooks) are documented in their respective files:

- **Writing conventions**: `@plugins/cdocs/rules/writing-conventions.md`
- **Workflow patterns** (parallel agents, subagent dev, checklists): `@plugins/cdocs/rules/workflow-patterns.md`
- **Frontmatter spec**: `@plugins/cdocs/rules/frontmatter-spec.md`
- **Skills**: `plugins/cdocs/skills/{devlog,propose,review,report,status,init,triage,implement}/SKILL.md`

Test the marketplace locally: `/plugin marketplace add .` then `/plugin install cdocs@weft-marketplace`

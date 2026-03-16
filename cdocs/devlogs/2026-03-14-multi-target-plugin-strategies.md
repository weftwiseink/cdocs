---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-14
task_list: research/multi-target-plugins
type: devlog
state: live
status: done
tags: [research, multi-target, plugins, opencode, claude-code, portability]
---

# Devlog: Multi-Target Plugin Strategies Research

> BLUF: Researched and wrote a comprehensive report on strategies for publishing a single cdocs plugin across Claude Code and OpenCode. The dominant pattern is "author in CC format, convert at install time." Skills are already portable; rules nearly so; agents require frontmatter conversion; hooks must be reimplemented per target.

## Work Done

1. Researched current multi-target approaches via web search (March 2026 data).
2. Investigated the GSD project and compound-engineering converter as proven multi-target implementations.
3. Confirmed SKILL.md format convergence: both CC and OpenCode read `.claude/skills/` without modification.
4. Mapped rules portability: OpenCode reads CLAUDE.md as fallback; AGENTS.md is the AAIF standard but CC does not read it natively.
5. Documented plugin manifest differences (plugin.json vs opencode.json/package.json) and agent frontmatter transformation requirements.
6. Assessed MCP as universal extension layer: works identically in both tools with trivial config differences.
7. Surveyed 7 community repos targeting multiple tools.
8. Analyzed AGENTS.md as cross-tool standard under AAIF (Linux Foundation), backed by Anthropic, OpenAI, Block, Google, Microsoft, AWS.

## Artifacts

- `/var/home/mjr/code/weft/clauthier/cdocs/reports/2026-03-14-multi-target-plugin-strategies.md`

## Key Findings

- **Skills**: Already portable. `.claude/skills/` is read by both CC and OC. No action needed.
- **Rules**: Nearly portable. OC reads CLAUDE.md as fallback. Adding an AGENTS.md root file covers the widest tool surface.
- **Agents**: Require frontmatter conversion (tool names from comma-separated to boolean objects, model aliases to full paths, explicit permission blocks).
- **Hooks**: Not portable. CC uses shell-command JSON (9 events); OC uses JS/TS plugin exports (30+ events). Must be reimplemented.
- **MCP**: Fully portable. Only config wrapper differs between tools.
- **Converters exist**: compound-engineering-plugin supports CC-to-10-targets conversion via Bun CLI.

## Verification

Report reviewed against prior parity analysis (2026-03-13-parity-opencode.md) for consistency.
All claims cross-referenced against multiple sources.

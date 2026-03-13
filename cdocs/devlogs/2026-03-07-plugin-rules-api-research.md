---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-07T00:00:00-05:00
task_list: cdocs/plugin-rules-research
type: devlog
state: live
status: complete
tags: [research, plugin-api, rules]
---

# Plugin Rules API Research: Devlog

## Objective

Research whether Claude Code has added an API or mechanism for plugins to declare rules that installing projects can reference via @-mention or otherwise.
The cdocs plugin has important rules files that currently only work in the source repo; making them usable by external installers is on the backburner.

## Plan

1. Search repo for existing research and proposals on this topic.
2. Search Claude Code docs, changelog, and GitHub issues for current plugin rules support.
3. Examine the cdocs plugin structure to understand the current gap.
4. Produce a `/cdocs:report` with findings.

## Implementation Notes

Research conducted via three parallel agents: repo exploration, web/docs research, and plugin structure examination.
Findings consolidated into the report at `cdocs/reports/2026-03-07-plugin-rules-api-research.md`.

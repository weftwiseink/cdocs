---
first_authored:
  by: "@claude-opus-4-5-20251101"
  at: 2026-01-30T19:05:00-05:00
task_list: clauthier/readme-restructure
type: devlog
state: live
status: wip
tags: [documentation, rename, marketplace]
---

# README Restructure: Devlog

## Objective

Restructure documentation for the repo rename from `cdocs` to `clauthier`.
Move the CDocs plugin README into `plugins/cdocs/README.md`, replace the root README with a marketplace-level overview pointing to plugins, and add local installation instructions for dogfooding.

## Plan

1. Update all repo references from `weftwiseink/cdocs` to `weft/clauthier`.
2. Move current root README content into `plugins/cdocs/README.md`, extending it with marketplace add + project-level plugin enablement instructions.
3. Write a new root README for clauthier as a marketplace, with a local installation section.
4. Update CLAUDE.md to reflect the rename.

## Implementation Notes

- Owner changed from `weftwiseink` to `weft` in marketplace and plugin metadata.
- Historical cdocs documents (proposals, devlogs) retain their original `weftwiseink/cdocs` references — these are point-in-time records.
- Project-level `.claude/settings.json` is recommended over user-level because it targets a specific repo and can be committed alongside the project.
- Local installation uses `"source": "local"` with a `"directory"` path, letting changes take effect without reinstall.

## Changes Made

| File | Description |
|------|-------------|
| `plugins/cdocs/.claude-plugin/plugin.json` | Updated owner to `weft`, repo URL to `weft/clauthier` |
| `.claude/settings.json` | Updated marketplace repo to `weft/clauthier` |
| `.claude-plugin/marketplace.json` | Updated owner to `weft`, description to reference `weft` |
| `LICENSE` | Updated copyright holder to `weft` |
| `plugins/cdocs/README.md` | Created — full CDocs plugin docs with marketplace installation (project-level recommended), quick start, skills, rules, hooks, doc types |
| `README.md` | Replaced — now a marketplace-level overview with plugin table, installation, and local installation for dogfooding |
| `CLAUDE.md` | Updated title and structure section for clauthier rename |

## Verification

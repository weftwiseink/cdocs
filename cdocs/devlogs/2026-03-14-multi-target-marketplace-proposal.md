---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-14T12:00:00-07:00
task_list: marketplace/multi-target
type: devlog
state: live
status: done
tags: [proposal, multi-target, opencode]
---

# Multi-Target Marketplace Proposal: Devlog

## Objective

Author a `/cdocs:propose` for migrating the clauthier marketplace to support multi-target publishing (Claude Code + OpenCode).

## Plan

1. Read the propose SKILL.md for template and conventions.
2. Read prior research reports: multi-target strategies, agent harness executive summary, OpenCode parity analysis.
3. Explore the current plugin structure (agents, skills, hooks, rules, manifests).
4. Draft the proposal following the SKILL.md template.
5. Save to `cdocs/proposals/2026-03-14-multi-target-marketplace.md`.

## Implementation Notes

Research inputs synthesized:
- The multi-target strategies report confirmed the "author once, convert at install time" pattern as dominant, with GSD and compound-engineering as proven examples.
- Skills are fully portable (both CC and OC read SKILL.md from `.claude/skills/`).
- Rules are nearly portable (OC reads `.claude/rules/` as a fallback).
- Agents need deterministic frontmatter conversion (model aliases, tool names, permissions).
- Hooks are not portable and must be reimplemented in OC's JS/TS plugin format.

The proposal covers six phases: build script, AGENTS.md integration, OC hooks plugin, npm packaging, CI/CD, and documentation.

## Changes Made

| File | Description |
|------|-------------|
| `cdocs/proposals/2026-03-14-multi-target-marketplace.md` | Full implementation proposal for multi-target publishing |
| `cdocs/devlogs/2026-03-14-multi-target-marketplace-proposal.md` | This devlog |

## Verification

The proposal follows the `/cdocs:propose` template structure (BLUF, Summary, Objective, Background, Proposed Solution, Important Design Decisions, Edge Cases, Test Plan, Verification Methodology, Implementation Phases).
Frontmatter conforms to the cdocs spec.
All findings reference prior research reports.

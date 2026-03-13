---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-13T00:00:00-05:00
task_list: research/agent-harness-alternatives
type: devlog
state: live
status: done
tags: [research, agent-harness, alternatives, landscape]
---

# Agent Harness Alternatives Research

> BLUF: Comprehensive research of 18+ open-source and commercial CLI coding agents that compete with Claude Code, covering features, plugin/rules systems, maturity, and limitations. Output is a structured cdocs report.

## Objective

Research all viable open-source or open agent harness alternatives to Claude Code.
Produce a structured report covering name, URL, tech stack, LLM backends, maturity, differentiating features, plugin/rules/extension systems, and limitations for each tool.

## Plan

1. Web search for current (March 2026) information on each candidate tool.
2. For each tool, gather: GitHub stats, tech stack, LLM support, plugin/rules system, key features, limitations.
3. Compile into a cdocs report at `cdocs/reports/2026-03-13-agent-harness-alternatives.md`.

## Implementation Notes

Research conducted via 30+ web searches covering all tools in the candidate list plus additional tools discovered during research (Roo Code, Forge, Gemini CLI).
Key finding: the landscape has consolidated around a few standards (AGENTS.md, MCP, ACP) that enable cross-tool interoperability.
The "agent harness" framing (vs. just "coding agent") is a 2026 industry shift recognizing that the infrastructure wrapping the model matters more than the model itself.

## Changes Made

| File | Description |
|------|-------------|
| `cdocs/reports/2026-03-13-agent-harness-alternatives.md` | Full research report |
| `cdocs/devlogs/2026-03-13-agent-harness-alternatives-research.md` | This devlog |

## Verification

Web search results cross-referenced across multiple sources for each tool.
Star counts and feature claims verified against GitHub repos and official documentation where possible.

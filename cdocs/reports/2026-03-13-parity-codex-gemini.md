---
first_authored:
  by: "@claude-sonnet-4-6"
  at: 2026-03-13
type: report
report_type: analysis
state: final
status: complete
tags: [research, parity, codex-cli, gemini-cli, claude-code]
---

# Feature Parity: Codex CLI and Gemini CLI vs Claude Code

> BLUF: Claude Code leads on composability (hooks, plugin marketplace, subagent coordination).
> Gemini CLI leads on model economics (free tier, 1M context at no cost).
> Codex CLI leads on OS-level sandbox hardness.
> Neither competitor matches CC's rules/plugin reusability story — but both are closing the gap, and a cross-platform skills standard is emerging faster than expected.

## Quick Reference

| Dimension | Codex CLI | Gemini CLI |
|---|---|---|
| Stars (as of Mar 2026) | ~65K | ~97K |
| Language | Rust | TypeScript |
| License | Apache 2.0 | Apache 2.0 |
| Model lock-in | OpenAI only (o3, o4-mini, GPT-4.1, codex-1) | Gemini only (2.5 Pro, Flash, Flash-Lite) |
| Free tier | No (API key required) | Yes (Gemini 2.5 Pro, rate-limited) |
| Context window | Model-dependent | 1M tokens (Gemini 2.5 Pro) |

---

## Parity Matrix

Rating scale: **parity** / **partial** / **absent** / **ahead**

### Core Agentic Capabilities

| CC Feature | Codex Rating | Codex Notes | Gemini Rating | Gemini Notes |
|---|---|---|---|---|
| Background agents | partial | Cloud-based Automations in beta; desktop app shows parallel sessions but no Ctrl+B equivalent | partial | Subagents exist but true parallelization not yet implemented; open feature request as of Jan 2026 |
| Task lists (TodoWrite) | partial | No native task-tracking UI; multi-agent CSV fan-out is the closest analog | absent | No equivalent structured task tracking |
| Subagents / agent teams | partial | Multi-agent experimental via `/experimental`; Agents SDK integration for spawning workers | partial | Subagents (experimental) exist; sequential only; parallel dispatch a stated roadmap item |
| Plan mode | absent | No dedicated pre-execution planning phase | absent | No equivalent; the 1M context window is used for upfront loading rather than phased planning |
| Extended thinking | absent | o3/o4-mini use chain-of-thought internally; not user-surfaced or configurable | absent | No user-facing reasoning budget control |
| Memory system | partial | `~/.codex/AGENTS.md` as persistent global context; no `/memory` commands | partial | `/memory add`, `/memory show`, `/memory refresh`; `save_memory` tool writes to `~/.gemini/GEMINI.md`; project-scope isolation is a known bug (#6371) |
| Context management | partial | AGENTS.md hierarchy + `@file` inline injection | parity | `@` file injection, `/memory` commands, hierarchical GEMINI.md loading; 1M window reduces pressure |
| Remote / cloud execution | partial | Codex Automations (cloud triggers, continuous background); Codex app for managing cloud sessions | absent | No remote execution model; all local |
| Multi-model support | absent | OpenAI models only; no mid-session model switching | absent | Gemini models only; Gemini Flash available as a lighter option |

### Customization and Rules

| CC Feature | Codex Rating | Codex Notes | Gemini Rating | Gemini Notes |
|---|---|---|---|---|
| Project instructions file | parity | AGENTS.md; hierarchical with override semantics | parity | GEMINI.md; hierarchical with identical multi-level loading |
| Global instructions | parity | `~/.codex/AGENTS.md` | parity | `~/.gemini/GEMINI.md` |
| Non-negotiable system rules | partial | AGENTS.override.md provides priority override but is user-editable | ahead | SYSTEM.md (via `GEMINI_SYSTEM_MD`) fully replaces the system prompt; admin-tier TOML policy applies even above user config |
| Hooks (pre/post tool-use) | partial | 4 hook events: `SessionStart`, `Stop`, `AfterAgent`, `AfterToolUse` (experimental as of v0.114.0) | absent | No hook system; tool exclusion lists are the bluntest equivalent |
| Permission / sandbox modes | parity | OS-level sandbox (Seatbelt/Landlock/seccomp); approval modes (`--full-auto`, `--ask-for-approval`); granular per-command permission requests | partial | TOML policy engine with `allow`/`deny` rules, MCP tool annotations (`readOnlyHint`, `destructiveHint`), `mcpName = "*"` wildcard; no OS-level isolation |
| Custom slash commands | partial | Skills can be invoked via `/skills` or `$`; not pure slash commands | parity | TOML-defined commands at `~/.gemini/commands/` or `<project>/.gemini/commands/`; namespaced (e.g., `/git:commit`) |

### Extensibility

| CC Feature | Codex Rating | Codex Notes | Gemini Rating | Gemini Notes |
|---|---|---|---|---|
| MCP support | parity | STDIO + streaming HTTP; auto-launched at session start; managed via `codex mcp` CLI | parity | MCP servers supported; `mcpName = "*"` wildcard in policy rules |
| Plugin marketplace | partial | Plugin system added (install, list, uninstall); no official marketplace; third-party marketplaces emerging (SkillsMP, Skills.sh, ClawHub) | absent | No marketplace concept; extensions are self-hosted GitHub repos; cross-conversion tool from CC plugins exists but is unofficial |
| Skills / reusable bundles | partial | `SKILL.md` + optional scripts; cross-platform standard emerging; auto-invoked by task match or explicit `$` | partial | Extensions bundle commands + context + MCP; distributable via GitHub; no auto-invocation |
| Hooks for CI/CD integration | partial | `AfterAgent` and `AfterToolUse` hooks; `SessionStart` stdout feeds model context | absent | No hooks; must wrap CLI externally |

---

## Deep Dive: Rules and Plugin Reusability

This is the axis most relevant to the cdocs project. Each question from the brief is answered in order.

### 1. How does Codex CLI's multi-level AGENTS.md work for org-wide standards?

Codex builds an instruction chain once per session using a strict three-tier hierarchy:

1. **Global** (`~/.codex/AGENTS.md` or `AGENTS.override.md`) — personal baseline
2. **Project scope** — walks from git root to CWD; reads `AGENTS.md` or `AGENTS.override.md` in each directory
3. **Concatenation order** — files closer to CWD appear later and therefore override earlier guidance

The override variant (`AGENTS.override.md`) exists at both global and project levels.
It lets a team ship an org-standard `AGENTS.md` in the repo root while an individual developer can place `AGENTS.override.md` in their working directory for personal overrides without modifying the shared file.

**Org-wide enforcement gap:** There is no admin tier.
An org cannot prevent developers from placing a `~/.codex/AGENTS.override.md` that supersedes repo-level rules.
The override is honored by position in the concatenation chain, not by trust level.
This is a meaningful difference from Gemini's TOML policy engine.

**Known bug:** The global location was not read by default until recently; issue #8759 (openai/codex) tracked this regression.

### 2. How does Gemini's TOML policy engine compare to CC's permission system?

These are architecturally distinct approaches to the same problem.

**Gemini TOML policy engine:**
- Policies live in `.toml` files loaded from three directories: Default (baked in), User (`~/.gemini/`), and Admin (org-configured)
- Admin-tier policies load before User-tier and cannot be overridden by users
- Rules can target specific tools, all tools from an MCP server (`mcpName = "*"`), or tools with specific semantic annotations (`readOnlyHint`, `destructiveHint`, `idempotentHint`)
- This is a **declarative allow/deny** model: the policy file says what is permitted, not what must be approved

**Claude Code permission system:**
- Application-layer: read-only by default, explicit approval for modifications
- `hooks` provide 17 programmable events (PreToolUse, PostToolUse, etc.) allowing arbitrary shell logic before/after any tool invocation
- OS-level isolation (filesystem + network sandboxing) layered on top
- Permission modes (`--dangerously-skip-permissions`, auto-approval lists) are user-controlled; no admin override tier

**Key difference:** Gemini's admin tier is the more powerful org-enforcement story.
A security team can deploy an admin-level TOML that silently blocks destructive tools across all users without requiring user cooperation.
CC's hook system is more powerful for *programmable* logic (run a linter after every file write) but has no admin enforcement tier.
Codex's OS-level sandbox (Seatbelt, Landlock, seccomp) is the hardest boundary — kernel-enforced, not bypassable by model output — but is coarse-grained and not policy-declarative.

### 3. Can either tool package and distribute reusable configuration bundles?

**Codex CLI:** Yes, partially.
A Codex skill is a directory containing `SKILL.md` plus optional scripts.
Skills can be invoked explicitly via `$skill-name` or auto-selected when the task description matches.
Distribution is currently manual (copy directory into `~/.codex/skills/` or a project-local `skills/` directory).
A plugin install system was added recently, but there is no official marketplace.
Third-party marketplaces (SkillsMP, Skills.sh, ClawHub) have emerged; as of February 2026 Skills.sh indexes 83K skills across 18 agents including Codex.
A cross-platform skills standard is solidifying: CC introduced `SKILL.md` in late 2025, Codex adopted the same format, and Skills.sh supports both.

**Gemini CLI:** Yes, via Extensions.
An Extension is a self-contained directory that bundles custom commands (TOML), context files, and MCP server configs.
Distribution is via GitHub URL: `gemini extension install github:org/repo`.
There is no official marketplace; the Extensions gallery at geminicli.com is community-maintained.
Extensions do not include a concept equivalent to `SKILL.md` auto-invocation — they must be explicitly activated.
An unofficial tool converts CC plugins to Gemini extensions (and vice versa), but it is not officially supported.
A GitHub issue (#17505) proposes a formal bridge to import CC plugin bundles into Gemini; it remains open.

**Comparison to CC:** Claude Code's plugin marketplace is the most mature distribution story: decentralized (any git repo with correct structure becomes a marketplace), installable via `/plugin marketplace add <url>` and `/plugin install <name>@<marketplace>`, with 340+ plugins as of early 2026.
Neither Codex nor Gemini has an equivalent first-party marketplace infrastructure.

### 4. How do Codex skills compare to CC skills?

Both use `SKILL.md` as the manifest format — the format originated with CC and Codex adopted it.

| Dimension | CC Skills | Codex Skills |
|---|---|---|
| Manifest | `SKILL.md` with `name`, `description` | `SKILL.md` with `name`, `description` |
| Invocation | `/skill-name` slash command, or auto-match | `$skill-name` or auto-match by description |
| Bundled scripts | Yes (arbitrary files in skill directory) | Yes (scripts/ directory) |
| Plugin packaging | Bundled inside CC plugins; installable from marketplace | Plugin system added; no first-party marketplace |
| Agent integration | Skills can declare hooks, reference agents | Skills invoke scripts; no hook integration |
| Distribution | `/plugin install` from any marketplace URL | Manual copy or emerging third-party marketplaces |

The functional model is nearly identical.
CC's advantage is the plugin packaging layer that wraps skills into installable, versioned bundles.
Codex skills are currently atomic and not bundled beyond manual directory sharing.

### 5. Is Gemini's SYSTEM.md more powerful than CLAUDE.md?

This depends on what "powerful" means.

**SYSTEM.md (Gemini) is more powerful for enforcement.**
`GEMINI_SYSTEM_MD` points to an external file that *completely replaces* the built-in system prompt — a full substitution, not a merge.
This means an org can ship a hardened system prompt that overrides Gemini CLI's defaults including its safety framing and tool-use mechanics.
Combined with admin-tier TOML policies, this is the strongest org-enforcement story of the three tools.
The risk is that misuse of SYSTEM.md removes Gemini's built-in guardrails; the user is responsible for re-implementing them.

**CLAUDE.md (CC) is more powerful for composability.**
`CLAUDE.md` is additive: it appends to CC's built-in system context rather than replacing it.
The `@import` syntax chains multiple rules files, enabling modular factoring (per-repo, per-directory, per-plugin).
The auto-memory system can promote conversation learnings into persistent CLAUDE.md entries.
CC's hooks provide programmatic injection at every tool boundary — something SYSTEM.md cannot do.

**Codex AGENTS.md** sits between the two: additive like CLAUDE.md, hierarchical with override semantics, but no admin enforcement tier and no programmatic hook integration.

**Bottom line for cdocs specifically:** The CC plugin rules gap (reported in `2026-03-07-plugin-rules-api-research.md`) has no equivalent in either competitor.
Gemini extensions can bundle GEMINI.md context files that load automatically — effectively what CC plugin rules would do if feature request #14200 were implemented.
This is one area where Gemini's extension model is currently ahead of CC's plugin model.

---

## Synthesis: Where Each Tool Leads

**Claude Code ahead:**
- Hook system depth (17 events vs Codex's 4, vs Gemini's 0)
- Plugin marketplace infrastructure (decentralized, 340+ plugins)
- Subagent orchestration maturity (Agent Teams research preview, Swarms experimental)
- Plan mode + extended thinking surface area
- Memory system ergonomics (`/memory` commands, auto-memory)
- Multi-model flexibility (Opus/Sonnet/Haiku switching mid-session)

**Codex CLI ahead:**
- OS-level sandbox hardness (kernel-enforced via Seatbelt/Landlock/seccomp)
- Sandbox granularity (per-command permission escalation requests)
- Reasoning model depth (o3/o4-mini chain-of-thought, though not user-surfaced)

**Gemini CLI ahead:**
- Model economics (Gemini 2.5 Pro free tier; 1M context at zero cost)
- Admin-tier policy enforcement (TOML policy engine with org override capability)
- SYSTEM.md for full system prompt replacement (org hardening use case)
- Extension bundling of context files (closer to what CC plugin rules would provide)
- Context window size (1M tokens vs CC's 1M via Opus 4.6, vs Codex's model-dependent limit)

**Effectively at parity:**
- MCP support (all three)
- Project-level instruction files (AGENTS.md / GEMINI.md / CLAUDE.md)
- Custom slash commands / skills invocation
- Basic multi-agent orchestration (all experimental or partial)

---

## Sources

- [Codex CLI features](https://developers.openai.com/codex/cli/features)
- [Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md/)
- [Agent Skills — Codex](https://developers.openai.com/codex/skills/)
- [Codex changelog](https://developers.openai.com/codex/changelog/)
- [Codex multi-agents](https://developers.openai.com/codex/multi-agent/)
- [Codex security](https://developers.openai.com/codex/security/)
- [Codex agent approvals & security](https://developers.openai.com/codex/agent-approvals-security/)
- [Gemini CLI documentation](https://geminicli.com/docs/)
- [Gemini CLI policy engine](https://geminicli.com/docs/reference/policy-engine/)
- [Provide context with GEMINI.md files](https://geminicli.com/docs/cli/gemini-md/)
- [System Prompt Override (GEMINI_SYSTEM_MD)](https://geminicli.com/docs/cli/system-prompt/)
- [Gemini CLI custom commands](https://geminicli.com/docs/cli/custom-commands/)
- [Gemini CLI memory tool](https://geminicli.com/docs/tools/memory/)
- [Gemini CLI subagents (experimental)](https://geminicli.com/docs/core/subagents/)
- [Policy Engine Enhancements for MCP — GitHub issue #19655](https://github.com/google-gemini/gemini-cli/issues/19655)
- [Parallel Execution of Subagents — GitHub issue #17749](https://github.com/google-gemini/gemini-cli/issues/17749)
- [Bridge Ecosystems: Import External Plugin Bundles into Gemini CLI — GitHub issue #17505](https://github.com/google-gemini/gemini-cli/issues/17505)
- [Codex CLI AGENTS.md global location bug — GitHub issue #8759](https://github.com/openai/codex/issues/8759)
- [Claude Code Sandbox Guide (2026)](https://claudefa.st/blog/guide/sandboxing-guide)
- [Anthropic: making Claude Code more secure and autonomous](https://www.anthropic.com/engineering/claude-code-sandboxing)
- [Claude Code subagents docs](https://code.claude.com/docs/en/sub-agents)
- [Codex CLI vs Claude Code 2026 Architecture Deep Dive](https://blakecrosley.com/blog/codex-vs-claude-code-2026)
- [Claude Code Plugins vs Gemini CLI Extensions: A Comparison](https://harishgarg.com/claude-code-plugins-vs-gemini-cli-extensions-a-comparison)
- [Agent Skills Are the New npm: AI Package Manager Marketplace 2026](https://www.buildmvpfast.com/blog/agent-skills-npm-ai-package-manager-2026)

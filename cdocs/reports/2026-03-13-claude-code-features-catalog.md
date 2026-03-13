---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-13
type: report
report_type: analysis
state: final
status: complete
tags: [research, claude-code, features, technical-catalog]
---

# Claude Code Major Features Catalog (as of March 2026)

> BLUF: Claude Code has evolved from a terminal chat tool (Feb 2025) into a full agentic development platform with multi-agent orchestration, a plugin ecosystem, IDE-native integrations, and cloud/remote execution.
> This report catalogs the 16 most architecturally significant features, with introduction dates, maturity assessments, and known limitations.

## Timeline Overview

| Date | Milestone |
|------|-----------|
| Feb 2025 | Research preview launch: terminal tool with file editing and bash |
| May 2025 | General availability alongside Claude 4 |
| Aug 2025 | Chrome extension for browser control |
| Oct 2025 | Web version, plugins public beta |
| Nov 2025 | $1B annualized revenue; sandboxing, background agents |
| Dec 2025 | Slack integration (research preview), GitHub Actions support |
| Jan 2026 | Skills/SKILL.md, session forking, Cowork research preview |
| Feb 2026 | Opus 4.6, agent teams, fast mode, auto-memory, remote control, 1M context |
| Mar 2026 | Effort level simplification, /context suggestions, memory leak fixes |

## Feature Catalog

### 1. Background Agents

**Introduced:** ~v2.0.60 (Nov 2025), formalized in v2.1.32+ (Feb 2026)
**Problem:** Long-running tasks (test suites, migrations, builds) block the interactive session.
**How it works:** Agents defined with `background: true` in frontmatter run in a separate context.
Press Ctrl+B to background a running task, Ctrl+F to manage active background agents.
Each agent has its own token budget, status display, and progress tracking.
**Maturity:** Stable. Widely used in production for migrations and CI-like workflows.
**Limitations:** Background agents share the same filesystem, so concurrent writes can conflict.
No built-in coordination primitive between background agents and the foreground session beyond status polling.

### 2. TodoWrite (Task Tracking)

**Introduced:** Early 2025 (simple checklists), upgraded Jan 2026 (v2.1.16+, dependency tracking)
**Problem:** Complex multi-step tasks need visible progress and structured tracking.
**How it works:** The `TodoWrite` tool creates and manages a checklist displayed in the terminal UI.
Items have three states: `pending`, `in_progress`, `completed`.
The Jan 2026 upgrade added dependency tracking, blockers, and multi-session persistence via `~/.claude/tasks/`.
Four specialized tools (`TaskCreate`, `TaskUpdate`, `TaskGet`, `TaskList`) replaced the old system.
**Maturity:** Stable. Core tool available to all agents and subagents.
**Limitations:** Task state is local to the machine.
No cross-machine sync.
Dependency tracking is best-effort: Claude respects it but it is not enforced at the system level.

### 3. Subagents (Task Tool)

**Introduced:** v2.1.32 (Feb 2026)
**Problem:** Single-context execution limits parallelism and creates context bloat on large tasks.
**How it works:** The `Task` tool spawns child agents, each running in an isolated context window with a custom system prompt.
Up to 7 subagents run simultaneously.
Subagents inherit all tools from the parent except `Task` itself: no nested spawning.
Custom subagents are defined as markdown files in `.claude/agents/` with YAML frontmatter specifying `name`, `model`, `tools`, `memory`, and `isolation` settings.
Results flow back as summaries, keeping the parent's context clean.
**Maturity:** Stable for fan-out patterns (parallel file analysis, multi-module changes).
**Limitations:** No nested subagent spawning (flat hierarchy only).
Subagents cannot communicate with each other, only with the parent.
Each subagent consumes a full context window worth of tokens.

### 4. Skills System

**Introduced:** v2.1.0 (Jan 2026, hot-reload), v2.1.3 (merged slash commands and skills)
**Problem:** Repeatable workflows (deploy, review, report generation) need to be encapsulated and shareable.
**How it works:** Skills are folders containing a `SKILL.md` file with YAML frontmatter and instructions.
Placed in `~/.claude/skills/` (user-level) or `.claude/skills/` (project-level).
Skills appear in the `/` slash-command menu by default.
Claude detects relevant skills automatically from conversation context, or they can be invoked explicitly.
Frontmatter supports: `name`, `description`, `tools`, `allowed-tools`, `context` (fork to subagent), `agent`, `hooks`.
Skills load on demand: descriptions are visible at session start, full content loads only on invocation.
**Maturity:** Stable. Large community ecosystem (1000+ published skills).
**Limitations:** `disable-model-invocation: true` is needed to prevent auto-loading for context-heavy skills.
No formal versioning within skills: updates overwrite in place.

### 5. Plugin / Marketplace System

**Introduced:** Public beta Oct 2025, stable by Jan 2026 (v2.1.51)
**Problem:** Sharing and distributing skills, agents, hooks, and MCP configs across teams and the community.
**How it works:** Plugins are lightweight packages defined by a `plugin.json` manifest.
Each plugin can contain any combination of: commands, agents, skills, hooks, MCP servers, output styles, LSP servers.
Sources: git repos, npm packages, local file paths.
Marketplaces are catalogs of plugins.
The official Anthropic marketplace (`claude-plugins-official`) is built in.
Install: `/plugin marketplace add <url>`, then `/plugin install <name>`.
A trust model gates hook and MCP execution from untrusted plugins.
**Maturity:** Stable. Active community marketplaces with hundreds of plugins.
**Limitations:** No `rules` field in `plugin.json` (open feature request [#14200](https://github.com/anthropics/claude-code/issues/14200)).
Plugin updates require manual reinstall or reload (`/reload-plugins`).
No dependency resolution between plugins.

### 6. Hooks System

**Introduced:** v2.1.0 (Jan 2026)
**Problem:** Enforcing quality gates, automating side effects, and reacting to agent lifecycle events without manual intervention.
**How it works:** Hooks are shell commands (or HTTP endpoints, as of v2.1.63) triggered at defined events.
Events: `SessionStart`, `SessionEnd`, `PreToolUse`, `PostToolUse`, `Stop`, `TaskCompleted`, `ConfigChange` (v2.1.49), `InstructionsLoaded` (v2.1.69).
`PreToolUse` hooks can return `ask`, `deny`, or `allow` decisions (exit code 2 blocks execution).
Hooks can inject `additionalContext` at session start.
Configured in `.claude/settings.json`, skill frontmatter, or plugin manifest.
**Maturity:** Stable. Used in enterprise for policy enforcement and audit logging.
**Limitations:** `InstructionsLoaded` is observe-only: hooks cannot inject additional rules dynamically.
Hook timeout defaults are conservative (30s).
Error handling is silent by default: a failing hook does not surface diagnostics to the user.

### 7. MCP (Model Context Protocol) Servers

**Introduced:** v2.1.0+ (Jan 2026)
**Problem:** Connecting Claude to external systems (databases, APIs, SaaS tools) requires a standard protocol.
**How it works:** MCP is an open standard for AI-to-tool communication.
Claude Code acts as an MCP client, connecting to servers that expose tools, resources, and prompts.
Configure via `--mcp-config`, `.claude/settings.json`, or plugin manifest.
OAuth support is pre-configured for Slack and GitHub, with manual token fallback.
When >10% of context is consumed by MCP tool descriptions, Claude auto-disables them and uses `MCPSearch` for on-demand discovery (v2.1.7).
The `/mcp` command (v2.1.70) provides enable/disable, reconnect, and per-server context cost visibility.
**Maturity:** Stable and widely adopted. MCP is becoming an industry standard beyond Anthropic.
**Limitations:** Each connected MCP server adds tool definitions to every request, consuming context.
Server reliability varies: community MCP servers can be flaky.
Polling rate was excessive (fixed in v2.1.70: 300x server load reduction via 10-minute intervals).

### 8. Plan Mode

**Introduced:** v2.1.0 (Jan 2026)
**Problem:** Jumping straight to code changes without analysis leads to poor architectural decisions.
**How it works:** Activated via `Shift+Tab` (cycle to "Plan mode") or the `/plan` command.
Restricts Claude to read-only tools only.
Claude analyzes the codebase, reasons through the problem, and produces a structured plan.
The plan persists across messages (auto-loaded, cleared on `/clear`).
In VS Code (v2.1.70), plans render as native markdown documents with inline commenting.
Can be combined with "ultrathink" prompting for deep architectural analysis.
**Maturity:** Stable. Particularly effective for complex refactors and unfamiliar codebases.
**Limitations:** Plans are ephemeral: they do not persist across sessions unless manually saved.
No formal plan-to-execution pipeline: transitioning from plan to implementation is conversational.

### 9. Extended Thinking / Adaptive Reasoning

**Introduced:** Extended thinking since Claude 3.7 Sonnet (early 2025). Adaptive reasoning with Opus 4.6 (Feb 2026).
**Problem:** Complex reasoning tasks benefit from step-by-step thinking, but fixed token budgets waste resources on simple tasks.
**How it works:** Extended thinking is enabled by default.
Visible in verbose mode (Ctrl+O).
With Opus 4.6, thinking uses adaptive reasoning: the model dynamically allocates thinking tokens based on the effort level setting (low/medium/high).
Other models use a fixed budget of up to 31,999 tokens.
Thinking can be disabled via `/config` or Alt+T.
`MAX_THINKING_TOKENS` environment variable provides fine-grained control.
**Maturity:** Stable. Adaptive reasoning (Opus 4.6 only) is a significant improvement over fixed budgets.
**Limitations:** Thinking tokens count against the output budget.
Thinking content is not visible in the default (non-verbose) mode, making it opaque.
Effort levels are model-dependent: only Opus 4.6 supports adaptive reasoning.

### 10. IDE Integrations

**Introduced:** VS Code extension ~v2.1.16 (Jan 2026), JetBrains integration Sep 2025 (via JetBrains AI)
**Problem:** Terminal-only usage lacks visual context, diff review, and IDE-native workflows.
**How it works:**
- **VS Code:** Native extension providing graphical chat, inline diff review, @-mention files with line ranges, multi-tab conversations, session history, plan markdown view, and plugin management.
  Automatic context sharing: Claude sees the active file, selection, and Problems panel.
  Remote session support for SSH and container environments.
- **JetBrains:** Claude Agent integrated directly into JetBrains AI chat.
  No separate plugin install: included in JetBrains AI subscription.
  Full access to IDE capabilities including code navigation and refactoring.
**Maturity:** VS Code is the primary IDE target, with the most features. JetBrains is stable but less feature-rich.
**Limitations:** VS Code extension and terminal CLI can have feature parity gaps (some features land in CLI first).
JetBrains integration depends on JetBrains AI subscription pricing and availability.

### 11. Memory System

**Introduced:** CLAUDE.md since launch (Feb 2025). Auto-memory v2.1.59 (Feb 2026). Memory scopes v2.1.49.
**Problem:** Each session starts fresh. Project conventions, build commands, and workflow preferences are lost.
**How it works:** Two complementary systems:
- **CLAUDE.md files:** Markdown files with persistent instructions, loaded at session start.
  Scopes: project root, `.claude/`, `~/.claude/`, organization-level.
  Supports `@path/to/file` includes for modular rules.
  Editable via `/memory` command or directly.
- **Auto-memory:** Claude saves notes automatically as it works: build commands, debugging insights, code patterns, style preferences.
  Stored in `~/.claude/projects/<project>/memory/`.
  First 200 lines of MEMORY.md loaded each session.
  Toggle via `/memory`.
  Custom directory via `autoMemoryDirectory` setting (v2.1.74).
- **Memory scopes:** Agents can specify `memory: user`, `project`, or `local` (v2.1.49).
**Maturity:** CLAUDE.md is stable and widely adopted. Auto-memory is stable but can accumulate noise.
**Limitations:** Auto-memory has no curation: entries accumulate without pruning.
Only first 200 lines of MEMORY.md are loaded, so large memory files get truncated.
No cross-machine memory sync.

### 12. Permission Modes and Sandboxing

**Introduced:** Permission modes since launch (Feb 2025). OS-level sandboxing Nov 2025.
**Problem:** Balancing agent autonomy with safety on a developer's machine.
**How it works:**
- **Four permission modes:** Default (ask for everything), Auto-accept edits (files without asking, commands still gated), Plan mode (read-only), Bypass (no confirmations, for CI pipelines).
- **Granular rules:** Wildcard patterns in `.claude/settings.json` for trusted commands: `Bash(npm *)`, `Bash(git * main)`.
- **OS-level sandboxing:** macOS uses Seatbelt, Linux uses bubblewrap (bwrap).
  Filesystem isolation: Claude can only access specified directories.
  Network isolation: internet access only through a unix socket proxy.
  Sandboxing reduces permission prompts by 84% in internal usage.
- **Managed settings:** macOS plist / Windows Registry for admin-enforced policies (v2.1.51).
**Maturity:** Permission modes are stable and mature. Sandboxing is stable on supported platforms.
**Limitations:** Sandboxing only applies to Bash commands and their child processes, not to file operations via built-in tools.
Sandboxing is opt-in and requires bwrap on Linux.
Remote actions (API calls, deployments) cannot be sandboxed or checkpointed.

### 13. Git Integration

**Introduced:** Since launch (Feb 2025), enhanced continuously. Worktrees v2.1.49, `--from-pr` v2.1.20.
**Problem:** Git workflows (commit, branch, PR, conflict resolution) are repetitive and context-heavy.
**How it works:** Claude uses the `gh` CLI for GitHub operations.
- **Commits:** Reads full diff, generates contextual commit messages, asks for approval.
- **PRs:** Analyzes all branch commits, writes title/summary/test checklist, creates via `gh pr create`.
- **Worktrees:** `--worktree` / `-w` flag creates isolated git worktree for parallel branches.
- **GitHub Actions:** `claude-code-action` runs Claude as a CI agent, triggered by issues or PRs.
- **`--from-pr`:** Links a session to a PR for context.
- **Conflict resolution:** Analyzes conflicting code and suggests resolutions.
**Maturity:** Stable. Git is a first-class citizen in Claude Code's design.
**Limitations:** Force push protection and destructive command guards are convention-based (system prompt), not enforced at the tool level.
GitHub Actions execution depends on runner configuration and secrets management.

### 14. Multi-Model Support

**Introduced:** Model switching since mid-2025 (Alt+P shortcut in Dec 2025). `opusplan` alias ~Jan 2026.
**Problem:** Different tasks have different cost/quality tradeoffs: expensive models for architecture, cheap models for boilerplate.
**How it works:**
- **Runtime switching:** `/model <name>` during a session, or `claude --model <name>` at start.
- **Available models:** Opus 4.6 (complex reasoning, 1M context), Sonnet 4.6 (daily coding, 1M context), Haiku 4.5 (quick tasks, ~3x cheaper).
- **`opusplan` alias:** Uses Opus for plan mode reasoning, auto-switches to Sonnet for execution.
- **Model overrides:** `modelOverrides` setting for custom provider model IDs (e.g., Bedrock ARNs).
- **Fast mode:** Opus 4.6 at 2.5x output speed, 6x standard pricing. Toggle with `/fast`.
- **Effort levels:** Low/Medium/High control thinking depth. Medium is default for Max/Team plans.
**Maturity:** Stable. Model switching is seamless within sessions.
**Limitations:** Not all models support all features: adaptive reasoning is Opus 4.6 only.
Fast mode pricing (6x) makes it expensive for sustained use.
No automatic model selection based on task complexity: user must choose.

### 15. Context Window Management

**Introduced:** Auto-compact since mid-2025. 1M context v2.1.50 (Feb 2026). `/context` command v2.1.47.
**Problem:** Long agentic sessions exhaust the context window, losing early instructions and degrading quality.
**How it works:**
- **Auto-compact:** Triggers at ~83.5% capacity (~167K tokens for a 200K window). Summarizes conversation history, preserves requests and key code snippets, clears older tool outputs.
- **Manual compact:** `/compact [focus]` with optional focus directive (e.g., `/compact focus on the API changes`).
- **1M context:** Opus 4.6 and Sonnet 4.6 support full 1M token windows.
- **`/context` command:** Shows breakdown by tool, skill, MCP, with optimization suggestions (v2.1.74).
- **Prompt cache:** ~12x cost reduction on cached prompts (v2.1.70).
- **Context editing API:** `clear_tool_uses_20250919` strategy clears old tool results automatically.
- **Compact instructions:** A "Compact Instructions" section in CLAUDE.md controls what is preserved during compaction.
**Maturity:** Stable. The 1M window with Opus 4.6 significantly reduces compaction frequency.
**Limitations:** Compaction can lose nuanced instructions from early in the conversation.
No user control over which specific messages are preserved vs. summarized.
MCP tool definitions consume context on every request, even when unused.

### 16. Remote and Cloud Execution

**Introduced:** GitHub Actions Dec 2025. Cloud VMs ~Feb 2026. Remote Control Feb 24, 2026.
**Problem:** Local-only execution limits CI/CD integration, team collaboration, and mobile access.
**How it works:** Three execution environments:
- **Local:** Default. Full access to files, tools, and environment.
- **Cloud:** Anthropic-managed VMs. Work on repos without local checkout. Used by Claude Code on the web (`claude.ai/code`) and Slack integration.
- **Remote Control:** Run `claude remote-control` in terminal. Continue the session from phone, tablet, or browser via `claude.ai/code` or Claude mobile app. Code executes locally: only chat messages and tool results flow through an encrypted bridge.
- **GitHub Actions:** `claude-code-action` runs Claude as a CI agent in GitHub runners. Triggered by issues, PRs, or manual dispatch. Posts findings directly to PRs.
- **Slack:** @Claude in Slack triggers a Claude Code web session. Context from channel/thread messages. Status updates posted back to thread.
**Maturity:** GitHub Actions is stable. Remote Control is stable but limited to one connection per session. Cloud VMs and Slack integration are newer and less battle-tested.
**Limitations:** Remote Control ends if the terminal process stops.
Cloud VMs have limited environment customization.
Slack integration requires Team/Enterprise plan.

## Bonus: Agent Teams (Research Preview)

**Introduced:** v2.1.32 (Feb 2026), research preview.
**Problem:** Complex tasks with multiple independent workstreams (frontend, backend, tests) benefit from true parallel execution with coordination.
**How it works:** A lead agent delegates to multiple teammates, each with its own context window.
Teammates work independently and communicate with each other (not just with the lead).
Enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.
Best for: research and review, new modules, debugging with competing hypotheses, cross-layer changes.
**Maturity:** Research preview. Experimental flag required. Token-intensive.
**Limitations:** Significantly higher token usage than single sessions (each teammate has a full context window).
Coordination overhead can make simple tasks slower than a single session.
Not all task shapes benefit: routine tasks are better served by a single agent.

## Sources

- [Claude Code Changelog (official)](https://code.claude.com/docs/en/changelog)
- [How Claude Code Works](https://code.claude.com/docs/en/how-claude-code-works)
- [Claude Code GitHub Releases](https://github.com/anthropics/claude-code/releases)
- [Anthropic: Enabling Claude Code to Work More Autonomously](https://www.anthropic.com/news/enabling-claude-code-to-work-more-autonomously)
- [Anthropic Engineering: Claude Code Sandboxing](https://www.anthropic.com/engineering/claude-code-sandboxing)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [Claude Code Plugins Documentation](https://code.claude.com/docs/en/plugins)
- [Claude Code Memory Documentation](https://code.claude.com/docs/en/memory)
- [Claude Code Model Configuration](https://code.claude.com/docs/en/model-config)
- [Claude Code Fast Mode](https://code.claude.com/docs/en/fast-mode)
- [Claude Code Remote Control](https://code.claude.com/docs/en/remote-control)
- [Claude Code Agent Teams](https://code.claude.com/docs/en/agent-teams)
- [Claude Code Sandboxing](https://code.claude.com/docs/en/sandboxing)
- [Claude Code GitHub Actions](https://code.claude.com/docs/en/github-actions)
- [Claude Code Subagents](https://code.claude.com/docs/en/sub-agents)
- [Adaptive Thinking (API Docs)](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking)
- [ClaudeLog: Claude Code Changelog](https://claudelog.com/claude-code-changelog/)

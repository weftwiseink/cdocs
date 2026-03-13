---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-13T00:00:00-05:00
task_list: research/agent-harness-alternatives
type: report
report_type: analysis
state: final
status: complete
tags: [research, agent-harness, alternatives, landscape]
---

# Agent Harness Alternatives to Claude Code

> BLUF: The CLI coding agent landscape in March 2026 is dominated by six production-grade tools: **OpenCode** (121K stars, broadest model support), **Gemini CLI** (97K stars, free tier with 1M context), **OpenAI Codex CLI** (65K stars, Rust-native), **Cline** (59K stars, VS Code-first with new CLI), **Aider** (42K stars, git-native pioneer), and **Goose** (32K stars, MCP-extensible).
> All major tools now support AGENTS.md as a cross-tool configuration standard.
> Claude Code's strongest differentiators remain its plugin marketplace (340+ plugins, 1300+ skills), hook lifecycle system, and deep CLAUDE.md rules integration.
> The primary gap in most alternatives is the lack of a plugin distribution/marketplace mechanism comparable to Claude Code's.

## Context

The term "agent harness" describes the infrastructure wrapping an AI model to manage long-running coding tasks: filesystem access, tool orchestration, approval flows, sub-agents, and lifecycle management.
2025 proved agents could work; 2026 is about making them work reliably at scale.
This report evaluates every notable open-source or semi-open alternative to Claude Code as of March 2026.

## Methodology

Data gathered via web search (March 2026) cross-referenced against GitHub repos, official docs, and community reviews.
Star counts and contributor numbers are approximate and change rapidly.
Tools are categorized by primary interface: CLI-first, IDE-first (with CLI), and platform/web.

---

## Tier 1: Production-Grade CLI-First Tools

These tools are CLI-native, actively maintained, and have substantial adoption.

### OpenCode

| Attribute | Detail |
|-----------|--------|
| **URL** | [github.com/opencode-ai/opencode](https://github.com/opencode-ai/opencode) |
| **Tech stack** | TypeScript |
| **Stars / Contributors** | ~121K / 800+ |
| **License** | MIT |
| **LLM backends** | 75+ providers: Anthropic, OpenAI, Google, local (Ollama, LM Studio, vLLM), plus "Zen" curated models |
| **Release cadence** | Very active, daily/weekly releases |

**Key differentiating features:**
- TUI with multi-session support and Tab-switchable agents (build agent, plan agent).
- Agent Client Protocol (ACP) support: works as an agent backend for Zed, Neovim, Emacs, JetBrains.
- LSP integration for code intelligence across languages.
- 5M+ monthly active developers.
- Grew 18K stars in two weeks (Jan 2026) after v1.0 rewrite enabled Claude Max subscription routing.

**Plugin / rules / extension system:**
- **Plugins**: JS/TS files in a plugin directory auto-loaded at startup, or npm packages specified in config. Full hook system for events.
- **AGENTS.md**: Custom instructions file loaded into LLM context, similar to CLAUDE.md.
- **opencode-rules plugin**: Discovers and injects markdown rule files with conditional activation (file patterns, prompt keywords, tools, model, agent, branch, OS, CI). This is a community plugin, not built-in.
- **Custom tools**: Plugins can register tools backed by external npm packages.
- **No marketplace**: Plugin discovery is manual (npm, GitHub, community lists like awesome-opencode).

**Known limitations:**
- No native marketplace or plugin registry: discovery depends on community curation.
- Local model support requires manual context window configuration (Ollama defaults to 4K tokens, OpenCode needs 64K+).
- TypeScript runtime overhead vs. Rust-native alternatives.

---

### Aider

| Attribute | Detail |
|-----------|--------|
| **URL** | [github.com/Aider-AI/aider](https://github.com/Aider-AI/aider) |
| **Tech stack** | Python |
| **Stars / Contributors** | ~42K / 1,170+ |
| **License** | Apache 2.0 |
| **LLM backends** | Claude, OpenAI (GPT-4o, o1, o3-mini), DeepSeek R1/V3, local models, nearly any LLM via litellm |
| **Release cadence** | Very active, frequent releases |

**Key differentiating features:**
- Git-first philosophy: every AI edit becomes a git commit with descriptive messages.
- Architect mode: two-model pipeline where a "planner" model proposes changes and an "editor" model applies them.
- Tree-sitter repo map: automatic AST-based codebase indexing across 100+ languages.
- Multiple edit formats (diff, whole, editor-diff, editor-whole) optimized per model.
- Top SWE-Bench scores.
- 4.1M+ pip installs.

**Plugin / rules / extension system:**
- **CONVENTIONS.md**: Project-level conventions file loaded into context.
- **.aider.conf.yml**: Hierarchical config (home dir, repo root, cwd) for model, lint, test commands, and behavior.
- **Also reads CLAUDE.md and .cursorrules**: Cross-tool compatibility built in.
- **Community conventions repo**: [github.com/Aider-AI/conventions](https://github.com/Aider-AI/conventions) for shared convention files.
- **No plugin system**: No hooks, no custom tools, no extension API. Customization is purely configuration + conventions files.

**Known limitations:**
- No plugin/extension architecture: cannot add custom tools, hooks, or workflows.
- No TUI: purely a REPL-style CLI.
- No sub-agent orchestration.
- Git-commit-per-edit can create noisy history on exploratory work.

---

### Goose (Block)

| Attribute | Detail |
|-----------|--------|
| **URL** | [github.com/block/goose](https://github.com/block/goose) |
| **Tech stack** | Rust (CLI + core), Electron (desktop app) |
| **Stars / Contributors** | ~32K / 370+ |
| **License** | Apache 2.0 |
| **LLM backends** | Any LLM, multi-model configuration for cost/performance optimization |
| **Release cadence** | Active, regular releases with published OSS roadmap |

**Key differentiating features:**
- Goes beyond code: install packages, execute code, debug failures, orchestrate workflows, interact with APIs.
- MCP-native: connects to 3,000+ tools through Model Context Protocol.
- "Recipes" system for repeatable workflow orchestration.
- Desktop app + CLI dual interface.
- Vibe-coded apps: interactive MCP-backed extensions that feel like native capabilities.
- Used by 60% of Block's 12,000 employees.

**Plugin / rules / extension system:**
- **MCP extensions**: Six extension types: built-in, remote (HTTP/SSE), command-line, InlinePython, and more.
- **AGENTS.md**: Read natively for project instructions.
- **Custom extensions**: Build MCP servers in Python (or any language) that expose tools to Goose.
- **Recipes**: Scripted multi-step workflows with parameters, distinct from rules.
- **Subagents**: Customizable via `subagent_system.md` prompt templates.
- **No marketplace**: Extensions are self-hosted MCP servers or local scripts.

**Known limitations:**
- No centralized extension registry or marketplace.
- Desktop app is Electron-based (resource heavy).
- Younger project (Jan 2025 release), still stabilizing APIs.
- Recipe system is workflow orchestration, not a general plugin API.

---

### OpenAI Codex CLI

| Attribute | Detail |
|-----------|--------|
| **URL** | [github.com/openai/codex](https://github.com/openai/codex) |
| **Tech stack** | Rust (97.6% of codebase) |
| **Stars / Contributors** | ~65K / 285+ |
| **License** | Apache 2.0 |
| **LLM backends** | OpenAI models (GPT-5.4, o-series), extensible via MCP |
| **Release cadence** | Very active, 327+ releases |

**Key differentiating features:**
- Rust-native: fastest startup and lowest memory footprint of the major tools.
- Sandbox-first: network-disabled, directory-scoped execution for safety.
- Three approval modes: suggest (read-only), auto-edit (file changes auto-approved), full-auto.
- Experimental hooks engine (SessionStart, SessionStop events).
- Skills with `scripts/` directories for CLI automation.
- MCP integration for external tool connectivity.

**Plugin / rules / extension system:**
- **AGENTS.md**: Multi-level instruction loading (global `~/.codex/`, repo-level, directory-level). Closer files take precedence.
- **config.toml**: Global defaults in `~/.codex/config.toml`, overridable per invocation.
- **MCP servers**: STDIO and streaming HTTP servers configurable in config.toml or via `codex mcp` CLI.
- **Skills**: Bundled instruction + script directories, can include MCP server definitions.
- **Hooks**: Experimental `hooks.json` with SessionStart/Stop events and timeout configuration.
- **No marketplace**: Skills and MCP servers are manually configured.

**Known limitations:**
- Primarily OpenAI-model focused: using non-OpenAI models requires MCP workarounds.
- Hooks system is experimental and limited to session lifecycle events (no pre/post tool-use hooks).
- No plugin distribution mechanism.
- Sandbox restrictions can be limiting for tasks requiring network access.

---

### Gemini CLI (Google)

| Attribute | Detail |
|-----------|--------|
| **URL** | [github.com/google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli) |
| **Tech stack** | TypeScript / Node.js |
| **Stars / Contributors** | ~97K / 2,240+ |
| **License** | Apache 2.0 |
| **LLM backends** | Gemini 3 models (1M token context window), Google Search grounding |
| **Release cadence** | Weekly preview releases (Tuesdays), weekly stable promotions |

**Key differentiating features:**
- 1M token context window: largest native context of any CLI agent.
- Free tier: 60 req/min, 1,000 req/day with personal Google account.
- Google Search grounding: built-in web search as a tool.
- ReAct (reason-and-act) agent loop.
- GitHub Actions integration for autonomous repo tasks.
- MCP support for custom tool extensions.

**Plugin / rules / extension system:**
- **GEMINI.md**: Hierarchical context files loaded from multiple locations (global, project, directory). Equivalent to CLAUDE.md.
- **SYSTEM.md**: Non-negotiable operational rules for safety and tool-use protocols.
- **Policy engine**: Fine-grained TOML-based rules for tool execution (allow, deny, confirm). Supports project-level policies, MCP server wildcards, and tool annotation matching.
- **Custom commands**: User-defined slash commands as markdown files.
- **Extensions ecosystem**: Active community with projects like the Conductor extension (3K+ stars).
- **No formal marketplace**: Extensions distributed via npm and GitHub.

**Known limitations:**
- Gemini-only: no support for Claude, OpenAI, or local models.
- Policy engine is powerful but complex (TOML-based, multiple file locations).
- Free tier has rate limits that may constrain heavy usage.
- Younger project (mid-2025 launch), API still evolving.

---

## Tier 2: IDE-First Tools with CLI Capabilities

These tools are primarily IDE extensions but have CLI interfaces or agent modes.

### Cline

| Attribute | Detail |
|-----------|--------|
| **URL** | [github.com/cline/cline](https://github.com/cline/cline) |
| **Tech stack** | TypeScript (VS Code extension + CLI) |
| **Stars / Contributors** | ~59K / 516+ |
| **License** | Apache 2.0 |
| **LLM backends** | All major providers: OpenRouter, Anthropic, OpenAI, Google, AWS Bedrock, Azure, Vertex, Ollama |
| **Release cadence** | Very active |

**Key differentiating features:**
- "Approve everything" philosophy: every file change and terminal command requires explicit approval.
- Browser automation: launch browsers, click elements, capture screenshots.
- Workspace checkpoints for safe experimentation and rollback.
- MCP support for custom tools.
- CLI with `--acp` flag for Agent Client Protocol compliance (works with Zed, Neovim, Emacs).
- 5M+ developers.

**Plugin / rules / extension system:**
- **MCP tools**: Custom tool creation via MCP servers.
- **Custom instructions**: Project-level instructions loaded into context.
- **No rules file standard**: Does not natively read AGENTS.md, CLAUDE.md, or similar.
- **No plugin distribution**: Extensions are MCP servers, manually configured.

**Known limitations:**
- VS Code-primary: CLI is newer and less mature.
- Approval-heavy UX can slow down automated workflows.
- No native rules/conventions file standard.
- No plugin marketplace.

---

### Roo Code

| Attribute | Detail |
|-----------|--------|
| **URL** | [github.com/RooCodeInc/Roo-Code](https://github.com/RooCodeInc/Roo-Code) |
| **Tech stack** | TypeScript (VS Code extension + CLI) |
| **Stars / Contributors** | Active fork of Cline, diverged into own product |
| **License** | Apache 2.0 |
| **LLM backends** | All major providers, CLI default is Claude Opus 4.6 |
| **Release cadence** | Very active, frequent releases (v3.48.0 as of Feb 2026) |

**Key differentiating features:**
- Multi-mode system: Code, Architect, Ask, Debug modes, plus user-defined custom modes.
- Custom mode creation UI with fields for role, tools, instructions.
- CLI with stdin piping for automated scripting (`echo "task" | roo`).
- Auto-approval as CLI default (opt-in manual approval).

**Plugin / rules / extension system:**
- **.roo/rules/ directory**: Place `.md` or `.txt` files, read recursively and appended to system prompt alphabetically.
- **AGENTS.md + AGENTS.local.md**: Supports the standard, with `.local.md` personal overrides auto-gitignored.
- **Custom modes**: YAML-defined modes with per-mode tool access and instructions. Shareable via config files.
- **No marketplace**: Rules and modes are file-based, shared via repo.

**Known limitations:**
- Forked from Cline: carries some inherited complexity.
- VS Code-primary: CLI is secondary interface.
- No plugin distribution beyond file sharing.
- Custom modes are powerful but mode proliferation can confuse workflows.

---

### Continue

| Attribute | Detail |
|-----------|--------|
| **URL** | [github.com/continuedev/continue](https://github.com/continuedev/continue) |
| **Tech stack** | TypeScript |
| **Stars / Contributors** | ~32K / 4,239+ |
| **License** | Apache 2.0 |
| **LLM backends** | All major providers, local models |
| **Release cadence** | Active |

**Key differentiating features:**
- CI-enforceable AI checks: agents run as GitHub status checks on every PR.
- Each check is a markdown file in `.continue/checks/` with a name, description, and prompt.
- Agent mode for multi-file refactoring in IDE or CLI.
- TUI mode and headless mode for background agent execution.
- Hub for sharing configurations: [hub.continue.dev](https://hub.continue.dev).

**Plugin / rules / extension system:**
- **.continue/checks/**: Markdown files defining AI checks that run as GitHub status checks.
- **Rules repository**: CLI tool to create, manage, and convert rule sets across AI assistant platforms.
- **Continue Hub**: Centralized sharing of configurations, checks, and rules. The closest thing to a marketplace among IDE-first tools.
- **Agent mode**: Full file read/write, terminal commands, web search, codebase search.

**Known limitations:**
- IDE-first: CLI/TUI is secondary.
- Checks system is CI-focused, not general-purpose plugin architecture.
- Hub is young, limited content compared to Claude Code marketplace.

---

### Cursor

| Attribute | Detail |
|-----------|--------|
| **URL** | [cursor.com](https://cursor.com) |
| **Tech stack** | VS Code fork (TypeScript/Electron) |
| **Stars / Contributors** | Proprietary (not open source) |
| **License** | Proprietary |
| **LLM backends** | Claude, GPT, Cursor's own Composer model |
| **Release cadence** | Active, v2.0 released with Composer model |

**Key differentiating features:**
- Deep editor integration: Agent Mode woven into the editor core.
- Composer model: proprietary coding model at ~2x Sonnet speed.
- Plan Mode: AI crawls project, reads docs and rules, generates editable Markdown plan.
- Multi-agent parallel execution in v2.0.

**Plugin / rules / extension system:**
- **.cursor/rules/ directory**: Markdown files injected as persistent context into every AI request (autocomplete, chat, code generation).
- **Rule types**: Always, Auto Detect (AI decides when relevant), Agent Requested, Manual.
- **CLI agent mode**: Supports MCP, rules, and command approval from the terminal.
- **No plugin marketplace**: Rules shared via repo. VS Code extensions work but are not AI-specific plugins.

**Known limitations:**
- **Not open source**: Proprietary codebase, no community forks.
- Paid tiers ($20-$200/mo).
- CLI agent is secondary to the IDE experience.
- Vendor lock-in with Composer model.

---

### Amp (Sourcegraph)

| Attribute | Detail |
|-----------|--------|
| **URL** | [ampcode.com](https://ampcode.com) / [sourcegraph.com/amp](https://sourcegraph.com/amp) |
| **Tech stack** | TypeScript (npm package) |
| **Stars / Contributors** | Not fully open source (Sourcegraph is now closed-source) |
| **License** | Proprietary (Sourcegraph Enterprise license) |
| **LLM backends** | Claude Opus 4.6, GPT-5.4, Gemini 3, Grok, Kimi K2.5, and more. Unconstrained token usage. |
| **Release cadence** | Very active, multiple releases per day |

**Key differentiating features:**
- "Deep mode": autonomous research and problem-solving with extended reasoning.
- Multi-model: uses different models for what each is best at.
- Sub-agents: Oracle (code analysis), Librarian (external library analysis), Painter (image generation).
- Composable tool system with code review, walkthrough, and annotation capabilities.
- No token limits per task.

**Plugin / rules / extension system:**
- **AGENTS.md**: Native support, falls back to CLAUDE.md if absent.
- **Toolboxes**: Directory of custom scripts exposed as tools via `AMP_TOOLBOX` env var.
- **Custom slash commands**: `.agents/commands/` directory with markdown command definitions.
- **Skills with MCP**: Skill directories can bundle MCP server definitions (`mcp.json`). Servers start at launch, tools hidden until skill loads.
- **No open marketplace**: Toolboxes and skills are file-based.

**Known limitations:**
- **Not open source**: Sourcegraph closed its core repo in Aug 2024.
- Proprietary pricing (team-focused, no free tier announced).
- Heavy multi-model usage means costs are opaque.
- Toolbox system is less structured than Claude Code's plugin manifest.

---

## Tier 3: Platform / Specialized Tools

These tools serve different niches: web-based, research-focused, or now-inactive projects.

### OpenHands (formerly OpenDevin)

| Attribute | Detail |
|-----------|--------|
| **URL** | [github.com/OpenHands/OpenHands](https://github.com/OpenHands/OpenHands) |
| **Tech stack** | Python (SDK), React (GUI) |
| **Stars / Contributors** | ~69K / large contributor base |
| **License** | MIT |
| **LLM backends** | Model-agnostic, any LLM |
| **Release cadence** | Active, V1 SDK redesign in progress |

**Key differentiating features:**
- Full platform: Docker-sandboxed agent environment with web GUI, REST API, and SDK.
- AgentHub registry: CodeActAgent, BrowserAgent, Micro-agents.
- Scales to 1,000+ parallel agents in the cloud.
- Native GitHub, GitLab, CI/CD, Slack integrations.
- $18.8M Series A funding.

**Plugin / rules / extension system:**
- **Agent Skills**: Slash menu for loaded skills in conversation context.
- **Marketplace datamodel**: `marketplace.json` with plugin, LSP server, and skill support.
- **SDK**: Composable Python library for defining custom agents.
- **V1 redesign**: Moving from mandatory Docker to optional sandboxing, LocalWorkspace by default.

**Known limitations:**
- Platform-first, not CLI-first: requires Docker or web UI for full functionality.
- V0 deprecated (April 2026), V1 in progress: API instability during transition.
- Heavier setup than pure CLI tools.
- Not a "terminal coding assistant" in the same sense as Claude Code.

---

### SWE-agent (Princeton/Stanford)

| Attribute | Detail |
|-----------|--------|
| **URL** | [github.com/SWE-agent/SWE-agent](https://github.com/SWE-agent/SWE-agent) |
| **Tech stack** | Python |
| **Stars / Contributors** | ~19K / 2,020+ |
| **License** | MIT |
| **LLM backends** | GPT-4o, Claude Sonnet 4, any LLM |
| **Release cadence** | Active, v1.0 released |

**Key differentiating features:**
- Research-focused: designed for SWE-Bench evaluation and automated issue fixing.
- Takes a GitHub issue URL and autonomously produces a fix.
- Multimodal support for processing images from GitHub issues.
- Configurable via a single YAML file.
- mini-swe-agent variant: 100 lines, scores >74% on SWE-bench verified.
- Academic pedigree (NeurIPS 2024 paper).

**Plugin / rules / extension system:**
- **YAML configuration**: Single config file governs all behavior.
- **Custom tool definitions**: YAML-based tool registration.
- **No plugin system**: Research tool, not designed for extensibility.

**Known limitations:**
- Research tool, not a daily-driver coding assistant.
- No interactive REPL or TUI.
- Issue-focused workflow: not designed for open-ended coding tasks.
- Requires Docker for sandboxed execution.

---

### Plandex

| Attribute | Detail |
|-----------|--------|
| **URL** | [github.com/plandex-ai/plandex](https://github.com/plandex-ai/plandex) |
| **Tech stack** | Go |
| **Stars / Contributors** | ~10K |
| **License** | MIT |
| **LLM backends** | Anthropic, OpenAI, Google, open source providers |
| **Release cadence** | **Winding down as of Oct 2025, no longer accepting new users** |

**Key differentiating features:**
- Sandbox-based: AI changes accumulate in a diff review sandbox, separate from project files until approved.
- 2M token context, 20M token directory indexing via tree-sitter project maps.
- Configurable autonomy: full auto to fine-grained control.
- JSON-based model config with IDE schema support.

**Plugin / rules / extension system:**
- **JSON model configuration**: Schema-validated model config files.
- **No plugin system**: Configuration-only customization.

**Known limitations:**
- **Winding down**: Not accepting new users as of Oct 2025.
- No plugin, rules, or extension system.
- Self-hosted server required for some features.

---

### Mentat (AbanteAI)

| Attribute | Detail |
|-----------|--------|
| **URL** | [github.com/AbanteAI/mentat](https://github.com/AbanteAI/mentat) |
| **Tech stack** | Python |
| **Stars / Contributors** | Small community |
| **License** | Apache 2.0 |
| **LLM backends** | OpenAI, Anthropic |
| **Release cadence** | Low activity |

**Key differentiating features:**
- Multi-file coordinate editing from the command line.
- Automatic project context: no copy-pasting required.
- SWE-bench lite score of 38%.

**Plugin / rules / extension system:**
- **No plugin system**: No rules, hooks, or extension mechanism.

**Known limitations:**
- Small community, limited adoption.
- No plugin or customization system.
- Limited model support compared to peers.
- Development activity appears to have slowed significantly.

---

### Sweep

| Attribute | Detail |
|-----------|--------|
| **URL** | [github.com/sweepai/sweep](https://github.com/sweepai/sweep) |
| **Tech stack** | Python (originally), now JetBrains plugin |
| **Stars / Contributors** | Pivoted from GitHub bot to JetBrains IDE plugin |
| **License** | Mixed |
| **LLM backends** | Proprietary |
| **Release cadence** | Active on JetBrains plugin |

**Key differentiating features:**
- Pivoted to JetBrains autocomplete and AI assistant.
- "Next-edit autocomplete" unique to JetBrains ecosystem.

**Plugin / rules / extension system:**
- **sweep.yaml**: Configuration file for the original GitHub bot.
- **JetBrains plugin**: IDE-native, no separate rules system.

**Known limitations:**
- No longer a CLI tool or GitHub bot in its original form.
- JetBrains-only.
- Not relevant as a Claude Code alternative for terminal workflows.

---

### Bolt.new / bolt.diy (StackBlitz)

| Attribute | Detail |
|-----------|--------|
| **URL** | [github.com/stackblitz/bolt.new](https://github.com/stackblitz/bolt.new) / [github.com/stackblitz-labs/bolt.diy](https://github.com/stackblitz-labs/bolt.diy) |
| **Tech stack** | TypeScript, WebContainers |
| **Stars / Contributors** | Large community (bolt.diy is open-source fork) |
| **License** | bolt.diy: MIT; bolt.new hosted: proprietary |
| **LLM backends** | bolt.diy supports 19+ providers (OpenAI, Anthropic, Google, Ollama, and many more) |
| **Release cadence** | Active |

**Key differentiating features:**
- Browser-based: full-stack app development entirely in the browser via WebContainers.
- No local setup required: npm install, serve APIs, deploy from browser.
- One-prompt full application generation.

**Plugin / rules / extension system:**
- **No CLI agent**: Browser-only workflow.
- **No rules/plugin system**: Prompt-driven, no persistent configuration.

**Known limitations:**
- Not a CLI tool: entirely browser-based.
- Not suitable for working on existing codebases.
- No rules, hooks, or plugin architecture.
- bolt.diy requires self-hosting for open-source usage.

---

### Forge

| Attribute | Detail |
|-----------|--------|
| **URL** | [github.com/antinomyhq/forge](https://github.com/antinomyhq/forge) |
| **Tech stack** | Rust (CLI), also npm-installable |
| **Stars / Contributors** | ~1K+ |
| **License** | Open source |
| **LLM backends** | Claude, GPT, Grok, DeepSeek, 300+ models |
| **Release cadence** | Active |

**Key differentiating features:**
- Lightweight terminal-based AI pair programmer.
- Enterprise governance: full control over where code goes, any LLM (cloud or self-hosted).
- Integrates with VS Code, Neovim, IntelliJ, or any shell tools.
- Governance policies and GitHub Workflows scaffolding.

**Plugin / rules / extension system:**
- **Custom rules**: Governance policies with severity levels and checks.
- **GitHub Workflow integration**: Scaffolds CI/CD policies.
- **No marketplace or formal plugin system**.

**Known limitations:**
- Small community (1K stars).
- Limited documentation.
- Governance focus may not appeal to individual developers.

---

## Cross-Cutting Analysis

### Standards Convergence

Three standards are emerging across the ecosystem:

| Standard | Purpose | Supported by |
|----------|---------|-------------|
| **AGENTS.md** | Project-level instructions for coding agents | OpenCode, Codex, Goose, Amp, Roo Code, Gemini CLI (reads it too), and 60K+ repos on GitHub. Under Linux Foundation / AAIF governance. |
| **MCP** (Model Context Protocol) | Tool/extension interoperability | Claude Code, Goose, Codex, Cline, Gemini CLI, OpenCode, Amp, OpenHands |
| **ACP** (Agent Client Protocol) | Editor-agent communication | OpenCode, Cline, Zed, Neovim, Emacs, JetBrains |

### Plugin / Rules System Comparison

| Tool | Rules files | Hook lifecycle | Plugin distribution | Custom tools | Marketplace |
|------|------------|---------------|-------------------|-------------|-------------|
| **Claude Code** | CLAUDE.md + .claude/rules/ (scoped) | Pre/Post tool-use, Session hooks | Plugin manifest + marketplace | Skills, agents, MCP, hooks | Yes (340+ plugins) |
| **OpenCode** | AGENTS.md + opencode-rules plugin | Event hooks in plugins | npm packages | JS/TS plugins, MCP | No |
| **Aider** | CONVENTIONS.md, .aider.conf.yml | None | None | None | No |
| **Goose** | AGENTS.md | None (recipe-based) | None | MCP extensions (6 types) | No |
| **Codex CLI** | AGENTS.md (multi-level) | SessionStart/Stop (experimental) | None | MCP servers, skills | No |
| **Gemini CLI** | GEMINI.md + SYSTEM.md + policy engine | None | npm extensions | MCP, custom commands | No |
| **Cline** | Custom instructions | None | None | MCP tools | No |
| **Roo Code** | .roo/rules/ + AGENTS.md | None | None | MCP tools, custom modes | No |
| **Continue** | .continue/checks/ | CI event-driven | Continue Hub | Agent checks | Hub (limited) |
| **Cursor** | .cursor/rules/ (4 activation types) | None | None | MCP | No |
| **Amp** | AGENTS.md (+ CLAUDE.md fallback) | None | None | Toolboxes, skills+MCP | No |

### Maturity and Adoption

| Tool | Stars | Primary Strength | Primary Weakness |
|------|-------|-----------------|-----------------|
| OpenCode | 121K | Broadest model support, ACP | No marketplace |
| Gemini CLI | 97K | Free tier, 1M context | Gemini-only |
| OpenHands | 69K | Full platform, cloud scale | Not CLI-first |
| Codex CLI | 65K | Rust performance, safety | OpenAI-model focused |
| Cline | 59K | VS Code integration, approval UX | IDE-first |
| Aider | 42K | Git-native, mature | No plugins/extensions |
| Goose | 32K | MCP ecosystem, enterprise use | Younger project |
| Continue | 32K | CI integration, Hub | IDE-first |
| SWE-agent | 19K | Research benchmarks | Not a daily driver |
| Plandex | 10K | Large context handling | Winding down |

---

## Claude Code's Competitive Position

Claude Code's strongest differentiators relative to the field:

1. **Plugin marketplace**: The only tool with a formal plugin registry, manifest format (`plugin.json`), and distribution mechanism. 340+ plugins, 1300+ skills.
2. **Hook lifecycle**: Pre/PostToolUse, SessionStart/Stop, Notification, InstructionsLoaded hooks provide the most granular agent lifecycle control of any tool.
3. **Scoped rules**: `.claude/rules/*.md` with `paths:` frontmatter for file-pattern-based rule activation. No other tool has this granularity.
4. **Sub-agent orchestration**: Dedicated agent dispatch with model selection per sub-agent.
5. **CLAUDE.md ecosystem**: Widely adopted (feeds into Amp, Roo Code, Aider as well).

Claude Code's weaknesses relative to the field:

1. **Anthropic-only models**: Cannot use GPT, Gemini, or local models natively.
2. **Not open source**: Source available on GitHub but not community-forkable in the same way as OpenCode or Aider.
3. **Cost**: Requires Claude API subscription; no free tier like Gemini CLI.
4. **Plugin rules gap**: Plugins cannot declare rules that auto-load in installing projects (see [#14200](https://github.com/anthropics/claude-code/issues/14200)).

---

## Recommendations for Clauthier Plugin Development

1. **Target AGENTS.md compatibility**: The cdocs plugin's rules and conventions should be expressible in AGENTS.md format for cross-tool portability.
2. **Watch OpenCode's plugin ecosystem**: OpenCode's opencode-rules plugin and npm-based distribution are the closest open-source analog to Claude Code's plugin system.
3. **MCP as the extension lingua franca**: Any tool integrations should speak MCP, as it is the one standard all major tools support.
4. **Track ACP for editor integration**: If cdocs workflows should work in Zed/Neovim/Emacs, ACP is the path.

---

## Sources

- [OpenCode](https://github.com/opencode-ai/opencode) | [Docs](https://opencode.ai/docs/)
- [Aider](https://github.com/Aider-AI/aider) | [Docs](https://aider.chat/docs/)
- [Goose](https://github.com/block/goose) | [Docs](https://block.github.io/goose/)
- [OpenAI Codex CLI](https://github.com/openai/codex) | [Docs](https://developers.openai.com/codex/cli/)
- [Gemini CLI](https://github.com/google-gemini/gemini-cli) | [Docs](https://geminicli.com/docs/)
- [Cline](https://github.com/cline/cline) | [Site](https://cline.bot/)
- [Roo Code](https://github.com/RooCodeInc/Roo-Code) | [Docs](https://docs.roocode.com/)
- [Continue](https://github.com/continuedev/continue) | [Docs](https://docs.continue.dev/)
- [Cursor](https://cursor.com) | [Docs](https://cursor.com/docs/agent/overview)
- [Amp](https://ampcode.com) | [Manual](https://ampcode.com/manual)
- [OpenHands](https://github.com/OpenHands/OpenHands) | [Docs](https://docs.openhands.dev/)
- [SWE-agent](https://github.com/SWE-agent/SWE-agent) | [Docs](https://swe-agent.com/latest/)
- [Plandex](https://github.com/plandex-ai/plandex) | [Docs](https://docs.plandex.ai/)
- [Mentat](https://github.com/AbanteAI/mentat) | [Site](https://mentat.ai/)
- [Sweep](https://github.com/sweepai/sweep)
- [Bolt.new](https://github.com/stackblitz/bolt.new) | [bolt.diy](https://github.com/stackblitz-labs/bolt.diy)
- [Forge](https://github.com/antinomyhq/forge)
- [AGENTS.md Standard](https://agents.md/)
- [Agent Harness Framing](https://www.philschmid.de/agent-harness-2026)
- [Tembo CLI Tools Comparison](https://www.tembo.io/blog/coding-cli-tools-comparison)
- [Agentic Coding Frameworks Guide](https://ralphwiggum.org/blog/agentic-coding-frameworks-guide)

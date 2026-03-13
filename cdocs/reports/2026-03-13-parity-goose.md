---
first_authored:
  by: "@claude-sonnet-4-6"
  at: 2026-03-13
type: report
report_type: analysis
state: final
status: complete
tags: [research, parity, goose, claude-code]
---

# Feature Parity: Goose (Block) vs Claude Code

> BLUF: Goose has strong parity with Claude Code on agent fundamentals (subagents, parallelism, context management, MCP) and leads on LLM agnosticism and raw tool breadth (3000+ via MCP).
> Claude Code leads on plugin composability, hooks richness, the memory system, sandboxing, and IDE integration.
> The critical differentiator for organizations building workflows is **rules/convention bundling**: neither tool fully solves it, but they fail differently.
> Goose's `.goosehints` and Recipes are powerful but disjoint; CC's plugin system bundles more artifact types but still lacks native `rules` support (#14200).

## Background

Goose is an open-source, local-first AI agent by Block (Square/Cash App).
32K GitHub stars, written in Rust, Apache 2.0, supports any LLM.
MCP-native since inception - Block co-developed MCP with Anthropic.
Used by ~60% of Block's 12,000 employees as of early 2026.
Available as Desktop app and CLI.

Claude Code is Anthropic's agentic coding CLI, GA since May 2025.
Plugin ecosystem, background agents, subagents, Skills, Hooks, sandboxing, remote execution.

## Feature Parity Table

| Claude Code Feature | Goose Status | Notes |
|---|---|---|
| Background agents | partial | Subagents run asynchronously; no Ctrl+B-style task manager |
| Task tracking (TodoWrite) | partial | Recipes provide workflow structure; no checklist-style progress UI |
| Subagents | parity | Full subagent spawning with parallel execution |
| Skills system | partial | Recipes are analogous but YAML-based, not markdown; no auto-invocation from context |
| Plugin/marketplace | partial | Custom distros + MCP ecosystem, no curated plugin marketplace |
| Hooks system | partial | Lifecycle hooks exist (HTTP hooks as of Feb 2026); fewer event types than CC |
| MCP servers | ahead | Built from the ground up for MCP; 3000+ tools; 6 extension types |
| Plan mode | absent | No dedicated read-only planning mode; planning is conversational |
| Extended thinking | absent | No built-in chain-of-thought; depends on the configured LLM's capabilities |
| IDE integrations | absent | Desktop GUI + CLI only; no VS Code or JetBrains plugin |
| Memory system | partial | `.goosehints` + persistent instructions; no auto-memory or CLAUDE.md-equivalent |
| Permission modes | partial | Autonomous mode; extension-scoped subagents; no OS-level sandboxing |
| Git integration | partial | No native git/PR workflow; achieved via MCP git/GitHub servers |
| Multi-model | ahead | First-class: configure any provider (Anthropic, OpenAI, Gemini, Ollama, etc.) |
| Context management | parity | Auto-compaction at 80% token limit; manual context strategies |
| Remote execution | absent | Local-first by design; no cloud VM or remote control feature |
| Agent teams | partial | Parallel subagents with coordination; no named "teams" abstraction |

## Deep Dive: Rules and Plugin Reusability

This is the critical angle for organizations that want to distribute and enforce conventions alongside agent capabilities.

### 1. Can Goose MCP Extensions Bundle Rules with Tools?

No, not natively.
An MCP extension in Goose provides tools, resources, and prompts via the MCP protocol.
The extension types (Builtin, CommandLine, Remote SSE, Remote HTTP, InlinePython, Frontend) all expose MCP primitives.
There is no mechanism to declare "when this extension is loaded, also load these behavioral conventions."

The closest analog is MCP `prompts` - a server can expose prompt templates that the agent can invoke.
However, these are discrete, invocable prompts, not ambient persistent rules that shape agent behavior across all interactions.

Workaround: Pair an extension with a recipe that sets a `system_prompt` or `instructions` block embedding the conventions.
This is manual - the user must configure the recipe to use the extension and include the instructions.
There is no equivalent to CC's `plugin.json` bundling (even CC's bundling doesn't support `rules` today - see [#14200](https://github.com/anthropics/claude-code/issues/14200)).

> NOTE(@claude-sonnet-4-6/research/parity-goose): Both Goose and CC have this gap; they just surface it differently.
> CC at least has a tracking issue and a clear plugin manifest where `rules` could be added.
> Goose doesn't have a plugin manifest at all - the concept doesn't exist in the architecture.

### 2. Recipes vs Skills: A Structural Comparison

Recipes and Skills serve overlapping purposes but have meaningfully different designs.

**Recipes** (Goose):
- YAML files with: `version`, `title`, `description`, `instructions`, `extensions`, `activities`, optional `parameters`, optional `sub_recipes`.
- Pin specific MCP extensions required for the recipe.
- Pin specific LLM provider and model per recipe (as of Jan 2026).
- Parameterized: define typed input variables that the user fills in.
- Sub-recipes: a recipe can delegate to other recipes, enabling workflow composition.
- Shareable via deeplinks (one-click import in the Desktop app).
- A community cookbook accepts submissions (paid incentive: $10 in LLM credits).
- Distribution: share as files, deeplinks, or via git repos.

**Skills** (Claude Code):
- Markdown files (`SKILL.md`) with YAML frontmatter and free-form instructions.
- Frontmatter: `name`, `description`, `tools`, `allowed-tools`, `context`, `agent`, `hooks`.
- Automatically invoked when conversation context matches the skill description.
- Explicit invocation via `/skill-name` in the slash-command menu.
- Can fork to a subagent with its own isolated context (`context: subagent`).
- Can embed hooks to run on invocation.
- Distributed via the plugin marketplace (bundled in a `plugin.json` manifest).
- Lazy-loaded: descriptions are always visible; full content loads only on invocation.

**Key structural differences:**

| Dimension | Recipes (Goose) | Skills (CC) |
|---|---|---|
| Format | YAML | Markdown + YAML frontmatter |
| Extension pinning | Yes (explicit `extensions:` list) | No (tools listed, not servers) |
| Model pinning | Yes (per-recipe provider+model) | No (inherits session model) |
| Auto-invocation | No | Yes (context-matching) |
| Sub-workflows | Yes (sub_recipes) | Via subagent forking |
| Parameterization | Yes (typed input vars) | No |
| Distribution | Deeplinks, files | Plugin marketplace |
| Bundling with tools | No (recipes reference extensions) | Yes (plugin.json bundles both) |

Recipes have a significant advantage in **parameterization** and **model pinning** - a recipe specifies exactly what it needs.
Skills have a significant advantage in **auto-invocation** and **marketplace distribution** as part of a unified plugin.

The most important missing feature in Recipes: they cannot bundle the extensions they reference.
A recipe file says "you need the GitHub MCP extension" but doesn't ship or install it.
A CC plugin can ship MCP server config, skills, hooks, and agents together - even if it can't ship rules.

### 3. Packaging and Distributing Goose Configurations for an Org

Goose has two mechanisms for org-level distribution:

**Custom Distros** (`CUSTOM_DISTROS.md`):
Fork the Goose repository and build a branded binary.
Bake in: default LLM provider + model, pre-configured extensions, custom branding (name, icon), default behaviors.
Deploy via standard OS packaging (dmg, exe, deb).
Targeted at organizations that want to ship a "ready-to-use" agent to non-technical employees.
Limitation: requires a fork and build pipeline; not a lightweight distribution mechanism.

**Config files + environment variables**:
`~/.config/goose/config.yaml` holds provider, model, and extension config.
Orgs can distribute this file via dotfiles management or MDM tooling.
`GOOSE_PROVIDER`, `GOOSE_MODEL`, and extension env vars can be set at the system level.
Limitation: manual, no version tracking, no marketplace-style install workflow.

**Recipes as shared workflow packages**:
Recipes are the closest to "distributable workflow packages."
An org can maintain a git repo of recipes, share deeplinks, and treat recipes as the unit of convention.
Limitation: recipes are workflows, not persistent behavioral guidelines.
A recipe's instructions are only active during that recipe's execution, not across all sessions.

**`.goosehints` for project-level conventions**:
`.goosehints` is a project-level file (committed to the repo root) read at session start.
It injects conventions like coding standards, build targets, and style preferences.
`.goosehints.local` is a git-ignored personal override.
Persistent instructions (re-injected every turn, not just at session start) are a stronger version for guardrails.
Limitation: `.goosehints` is project-specific. There is no mechanism to distribute a `.goosehints` template via an extension - the extension author cannot say "when you install this extension, also get these project conventions."

Comparison to CC: CC's `CLAUDE.md` is the analog to `.goosehints`.
CC has the advantage of `@path/to/file` includes for modularity and the `paths:` frontmatter for scoped rules.
Neither CC nor Goose solves the extension-bundled-conventions problem today.

### 4. Subagent Customization

**Goose subagents**:
Spawned via natural language ("delegate this to a subagent") or via Recipes.
Two configuration modes:
1. Direct prompt: natural language instructions, quick one-off tasks.
2. Recipe: a `.yaml` file defining the subagent's goal, extensions, parameters, and activities.

Key customization capabilities:
- **Extension scoping**: a subagent can be configured with a specific subset of extensions ("only the developer extension"). This is a meaningful security/focus primitive.
- **Parallel execution**: multiple subagents run simultaneously; the main agent coordinates.
- **Isolation**: each subagent is a separate Agent instance with its own context, preventing context bleed.
- **Result aggregation**: only summaries flow back to the parent session.
- **Automatic delegation**: in autonomous mode, Goose decides when to spawn subagents without explicit instruction.

Limitations:
- Subagent definitions are not first-class files with version control (unlike CC's `.claude/agents/*.md`).
- No tool-level restrictions analogous to CC's `tools` frontmatter field.
- Sub-recipe composition is the closest to a formal subagent definition, but sub-recipes are workflow nodes, not reusable named agents.

**Claude Code subagents**:
Defined in `.claude/agents/*.md` with YAML frontmatter: `name`, `model`, `tools`, `memory`, `isolation`.
The Task tool spawns up to 7 simultaneous subagents.
Each inherits all tools from parent except `Task` (flat hierarchy).
Custom agents can restrict which tools are available and which model they use.
This is a clear CC advantage: subagent definitions are versioned markdown files with explicit capability manifests.

## Goose-Ahead Areas

**LLM agnosticism**: Goose genuinely works with any LLM provider without workarounds.
Model pinning per recipe means different workflow stages can use different models cost-effectively.
CC supports multiple models but is Anthropic-native; using non-Anthropic models is possible but not the primary use case.

**MCP ecosystem**: With 3000+ available tools and 6 extension types (including InlinePython for dependency-free scripting), Goose's tool breadth is substantially larger.
The InlinePython type is particularly useful: embed Python code + dependencies directly in the config YAML without needing a deployed server.

**Parameterized workflows**: Recipes support typed input variables, making them interactive workflow templates rather than static scripts.
CC skills have no equivalent parameterization.

## Claude Code-Ahead Areas

**Plugin composability**: A single `plugin.json` can bundle skills, agents, hooks, MCP server config, and output styles together.
Goose has no equivalent unit - extensions provide tools, recipes provide workflows, but there is no artifact that bundles all of these together.

**Hooks richness**: CC has 8+ hook event types with `PreToolUse` blocking capability (exit code 2 denies execution), `additionalContext` injection at session start, and HTTP endpoint support.
Goose has lifecycle hooks (HTTP as of Feb 2026) but fewer granular event types and no tool-blocking primitive.

**Sandboxing**: CC has OS-level sandboxing via Seatbelt (macOS) and bubblewrap (Linux), providing filesystem and network isolation without requiring a container.
Goose has no sandboxing; it runs with full user permissions.

**Remote and cloud execution**: CC can run on Anthropic-managed VMs, via GitHub Actions, and via the Remote Control bridge (mobile/browser continuation).
Goose is local-first with no official cloud execution path.

**IDE integration**: CC has a first-class VS Code extension and JetBrains integration.
Goose has a Desktop GUI and CLI but no IDE plugin.

**Auto-memory**: CC's auto-memory passively captures build commands, debugging insights, and code patterns across sessions.
Goose's memory is session-scoped by default (Desktop has persistent memories; CLI starts fresh each session).

**Subagent definition files**: CC's `.claude/agents/*.md` are versioned, named, and tool-constrained definitions.
Goose subagents are ephemeral or defined via recipes which are workflow-oriented, not agent-oriented.

## Summary Assessment

For a developer or team choosing between these tools:

- **Choose Goose** if: LLM agnosticism is a requirement, the team wants maximum MCP tool breadth, parameterized workflows (Recipes) are valuable, or cost optimization across LLMs per task is important.

- **Choose Claude Code** if: IDE-native workflow is important, sandboxed execution is needed, the plugin ecosystem's ability to bundle artifacts (skills + agents + hooks) matters, or Anthropic models are the primary choice.

- **Neither fully solves** bundled rules/conventions: both require manual configuration to distribute behavioral conventions alongside tools.
  Goose has no extension-bundled-conventions concept at all.
  CC has an open feature request ([#14200](https://github.com/anthropics/claude-code/issues/14200)) and existing workarounds (SessionStart hook injection, plugin CLAUDE.md).

## Sources

- [Goose GitHub (block/goose)](https://github.com/block/goose)
- [Goose Documentation](https://block.github.io/goose/)
- [Goose Subagents Guide](https://block.github.io/goose/docs/guides/subagents/)
- [Goose Extension Types (DeepWiki)](https://deepwiki.com/block/goose/5.3-extension-types-and-configuration)
- [Goose Custom Distros (CUSTOM_DISTROS.md)](https://github.com/block/goose/blob/main/CUSTOM_DISTROS.md)
- [Goose OSS Roadmap Feb-Apr 2026](https://github.com/block/goose/discussions/6973)
- [Goose Smart Context Management](https://block.github.io/goose/docs/guides/sessions/smart-context-management/)
- [Building Custom Goose Extensions](https://block.github.io/goose/docs/tutorials/custom-extensions/)
- [Using .goosehints Files](https://dev.to/lymah/using-goosehints-files-with-goose-304m)
- [Goose Recipes (PulseMCP Series)](https://www.pulsemcp.com/building-agents-with-goose/part-4-configure-your-agent-with-goose-recipes)
- [Goose with MCP Servers: Deep Dive](https://skywork.ai/skypage/en/Goose-with-MCP-Servers-A-Deep-Dive-for-AI-Engineers/1972517032359424000)
- [Linux Foundation AAIF Announcement (MCP, Goose, AGENTS.md)](https://www.linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation)
- [Goose Configuring for Team Environments](https://dev.to/lymah/configuring-goose-for-team-environments-and-shared-workflows-5ehn)
- [Claude Code Features Catalog (this repo)](cdocs/reports/2026-03-13-claude-code-features-catalog.md)
- [Plugin Rules API Research (this repo)](cdocs/reports/2026-03-07-plugin-rules-api-research.md)

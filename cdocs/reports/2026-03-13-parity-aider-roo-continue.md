---
first_authored:
  by: "@claude-sonnet-4-6"
  at: 2026-03-13
type: report
report_type: analysis
state: final
status: complete
tags: [research, parity, aider, roo-code, continue, claude-code]
---

# Feature Parity: Aider, Roo Code, and Continue vs Claude Code

> BLUF: Claude Code leads decisively on extensibility infrastructure (plugin marketplace, hooks, MCP, skills).
> Roo Code is the closest competitor via Boomerang orchestration and per-mode rule scoping.
> Aider holds its lead in git fidelity and repo mapping but has no plugin system.
> Continue is repositioning around CI-enforced checks and team-wide rule distribution, which is genuinely differentiated — but not a superset of Claude Code's developer-session capabilities.
> For the rules/plugin reusability angle: AGENTS.md convergence reduces lock-in, but no competitor matches Claude Code's `paths:` conditional activation or the plugin-as-distribution-unit model.

## Scope and Methodology

This report compares three tools (Aider 42K stars, Roo Code, Continue 32K stars) against Claude Code across the full CC feature surface.
Data gathered via web search (March 2026), official documentation, and GitHub issue trackers.
Ratings use four levels: **parity** (equivalent capability), **partial** (covers the use case with meaningful gaps), **absent** (feature does not exist), **ahead** (competitor has a capability CC lacks).

---

## Feature-by-Feature Parity Table

| CC Feature | Aider | Roo Code | Continue |
|---|---|---|---|
| Background agents | absent | parity | parity |
| Task lists / plan mode | partial | parity | parity |
| Subagent orchestration | absent | parity | partial |
| Skills / slash commands | absent | parity | partial |
| Plugin marketplace | absent | absent | partial |
| Hooks (pre/post tool-use) | absent | absent | absent |
| MCP integration | partial | parity | parity |
| Extended thinking | partial | parity | parity |
| Memory / persistent context | absent | absent | partial |
| Permission modes / sandboxing | partial | parity | partial |
| Multi-model routing | parity | parity | parity |
| Context management (repo map) | **ahead** | partial | partial |
| CI / headless / remote execution | partial | partial | **ahead** |
| Rules system (project-level) | partial | parity | partial |
| Rules: conditional activation | absent | absent | absent |
| Rules: org-level distribution | partial | partial | partial |
| Rules: cross-tool portability | **ahead** | partial | partial |

---

## Detailed Breakdowns by Feature Area

### Background Agents

**Roo Code — parity.**
Boomerang Tasks provide a native orchestrator mode that spawns subtasks in isolated contexts, delegating to specialized modes (Code, Architect, Debug) and resuming on completion summary.
Each subtask operates with its own conversation history; information must be explicitly passed between layers.
The orchestrator can assign different LLM providers per mode.

**Continue — parity.**
Continue CLI's headless mode runs agents in CI/CD pipelines (GitHub Actions, GitLab CI, Jenkins).
The `cn` CLI supports async agents that address Sentry alerts, resolve Snyk vulnerabilities, triage GitHub issues, and maintain documentation — all without a human in the loop.

**Aider — absent.**
Aider is single-session and single-agent.
No mechanism exists for spawning subtasks or background execution.
AiderDesk (third-party GUI wrapper) adds some workflow automation via JavaScript hooks but this is not Aider proper.

---

### Subagent Orchestration

**Roo Code — parity.**
Orchestrator mode + Boomerang is production-grade.
A commander model creates a task list, then delegates implementation subtasks to specialized subagents (including different providers/models per subtask).
Context isolation is explicit: the parent passes state down via initial instructions, and up via completion summaries.

**Continue — partial.**
Agent mode has tool-use loops but the orchestration model is single-agent with tool calls, not multi-agent delegation.
Cloud agents can run in parallel for CI tasks but the session-level UX is still single-threaded.

**Aider — absent.**
No orchestration layer exists.

---

### Skills / Slash Commands

**Roo Code — parity.**
Skills package task-specific instructions that activate on-demand when request context matches the skill's purpose.
Skills can be exposed as slash commands via the `run_slash_command` tool.
Slash commands are markdown files stored in `.roo/` and can be triggered programmatically, enabling chained automated workflows.

**Continue — partial.**
Continue has prompt templates and custom commands in `config.yaml`.
These are session-scoped and reusable within a team via Hub distribution, but not packaged as composable skill units with activation conditions.

**Aider — absent.**
Aider has no slash command or skill system.
Custom prompts must be managed externally (shell aliases, wrapper scripts).

---

### Plugin Marketplace

**Claude Code** — 340+ plugins (as of early March 2026, the ecosystem has grown significantly).
Plugins bundle skills, agents, hooks, MCP servers, and LSP servers as a single distributable unit.
Custom marketplace registration: `/plugin marketplace add org/repo`.

**Roo Code — absent.**
Custom modes can be exported as YAML and imported via one click.
A community Mode Gallery exists with pre-tested configurations.
This covers mode/persona sharing but is not a plugin system — there is no bundled distribution of tools, hooks, and commands as a unit.

**Continue — partial.**
Continue Hub is the most marketplace-like analog among the three competitors.
Rule blocks, prompt templates, model configs, and assistant configurations are published as packages and can be installed into a team's config.
Updates propagate automatically across team environments.
However, Hub cannot bundle hooks or MCP server definitions alongside rules — it distributes configuration components, not executable extension units.
There is no equivalent to CC's plugin-as-a-unit model that co-deploys rules + skills + hooks in one install.

**Aider — absent.**
No plugin or marketplace system.
The community conventions repo (`Aider-AI/conventions`) is a shared file library, not a package registry.

---

### Hooks (Pre/Post Tool-Use)

**Claude Code** — full lifecycle hook system: `PreToolUse`, `PostToolUse`, `Stop`, `Notification`, `UserPromptSubmit`, `SubagentStop`.
Hooks run shell commands or HTTP endpoints.
Plugins can declare hooks in their manifest.

**Roo Code — absent.**
AiderDesk (third-party) implements JavaScript hooks for events, but Roo Code itself has no hook lifecycle.
Mode-specific rules and custom instructions fill some behavioral control needs but cannot intercept tool calls.

**Continue — absent.**
No pre/post tool-use hook system in the IDE extension or CLI.
CI-based checks approximate some post-edit enforcement patterns but these run asynchronously after a PR, not inline during agent execution.

**Aider — absent.**
Aider integrates with the git pre-commit hook ecosystem (via `--git-commit-verify` flag).
This is standard git plumbing, not an agent tool-use lifecycle hook.
Aider skips pre-commit hooks by default (`--no-verify`).

---

### MCP Integration

**Roo Code — parity.**
Full MCP client support.
Orchestrator mode can expose itself as an MCP server for other tools.

**Continue — parity.**
MCP tools are available in both Agent mode and Plan mode (read-only MCP tools only in Plan).

**Aider — partial.**
Aider added basic MCP client support but it is not a first-class feature with the same depth as Roo Code or CC.
Tool invocation is available but MCP server composition and marketplace distribution are absent.

---

### Context Management / Repo Map

**Aider — ahead.**
Aider's tree-sitter repo map is the most sophisticated among these tools.
It extracts symbol definitions using tree-sitter, builds a NetworkX dependency graph with PageRank, and ranks definitions by relevance to include only a token-budget-limited slice.
100+ languages supported (recently expanded via tree-sitter-language-pack).
This is the model Aider is most differentiated on versus CC's context management, which relies on explicit `@file` references and `--include` patterns.

**Roo Code — partial.**
Context is file-based with manual `@file` references.
No automated repo map or graph-based relevance ranking.

**Continue — partial.**
Continue's IDE extension has codebase indexing for context retrieval, but the CLI mode relies on explicit file references similar to Roo Code.

---

### CI / Headless / Remote Execution

**Continue — ahead.**
Continue CLI is designed from the ground up for CI integration.
`cn` (the Continue CLI) supports headless mode (minimal output, Unix-pipeable) and TUI mode (interactive).
AI checks are stored as markdown files and are natively enforceable in CI pipelines via GitHub Actions / Jenkins / GitLab CI.
This is Continue's primary 2026 positioning: "quality control for your software factory."

**Aider — partial.**
Aider can be scripted non-interactively via `--message` flags and stdin, making CI use possible.
Not designed for CI-first workflows; lacks structured check output or PR integration.

**Roo Code — partial.**
VS Code-first; no standalone CLI.
Background agents exist inside the VS Code extension only.
CI integration requires third-party wrappers.

---

### Memory / Persistent Context

**Claude Code** — `CLAUDE.md` hierarchy (user global → project → subdir), `@` imports, memory compaction, and `/memory` commands.

**Continue — partial.**
Continue Hub persists team configurations and rules across sessions.
Individual session memory is not a first-class feature in the CLI; rules in `config.yaml` are the primary persistence mechanism.

**Roo Code — absent.**
Roo Code has no built-in memory system.
Context is per-task; mode-specific rules in `.roo/rules/` approximate project memory but do not persist agent-generated knowledge.

**Aider — absent.**
`.aider.conf.yml` persists preferences; `--read` files persist context for a session.
No agent-managed memory or automatic context compaction.

---

## Deep Dive: Rules and Plugin Reusability

This section addresses the five specific questions raised in the brief.

### 1. Aider's CONVENTIONS.md and Community Conventions Repo

**How it works:**
Aider loads a conventions file via `--read CONVENTIONS.md` or by configuring `read: CONVENTIONS.md` in `.aider.conf.yml`.
The file is marked read-only, which enables prompt caching when the model supports it.
The community repo [`Aider-AI/conventions`](https://github.com/Aider-AI/conventions) collects contributed convention files organized by stack (Python, TypeScript, Django, etc.).

**For org standards:**
The pattern works well for single-project consistency: one `CONVENTIONS.md` per repo, version-controlled with the code.
For org-wide standards, the workflow is: maintain a central conventions repo, reference it in each project's `.aider.conf.yml` as a `--read` path, or symlink/copy the file into each project.
There is no package/dependency mechanism — distribution is by file copy, symlink, or git submodule.
Updating org standards requires propagating the file change to every project manually (no registry, no versioned install).

**Verdict:**
Viable for team consistency within a project.
Painful for org-wide standards with many repos; version drift is unmanaged.
No equivalent to CC's plugin marketplace install where rules propagate automatically.

---

### 2. Roo Code's `.roo/rules/` with Recursive Loading vs. `.claude/rules/`

**How Roo Code loads rules:**
- `.roo/rules/` — global workspace rules, applied to ALL modes.
- `.roo/rules-{modeSlug}/` — mode-specific rules, applied only when that mode is active.
- Files are loaded recursively including subdirectories, appended in alphabetical filename order.
- `AGENTS.md` is loaded after mode-specific rules, before generic rules from `~/.roo/rules/`.
- Recursive subfolder loading (v3.38.3+): optional setting to auto-load rules from subdirectories, useful for monorepos.

**Comparison to `.claude/rules/`:**
Roo's mode-scoped rules (`.roo/rules-code/`, `.roo/rules-architect/`) are more granular than CC's directory-based approach for separating concerns by task type.
CC's equivalent is primarily file-based path scoping (the `paths:` frontmatter), not mode/persona scoping.
Roo's recursive subfolder loading for monorepos matches CC's subdirectory `CLAUDE.md` hierarchical loading pattern.

**Is it better?**
The mode-scoped directories are a meaningful usability advantage: activating different rule sets by switching modes (Code → Architect → Debug) is more ergonomic than managing path globs.
However, Roo's rules system has no equivalent to CC's `paths:` conditional activation — rules activate by mode selection, not by which files the agent is touching.
Roo also lacks the `@import` mechanism to compose rules from other files.

**`AGENTS.local.md`:**
This is a user-local override file (not committed to the repo) loaded alongside `AGENTS.md`, serving the same purpose as `.claude/settings.local.json` — user-specific overrides that shouldn't be shared.

---

### 3. Continue Hub: Viable Marketplace?

**What it is:**
Continue Hub is a centralized repository of AI assistant building blocks: models, rules, prompts, MCP tool configs, and assistant configurations.
Teams can publish rule blocks, subscribe to updates, and propagate changes to all team environments automatically.
Rule blocks are installed into `config.yaml` and activated globally or per-model.

**Can it distribute rules + checks as packages?**
Yes, with meaningful caveats:
- Rules (behavioral instructions) and CI check definitions (markdown files) can be published and installed via Hub.
- A team can maintain a private Hub org and push standardized rules to all members' configs.
- Automatic propagation is the strongest feature: when a rule block is updated, the change flows to all subscribers without manual file copying.

**Where it falls short vs. CC's marketplace:**
- Continue Hub distributes configuration components, not executable extension units.
  A Hub "package" cannot bundle a CLI hook, a custom tool definition, and a set of rules as one installable unit.
- There is no equivalent to CC's `plugin.json` manifest that declares skills + agents + hooks + MCP servers together.
- Hub is cloud-mediated; offline or air-gapped installation is not supported.
- No versioning for rollback (a breaking rule change propagates immediately to all subscribers).

**Verdict:**
Continue Hub is the most credible team-rules-distribution system among the three competitors.
It is ahead of Aider's file-copy approach and Roo Code's manual YAML export/import.
It is not a plugin marketplace — it is a config synchronization system.

---

### 4. Conditional Rule Activation (Like CC's `paths:` Frontmatter)

**Claude Code:**
Rules in `.claude/rules/` support a `paths:` YAML frontmatter field with glob patterns.
A rule only activates when CC is working with files matching those patterns.
This enables fine-grained context injection: TypeScript rules only fire on `.ts` files, migration rules only fire in `db/migrations/`.

**Aider — absent.**
All conventions files are loaded unconditionally for the session.
No path-based or task-based filtering exists.

**Roo Code — absent.**
Rule activation is scoped by mode (`rules-code/`, `rules-architect/`) not by file path.
There is no glob-pattern filtering equivalent to `paths:`.
A bug report from February 2026 references `paths:` frontmatter in CC (not Roo Code), confirming Roo does not implement this pattern.

**Continue — absent.**
Rules in `config.yaml` apply globally or per-model; there is no file-path-conditional activation.
CI checks are file-targeted via the check definition's scope, but this is a CI enforcement mechanism, not a session-level rule activation system.

**Verdict:**
`paths:` conditional activation is a Claude Code exclusive among these four tools.
It is particularly valuable for monorepos where different subdirectories have different conventions.
No competitor has an equivalent, though Roo's mode-scoping achieves a related goal via a different UX.

---

### 5. Cross-Tool Rule Portability: Does Our cdocs Rules "Just Work" in Aider?

**What Aider reads:**
Aider reads `AGENTS.md` from the project root (the cross-tool standard).
It also reads `CLAUDE.md` and `.cursorrules` as legacy convention sources.
Reading is unconditional: the file is loaded as a read-only context document, not as a structured rules system.

**The practical answer:**
Yes and no.

*Yes*: The prose content of `CLAUDE.md` (or any file Aider loads) is passed to the LLM as context.
If our cdocs rules are written as clear natural-language instructions (which they are — they use BLUF format, markdown prose, etc.), Aider will follow them the same way it follows any CONVENTIONS.md content.
The LLM does not care whether the file was written for CC or Aider.

*No*: Aider does not interpret CC-specific structural features:
- `@path/to/other-file` imports are not resolved — Aider reads the file literally, so the import reference appears as text.
- `paths:` YAML frontmatter is not parsed — it appears as a YAML block at the top of the rule content.
- Skills and hooks declared in `.claude/` structure have no meaning to Aider.
- The `.claude/rules/` directory is not scanned by Aider — only the specific files configured via `--read` or `aider.conf.yml` are loaded.

**What this means for cdocs rules:**
The prose rules in `plugins/cdocs/rules/writing-conventions.md` and `workflow-patterns.md` would be followed by Aider if explicitly loaded (`aider --read plugins/cdocs/rules/writing-conventions.md`).
The `frontmatter-spec.md` rule's `paths: [cdocs/**/*.md]` frontmatter would appear as literal YAML text rather than being applied conditionally — it would still read as an instruction, just without the filtering.

**The rulesync ecosystem:**
Third-party tools (`rulesync`, `rule-porter`) now exist to convert between rule formats.
These can take `.claude/rules/` content and output it as `AGENTS.md`, `.cursorrules`, or Copilot instructions.
They handle the structural translation (resolving imports, stripping CC-specific frontmatter) but still produce a monolithic file, not a structured directory.

---

## Summary Assessment

### Where CC Is Ahead

- **Plugin marketplace as distribution unit**: No competitor bundles skills + agents + hooks + MCP in one installable unit.
  Continue Hub is the closest analog but distributes config components, not executable extension packages.
- **Hooks lifecycle**: Pre/post tool-use interception is CC-exclusive among these tools.
  This is the capability that enables automated enforcement, audit logging, and test-after-edit workflows.
- **`paths:` conditional activation**: Absent in all three competitors.
  The monorepo use case (different rules for different subdirectories) is solved only by CC.
- **Plugin rules gap**: CC has a known gap here too — plugins cannot declare rules that auto-load in installing projects (see `#14200`).
  This is a shared limitation, but CC is the only tool where the infrastructure exists to close it.

### Where Competitors Have Meaningful Advantages

- **Aider / repo map**: Tree-sitter + PageRank relevance scoring gives Aider the best out-of-the-box code understanding with no `@file` annotation burden.
  CC requires explicit context inclusion; Aider infers it.
- **Continue / CI-first design**: Continue's headless CLI, structured check output, and native GitHub Actions integration make it the strongest tool for enforcing AI-assisted standards in CI pipelines.
  CC's hooks can approximate this but it is not CC's primary design mode.
- **Roo Code / mode-scoped rules**: The `rules-{modeSlug}/` directory pattern is a practical and ergonomic solution for task-type rule separation that CC does not have a direct equivalent for.

### Cross-Tool Convergence

AGENTS.md has become a genuine cross-tool standard (Aider, Roo Code, CC, Cursor, Copilot, Gemini CLI, Windsurf, Zed, Warp).
Rule content written as clear natural-language markdown is now substantially portable across tools at the prose level.
Structural features (CC's `paths:`, Roo's mode directories) remain tool-specific.
The convergence reduces lock-in for rule *content* while leaving the *activation and distribution infrastructure* as a key differentiator for CC.

---

## Sources

- [Aider Documentation](https://aider.chat/docs/)
- [Aider Git Integration](https://aider.chat/docs/git.html)
- [Aider Specifying Coding Conventions](https://aider.chat/docs/usage/conventions.html)
- [Aider-AI/conventions community repo](https://github.com/Aider-AI/conventions)
- [Aider Repo Map](https://aider.chat/docs/repomap.html)
- [Roo Code Documentation](https://docs.roocode.com/)
- [Roo Code Custom Instructions](https://docs.roocode.com/features/custom-instructions)
- [Roo Code Custom Modes](https://docs.roocode.com/features/custom-modes)
- [Roo Code Boomerang Tasks](https://docs.roocode.com/features/boomerang-tasks)
- [Roo Code Skills](https://docs.roocode.com/features/skills)
- [Roo Code Slash Commands](https://docs.roocode.com/features/slash-commands)
- [Roo Code v3.38.3 Release Notes (recursive subfolder rules)](https://docs.roocode.com/update-notes/v3.38.3)
- [Roo Code AGENTS.md issue #5966](https://github.com/RooCodeInc/Roo-Code/issues/5966)
- [Continue Documentation](https://docs.continue.dev/overview)
- [Continue Agent Mode](https://docs.continue.dev/ide-extensions/agent/how-it-works)
- [Continue Plan Mode](https://docs.continue.dev/ide-extensions/agent/plan-mode)
- [Continue Hub Introduction](https://docs.continue.dev/hub/introduction)
- [Continue Hub: Creating Rule Blocks](https://blog.continue.dev/creating-rule-blocks-on-continue-hub-a-developers-guide/)
- [Continue CLI Guide](https://docs.continue.dev/guides/cli)
- [Claude Code Plugins Documentation](https://code.claude.com/docs/en/plugins)
- [Claude Code Path-Specific Rules](https://paddo.dev/blog/claude-rules-path-specific-native/)
- [Claude Code Memory Documentation](https://code.claude.com/docs/en/memory)
- [Claude Code Plugin Marketplace Distribution](https://code.claude.com/docs/en/plugin-marketplaces)
- [AGENTS.md cross-tool standard (Medium)](https://addozhang.medium.com/agents-md-a-new-standard-for-unified-coding-agent-instructions-0635fc5cb759)
- [rulesync cross-tool rules tool](https://dev.to/dyoshikawatech/rulesync-published-a-tool-to-unify-management-of-rules-for-claude-code-gemini-cli-and-cursor-390f)
- [rule-porter format converter](https://dev.to/nedcodes/rule-porter-convert-cursor-rules-to-claudemd-agentsmd-and-copilot-4hjc)

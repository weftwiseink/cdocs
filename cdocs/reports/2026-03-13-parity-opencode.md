---
first_authored:
  by: "@claude-sonnet-4-6"
  at: 2026-03-13
type: report
report_type: analysis
state: final
status: complete
tags: [research, parity, opencode, claude-code]
---

# Feature Parity: OpenCode vs Claude Code (March 2026)

> BLUF: OpenCode matches or exceeds Claude Code on multi-model flexibility, TUI/session UX, LSP integration, and hook granularity. Claude Code leads on plugin distribution (marketplace), scoped rules, agent orchestration depth, sandboxing, and memory. The **rules/plugin reusability** gap is the sharpest structural difference: OpenCode's opencode-rules plugin and npm distribution offer a cleaner path than Claude Code's current plugin-rules workarounds, but lack the CDocs-style structured manifest and marketplace discoverability.

---

## Ratings Key

- **parity** — functionally equivalent for common use cases
- **partial** — meaningful capability present but narrower, less ergonomic, or community-supported only
- **absent** — no current equivalent; may be on roadmap
- **ahead** — OpenCode's implementation is broader or more capable

---

## Feature Parity Table

| CC Feature | OpenCode Rating | Notes |
|------------|----------------|-------|
| Background agents | partial | ACP enables headless background sessions; no `background: true` frontmatter equivalent |
| Task tracking (TodoWrite) | absent | No native task list or checklist system |
| Subagents (Task tool) | partial | Build + Plan + General + Explore agents; no flat 7-parallel dispatch via a `Task` tool |
| Agent teams (parallel multi-agent) | partial | Parallel named sessions via `-s`; no cross-agent communication |
| Skills / SKILL.md | partial | Plugins can register tools; no `SKILL.md` frontmatter conventions or skill menu |
| Plugin marketplace | absent | npm + community lists (awesome-opencode); no formal registry or manifest-based distribution |
| Hooks — pre/post tool-use | ahead | 30+ event types in JS/TS plugins; CC has 9 shell-command events |
| Hooks — shell/config | partial | Config-based hooks are experimental and limited to `file_edited` + `session_completed` |
| MCP servers | parity | Both support MCP; OpenCode auto-installs via Bun, CC manages via `/mcp` command |
| Plan mode | parity | Plan agent (read-only, analysis-only) is a direct equivalent; Tab-switchable |
| Extended thinking | partial | Adaptive thinking supported via Claude Sonnet 4.6 / Opus 4.6 API keys; not OpenCode-native |
| Memory — CLAUDE.md / AGENTS.md | parity | AGENTS.md natively; also reads CLAUDE.md and `~/.claude/CLAUDE.md` as fallback |
| Memory — auto-memory | partial | Third-party only (claude-mem-opencode, opencode-mem plugins); no native equivalent |
| Memory — scoped agents | absent | No `memory: user | project | local` per-agent scoping |
| Permission modes | partial | Glob-based allow/deny for commands; no four-mode (default/auto/plan/bypass) abstraction |
| OS-level sandboxing | absent | "Workspaces" (Docker/cloud isolation) are on the roadmap but not shipped |
| Multi-model support | ahead | 75+ providers; local models (Ollama, LM Studio, vLLM); CC is Anthropic-only |
| Fast mode | absent | No explicit speed/cost mode toggle; provider selection achieves similar ends |
| Context management — auto-compact | absent | No built-in compaction; relies on provider context window and LSP context enrichment |
| Context management — /context | absent | No context usage breakdown command |
| LSP integration | ahead | Native LSP for code intelligence; CC has no LSP support |
| ACP (Agent Client Protocol) | ahead | Full ACP server; CC has no equivalent protocol for editor-agent communication |
| Multi-session TUI | ahead | Named sessions, Tab-switching, HTTP API for remote control; CC's background agents are not TUI-visible |
| Remote execution / cloud VMs | partial | HTTP API allows remote control; no Anthropic-managed cloud VM equivalent |
| GitHub Actions | absent | No `opencode-action` CI runner; ACP covers IDE integration only |
| Git integration | parity | Both handle commits, PRs, branches; CC has `--from-pr` and `--worktree` flags |
| IDE integrations | ahead | ACP support for Zed, Neovim, Emacs, JetBrains; CC has VS Code extension + JetBrains AI |
| Worktrees | absent | No `--worktree` flag or parallel-branch isolation |

---

## Deep Dive: Rules and Plugin Reusability

This is the primary concern for packaging cdocs conventions as reusable standards.

### How opencode-rules Works

opencode-rules is a **community plugin** (not built-in) that discovers and injects markdown rule files into agent system prompts.

**Discovery paths:**
- Global: `~/.config/opencode/rules/`
- Project: `.opencode/rules/`

**File formats:** `.md` and `.mdc` (both accept optional YAML frontmatter).

**Conditional activation via frontmatter:**

```yaml
---
globs:
  - "src/**/*.ts"
keywords:
  - "test"
  - "spec"
tools:
  - "mcp://github/search"
model: claude-sonnet*
agent: build
branch: "feature/*"
os: linux
ci: false
match: all   # default is "any"
---
```

- `globs` activates on file path matches in the current context (uses minimatch).
- `keywords` activates on case-insensitive word-boundary match in the user's prompt.
- `tools` activates when listed MCP tool IDs are available.
- Runtime filters (`model`, `agent`, `branch`, `os`, `ci`) match the live environment.
- `match: any` (default) = OR logic; `match: all` = AND logic.

This is **richer than Claude Code's `.claude/rules/` system**, which supports `paths:` frontmatter (file pattern scoping) but not prompt-keyword matching, model/agent-specific activation, or branch/OS/CI conditions.

### Can OpenCode Plugins Bundle Rules + Tools Together?

Yes, with a critical caveat.

An OpenCode npm plugin is a single JS/TS file that can:
1. Register custom tools (`plugin.addTool(...)`)
2. Hook into events (including `session.created`, pre/post message events)
3. Inject context at session start

A plugin **cannot** directly ship `.md` rule files the way opencode-rules loads them — that requires the user to also install opencode-rules and populate the rules directories. However, a plugin can **simulate rule injection** by:

- Using the `session.created` hook to inject markdown content as system context.
- Shipping an `install` script that copies `.md` files into `.opencode/rules/`.

**In practice**, the closest pattern to "bundle rules + tools in one npm package" is:
1. The plugin JS registers tools and event hooks.
2. The plugin's `package.json` includes a `postinstall` script that copies rule files to `.opencode/rules/`.
3. Users install opencode-rules globally; the plugin's rules become discoverable.

This is more ergonomic than Claude Code's workaround (SessionStart hook injection) but relies on a postinstall convention rather than a first-class manifest field.

### npm Distribution vs CC Plugin Marketplace

| Dimension | OpenCode (npm) | Claude Code (marketplace) |
|-----------|---------------|--------------------------|
| Discovery | Manual (awesome-opencode, npm search, GitHub) | `/plugin marketplace list`, official Anthropic registry |
| Install | Add to `opencode.json` config; Bun auto-installs | `/plugin install <name>` |
| Manifest | `package.json` (npm standard) | `plugin.json` (CC-specific schema) |
| Rules bundling | No first-class support; postinstall convention | No first-class support; open FR [#14200](https://github.com/anthropics/claude-code/issues/14200) |
| Scoped packages | Yes (`@org/plugin-name`) | Yes (publisher namespacing) |
| Versioning | npm semver | Plugin version field in manifest |
| Trust model | No trust model; all plugins execute at install | Trust gates on hook/MCP execution |
| Private distribution | npm private registry or local file path | Local file path or git URL |

**Net assessment**: npm distribution is more familiar to TypeScript developers and has better tooling (npm audit, dependabot). CC's marketplace offers discoverability and a trust model. Neither has native rules bundling — this is a parity gap in both ecosystems.

### CC `.claude/rules/` Scoped Rules vs OpenCode Equivalents

CC's `.claude/rules/` system:
- Markdown files with optional `paths:` frontmatter (glob-scoped to file patterns).
- Loaded by CC at session start; visible in `/memory`.
- `@`-mentionable from CLAUDE.md.
- **Plugins cannot declare rules.** Rules must be in the project's `.claude/rules/`, not in the plugin cache.

OpenCode's scoped rules (via opencode-rules plugin):
- Markdown files in `.opencode/rules/` (project) or `~/.config/opencode/rules/` (global).
- Conditional on `globs`, `keywords`, `model`, `agent`, `branch`, `os`, `ci`.
- **Not built-in**: requires installing opencode-rules separately.
- A plugin can ship rules files via postinstall convention.

**The structural difference**: CC has native rules with scope/path support but no plugin delivery path. OpenCode has richer conditional activation but relies on a community plugin and a convention for plugin delivery. Neither fully solves "install a plugin, get its rules automatically."

For cdocs specifically:
- In CC: cdocs rules work in the source repo (local `@`-imports); external installs need SessionStart hook injection (workaround B from the plugin-rules research).
- In OpenCode: cdocs could publish an npm plugin that registers tools and runs a postinstall to populate `.opencode/rules/` from the package. opencode-rules then discovers those files. This is a workable delivery path — arguably better than CC's current workaround — but it still requires two packages (cdocs plugin + opencode-rules).

---

## Summary Scorecard

| Category | OpenCode | Claude Code |
|----------|----------|-------------|
| Model breadth | ++ | -- (Anthropic-only) |
| TUI / session UX | ++ | + |
| LSP / editor integration | ++ | + |
| Hook granularity | ++ | + |
| Plugin marketplace | -- | ++ |
| Scoped rules (native) | + (via plugin) | ++ |
| Rules-in-plugin delivery | + (postinstall convention) | - (workaround only) |
| Subagent orchestration | + | ++ |
| Background agents | + | ++ |
| Sandboxing | -- | ++ |
| Memory / auto-memory | - | ++ |
| Context management | - | ++ |
| Remote / cloud execution | + | ++ |
| CI / GitHub Actions | -- | ++ |
| Open source | ++ (MIT) | - (source-available) |

---

## Implications for weft/cdocs

1. **cdocs conventions as reusable standards across both tools is viable but requires two separate delivery formats:**
   - CC: `plugin.json` + SessionStart hook injection (pending [#14200](https://github.com/anthropics/claude-code/issues/14200) for a cleaner path).
   - OpenCode: npm package with postinstall script populating `.opencode/rules/` + opencode-rules as a declared peer dependency.

2. **OpenCode's opencode-rules conditional activation is a genuine capability advantage** for targeting rules at specific file types, branches, or models — useful if cdocs rules should only activate on `.md` files, or only in the cdocs plugin context. CC's `paths:` frontmatter handles the file-type case but not the model/agent/branch cases.

3. **npm distribution reduces friction for OpenCode adoption** relative to CC's marketplace install flow for TypeScript-native teams, since `opencode.json` already uses npm package names.

4. **Neither ecosystem fully solves plugin-bundled rules today.** For a team that wants a single-install path to adopt cdocs conventions, both require either: (a) waiting for native rules-in-plugin support, or (b) running a setup step (SessionStart hook on CC, postinstall script on OpenCode).

---

## Sources

- [OpenCode Plugins Docs](https://opencode.ai/docs/plugins/)
- [OpenCode Rules Docs](https://opencode.ai/docs/rules/)
- [OpenCode Agents Docs](https://opencode.ai/docs/agents/)
- [OpenCode ACP Docs](https://opencode.ai/docs/acp/)
- [frap129/opencode-rules on GitHub](https://github.com/frap129/opencode-rules)
- [OpenCode vs Claude Code — Morph LLM](https://www.morphllm.com/comparisons/opencode-vs-claude-code)
- [OpenCode vs Claude Code Hooks Comparison](https://gist.github.com/zeke/1e0ba44eaddb16afa6edc91fec778935)
- [OpenCode vs Claude Code — Builder.io](https://www.builder.io/blog/opencode-vs-claude-code)
- [Claude Code vs OpenCode — Infralovers](https://www.infralovers.com/blog/2026-01-29-claude-code-vs-opencode/)
- [claude-mem-opencode](https://github.com/mc303/claude-mem-opencode)
- [opencode-mem](https://github.com/bloodf/opencode-mem)
- [oh-my-opencode on npm](https://www.npmjs.com/package/oh-my-opencode)
- [awesome-opencode](https://github.com/awesome-opencode/awesome-opencode)
- [cdocs/reports/2026-03-07-plugin-rules-api-research.md](../reports/2026-03-07-plugin-rules-api-research.md) — CC plugin rules gap analysis
- [cdocs/reports/2026-03-13-claude-code-features-catalog.md](../reports/2026-03-13-claude-code-features-catalog.md) — CC feature baseline
- [cdocs/reports/2026-03-13-agent-harness-alternatives.md](../reports/2026-03-13-agent-harness-alternatives.md) — landscape context

---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-13
type: report
report_type: analysis
state: final
status: complete
tags: [research, executive-summary, agent-harness, landscape, claude-code-alternatives]
---

# Agent Harness Landscape: Executive Summary

> BLUF: Claude Code remains the most featureful agent harness overall, but its moat is narrowing fast.
> OpenCode and Gemini CLI are the strongest open alternatives — OpenCode for breadth and extensibility, Gemini CLI for economics and org policy enforcement.
> **For weft's specific need (reusable cdocs rules as org standards), no tool fully solves plugin-bundled rules today.**
> Gemini CLI's extension model is currently *closer* to solving this than CC's plugin system, and OpenCode's community `opencode-rules` plugin offers richer conditional activation than CC's native `paths:` frontmatter.
> The cross-platform skills standard (SKILL.md) is converging across CC and Codex, with third-party indexers (Skills.sh) bridging the gap.

## Supporting Reports

| Report | Scope |
|--------|-------|
| [agent-harness-alternatives](2026-03-13-agent-harness-alternatives.md) | 18 tools surveyed across 3 tiers |
| [claude-code-features-catalog](2026-03-13-claude-code-features-catalog.md) | 17 CC features cataloged with maturity assessments |
| [parity-opencode](2026-03-13-parity-opencode.md) | OpenCode vs CC deep-dive |
| [parity-goose](2026-03-13-parity-goose.md) | Goose vs CC deep-dive |
| [parity-codex-gemini](2026-03-13-parity-codex-gemini.md) | Codex CLI + Gemini CLI vs CC deep-dive |
| [parity-aider-roo-continue](2026-03-13-parity-aider-roo-continue.md) | Aider + Roo Code + Continue vs CC deep-dive |

---

## Landscape at a Glance (March 2026)

The CLI agent harness space has exploded.
Six tools have crossed the "production-grade" threshold, three standards are converging (AGENTS.md, MCP, ACP), and the gap between leader and pack is closing quarterly.

| Tool | Stars | Best At | Worst At |
|------|-------|---------|----------|
| **Claude Code** | N/A (proprietary) | Plugin ecosystem, hooks, subagents, memory | Anthropic-only models, no free tier, plugin rules gap |
| **OpenCode** | 121K | Model breadth (75+), hooks (30+ events), ACP/LSP, MIT license | No marketplace, no sandboxing, no auto-memory |
| **Gemini CLI** | 97K | Free tier, 1M context, admin policy enforcement, SYSTEM.md | Gemini-only, no hooks, no marketplace |
| **Codex CLI** | 65K | Rust perf, OS sandbox (kernel-enforced), SKILL.md convergence | OpenAI-only, experimental hooks, no marketplace |
| **Aider** | 42K | Git-native workflow, repo map, cross-tool rule reading | No plugins/hooks/extensions whatsoever |
| **Goose** | 32K | MCP-native (3000+ tools), enterprise adoption (Block) | No plan mode, no marketplace, no sandboxing |

---

## Where CC Still Leads

1. **Plugin marketplace** — CC is the only tool with a formal registry, manifest format, trust model, and one-command install. 340+ plugins, 1300+ skills. Nothing else comes close.
2. **Hook lifecycle** — 17 events including PreToolUse (with block/allow decisions) and PostToolUse. OpenCode's JS plugin hooks are richer in event count (~30) but lack the allow/deny gate pattern. Codex has 4 experimental events. Gemini has zero.
3. **Subagent orchestration** — Up to 7 parallel subagents with model selection, dedicated agent types (Explore, Plan, Bash), and Agent Teams (research preview). No competitor has equivalent depth.
4. **Memory system** — CLAUDE.md + auto-memory + scoped memory per agent. Competitors have instruction files but not adaptive, auto-accumulating memory.
5. **Context management** — Auto-compact at 83.5%, `/compact` with focus, `/context` breakdown, prompt caching (12x cost reduction). Most competitors rely on raw context window size.

## Where CC is Behind or Tied

1. **Model lock-in** — Anthropic-only. OpenCode supports 75+ providers. Goose supports any LLM. This is CC's single biggest structural limitation.
2. **Org policy enforcement** — Gemini CLI's admin-tier TOML policy engine is more powerful for org governance than CC's permission modes or hooks. CC has no admin override tier.
3. **OS-level sandboxing** — Codex CLI's kernel-enforced sandbox (Seatbelt/Landlock/seccomp) is harder than CC's bubblewrap approach. Gemini has declarative tool annotations.
4. **Economics** — Gemini CLI offers a free tier with 1M context. CC requires a paid subscription.
5. **Open source** — CC is source-available but not MIT/Apache. OpenCode, Aider, Goose, Codex, Gemini CLI are all Apache 2.0 or MIT.
6. **LSP/ACP** — OpenCode has native LSP integration and serves as an ACP server for editors. CC relies on IDE-specific extensions.

---

## The Rules/Plugin Reusability Question

This is the crux of weft's interest: **can we package cdocs conventions as reusable, installable standards across tools?**

### Current State by Tool

| Tool | Rules delivery | Conditional activation | Bundled with tools? | Distribution |
|------|---------------|----------------------|--------------------|----|
| **Claude Code** | `.claude/rules/*.md` with `paths:` | File-pattern globs | **No** — plugins can't declare rules ([#14200](https://github.com/anthropics/claude-code/issues/14200)) | Plugin marketplace (workaround: SessionStart hook) |
| **OpenCode** | `.opencode/rules/*.md` via opencode-rules | Globs, keywords, model, agent, branch, OS, CI | Partial — npm postinstall convention | npm packages |
| **Gemini CLI** | GEMINI.md + extension-bundled context | No conditional activation | **Yes** — extensions bundle context files that auto-load | GitHub URLs |
| **Codex CLI** | AGENTS.md hierarchy + skills | No conditional activation | Partial — skills bundle scripts | Manual / third-party marketplaces |
| **Aider** | CONVENTIONS.md (reads CLAUDE.md too) | None | No | File copy |
| **Roo Code** | `.roo/rules/` + mode-scoped dirs | Mode-based (not file-pattern) | No | File copy |
| **Continue** | Continue Hub | None | Partial — Hub distributes config | Continue Hub |

### Key Findings

1. **No tool fully solves "install plugin, get rules automatically" today.** CC has an open feature request (#14200). Gemini CLI's extension model is the closest to solving it — extensions can bundle context files. OpenCode requires a two-package approach (plugin + opencode-rules).

2. **OpenCode's conditional activation is the richest.** The community `opencode-rules` plugin supports 8 condition types (globs, keywords, model, agent, branch, OS, CI, tools) vs CC's single `paths:` frontmatter. This matters for cdocs rules that should only activate on certain file types or in certain contexts.

3. **Cross-tool portability is emerging but fragile.** Aider reads CLAUDE.md and .cursorrules. Roo Code reads AGENTS.md. But `@import` syntax, `paths:` frontmatter, and scoped rules directories are tool-specific. Rule *prose* is portable; rule *structure* is not.

4. **The SKILL.md format is converging.** CC and Codex both use it. Skills.sh indexes 83K skills across 18 agents. This is the most promising cross-platform standard for reusable workflows.

5. **AGENTS.md is the closest thing to a universal instructions standard.** Under Linux Foundation / AAIF governance, supported by OpenCode, Codex, Goose, Amp, Roo Code. 60K+ repos on GitHub. CC uses CLAUDE.md but could read AGENTS.md too.

### Recommendation for weft/cdocs

**Short-term (today):**
- Continue developing cdocs rules in CC's `.claude/rules/` format with `paths:` frontmatter.
- Use the SessionStart hook workaround for plugin-based delivery in CC (per the [plugin-rules-api-research](2026-03-07-plugin-rules-api-research.md)).
- Write cdocs convention *prose* in a tool-agnostic way so it reads correctly when loaded as AGENTS.md or CONVENTIONS.md.

**Medium-term (watch):**
- Track CC issue #14200 (plugin rules). If this ships, it's the cleanest solution.
- Prototype an OpenCode delivery format (npm package + opencode-rules peer dep) as a second distribution channel.
- Evaluate whether Gemini CLI's extension-bundled context files are worth targeting as a third format.

**Long-term (bet):**
- AGENTS.md + MCP + SKILL.md are the three converging standards. cdocs rules should be expressible in AGENTS.md, cdocs tools should be MCP servers, and cdocs workflows should be SKILL.md skills. This maximizes portability across the ecosystem.
- Consider publishing cdocs rules as a standalone AGENTS.md-compatible package (e.g., npm or git-based) that any tool can consume, with tool-specific wrappers for CC plugins, OpenCode plugins, and Gemini extensions.

---

## Overall Assessment

Claude Code is still the most capable tool for the kind of deeply-customized agentic workflows we build with cdocs — the combination of skills, hooks, subagents, memory, and the plugin marketplace creates a uniquely composable platform.

However, the landscape is converging fast:
- **OpenCode** is the strongest general-purpose open alternative, with a more extensible hook system and dramatically broader model support. Its main gap is marketplace infrastructure and memory.
- **Gemini CLI** is the most interesting for org governance, with admin-enforced policies and free 1M-token context. Its extension model is ahead of CC on bundled context delivery.
- **Codex CLI** is the most interesting for security-sensitive environments, with kernel-enforced sandboxing.
- **Aider** remains the best pure git-native coding assistant, but its lack of any extensibility makes it irrelevant for our plugin/rules distribution needs.
- **Goose** is compelling for teams already in the Block ecosystem, with the richest MCP integration, but lacks the rules/plugin infrastructure we need.

The honest truth: **the "reusable rules as org standards" problem isn't well-solved by any tool yet.** CC is closest with its plugin marketplace but is blocked on #14200. The best strategy is to write tool-agnostic convention prose, wrap it in tool-specific delivery mechanisms, and bet on the AGENTS.md + MCP + SKILL.md convergence to reduce the number of formats we need to maintain over time.

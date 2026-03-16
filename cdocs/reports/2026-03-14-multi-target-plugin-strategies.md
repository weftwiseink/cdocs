---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-14
type: report
report_type: analysis
state: final
status: complete
tags: [research, multi-target, plugins, opencode, claude-code, portability]
---

# Multi-Target Agent Harness Plugin Strategies

> BLUF: Publishing a single plugin (rules, skills, agents, hooks) across Claude Code and OpenCode is achievable today, but requires a build step: author in CC format (the canonical source), convert at install time.
> The GSD project and the compound-engineering converter have proven this pattern at scale.
> Skills (SKILL.md) are the most portable layer: both CC and OpenCode read the same format from the same directories.
> Rules are the messiest layer: AGENTS.md is converging as the cross-tool standard under AAIF, but CC still reads CLAUDE.md natively and treats AGENTS.md as advisory.
> Hooks are not portable at all and must be reimplemented per target.
> MCP servers are the only truly universal extension mechanism, but they solve tool functionality, not conventions.
> The recommended strategy for cdocs: keep CC plugin.json as canonical, ship skills as-is (already portable), translate agents/rules at install time, reimplement hooks per target, and use MCP for any tool logic that must work everywhere.

---

## 1. Current Multi-Target Approaches

### The "Author Once, Convert at Install Time" Pattern

The dominant approach in March 2026 is to author everything in Claude Code format, then convert to other targets during installation.
The most mature implementation is **GSD** (spec-driven development), which ships 11 specialized agents, slash commands, workflow definitions, templates, and hooks, and keeps them in sync across Claude Code, OpenCode, and Gemini CLI.

The **compound-engineering-plugin** from EveryInc provides a Bun/TypeScript CLI that converts Claude Code plugins to 10 additional targets:

```
bunx @every-env/compound-plugin install compound-engineering --to opencode
```

The converter auto-detects installed editors with `--to all` or targets specific platforms individually.

Each target receives functionally equivalent configurations adapted to its native format:

| Target | Output Format | Key Mappings |
|--------|---------------|--------------|
| OpenCode | `.md` agent files + `opencode.json` | MCP config deep-merged; `allowed-tools` arrays become `tools: { tool: true }` objects |
| Codex | Prompt/skill pairs | Descriptions truncated to 1024 chars |
| Gemini CLI | `.toml` files + directories | Namespaced commands become directories |
| Copilot | `.agent.md` + frontmatter | MCP env vars prefixed with `COPILOT_MCP_` |
| Windsurf | Skills + workflows | Agents become skills; commands become flat workflows |
| Droid | Tool name remapping | `Bash` becomes `Execute`, `Write` becomes `Create` |

### Alternative: The "Symbiotic Directory" Pattern

Projects like **everything-claude-code** take a different approach: maintain parallel directory structures (`.claude/`, `.opencode/`, `.agents/`) in a single repo, with shared markdown content and per-target configuration wrappers.
This avoids a build step but requires manual synchronization.

### The OpenSkills Approach

**OpenSkills** (`npx openskills`) takes a third path: it replicates Claude Code's `<available_skills>` XML format in an AGENTS.md file, making skills readable by any agent that supports that spec.
It treats skills as static, versioned assets that live alongside project code, with no server required.

---

## 2. The SKILL.md Convergence

### Format Compatibility

SKILL.md is the most portable layer in the agent plugin ecosystem.
Both Claude Code and OpenCode read skills from the same directories and use the same frontmatter format:

```yaml
---
name: my-skill
description: What this skill does
---

# Skill Instructions
[Agent-facing guidance]
```

Frontmatter fields recognized by both tools:
- `name` (required): 1-64 characters, lowercase alphanumeric with single hyphens
- `description` (required): 1-1024 characters

OpenCode additionally recognizes `license`, `compatibility`, and `metadata` fields.
Unknown fields are ignored, which means a CC skill with extra fields works in OpenCode without modification.

### Discovery Paths

OpenCode searches a 6-scope priority hierarchy that includes CC-compatible paths:

| Priority | Path | Native To |
|----------|------|-----------|
| 1 | `.opencode/skills/<name>/SKILL.md` | OpenCode |
| 2 | `.claude/skills/<name>/SKILL.md` | Claude Code |
| 3 | `.agents/skills/<name>/SKILL.md` | AGENTS.md spec |
| 4 | `~/.config/opencode/skills/<name>/SKILL.md` | OpenCode |
| 5 | `~/.claude/skills/<name>/SKILL.md` | Claude Code |
| 6 | `~/.agents/skills/<name>/SKILL.md` | AGENTS.md spec |

Project-local skills override global ones.
A skill in `.opencode/skills/` overrides a same-named skill in `.claude/skills/`.

This means: **a single `.claude/skills/` directory works in both CC and OpenCode without modification.**
CC reads it natively; OpenCode reads it as a compatibility fallback.

### Skills.sh as Distribution Channel

Skills.sh (launched by Vercel, January 2026) is a directory and leaderboard for skill packages.
It indexes skills from GitHub repos and provides a CLI for discovery and installation.
The related agentskill.sh indexes 100K+ skills across the ecosystem.

Skills.sh is a viable discovery channel, but it indexes skills that already exist in repos.
It does not add any format requirements beyond what SKILL.md already specifies.

**For cdocs:** The existing `skills/` directory structure is already portable.
No changes needed for OpenCode compatibility.

---

## 3. Rules Portability

### The Current Mess

Rules are the least portable layer.
Each tool has its own primary format:

| Tool | Primary Format | Reads Others |
|------|---------------|-------------|
| Claude Code | CLAUDE.md | Does not read AGENTS.md |
| OpenCode | AGENTS.md | Reads CLAUDE.md as fallback |
| Codex | AGENTS.md | Reads CLAUDE.md |
| Gemini CLI | GEMINI.md | Does not read CLAUDE.md or AGENTS.md |
| Cursor | .cursor/rules/ | Reads AGENTS.md |
| Copilot | .github/copilot-instructions.md | Reads AGENTS.md |
| Aider | CONVENTIONS.md | Reads AGENTS.md |

### OpenCode's Fallback Chain

OpenCode searches in this order:
1. Local files traversing upward from CWD: AGENTS.md first, then CLAUDE.md
2. Global: `~/.config/opencode/AGENTS.md`
3. Claude Code global: `~/.claude/CLAUDE.md` (unless disabled via `OPENCODE_DISABLE_CLAUDE_CODE`)

If both AGENTS.md and CLAUDE.md exist, only AGENTS.md is used.
This means a project can maintain a single CLAUDE.md and it works in OpenCode, or maintain both files with AGENTS.md as the primary.

### Conditional Activation

OpenCode's community `opencode-rules` plugin supports richer conditional activation than CC's native `paths:` frontmatter:

```yaml
---
globs: ["src/**/*.ts"]
keywords: ["test", "spec"]
model: claude-sonnet*
agent: build
branch: "feature/*"
os: linux
ci: false
match: all
---
```

CC supports only `paths:` for glob-based scoping.
This is a genuine capability gap: CC cannot scope rules by keyword, model, agent, branch, OS, or CI status.

### Practical Approach for cdocs

The cdocs rules (`writing-conventions.md`, `workflow-patterns.md`, `frontmatter-spec.md`) are pure markdown with optional `paths:` frontmatter.
They work in both CC (natively via `.claude/rules/`) and OpenCode (via `.claude/rules/` compatibility path, or copied to `.opencode/rules/`).

**Recommendation:** Keep `.claude/rules/` as the canonical location.
OpenCode reads it.
If richer activation is needed (keywords, agent-scoping), add opencode-rules-specific frontmatter in a separate `.opencode/rules/` copy, since CC ignores unknown frontmatter fields anyway.

---

## 4. Plugin Manifest Translation

### Format Comparison

| Aspect | Claude Code | OpenCode |
|--------|------------|----------|
| Manifest | `.claude-plugin/plugin.json` | `opencode.json` + `package.json` |
| Language | JSON (declarative) | JS/TS (imperative) |
| Skills | `skills/<name>/SKILL.md` (auto-discovered) | Same, plus `.opencode/skills/` |
| Agents | `agents/<name>.md` (auto-discovered) | `~/.config/opencode/agents/` or `.opencode/agents/` |
| Hooks | `hooks/hooks.json` (9 event types, shell commands) | JS/TS plugin exports (30+ event types) |
| Rules | `.claude/rules/` (native, `paths:` scoping) | `.opencode/rules/` (via opencode-rules plugin) |
| Distribution | Plugin marketplace (`/plugin install`) | npm (`opencode.json` plugin array) |
| MCP | `.mcp.json` | `opencode.json` mcp section |

### Agent Format Differences

CC agent frontmatter:

```yaml
---
name: triage
model: haiku
description: Analyze cdocs frontmatter
tools: Read, Glob, Grep, Edit
---
```

OpenCode agent frontmatter:

```yaml
---
description: Analyze cdocs frontmatter
mode: subagent
model: anthropic/claude-3-5-haiku-20241022
temperature: 0.3
tools:
  read: true
  write: true
  bash: false
permission:
  edit: ask
---
```

Key differences:
- CC uses comma-separated tool names; OpenCode uses boolean flags per tool
- CC infers permissions; OpenCode declares them explicitly
- CC uses short model aliases (`haiku`); OpenCode uses full provider/model paths
- OpenCode adds `mode` (subagent vs primary) and `temperature` fields

### Dual-Publish Workflow

A single repo can build both formats.
The compound-engineering converter demonstrates this pattern:

```
clauthier/
  plugins/cdocs/
    .claude-plugin/plugin.json    # CC manifest (canonical)
    agents/                       # CC format (canonical)
    skills/                       # Shared (works in both)
    rules/                        # Shared (works in both)
    hooks/hooks.json              # CC format
    hooks/*.sh                    # CC hook scripts
    opencode/                     # Generated at build time
      agents/                     # Converted agent files
      plugins/cdocs.ts            # JS plugin with hook implementations
      package.json                # npm manifest
```

The build step:
1. Copy `skills/` as-is (already compatible).
2. Transform agent frontmatter: expand tool names to boolean objects, add `mode`, add full model paths, add `permission` blocks.
3. Rewrite hooks from shell-command JSON to JS/TS plugin exports.
4. Generate `opencode.json` entries from `plugin.json` metadata.
5. Generate `package.json` with appropriate npm metadata.

This could be a Bun script in the repo, a CI step, or a `Makefile` target.

---

## 5. MCP as the Universal Extension Layer

### The Pragmatic Answer

Both Claude Code and OpenCode support MCP.
MCP servers provide tools, resources, and prompts via JSON-RPC 2.0.
An MCP server works identically in both tools, with zero format translation.

For cdocs, the practical question is: **what functionality belongs in MCP vs. rules/skills?**

| Extension Type | Best Delivered Via | Why |
|---------------|--------------------|-----|
| Writing conventions | Rules (markdown) | Static instructions; no tool calls needed |
| Document templates | Skills (SKILL.md) | On-demand loading; template content |
| Frontmatter validation | MCP server or Hooks | Tool-like behavior; needs file system access |
| Status querying | MCP server | Structured data; filtering; aggregation |
| Document scaffolding | Skills or MCP server | Either works; skills are simpler |

**Recommendation:** Use MCP for anything that behaves like a tool (validation, querying, structured operations).
Use rules and skills for everything that is instructional or template-based.
This split makes the rules/skills layer fully portable (just markdown) while isolating the non-portable logic in MCP (universally supported).

### MCP Configuration Differences

CC (`.mcp.json`):
```json
{
  "mcpServers": {
    "cdocs": {
      "command": "node",
      "args": ["./mcp/cdocs-server.js"],
      "env": {}
    }
  }
}
```

OpenCode (`opencode.json`):
```json
{
  "mcp": {
    "cdocs": {
      "type": "stdio",
      "command": "node",
      "args": ["./mcp/cdocs-server.js"]
    }
  }
}
```

The differences are minor (key naming, `type` field).
A single MCP server binary works in both; only the configuration wrapper differs.

---

## 6. Community Patterns

### Repos Targeting Multiple Tools

| Repo | Strategy | Targets |
|------|----------|---------|
| [compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) | Build-time converter CLI | CC + 10 targets |
| [everything-claude-code](https://github.com/affaan-m/everything-claude-code) | Parallel directory structures | CC, Codex, OpenCode, Cursor |
| [claude-skills](https://github.com/alirezarezvani/claude-skills) | 180+ skills with conversion scripts | CC + 10 other tools |
| [myclaude](https://github.com/stellarlinkco/myclaude) | Multi-agent orchestration | CC, Codex, Gemini, OpenCode |
| [openskills](https://github.com/numman-ali/openskills) | Universal SKILL.md loader via AGENTS.md injection | Any agent supporting AGENTS.md |
| [oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode) | OpenCode plugin with CC compatibility layer | OpenCode primary, CC compatible |
| [agents](https://github.com/amtiYo/agents) | Single `.agents` source of truth synced to all targets | Codex, CC, Gemini CLI, Cursor, Copilot |

### Emerging Template Pattern

The most common emerging pattern is:

```
my-plugin/
  .agents/                    # AGENTS.md-standard (universal)
    skills/<name>/SKILL.md    # Works everywhere
    agents/<name>.md          # AGENTS.md format
    AGENTS.md                 # Root rules
  .claude/                    # CC-specific overrides
    rules/*.md                # CC-native rules with paths: scoping
    commands/*.md             # CC slash commands (no equivalent elsewhere)
  .opencode/                  # OC-specific overrides
    agents/*.md               # OC frontmatter format
    plugins/my-plugin.ts      # OC hooks (JS/TS)
  mcp/                        # Universal
    server.ts                 # MCP server (works in both)
  scripts/
    convert.ts                # Build-time converter
  plugin.json                 # CC manifest
  package.json                # npm/OC manifest
```

The `.agents/` directory serves as the lowest-common-denominator, with tool-specific directories providing overrides.

---

## 7. The AGENTS.md Angle

### AAIF Standardization

AGENTS.md is now stewarded by the **Agentic AI Foundation (AAIF)** under the Linux Foundation, co-founded by Anthropic, Block, and OpenAI, with support from Google, Microsoft, AWS, Cloudflare, and Bloomberg.
It sits alongside MCP and Goose as the AAIF's inaugural projects.

AGENTS.md is used by 20,000+ open source projects and is read by 17+ coding agents.

### Should AGENTS.md Be the Primary Format?

The case for AGENTS.md as primary:
- Broadest tool support (17+ tools, including OpenCode, Cursor, Copilot, Codex, Kilo, Windsurf)
- AAIF backing gives it institutional permanence
- OpenCode reads it natively; CC does not (but can be worked around)
- Directory-scoped: nested AGENTS.md files apply to subdirectories
- Simple format: just markdown, optionally with YAML frontmatter

The case against:
- CC does not read AGENTS.md natively; it reads CLAUDE.md
- CC's plugin system is built around `.claude/` conventions, not `.agents/`
- CC's `@`-mention system references `.claude/rules/*.md`, not AGENTS.md
- Maintaining AGENTS.md as primary with CC wrappers adds complexity for CC-first users

### Practical Recommendation for cdocs

Do not switch the canonical format yet.
The cost of maintaining both is low (they are markdown files), and the tooling gap is closing.

**Near-term (now):**
1. Keep `.claude/` as the canonical plugin structure.
2. Add an `AGENTS.md` at the project root that `@`-imports the same rules: `@.claude/rules/writing-conventions.md` (CC understands this; OpenCode reads the AGENTS.md and follows the reference).
3. Skills already work in both tools from `.claude/skills/`.

**Medium-term (when CC adds AGENTS.md support):**
1. Move rules to `.agents/rules/` as the single source of truth.
2. Keep `.claude/` as a thin wrapper that references `.agents/` content.

**Long-term (when plugin manifest standards converge):**
1. Ship a single manifest that both tools read.
2. This is speculative; no timeline exists.

---

## 8. Recommended Strategy for cdocs

### Portability Tiers

| Component | Portability | Action Required |
|-----------|------------|-----------------|
| Skills (SKILL.md) | Works as-is | None. `.claude/skills/` is read by both CC and OC |
| Rules (markdown) | Works with minor effort | Add AGENTS.md root file; keep `.claude/rules/` canonical |
| Agents (markdown) | Requires conversion | Frontmatter transformation (tool names, permissions, model paths) |
| Hooks (JSON + shell) | Not portable | Reimplement as OC JS/TS plugin |
| MCP servers | Fully portable | Only config wrapper differs |
| Plugin manifest | Not portable | Separate manifests per target |

### Concrete Repo Structure

```
plugins/cdocs/
  .claude-plugin/
    plugin.json                         # CC manifest (canonical)
  agents/
    triage.md                           # CC format (canonical)
    reviewer.md
    nit-fix.md
  skills/
    devlog/SKILL.md                     # Portable (no changes)
    propose/SKILL.md
    review/SKILL.md
    report/SKILL.md
    status/SKILL.md
    init/SKILL.md
  rules/
    writing-conventions.md              # Portable (no changes)
    workflow-patterns.md
    frontmatter-spec.md
  hooks/
    hooks.json                          # CC format
    cdocs-validate-frontmatter.sh       # CC hook scripts
  AGENTS.md                             # Cross-tool root rules (references ./rules/)
  opencode/                             # Generated directory
    agents/
      triage.md                         # OC format (converted frontmatter)
      reviewer.md
      nit-fix.md
    plugins/
      cdocs-hooks.ts                    # OC hook implementations
    package.json                        # npm manifest
  scripts/
    build-opencode.ts                   # Converter script
```

### Build Script Sketch

```typescript
// scripts/build-opencode.ts
// Converts CC agent frontmatter to OpenCode format

const MODEL_MAP: Record<string, string> = {
  haiku: "anthropic/claude-3-5-haiku-20241022",
  sonnet: "anthropic/claude-sonnet-4-6-20261022",
  opus: "anthropic/claude-opus-4-6-20261022",
};

const TOOL_MAP: Record<string, string> = {
  Read: "read",
  Write: "write",
  Edit: "edit",
  Bash: "bash",
  Glob: "read",      // maps to file read permission
  Grep: "read",      // maps to file read permission
};

function convertAgentFrontmatter(ccFrontmatter: CCAgent): OCAgent {
  const tools: Record<string, boolean> = {};
  for (const tool of ccFrontmatter.tools.split(", ")) {
    const mapped = TOOL_MAP[tool.trim()];
    if (mapped) tools[mapped] = true;
  }

  return {
    description: ccFrontmatter.description,
    mode: "subagent",
    model: MODEL_MAP[ccFrontmatter.model] ?? ccFrontmatter.model,
    tools,
    permission: { edit: "ask", bash: "ask" },
  };
}
```

### Install-Time Workflow

For users installing from the CC marketplace:
```bash
claude plugin marketplace add weftwiseink/clauthier
claude plugin install cdocs@clauthier --scope project
```

For users installing for OpenCode:
```bash
# Option A: npm package (when published)
# In opencode.json: { "plugin": ["@weft/cdocs-opencode"] }

# Option B: Manual setup
git clone https://github.com/weftwiseink/clauthier
cd clauthier && bun run scripts/build-opencode.ts
cp -r plugins/cdocs/opencode/agents/* .opencode/agents/
cp -r plugins/cdocs/skills/* .opencode/skills/
cp plugins/cdocs/AGENTS.md ./AGENTS.md
```

---

## 9. What Not to Do

**Do not maintain two independent copies of the same content.**
This is the trap that leads to drift.
Author once, convert mechanically.

**Do not make AGENTS.md the canonical format if CC is the primary tool.**
CC's plugin system, marketplace, `@`-mentions, and hook lifecycle all depend on `.claude/` conventions.
Fighting the primary tool's conventions creates friction disproportionate to the portability gain.

**Do not rewrite hooks as MCP servers just for portability.**
Hooks are system-facing (run without model consent); MCP tools are model-facing (require model invocation).
They solve different problems.
A frontmatter validation hook should remain a hook in CC and become a `tool.execute.after` event handler in OpenCode.

**Do not publish to Skills.sh prematurely.**
Skills.sh indexes public repos.
When cdocs skills are stable enough for external consumption, ensure the SKILL.md frontmatter is clean and the descriptions are self-contained.
The indexer will pick them up automatically.

---

## Sources

- [One Codebase, Three Runtimes: How GSD Targets Claude Code, OpenCode, and Gemini CLI](https://medium.com/@richardhightower/one-codebase-three-runtimes-how-gsd-targets-claude-code-opencode-and-gemini-cli-29c98cfe96c6)
- [Claude Code Agents to OpenCode Agents (conversion gist)](https://gist.github.com/RichardHightower/827c4b655f894a1dd2d14b15be6a33c0)
- [compound-engineering-plugin (multi-target converter)](https://github.com/EveryInc/compound-engineering-plugin)
- [OpenCode Plugins Documentation](https://opencode.ai/docs/plugins/)
- [OpenCode Agents Documentation](https://opencode.ai/docs/agents/)
- [OpenCode Skills Documentation](https://opencode.ai/docs/skills/)
- [OpenCode Rules Documentation](https://opencode.ai/docs/rules/)
- [AGENTS.md Specification](https://github.com/agentsmd/agents.md)
- [AAIF Formation Announcement (Linux Foundation)](https://www.linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation)
- [Skills.sh - The Agent Skills Directory](https://skills.sh/)
- [agentskill.sh - AI Agent Skills Directory](https://agentskill.sh/)
- [OpenSkills - Universal Skills Loader](https://github.com/numman-ali/openskills)
- [everything-claude-code (multi-target agent harness)](https://github.com/affaan-m/everything-claude-code)
- [claude-skills (180+ skills, multi-tool)](https://github.com/alirezarezvani/claude-skills)
- [oh-my-opencode](https://www.npmjs.com/package/oh-my-opencode)
- [awesome-opencode](https://github.com/awesome-opencode/awesome-opencode)
- [Claude Code Plugins Reference](https://code.claude.com/docs/en/plugins-reference)
- [skill.md: An open standard for agent skills (Mintlify)](https://www.mintlify.com/blog/skill-md)
- [Claude Code Plugin Marketplace](https://claude-plugins.dev/)
- [OpenCode undocumented CLAUDE.md compatibility](https://gist.github.com/zeke/c6bed98a445e559b0d3563087b5e6764)
- [cdocs/reports/2026-03-13-parity-opencode.md](2026-03-13-parity-opencode.md) - Prior CC vs OC parity analysis
- [cdocs/reports/2026-03-07-plugin-rules-api-research.md](2026-03-07-plugin-rules-api-research.md) - CC plugin rules gap analysis
- [cdocs/reports/2026-03-13-agent-harness-executive-summary.md](2026-03-13-agent-harness-executive-summary.md) - Landscape context

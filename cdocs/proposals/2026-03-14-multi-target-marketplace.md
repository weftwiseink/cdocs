---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-14T12:00:00-07:00
task_list: marketplace/multi-target
type: proposal
state: live
status: review_ready
revision_round: 3
tags: [architecture, multi-target, opencode, portability, build-system, compound-engineering]
last_reviewed:
  status: revision_requested
  by: "@mjr"
  at: 2026-03-16T00:00:00-07:00
  round: 2
---

# Multi-Target Marketplace: Publishing cdocs to Claude Code and OpenCode

> BLUF: Extend the clauthier marketplace to publish cdocs for both Claude Code (CC) and OpenCode (OC) from a single canonical source.
> CC remains the canonical authoring format.
> The `compound-engineering-plugin` (`@every-env/compound-plugin`) converts agents to OC format; hooks are reimplemented by hand; skills and rules require no conversion.
> The OC output lives in a generated `opencode/` directory within `plugins/cdocs/` and is committed as build artifacts.
> Based on the [multi-target-plugin-strategies report](../reports/2026-03-14-multi-target-plugin-strategies.md), this follows the "author once, convert at install time" pattern proven by GSD and compound-engineering.

## Summary

This proposal covers the full pipeline from CC-canonical sources to a working OC installation: repo structure changes, agent conversion via `compound-engineering-plugin` (an existing multi-target converter), hook reimplementation strategy, rules integration via AGENTS.md and `.claude/rules/` compatibility paths, npm packaging, CI/CD, and testing.

The approach minimizes maintenance burden by keeping a single source of truth (CC format) and generating the OC target using an established ecosystem tool rather than a custom build script.
Skills are the easiest layer: they work as-is in both tools.
Rules are nearly as easy: OC reads `.claude/rules/` as a fallback.
Agents require frontmatter conversion but the mapping is deterministic.
Hooks are the hardest: OC uses JS/TS plugin exports instead of shell commands, so they must be reimplemented (not converted).

> NOTE(claude-opus-4-6/multi-target): The OC plugin ecosystem is younger than CC's.
> Some conventions (like opencode-rules conditional activation) are community plugins, not built-in.
> This proposal targets the stable OC primitives: agents, skills, and JS/TS plugins.

## Objective

Enable users of OpenCode to install and use cdocs with the same skill set, writing conventions, and document workflows available to CC users today, without requiring CC authors to maintain a separate copy of the plugin.

## Background

Key findings from prior research:

- **[Multi-target plugin strategies](../reports/2026-03-14-multi-target-plugin-strategies.md):** The dominant pattern is CC-canonical with build-time conversion.
  Skills are fully portable.
  Rules are nearly portable (OC reads `.claude/rules/`).
  Agents need frontmatter conversion.
  Hooks are not portable.

- **[OpenCode parity report](../reports/2026-03-13-parity-opencode.md):** OC matches or exceeds CC on hook granularity (30+ event types vs 9), model breadth (75+ providers), and LSP integration.
  CC leads on plugin distribution (marketplace), memory, and subagent orchestration depth.

- **[Agent harness executive summary](../reports/2026-03-13-agent-harness-executive-summary.md):** The "reusable rules as org standards" problem is not well-solved by any tool.
  The best strategy is tool-agnostic prose with tool-specific delivery mechanisms.

### Current cdocs Plugin Structure

```
plugins/cdocs/
  .claude-plugin/plugin.json    # CC manifest
  agents/
    triage.md                   # CC agent format
    reviewer.md
    nit-fix.md
  skills/
    devlog/SKILL.md             # Portable (no changes needed)
    propose/SKILL.md
    review/SKILL.md
    report/SKILL.md
    status/SKILL.md
    init/SKILL.md
    triage/SKILL.md
    implement/SKILL.md
    rfp/SKILL.md
    nit_fix/SKILL.md
  rules/
    writing-conventions.md      # Portable (no changes needed)
    workflow-patterns.md
    frontmatter-spec.md
  hooks/
    hooks.json                  # CC hook declarations (1 active hook)
    cdocs-validate-frontmatter.sh   # ACTIVE: PostToolUse Write|Edit (73 lines)
    validate-cdocs-edit-path.sh     # UNWIRED: file exists but not declared in hooks.json (18 lines)
```

> NOTE(claude-opus-4-6/multi-target): Only `cdocs-validate-frontmatter.sh` is wired in `hooks.json` (as a `PostToolUse` matcher for `Write|Edit`).
> The `validate-cdocs-edit-path.sh` script exists as a file but has no corresponding entry in `hooks.json`.
> See the Phase 0 step below for the decision on wiring it up.

## Proposed Solution

### Repo Structure After Implementation

```
plugins/cdocs/
  .claude-plugin/plugin.json        # CC manifest (canonical, unchanged)
  agents/                           # CC format (canonical, unchanged)
    triage.md
    reviewer.md
    nit-fix.md
  skills/                           # Shared: works in both CC and OC
    devlog/SKILL.md
    propose/SKILL.md
    review/SKILL.md
    report/SKILL.md
    status/SKILL.md
    init/SKILL.md
    triage/SKILL.md
    implement/SKILL.md
    rfp/SKILL.md
    nit_fix/SKILL.md
  rules/                            # Shared: OC reads .claude/rules/ path
    writing-conventions.md
    workflow-patterns.md
    frontmatter-spec.md
  hooks/                            # CC-specific
    hooks.json
    cdocs-validate-frontmatter.sh
    validate-cdocs-edit-path.sh
  AGENTS.md                         # Cross-tool root rules (uses @-imports for CC)
  opencode/                         # GENERATED: do not edit manually
    agents/
      triage.md                     # OC format (converted frontmatter)
      reviewer.md
      nit-fix.md
    plugins/
      cdocs-hooks.ts                # OC hook implementations (hand-written)
    package.json                    # npm manifest for OC distribution
  scripts/
    build-opencode.sh               # Thin wrapper: calls compound-engineering + cdocs-specific post-processing
```

### Layer-by-Layer Portability

#### 1. Skills: No Changes Needed

Both CC and OC read SKILL.md files from `.claude/skills/` paths.
OC's discovery hierarchy includes `.claude/skills/<name>/SKILL.md` at priority 2 (after `.opencode/skills/`).
The cdocs SKILL.md frontmatter uses only `name` and `description`, which both tools recognize.
Extra OC-recognized fields (`license`, `compatibility`, `metadata`) can be added later without breaking CC (it ignores unknown fields).

No conversion, no duplication, no build step.

#### 2. Rules: Minor Addition

OC reads `.claude/rules/` as a compatibility fallback.
The three cdocs rule files (`writing-conventions.md`, `workflow-patterns.md`, `frontmatter-spec.md`) are pure markdown with optional `paths:` frontmatter.
OC ignores the `paths:` field but still loads the rule content.

The one addition: an `AGENTS.md` file at `plugins/cdocs/AGENTS.md` that imports the rules for tools that rely on AGENTS.md as the primary entry point:

```markdown
# CDocs Agent Instructions

@rules/writing-conventions.md
@rules/workflow-patterns.md
@rules/frontmatter-spec.md
```

CC understands `@`-imports natively and follows them to inject the referenced content.

> NOTE(claude-opus-4-6/multi-target): OC and most other tools (Codex, Cursor, Copilot) likely do NOT follow `@`-imports.
> They read the AGENTS.md content as opaque markdown, meaning `@rules/writing-conventions.md` appears as literal text, not an inclusion directive.
> This plugin-level AGENTS.md uses `@`-imports for CC compatibility.
> The project-level AGENTS.md (managed by the companion [cross-target rules integration proposal](2026-03-14-cross-target-rules-integration.md) via its `/cdocs:init` extension) uses inlined content for cross-tool safety.
> This proposal defers to the rules proposal for the project-level AGENTS.md artifact and `/cdocs:init` OC extensions.
> For OC specifically, the primary rules delivery path is `.claude/rules/` directory reading, not AGENTS.md.

> NOTE(claude-opus-4-6/multi-target): If OC's opencode-rules plugin is installed by the user, they get richer conditional activation (keywords, model, agent, branch, OS, CI) beyond CC's `paths:` scoping.
> This is a user-side enhancement, not something the plugin needs to configure.

#### 3. Agents: Frontmatter Conversion

The three CC agents (`triage.md`, `reviewer.md`, `nit-fix.md`) use CC-specific frontmatter that must be converted for OC.

CC format (example: `triage.md`):

```yaml
---
name: triage
model: haiku
description: Analyze cdocs frontmatter and apply mechanical fixes
tools: Read, Glob, Grep, Edit
---
```

OC format (converted):

```yaml
---
description: Analyze cdocs frontmatter and apply mechanical fixes
mode: subagent
model: anthropic/claude-3-5-haiku-20241022
tools:
  read: true
  edit: true
  write: false
  bash: false
permission:
  edit: ask
---
```

> NOTE(claude-opus-4-6/multi-target): Model IDs shown are current as of March 2026.
> compound-engineering-plugin maintains its own model mapping which should be kept up to date.
> The `anthropic/claude-3-5-haiku-20241022` ID for `haiku` is from late 2024 and may be outdated; verify compound-engineering's mapping when newer model versions are available.

Key transformations (handled by compound-engineering-plugin):
- `model` short alias expanded to full provider/model path
- `tools` comma-separated string expanded to boolean object with OC tool names
- `mode: subagent` added (all cdocs agents are subagents)
- `permission` block added based on the tool set (agents with Edit get `edit: ask`)
- `name` field dropped (OC infers name from filename)
- `skills` field dropped (OC does not have an equivalent frontmatter field; skills are available globally)

CC-to-OC tool mapping:

| CC Tool | OC Tool Field | Notes |
|---------|---------------|-------|
| `Read` | `read: true` | Direct mapping |
| `Glob` | (available by default) | No direct OC equivalent; always available |
| `Grep` | (available by default) | No direct OC equivalent; always available |
| `Edit` | `edit: true` + `permission: { edit: ask }` | OC separates edit from write |
| `Write` | `write: true` + `permission: { write: ask }` | OC separates write from edit |

The body content (markdown instructions) is copied verbatim.

#### 4. Hooks: Reimplementation Required

CC hooks are shell commands triggered by 9 event types, declared in `hooks.json`.
OC hooks are JS/TS plugin functions triggered by 30+ event types, exported from a plugin module.

The cdocs hooks:

| Hook | CC Event | CC Status | CC Behavior | OC Equivalent |
|------|----------|-----------|-------------|---------------|
| `cdocs-validate-frontmatter.sh` (73 lines) | PostToolUse (Write\|Edit) | **Active** (declared in hooks.json) | Validates frontmatter fields; returns warnings in `additionalContext` | `tool.execute.after` event handler; inspect tool output for cdocs paths; validate frontmatter |
| `validate-cdocs-edit-path.sh` (18 lines) | PreToolUse (Write\|Edit) | **Unwired** (file exists, not declared in hooks.json) | Blocks edits outside `cdocs/` directories (exit 2) | `tool.execute.before` event handler; return error to block |

> NOTE(claude-opus-4-6/multi-target): The `validate-cdocs-edit-path.sh` script is an agent safety guard that exists as a file but is not wired in `hooks.json`.
> **Decision: wire it up in CC first as a Phase 0 prerequisite.**
> Add a `PreToolUse` entry to `hooks.json` matching `Write|Edit` before porting to OC.
> This ensures both hooks are tested in CC before the OC reimplementation in Phase 3.

The OC plugin file (`opencode/plugins/cdocs-hooks.ts`) will be hand-written (not generated), since the logic translates concepts, not syntax.

Sketch:

```typescript
// opencode/plugins/cdocs-hooks.ts
import type { Plugin } from "opencode";

export default {
  name: "cdocs-hooks",
  version: "0.1.0",

  setup(plugin: Plugin) {
    // Path restriction (equivalent to PreToolUse Write|Edit)
    plugin.on("tool.execute.before", async (event) => {
      const filePath = event.input?.file_path;
      if (!filePath) return;
      if (!filePath.match(/cdocs\/(devlogs|proposals|reviews|reports)\//)) {
        return { error: "Blocked: this agent can only edit files in cdocs document directories." };
      }
    });

    // Frontmatter validation (equivalent to PostToolUse Write|Edit)
    plugin.on("tool.execute.after", async (event) => {
      const filePath = event.output?.file_path;
      if (!filePath?.match(/cdocs\/(devlogs|proposals|reviews|reports)\//)) return;
      // ... frontmatter validation logic (port from bash) ...
    });
  }
} satisfies Plugin;
```

> NOTE(claude-opus-4-6/multi-target): The OC event object shape (`event.input?.file_path`, `event.output?.file_path`) is assumed based on the parity report's description of typed event objects.
> The exact shape of `tool.execute.after` and `tool.execute.before` events should be verified against OC source during implementation.

#### 5. Plugin Manifest and npm Packaging

OC plugins are distributed as npm packages referenced in `opencode.json`.
The generated `opencode/package.json`:

```json
{
  "name": "@weft/cdocs-opencode",
  "version": "0.1.0",
  "description": "CDocs documentation framework for OpenCode",
  "main": "plugins/cdocs-hooks.ts",
  "files": [
    "agents/",
    "plugins/",
    "package.json"
  ],
  "keywords": ["opencode", "plugin", "documentation", "cdocs"],
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/weftwiseink/clauthier"
  },
  "scripts": {
    "postinstall": "node -e \"if(process.env.CDOCS_SKIP_POSTINSTALL){process.exit(0)} const fs=require('fs'),p=require('path'); const dst=p.resolve('.opencode','skills','cdocs'); if(!fs.existsSync(dst)){fs.mkdirSync(dst,{recursive:true})} const src=p.resolve(__dirname,'..','skills'); if(fs.existsSync(src)){fs.cpSync(src,dst,{recursive:true})} const rdst=p.resolve('.claude','rules'); if(!fs.existsSync(rdst)){fs.mkdirSync(rdst,{recursive:true})} const rsrc=p.resolve(__dirname,'..','rules'); if(fs.existsSync(rsrc)){fs.cpSync(rsrc,rdst,{recursive:true})} console.log('cdocs: skills and rules installed. Set CDOCS_SKIP_POSTINSTALL=1 to skip.')\""
  }
}
```

> NOTE(claude-opus-4-6/multi-target): The postinstall copies skills to `.opencode/skills/cdocs/` and rules to `.claude/rules/`.
> Set `CDOCS_SKIP_POSTINSTALL=1` to skip the postinstall copy.

> NOTE(claude-opus-4-6/multi-target): The `.ts` entry point (`plugins/cdocs-hooks.ts`) requires a Bun-compatible runtime.
> OC auto-installs plugins via Bun, so this works in the standard OC installation path.
> Node-based OC installations (if any exist) would fail to load a `.ts` entry point.
> This is a known constraint; the workaround is to add a build step that compiles to JS, but this is deferred until there is evidence of Node-based OC usage.

Users install via:

```json
// In their opencode.json:
{
  "plugin": ["@weft/cdocs-opencode"]
}
```

Skills and rules do not need to be in the npm package: OC reads them from `.claude/skills/` and `.claude/rules/` in the project.
For standalone installation (not in the clauthier repo), the npm `postinstall` copies skills and rules into the appropriate paths automatically.

> NOTE(claude-opus-4-6/multi-target): The npm package primarily delivers the hooks plugin and converted agents.
> Skills and rules have their own cross-tool discovery paths and do not strictly need npm packaging, but the postinstall handles the copy for standalone users.

## Important Design Decisions

### Decision: CC remains the canonical authoring format

**Why:** CC is the primary development tool for this project.
Its plugin system (marketplace, `plugin.json`, hooks.json, agent frontmatter) is the format authors interact with.
Fighting the primary tool's conventions creates friction disproportionate to any portability gain.
OC output is generated, not maintained.

### Decision: Commit the generated `opencode/` output

**Why:** Keeps the build output co-located with the source.
Committing the generated output allows users to consume the OC format without running the wrapper script and makes CI validation straightforward (build, diff, fail if dirty).
A separate repo would require cross-repo synchronization.

If the generated output ever needs regeneration (e.g., OC changes its agent format), the fix path is always: update compound-engineering (or the wrapper's post-processing), re-run, commit.
Never manually edit files in `opencode/`.

### Decision: Hand-write OC hooks, do not attempt mechanical conversion

**Why:** CC hooks are bash scripts consuming JSON on stdin and emitting JSON on stdout.
OC hooks are TypeScript plugin exports with typed event objects.
The impedance mismatch is conceptual, not syntactic: translating one shell script line-by-line into TypeScript would produce unidiomatic, fragile code.
The two hooks are small enough (73 and 18 lines of bash) that hand-writing the TypeScript equivalents is faster and produces better results.

### Decision: Use compound-engineering-plugin for agent conversion instead of a custom build script

**Why:** Based on research findings, the `compound-engineering-plugin` (`@every-env/compound-plugin`) is a mature ecosystem tool that handles agent frontmatter conversion from CC to OC format, including model mapping, tool expansion, and permission generation.
The [multi-target strategies report](../reports/2026-03-14-multi-target-plugin-strategies.md) identified it as a proven converter used by GSD and other multi-target projects.
Writing a custom ~100-200 line TypeScript build script to reimplement the same transformations is unnecessary when an existing tool already solves the problem.

The rationale for build-vs-buy:
- compound-engineering handles the deterministic frontmatter transformation (model aliases to full paths, tool names to boolean objects, permission block generation).
- It supports 10+ targets beyond OC, giving us a future migration path if we target Codex, Gemini CLI, or Copilot.
- Format evolution is handled upstream -- when OC changes its agent format, compound-engineering updates rather than our custom script.
- A thin wrapper script (under 50 lines) handles the cdocs-specific concerns compound-engineering does not cover: relative path rewriting in agent bodies and version synchronization from `plugin.json`.

> NOTE(claude-opus-4-6/multi-target): The compound-engineering-plugin's existence, star count, and CLI interface were identified via web research in a prior conversation.
> These claims should be verified against the actual repository (`https://github.com/EveryInc/compound-engineering-plugin`) before implementation.
> Phase 1 includes a verification step as its first action item.

### Decision: Do not switch the canonical format to AGENTS.md

**Why:** Per the multi-target report's recommendation, the cost of maintaining both is low, and CC's plugin system, marketplace, `@`-mentions, and hook lifecycle all depend on `.claude/` conventions.
An `AGENTS.md` file is added as a cross-tool compatibility shim, not as the primary source of truth.
The project-level AGENTS.md (with inlined content for cross-tool safety) is owned by the [cross-target rules integration proposal](2026-03-14-cross-target-rules-integration.md) and its `/cdocs:init` extension.

### Decision: Use Bun as the build runtime

**Why:** compound-engineering-plugin runs via `bunx`, and the thin wrapper script benefits from Bun's fast startup.
Bun is already in the OC ecosystem (OC auto-installs plugins via Bun) and handles TypeScript natively if the wrapper needs to be more than a shell script.

### Decision: Wire `validate-cdocs-edit-path.sh` in CC before porting to OC

**Why:** The path-restriction hook exists as a file but is not declared in `hooks.json`.
Wiring it up in CC first (adding a `PreToolUse` entry to `hooks.json`) ensures the hook logic is tested in the simpler CC environment before the more complex OC reimplementation.
This is a Phase 0 prerequisite.

### Decision: Use relative paths in agent body content

**Why:** The `triage.md` agent body references `plugins/cdocs/rules/frontmatter-spec.md` (absolute from repo root).
This path is CC-relative (from the plugin cache root) and would not resolve in OC's agent loading context.
Update the CC source to use a relative path (`./rules/frontmatter-spec.md` from agents/) that works in both environments.
The wrapper script's post-processing step verifies that referenced paths resolve in both contexts.

### Decision: Derive `package.json` version from `plugin.json` version

**Why:** The CC plugin version lives in `.claude-plugin/plugin.json` (currently `0.1.0`).
The OC npm package version in `opencode/package.json` must match.
The wrapper script's post-processing step copies the version field from `plugin.json` to `package.json` on each run.
This prevents version drift between the two manifests.

## Edge Cases / Challenging Scenarios

### Agent body content referencing CC-specific paths

The `triage.md` agent body says "read the frontmatter specification: `plugins/cdocs/rules/frontmatter-spec.md`".
This path is CC-relative (from the plugin cache root).
In OC, the agent is loaded from a different location.

**Mitigation:** Update the CC source agent body to use relative paths (`./rules/frontmatter-spec.md` from agents/).
The wrapper script's post-processing step verifies that all path references in agent body content resolve in both the CC plugin directory tree and the OC output directory tree.

### Skills referencing templates via relative paths

Some SKILL.md files reference `template.md` alongside the skill file.
This works because both CC and OC resolve template paths relative to the SKILL.md location, and skills are not converted (same files, same directory structure).

No action needed.

### OC version drift

If the OC agent frontmatter format changes, compound-engineering handles format evolution upstream -- we inherit format compatibility by updating the compound-engineering dependency rather than maintaining our own conversion logic.
OC's format has been stable since late 2025 but tool permission fields have evolved.

**Mitigation:** When OC changes its agent format, update to the latest compound-engineering version and regenerate.
Add a CI check that validates the generated agent files against OC's expected schema (if one exists) or against a snapshot.
Never manually edit files in `opencode/`.
The fix path is always: update compound-engineering, re-run the wrapper, commit.

### CC `skills:` frontmatter in agents

The `reviewer.md` agent declares `skills: - cdocs:review` in its frontmatter.
OC does not have an equivalent frontmatter field for preloading skills into an agent context.

**Mitigation:** compound-engineering drops unrecognized CC-specific fields (including `skills:`) during conversion.
In OC, skills are globally available via slash commands; the agent body instructions already tell the reviewer to "follow the preloaded `cdocs:review` skill," which works because OC makes skills available to all agents.
If compound-engineering does not drop `skills:` automatically, the wrapper script handles it as a post-processing step.

### Hook input/output format differences

CC hooks receive a JSON blob on stdin with `tool_input`, `tool_result`, etc.
OC event handlers receive a typed event object.
The shape of tool metadata (file paths, tool names) differs.

**Mitigation:** The hand-written OC hooks abstract over this: they extract the file path from the OC event structure and apply the same validation logic.
This is why mechanical conversion is not attempted.

## Test Plan

### Unit Tests for the Wrapper Script Post-Processing

Since compound-engineering handles the core frontmatter transformation (model mapping, tool expansion, permission generation), unit tests focus on the cdocs-specific post-processing that the wrapper script performs:

1. **Version synchronization:** Assert the wrapper copies the version from `plugin.json` to `package.json`.
2. **Path rewriting:** Assert the wrapper rewrites absolute paths (e.g., `plugins/cdocs/rules/frontmatter-spec.md`) to relative paths in agent body content.
3. **Path verification:** Assert the wrapper warns on agent body content containing unrewritten absolute paths.
4. **Body content integrity:** Assert agent body markdown (minus rewritten paths) is otherwise identical before and after the wrapper runs.

### Integration Tests

1. **Generated agent file validity:** After running the wrapper script, validate each generated OC agent file has well-formed YAML frontmatter.
2. **Idempotency:** Running the wrapper script twice produces identical output.
3. **Dirty-check in CI:** After building, `git diff --exit-code opencode/` passes (no uncommitted changes to generated files).
4. **Auto-discovery:** Adding a new `.md` file to `agents/` and rebuilding via compound-engineering produces a corresponding OC agent file in `opencode/agents/`.

### AGENTS.md Integration Tests

1. **CC `@`-import resolution:** In a CC session with the cdocs plugin installed, verify the agent receives imported rule content (expected: agent response references BLUF, sentence-per-line, and callout syntax from the imported rules).
   Pass: agent output demonstrates awareness of all three rule files' content.
   Fail: agent treats `@rules/...` lines as literal text or ignores them.

2. **OC AGENTS.md handling:** In an OC session with the plugin-level AGENTS.md present, verify whether OC follows `@`-imports or treats them as literal text (expected: OC treats `@`-imports as literal text, confirming the need for the inlined approach from the rules proposal).
   Pass: test confirms the expected behavior (literal text) and the `.claude/rules/` fallback delivers rule content.
   Fail: OC unexpectedly follows `@`-imports (a positive surprise that simplifies the architecture).

3. **`.claude/rules/` fallback in OC:** In an OC session with rules files in `.claude/rules/`, verify OC loads the rule content (expected: agent response includes references to BLUF, sentence-per-line, and callout syntax when asked about writing conventions).
   Pass: agent output demonstrates awareness of writing conventions from `.claude/rules/`.
   Fail: OC does not read `.claude/rules/` as a fallback.

### Manual Validation

1. **OC agent loading:** Start OC in a test project with the generated agents in `.opencode/agents/` and verify they appear in the agent list.
   Expected: all 3 agents (triage, reviewer, nit-fix) appear by name in OC's agent selection menu.
   Fail: any agent is missing or has malformed metadata.

2. **Skill availability:** Verify cdocs skills appear in OC's skill menu when `.claude/skills/` is populated.
   Expected: all 10 skills (devlog, propose, review, report, status, init, triage, implement, rfp, nit_fix) appear by name.
   Fail: any skill is missing or not invocable.

3. **Rules loading:** Verify OC loads the rules from `.claude/rules/` or via `AGENTS.md` references.
   Expected: agent response includes references to BLUF, sentence-per-line, and callout syntax when asked "what writing conventions are you following?"
   Fail: agent has no awareness of cdocs writing conventions.

4. **Hook execution:** Trigger the PostToolUse equivalent by writing a cdocs file in OC and checking for validation output.
   Expected: writing a cdocs file with missing frontmatter fields triggers a validation warning naming the missing fields.
   Fail: no validation feedback appears, or the validation produces false positives/negatives.

## Verification Methodology

The primary verification loop:

1. Run the wrapper script (`scripts/build-opencode.sh`) and confirm clean exit (compound-engineering conversion + cdocs post-processing).
2. Diff `opencode/agents/*.md` against expected snapshots.
3. In a test project, install the OC plugin:
   - Copy `opencode/agents/` to `.opencode/agents/`
   - Copy `skills/` to `.claude/skills/` (or `.opencode/skills/`)
   - Copy `rules/` to `.claude/rules/`
   - Add `AGENTS.md` at project root (with inlined content per the rules proposal)
   - Add plugin to `opencode.json`
4. Start OC and verify:
   - `/cdocs:devlog test` creates a devlog with correct frontmatter
   - Agent list shows triage, reviewer, nit-fix
   - Rules content appears in agent context (check via a prompt like "what writing conventions are you following?")

> NOTE(claude-opus-4-6/multi-target): Full automated integration testing of OC is currently limited by the lack of a headless OC mode for CI environments.
> Manual verification is required for the initial implementation.
> A future CI step could use the OC HTTP API for automated validation.

## Implementation Phases

### Phase 0: Wire Up Path-Restriction Hook in CC

**Scope:** Activate the existing but unwired `validate-cdocs-edit-path.sh` hook in CC.

1. Add a `PreToolUse` entry to `hooks.json` matching `Write|Edit` that invokes `validate-cdocs-edit-path.sh`.
2. Test the hook in a CC session: attempt to edit a file outside `cdocs/` directories and verify the edit is blocked.
3. Test that edits to files inside `cdocs/` directories are permitted.

**Success criteria:** `hooks.json` declares both hooks.
Editing a non-cdocs file triggers the path-restriction block.
Editing a cdocs file proceeds normally.

**Constraints:** Do not modify the hook script itself.
Do not modify agent files.
This is purely a `hooks.json` wiring change.

### Phase 1: Agent Conversion via compound-engineering-plugin

**Scope:** Use the existing `compound-engineering-plugin` (`@every-env/compound-plugin`) to convert CC agents to OC format, with a thin wrapper script for cdocs-specific post-processing.

> NOTE(claude-opus-4-6/multi-target): The `compound-engineering-plugin` CLI syntax and capabilities described below are based on prior ecosystem research.
> The exact CLI interface (`bunx @every-env/compound-plugin convert ...`) should be verified against compound-engineering's current documentation before implementation begins.
> If the tool does not exist or does not work as described, fall back to the custom build script approach described in the [strategies report](../reports/2026-03-14-multi-target-plugin-strategies.md) Section 8.

1. **Verify compound-engineering-plugin works for cdocs (first step).**
   Run `bunx @every-env/compound-plugin convert ./plugins/cdocs --to opencode` and inspect the output.
   Confirm the tool:
   - Exists and installs successfully.
   - Converts agent frontmatter (model mapping, tool expansion, permission generation).
   - Produces valid OC agent markdown files.
   If verification fails, document the failure and fall back to the custom build script approach from the strategies report.

2. **Create a thin wrapper script** at `plugins/cdocs/scripts/build-opencode.sh`:
   - Invoke compound-engineering to perform the core conversion.
   - Apply cdocs-specific post-processing that compound-engineering may not handle:
     - **Relative path rewriting** in agent body content (e.g., rewrite `plugins/cdocs/rules/frontmatter-spec.md` to `./rules/frontmatter-spec.md` from agents/).
     - **Version synchronization** from `.claude-plugin/plugin.json` to `opencode/package.json`.
     - **Validation** that agent body path references resolve in both CC and OC contexts (warn on absolute paths).
   - The wrapper should be short (under 50 lines of shell or TypeScript) -- compound-engineering handles the heavy lifting.

3. Create `opencode/` directory structure.
4. Run the wrapper and verify output for all three agents.
5. Add tests for the cdocs-specific post-processing (not for the core conversion, which is compound-engineering's responsibility).

**Success criteria:** The wrapper script produces three valid OC agent files.
Diffing the generated frontmatter against hand-crafted expected output shows no differences.
The wrapper is under 50 lines (excluding comments); the core conversion is delegated to compound-engineering.

**Constraints:** Do not modify any CC-format files (except updating agent body paths from absolute to relative if needed).
Do not modify skills or rules.
Do not reimplement functionality that compound-engineering already provides.

### Phase 2: AGENTS.md and Rules Integration

**Scope:** Add the cross-tool rules entry point.

1. Create `plugins/cdocs/AGENTS.md` with `@`-imports of the three rule files (for CC compatibility).
2. Verify CC still reads the rules from `.claude/rules/` (the AGENTS.md does not interfere).
3. Verify OC reads the rules via the `.claude/rules/` fallback.
4. Test OC's handling of `@`-imports in AGENTS.md (expected: treated as literal text, confirming the need for the inlined approach).
5. Document the rules discovery behavior in a brief section of the cdocs README.

The project-level AGENTS.md (with inlined content for cross-tool safety) is owned by the [cross-target rules integration proposal](2026-03-14-cross-target-rules-integration.md).
This proposal defers to that proposal for the AGENTS.md approach used in `/cdocs:init` and project-level configuration.

**Success criteria:** Both CC and OC load the writing conventions, workflow patterns, and frontmatter spec rules when the plugin is installed (CC via `@`-imports or `.claude/rules/`, OC via `.claude/rules/` fallback).

**Constraints:** Do not modify existing rule files.
The AGENTS.md is additive only.

### Phase 3: OC Hooks Plugin

**Scope:** Hand-write the OC TypeScript plugin implementing hook equivalents for both hooks (frontmatter validation and path restriction).

1. Create `opencode/plugins/cdocs-hooks.ts`:
   - Implement frontmatter validation on `tool.execute.after` for Write/Edit to cdocs paths (port from `cdocs-validate-frontmatter.sh`, 73 lines of bash).
   - Implement path restriction on `tool.execute.before` for Write/Edit to non-cdocs paths (port from `validate-cdocs-edit-path.sh`, 18 lines of bash; wired in CC during Phase 0).
2. Test the hooks manually in an OC session:
   - Write a cdocs file with missing frontmatter and verify the validation warning appears.
   - Attempt to edit a file outside `cdocs/` directories and verify the edit is blocked.
3. Document any behavioral differences from the CC hooks (e.g., output format, error messaging).

**Success criteria:** Writing a cdocs file in OC triggers frontmatter validation feedback.
The hook correctly identifies missing required fields.
Path restriction blocks edits to non-cdocs files.

**Constraints:** This is hand-written code, not generated by compound-engineering or the wrapper script.
Keep the implementation minimal: match CC hook behavior, do not add new functionality.

### Phase 4: npm Packaging

**Scope:** Create the npm package manifest and publish workflow.

1. Create `opencode/package.json` with appropriate metadata (version derived from `plugin.json` by the wrapper script).
2. Add a `files` field to control what ships in the package.
3. Implement the postinstall script that copies skills and rules (with `CDOCS_SKIP_POSTINSTALL` opt-out).
4. Test local installation: `npm pack` in `opencode/`, then reference the tarball in a test project's `opencode.json`.
5. Set up npm publishing (scoped under `@weft`).

**Success criteria:** `npm pack` produces a valid tarball.
A test project can reference the local tarball and OC loads the plugin, agents, and hooks.
The postinstall copies skills and rules to the correct paths.

**Constraints:** Do not publish to npm until the build output is validated and the plugin works end-to-end.

### Phase 5: CI/CD

**Scope:** Automate build, validation, and optionally publishing.

1. Add a GitHub Actions workflow:
   - Step 1: Run `scripts/build-opencode.sh` (compound-engineering conversion + cdocs post-processing).
   - Step 2: `git diff --exit-code opencode/` (dirty check: fail if generated files are stale).
   - Step 3: YAML lint on generated agent files.
   - Step 4: (Optional) `npm pack` in `opencode/` (package validation).
2. On tagged releases, optionally publish the npm package.
3. Add a `Makefile` or `package.json` script at the repo root for local convenience: `make build-opencode` or `npm run build:opencode`.

Use a separate GitHub Actions job with path filters (`plugins/cdocs/**`) and `continue-on-error: true` so CC-only PRs are not blocked by OC build failures.

**Success criteria:** CI catches stale generated files on PRs.
Tagged releases produce a valid npm package.

### Phase 6: Documentation and README Updates

**Scope:** Update the cdocs README and clauthier CLAUDE.md to document multi-target support.

1. Add an "OpenCode Installation" section to `plugins/cdocs/README.md`.
2. Document the wrapper script usage (compound-engineering invocation + post-processing), including auto-discovery of new agents.
3. Add a brief note in `CLAUDE.md` about the multi-target structure.
4. Add a `.gitattributes` or comment header in generated files marking them as auto-generated.

**Success criteria:** A new user can follow the README to install cdocs in either CC or OC.

**Constraints:** Do not restructure existing documentation.
Add sections, do not rewrite.

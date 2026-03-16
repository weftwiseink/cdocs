---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-16T00:00:00-07:00
task_list: marketplace/multi-target
type: devlog
state: live
status: done
tags: [architecture, multi-target, compound-engineering, critical-review, decision-chain]
---

# Devlog: Critical Review of the compound-engineering Decision Chain

> BLUF: The compound-engineering-plugin is an **install tool** that deploys converted plugins to user config directories (`~/.config/opencode/`, etc.), not a **build tool** that generates committed artifacts in a repo's `opencode/` directory.
> The strategies report correctly described it as an install-time converter ("author once, convert at install time"), but the proposal and amendment misread this as a build-time converter for generating repo-committed artifacts.
> compound-engineering IS useful for our use case, but as a user-side installation mechanism, not as a replacement for a custom build script.
> The `convert` subcommand can write to an arbitrary `--output` directory, which partially bridges the gap, but the tool was not designed for the "generate committed build artifacts" workflow the proposal assumed.

## The Decision Chain, Step by Step

### Step 1: Strategies Report (2026-03-14)

The report (`cdocs/reports/2026-03-14-multi-target-plugin-strategies.md`) made two distinct claims about compound-engineering:

**Claim A (Section 1):** compound-engineering is a CLI that "converts Claude Code plugins to 10 additional targets" using `bunx @every-env/compound-plugin install compound-engineering --to opencode`.
This is accurate.
The key word is **install** -- the report quoted the actual CLI syntax, which is an install command.

**Claim B (Section 4, "Dual-Publish Workflow"):** A repo "can build both formats" following a pattern with a generated `opencode/` directory.
The report then sketched a custom `scripts/build-opencode.ts` in Section 8.
It described compound-engineering as demonstrating the *pattern*, not as being the tool that performs the build.

**What actually happened:** The report correctly identified compound-engineering as a user-side install tool ("convert at install time") but then described a *separate* build-time workflow using a custom script.
The report did not conflate the two.
It said "the compound-engineering converter *demonstrates* this pattern" (emphasis on demonstrates, not implements).

### Step 2: The Proposal (2026-03-14)

The original proposal (`cdocs/proposals/2026-03-14-multi-target-marketplace.md`) initially followed the strategies report's Section 8 recommendation: write a custom `scripts/build-opencode.ts` to generate committed artifacts in `opencode/`.
This was consistent with the report.

### Step 3: The Amendment (2026-03-16)

The amendment devlog (`cdocs/devlogs/2026-03-16-marketplace-compound-engineering-amendment.md`) made the critical pivot.
It argued:

> "The strategies report already identified compound-engineering as a proven converter but prescribed a custom script anyway; the proposal followed that recommendation without questioning build-vs-buy."

The amendment then replaced the custom build script with `bunx @every-env/compound-plugin convert ./plugins/cdocs --to opencode` wrapped in a thin shell script.

**This is where the confusion enters.**
The amendment framed the change as a build-vs-buy decision -- why write a custom converter when an existing tool already does it?
But the amendment did not verify what compound-engineering's `install` or `convert` commands actually DO in terms of output location and workflow assumptions.

### Step 4: What compound-engineering Actually Does

Reading the actual source code of compound-engineering-plugin reveals two subcommands:

**`install`** -- The command shown in the README and strategies report.
- Takes a plugin name (e.g., `compound-engineering`) or local path.
- If given a name, it **clones the EveryInc GitHub repo** into a temp directory and looks for the plugin inside `plugins/<name>/`.
- Default output for opencode: `~/.config/opencode/` (the user's global config directory).
- Designed for end-user consumption: "I want to use this CC plugin in my OpenCode setup."

**`convert`** -- Not mentioned in the README's install examples, but present in the CLI.
- Takes a local source path (e.g., `./plugins/cdocs`).
- Default output: `process.cwd()` (the current working directory).
- Accepts `--output` to write to an arbitrary directory.
- Otherwise functionally identical to `install` in terms of conversion logic.

The key differences between the two:

| Aspect | `install` | `convert` |
|--------|-----------|-----------|
| Plugin resolution | Name (clones from GitHub) or local path | Local path only |
| Default output (opencode) | `~/.config/opencode/` | `process.cwd()` |
| Default permissions | `none` | `broad` |
| Intended workflow | User installs a published plugin | Developer converts a plugin during development |

Both commands call the same `target.convert()` and `target.write()` functions.
The conversion logic is identical.
The difference is in resolution and output path defaults.

## Assessment

### Is compound-engineering suitable for generating committed build artifacts?

**Partially, with caveats.**

The `convert` command with `--output ./plugins/cdocs/opencode` could write converted agents to the right place in our repo.
However, compound-engineering was designed for deployment, not artifact generation:

1. **It writes to config directories, not repo directories.**
   The output format assumes the files land in `~/.config/opencode/` (or equivalent), where they are consumed directly by the target tool.
   It does not generate a `package.json`, does not set up npm packaging structure, and does not produce a self-contained distributable directory.

2. **It does not generate package manifests.**
   The proposal's `opencode/package.json` would still need to be hand-maintained or generated by our own script.
   compound-engineering converts individual plugin artifacts (agents, commands, MCP config), not packaging metadata.

3. **It does not handle version synchronization.**
   Deriving `package.json` version from `plugin.json` is our concern, not compound-engineering's.

4. **It does not do path rewriting in agent body content.**
   The cdocs-specific post-processing (rewriting `plugins/cdocs/rules/frontmatter-spec.md` to relative paths) is not something compound-engineering does.

5. **The output directory structure may not match what we want.**
   compound-engineering writes to the target's expected config layout (e.g., commands as `.md` files in specific directories, `opencode.json` for MCP config).
   Our proposal wants a self-contained `opencode/` directory that gets committed and later copied by users or npm postinstall.

### Is it designed for end-user installation?

**Yes, this is its primary use case.**
The README, the CLI defaults, the `install` command's GitHub-cloning behavior, and the `sync` command all point to a tool designed for:
- End users who want to use CC plugins in other tools.
- Developers who want to test their CC plugin in other tools during development.

### Could it be useful as a user-side install recommendation?

**Yes, and this may be the correct way to use it.**

Instead of compound-engineering being part of our build pipeline, we could:

1. **For CC users:** Install via the CC marketplace as today.
2. **For OC users:** Recommend `bunx @every-env/compound-plugin install ./plugins/cdocs --to opencode` (local path) or, if we publish to the compound-engineering marketplace, `bunx @every-env/compound-plugin install cdocs --to opencode` (by name).
3. **For multi-tool users:** `bunx @every-env/compound-plugin install cdocs --to all`.

This shifts the conversion from build-time to install-time -- which is actually what the strategies report originally described as the "dominant pattern."

## What the Documents Actually Claimed vs. Reality

| Document | Claimed | Reality |
|----------|---------|---------|
| Strategies report (Sec 1) | compound-engineering is a CLI that converts CC plugins using `install` command | Accurate -- it is an install-time converter |
| Strategies report (Sec 4) | A repo "can build both formats" with a generated `opencode/` directory | Accurate -- but described a *custom* build script, not compound-engineering |
| Strategies report (Sec 8) | Recommended a custom `build-opencode.ts` | Consistent with its own analysis |
| Amendment devlog | Report "identified compound-engineering as a proven converter but prescribed a custom script anyway" | Slightly misleading -- report correctly distinguished install-time tool from build-time script |
| Amendment devlog | compound-engineering handles "model mapping, tool expansion, permission generation" for build-time use | The conversion logic exists, but the tool's workflow assumptions target install-time, not build-time |
| Proposal (amended) | `bunx @every-env/compound-plugin convert ./plugins/cdocs --to opencode` as a build step | The `convert` command exists and could be used this way, but the tool was not designed for committed-artifact generation |

## Recommended Path Forward

Three viable options, in order of recommendation:

### Option A: Hybrid approach (recommended)

1. **Custom build script** for generating committed `opencode/` artifacts.
   The script is small (~100-200 lines of TypeScript) and gives us full control over output structure, `package.json` generation, version sync, and path rewriting.
   This is what the strategies report originally recommended.

2. **compound-engineering as user-side install** for users who do not want to use our npm package.
   Document it in the README: "Alternatively, install cdocs for OpenCode via `bunx @every-env/compound-plugin install ...`".
   This leverages compound-engineering for what it was designed to do.

### Option B: compound-engineering `convert` with heavy wrapper

Use `convert --output ./plugins/cdocs/opencode` as the core conversion, then wrap it with 50-100 lines of post-processing (package.json generation, version sync, path rewriting, output restructuring).
This is the amended proposal's approach.
It works but relies on compound-engineering's output format matching our repo layout, which is not guaranteed across versions.

### Option C: compound-engineering only (user-side)

Drop the committed `opencode/` directory entirely.
OC users install via compound-engineering at install time.
This eliminates the build step and the committed artifacts, but means OC users cannot just `npm install` a package -- they need compound-engineering.

## Conclusion

The amendment was not *wrong* -- compound-engineering's `convert` command genuinely can convert our agents.
But the amendment overstated the build-vs-buy argument by treating an install-time tool as a build-time tool.
The strategies report's original recommendation of a custom build script was more appropriate for the "generate committed artifacts" workflow.
compound-engineering's best role in our architecture is as a user-side install mechanism, documented in the README as an alternative installation path.

The proposal should be amended to revert Phase 1 to a custom build script for committed artifacts, and add compound-engineering as a documented user-side install option.

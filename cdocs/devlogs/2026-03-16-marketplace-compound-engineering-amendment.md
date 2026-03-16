---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-16T00:00:00-07:00
task_list: marketplace/multi-target
type: devlog
state: live
status: done
tags: [architecture, multi-target, opencode, compound-engineering, amendment]
---

# Devlog: Marketplace Proposal Amendment -- Use compound-engineering-plugin

> BLUF: Amended the multi-target marketplace proposal to use `compound-engineering-plugin` (`@every-env/compound-plugin`) for CC-to-OC agent conversion instead of a custom ~100-200 line TypeScript build script.
> The strategies report already identified compound-engineering as a proven converter but prescribed a custom script anyway; the proposal followed that recommendation without questioning build-vs-buy.

## Problem

The [multi-target marketplace proposal](../proposals/2026-03-14-multi-target-marketplace.md) originally specified writing a custom `scripts/build-opencode.ts` to convert CC agent frontmatter to OC format.
The [multi-target strategies report](../reports/2026-03-14-multi-target-plugin-strategies.md) identified `compound-engineering-plugin` as a mature, existing converter in Sections 1 and 4, but then prescribed a custom build script in Section 8's "Recommended Strategy."
The proposal followed that recommendation without questioning the build-vs-buy tradeoff.

## Changes Applied

### 1. BLUF and Summary

Updated to reference compound-engineering as the conversion tool rather than a custom build script.

### 2. Phase 1: Rewritten

Replaced the custom build script approach with:
- Use `bunx @every-env/compound-plugin convert ./plugins/cdocs --to opencode` for core conversion.
- A thin wrapper script (`scripts/build-opencode.sh`, under 50 lines) for cdocs-specific post-processing: relative path rewriting in agent bodies, version synchronization from `plugin.json`.
- A verification-first step: confirm compound-engineering exists and works before depending on it, with a fallback to the custom script approach.
- Added appropriate hedging: all ecosystem tooling references from prior research are potentially hallucinated and must be verified.

### 3. Repo Structure

Replaced `scripts/build-opencode.ts` with `scripts/build-opencode.sh` (thin wrapper).

### 4. Design Decisions

Added "Decision: Use compound-engineering-plugin for agent conversion instead of a custom build script" with build-vs-buy rationale:
- Mature ecosystem tool handling model mapping, tool expansion, permission generation.
- 10+ target support for future portability.
- Format evolution handled upstream.
- Thin wrapper covers cdocs-specific concerns only.

### 5. Edge Cases

Updated "OC version drift" to note that compound-engineering handles format evolution upstream -- we inherit compatibility by updating the dependency rather than maintaining conversion logic.
Updated "CC `skills:` frontmatter" to note compound-engineering likely drops unrecognized fields, with wrapper fallback.

### 6. Test Plan

Simplified unit tests from 7 items (testing custom conversion logic) to 4 items (testing only the wrapper's post-processing: version sync, path rewriting, path verification, body integrity).
The core conversion is compound-engineering's responsibility to test.

### 7. CI/CD (Phase 5)

Updated to invoke the wrapper script instead of the custom TypeScript build script.

### 8. Consistency Pass

Updated all remaining references throughout the document: "build script" -> "wrapper script" or "compound-engineering" as appropriate.
Updated design decisions for version derivation, relative paths, Bun runtime, and committed output.
Bumped revision_round to 3 and updated last_reviewed to reflect this amendment.

## What Was NOT Changed

- The [cross-target rules integration proposal](../proposals/2026-03-14-cross-target-rules-integration.md) -- it covers hook-based rules injection, not build scripts.
- The strategies report -- not amended retroactively.
- Hooks (Phase 3) -- correctly identified as needing hand-written reimplementation.
- Skills/rules portability sections (Layers 1-2) -- already "no changes needed."
- The agent frontmatter examples and mapping tables -- these document the format, not the tool that performs the conversion.

## Verification

Searched the amended proposal for remaining references to `build-opencode.ts` (zero found) and `build script` (only in the design decision explaining why we chose NOT to write one, and in fallback references).
All phases, edge cases, test plan items, and design decisions are internally consistent with the compound-engineering approach.

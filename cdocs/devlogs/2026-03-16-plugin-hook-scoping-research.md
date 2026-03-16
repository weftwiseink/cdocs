---
first_authored:
  by: "@claude-opus-4-6"
  at: 2026-03-16T00:00:00-04:00
task_list: cdocs/hook-scoping-research
type: devlog
state: live
status: complete
tags: [research, hooks, plugins, subagents, security]
---

# Plugin Hook Scoping Research: Devlog

## Objective

Determine whether Claude Code plugin hooks can be scoped to specific subagents, so that a PreToolUse hook blocking Write/Edit to non-cdocs paths does not interfere with normal development in the main session.

## Context

The cdocs plugin has `validate-cdocs-edit-path.sh` -- a PreToolUse hook that blocks Write/Edit to files outside `cdocs/` directories. This is appropriate for cdocs subagents (triage, reviewer, nit-fix) but would break normal development if wired globally via `hooks.json`.

## Findings

### 1. Plugin hooks.json hooks are global

Hooks declared in a plugin's `hooks/hooks.json` fire for ALL tool uses in the session, including the main thread and all subagents. There is no `hooks.json`-level field to restrict a hook to specific agent types or subagent contexts.

### 2. agent_id and agent_type are available in hook input

All hook events include two context fields when firing inside a subagent:

- `agent_id` -- unique identifier, **present only inside a subagent** (absent in main session)
- `agent_type` -- the subagent's name (e.g., `"triage"`, `"nit-fix"`, `"reviewer"`)

This means a hook script can trivially detect its execution context:

```bash
INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // empty')
if [ -z "$AGENT_TYPE" ]; then
  exit 0  # main session -- allow everything
fi
```

This is the **primary mechanism** for scoping a global hook to specific subagents.

### 3. Agent frontmatter hooks are natively scoped

Hooks defined in agent markdown frontmatter are automatically scoped to that subagent's lifecycle and cleaned up when it finishes. This is the cleanest solution:

```yaml
---
name: triage
hooks:
  PreToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/hooks/validate-cdocs-edit-path.sh"
---
```

**However**: the subagents documentation explicitly states that plugin-sourced agents **do not support** `hooks`, `mcpServers`, or `permissionMode` frontmatter fields. These are silently ignored when loading agents from a plugin. This is a security restriction -- plugins are third-party code and Anthropic does not allow them to define lifecycle hooks on agents.

Workaround: users must copy the agent file into `.claude/agents/` or `~/.claude/agents/` for hooks in frontmatter to take effect. This defeats the zero-config plugin experience.

### 4. disallowedTools is the simpler alternative

The `disallowedTools` frontmatter field (now supported; issue #6005 closed) blocks specific tools at the agent level. But this is a blunt instrument: it blocks ALL Write/Edit operations, not just writes to non-cdocs paths. The cdocs agents legitimately need Write/Edit for cdocs files.

The `tools` allowlist is already in use (e.g., `tools: Read, Glob, Grep, Edit`). This restricts the tool surface but does not restrict by file path.

Neither `tools` nor `disallowedTools` support path-based restrictions. They operate on tool names only.

### 5. Recommended approach: conditional hook script in hooks.json

Wire the hook globally in `hooks.json` but have the script check `agent_type` and only enforce the path restriction for known cdocs agents:

```bash
#!/usr/bin/env bash
set -euo pipefail
INPUT=$(cat)

# Only enforce for cdocs subagents
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // empty')
case "$AGENT_TYPE" in
  triage|nit-fix|reviewer) ;;  # enforce
  *) exit 0 ;;                  # allow everything else
esac

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

if [[ ! "$FILE_PATH" =~ cdocs/(devlogs|proposals|reviews|reports)/ ]]; then
  echo "Blocked: this agent can only edit files in cdocs document directories." >&2
  exit 2
fi

exit 0
```

This fires globally (small overhead: one jq parse per Write/Edit) but only blocks in the right context.

### 6. OpenCode (OC) equivalent

OpenCode's `tool.execute.before` event is the closest equivalent to PreToolUse. However, OC's plugin system has **no documented agent-scoped hooks or agent context fields**. The hook context includes `project`, `directory`, and `worktree` but no agent identity. Agent-scoped tool restrictions in OC would require a different mechanism (possibly the oh-my-opencode plugin's permission-object approach, but that is a third-party extension, not core OC).

### 7. Relevant CC issues

| Issue | Status | Relevance |
|-------|--------|-----------|
| [#35099](https://github.com/anthropics/claude-code/issues/35099) | Open | Skill-scoped tool permissions (not yet supported) |
| [#35054](https://github.com/anthropics/claude-code/issues/35054) | Open | `context: fork` and `agent` frontmatter silently ignored for plugin-loaded skills |
| [#6005](https://github.com/anthropics/claude-code/issues/6005) | Closed | `disallowedTools` in agent frontmatter (now supported) |
| [#4740](https://github.com/anthropics/claude-code/issues/4740) | Closed | Sub-agents use tools without permission (historical bug) |

## Recommendations

**For CC (immediate):** Update `validate-cdocs-edit-path.sh` to check `agent_type` and wire it as a global PreToolUse hook in `hooks.json`. The overhead is minimal (one jq call per Edit/Write) and the script already exists. This is production-ready today.

**For CC (aspirational):** File an issue requesting that plugin-sourced agents support `hooks` in frontmatter, at least for `type: command` hooks that reference scripts within the plugin root. This would enable the cleanest architecture (agent-scoped hooks without global overhead) while maintaining security (scripts are sandboxed to the plugin directory).

**For OC:** The path-restriction safeguard cannot be ported as a hook today. OC's `tool.execute.before` lacks agent context. Two alternatives: (a) rely on agent prompt instructions alone (soft guardrail), or (b) wait for OC to add agent context to hook payloads.

**Do not abandon the safeguard.** The conditional-script approach is simple, zero-overhead in the main session, and provides a genuine safety net against subagent path confusion.

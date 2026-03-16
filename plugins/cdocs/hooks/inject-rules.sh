#!/usr/bin/env bash
# CDocs SessionStart hook: inject rule content as additionalContext
#
# For CC external installs, rules are not available via @-imports in CLAUDE.md.
# This hook reads all rules/*.md from the plugin directory and returns their
# content as additionalContext at session start.
#
# Skips injection in the source repo where rules are already loaded via
# CLAUDE.md @-imports.
#
# Dependencies: bash, jq (for JSON escaping)

set -euo pipefail

RULES_DIR="${CLAUDE_PLUGIN_ROOT}/rules"

# Skip injection if we're in the source repo (rules already loaded via CLAUDE.md @-imports)
PROJECT_CLAUDE_MD="${PWD}/CLAUDE.md"
if [ -f "$PROJECT_CLAUDE_MD" ] && grep -q '@plugins/cdocs/rules/' "$PROJECT_CLAUDE_MD" 2>/dev/null; then
  exit 0
fi

CONTEXT=""

for rule_file in "$RULES_DIR"/*.md; do
  [ -f "$rule_file" ] || continue
  BASENAME=$(basename "$rule_file" .md)
  CONTENT=$(cat "$rule_file")
  # Strip entire YAML frontmatter block (content between first two --- lines)
  CONTENT=$(echo "$CONTENT" | awk 'BEGIN{fm=0} /^---$/{fm++; next} fm>=2{print}')
  CONTEXT="${CONTEXT}

## [cdocs rule: ${BASENAME}]

${CONTENT}
"
done

if [ -n "$CONTEXT" ]; then
  # Escape for JSON using jq (lighter than python3, commonly available)
  ESCAPED=$(echo "$CONTEXT" | jq -Rs .)
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":${ESCAPED}}}"
fi

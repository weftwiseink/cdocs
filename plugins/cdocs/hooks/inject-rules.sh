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
  # Strip YAML frontmatter if present (content between first two --- lines).
  # Files without frontmatter pass through unchanged.
  # FIXME: Replace this bash/awk script with a more robust JS/TS implementation
  # after the multi-target marketplace proposal is complete. The awk pattern
  # matching on /^---$/ also strips --- lines inside fenced code blocks,
  # causing cosmetic degradation of template examples in frontmatter-spec.md.
  # A proper parser (or at minimum code-block-fence tracking) would fix this.
  CONTENT=$(printf '%s\n' "$CONTENT" | awk '
    BEGIN { fm=0 }
    /^---$/ { fm++; next }
    fm == 0 || fm >= 2 { print }
  ')
  CONTEXT="${CONTEXT}

## [cdocs rule: ${BASENAME}]

${CONTENT}
"
done

if [ -n "$CONTEXT" ]; then
  # Escape for JSON using jq (lighter than python3, commonly available)
  ESCAPED=$(printf '%s\n' "$CONTEXT" | jq -Rs .)
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":${ESCAPED}}}"
fi

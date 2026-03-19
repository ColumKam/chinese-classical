#!/usr/bin/env bash
# SessionStart hook for chinese-classical plugin
# Automatically injects instruction content at session start

set -euo pipefail

# Determine plugin root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Read INSTRUCTION.md content
INSTRUCTION_FILE="${PLUGIN_ROOT}/INSTRUCTION.md"
if [ ! -f "$INSTRUCTION_FILE" ]; then
    echo '{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": ""}}'
    exit 0
fi

INSTRUCTION_CONTENT=$(cat "$INSTRUCTION_FILE" 2>&1 || echo "Error reading instruction file")

# Read vocabulary.md content
VOCAB_FILE="${PLUGIN_ROOT}/references/vocabulary.md"
VOCAB_CONTENT=""
if [ -f "$VOCAB_FILE" ]; then
    VOCAB_CONTENT=$(cat "$VOCAB_FILE" 2>&1 || echo "")
fi

# Escape outputs for JSON using pure bash
escape_for_json() {
    local input="$1"
    local output=""
    local i char
    for (( i=0; i<${#input}; i++ )); do
        char="${input:$i:1}"
        case "$char" in
            $'\\') output+='\\' ;;
            '"') output+='\"' ;;
            $'\n') output+='\n' ;;
            $'\r') output+='\r' ;;
            $'\t') output+='\t' ;;
            *) output+="$char" ;;
        esac
    done
    printf '%s' "$output"
}

INSTRUCTION_ESCAPED=$(escape_for_json "$INSTRUCTION_CONTENT")
VOCAB_ESCAPED=$(escape_for_json "$VOCAB_CONTENT")

# Build additional context
ADDITIONAL_CONTEXT=""

if [ -n "$INSTRUCTION_ESCAPED" ]; then
    ADDITIONAL_CONTEXT="<important-reminder>\n${INSTRUCTION_ESCAPED}"
    if [ -n "$VOCAB_ESCAPED" ]; then
        ADDITIONAL_CONTEXT="${ADDITIONAL_CONTEXT}\n\n---\n\n## 词汇参考\n\n${VOCAB_ESCAPED}"
    fi
    ADDITIONAL_CONTEXT="${ADDITIONAL_CONTEXT}\n</important-reminder>"
fi

# Output context injection as JSON
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "${ADDITIONAL_CONTEXT}"
  }
}
EOF

exit 0

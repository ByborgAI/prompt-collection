#!/usr/bin/env bash
# ============================================================================
# Hook Logger Library
# ============================================================================
# This library provides JSONL logging functionality for all hooks.
# Each hook script logs its output to a separate JSONL file.
# ============================================================================

# Get the directory where hook logs should be stored
get_log_dir() {
    # Use .rgw-logs directory in the project root
    echo "${PWD}/.rgw-logs"
}

# Initialize logging for a hook
init_logging() {
    local log_dir=$(get_log_dir)
    mkdir -p "$log_dir"
}

# Log the output that a hook is about to return
# Usage: log_hook_output "hook-name" "output-string"
log_hook_output() {
    local hook_name="$1"
    local output="$2"

    local log_dir=$(get_log_dir)
    local log_file="${log_dir}/${hook_name}.jsonl"

    # Create log directory if it doesn't exist
    mkdir -p "$log_dir"

    # Create JSONL entry with timestamp, hook name, and output
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Escape the output for JSON (handle quotes, newlines, etc.)
    local escaped_output=$(echo "$output" | python3 -c '
import sys
import json
content = sys.stdin.read()
print(json.dumps(content)[1:-1])  # Remove outer quotes added by json.dumps
' 2>/dev/null || echo "$output" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n' | sed 's/\\n$//')

    # Append JSONL entry to the log file
    echo "{\"timestamp\":\"$timestamp\",\"hook\":\"$hook_name\",\"output\":\"$escaped_output\"}" >> "$log_file"
}

# Check if JSON output contains a block reason and echo to stderr if present
# Usage: check_and_echo_block_reason "json-output-string"
check_and_echo_block_reason() {
    local output="$1"

    # Check for "permissionDecision": "deny" (pre-tool-use hook format)
    if command -v jq &> /dev/null; then
        # Use jq for reliable JSON parsing
        if echo "$output" | jq -e '.permissionDecision == "deny"' >/dev/null 2>&1; then
            local reason=$(echo "$output" | jq -r '.permissionDecisionReason // empty' 2>/dev/null)
            if [[ -n "$reason" ]]; then
                echo "$reason" >&2
            fi
            return 0
        fi

        # Check for "decision": "block" (post-tool-use hook format)
        if echo "$output" | jq -e '.decision == "block"' >/dev/null 2>&1; then
            local context=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext // empty' 2>/dev/null)
            if [[ -n "$context" ]]; then
                echo "$context" >&2
            fi
            return 0
        fi
    else
        # Fallback to grep/sed if jq not available (legacy support)
        if echo "$output" | grep -q '"permissionDecision"[[:space:]]*:[[:space:]]*"deny"'; then
            local reason=$(echo "$output" | grep -o '"permissionDecisionReason"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"permissionDecisionReason"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')
            if [[ -n "$reason" ]]; then
                echo "$reason" >&2
            fi
            return 0
        fi

        if echo "$output" | grep -q '"decision"[[:space:]]*:[[:space:]]*"block"'; then
            local context=$(echo "$output" | grep -o '"additionalContext"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"additionalContext"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')
            if [[ -n "$context" ]]; then
                echo "$context" >&2
            fi
            return 0
        fi
    fi

    return 1
}

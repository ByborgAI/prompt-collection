#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# PART -1: Check if required commands are installed
# ============================================================================

if ! command -v yq &> /dev/null; then
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "yq is not installed. Install it to enable hook functionality.\n  macOS: brew install yq\n  Linux: https://github.com/mikefarah/yq#install"
  }
}
EOF
    exit 0
fi

if ! command -v node &> /dev/null; then
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Node.js is not installed. Install it to enable hook functionality.\n  macOS: brew install node\n  Linux: https://nodejs.org/en/download/package-manager"
  }
}
EOF
    exit 0
fi

if ! command -v npx &> /dev/null; then
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "npx is not installed. Install it to enable hook functionality.\n  npm install -g npx"
  }
}
EOF
    exit 0
fi

# Determine which JSON command to use (prefer installed json, fallback to npx)
if command -v json &> /dev/null; then
    JSON_CMD="json"
else
    JSON_CMD="npx -y json"
fi

# Read JSON input
json=$(cat)

# Extract file path
file_path=$(echo "$json" | $JSON_CMD tool_input.file_path 2>/dev/null || echo "")

# ============================================================================
# PART 2: Verify Task
# ============================================================================

if [[ "$file_path" =~ task-[0-9]+\.yaml$ ]]; then
    if [[ -f "$file_path" ]]; then
        # Extract old and new status from the hook JSON
        old_string=$(echo "$json" | $JSON_CMD tool_input.old_string 2>/dev/null || echo "")
        new_string=$(echo "$json" | $JSON_CMD tool_input.new_string 2>/dev/null || echo "")

        current_status=""
        new_status=""
        old_has_status=false
        new_has_status=false

        # Parse status from old_string (format: "status: <value>" or "status: \"<value>\"" or "status: '<value>'")
        # Use grep to extract just the status line, handling multiline strings
        # Use grep -m 1 to only get the first match in case of multiline content
        if status_line=$(echo "$old_string" | grep -m 1 -E '^status:[[:space:]]*'); then
            # Match quoted or unquoted status values (including multi-word statuses)
            if [[ "$status_line" =~ ^status:[[:space:]]*\"([^\"]+)\" ]]; then
                current_status="${BASH_REMATCH[1]}"
                old_has_status=true
            elif [[ "$status_line" =~ ^status:[[:space:]]*\'([^\']+)\' ]]; then
                current_status="${BASH_REMATCH[1]}"
                old_has_status=true
            elif [[ "$status_line" =~ ^status:[[:space:]]*(.+)$ ]]; then
                # For unquoted values, capture everything after "status:" until end of line
                current_status=$(echo "${BASH_REMATCH[1]}" | sed 's/[[:space:]]*$//')
                old_has_status=true
            fi
        fi

        # Parse status from new_string (format: "status: <value>" or "status: \"<value>\"" or "status: '<value>'")
        # Use grep to extract just the status line, handling multiline strings
        # Use grep -m 1 to only get the first match in case of multiline content
        if status_line=$(echo "$new_string" | grep -m 1 -E '^status:[[:space:]]*'); then
            # Match quoted or unquoted status values (including multi-word statuses)
            if [[ "$status_line" =~ ^status:[[:space:]]*\"([^\"]+)\" ]]; then
                new_status="${BASH_REMATCH[1]}"
                new_has_status=true
            elif [[ "$status_line" =~ ^status:[[:space:]]*\'([^\']+)\' ]]; then
                new_status="${BASH_REMATCH[1]}"
                new_has_status=true
            elif [[ "$status_line" =~ ^status:[[:space:]]*(.+)$ ]]; then
                # For unquoted values, capture everything after "status:" until end of line
                new_status=$(echo "${BASH_REMATCH[1]}" | sed 's/[[:space:]]*$//')
                new_has_status=true
            fi
        fi

        # Check for status field removal
        if [[ "$old_has_status" == true && "$new_has_status" == false ]]; then
            cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Removal of status field is not allowed"
  }
}
EOF
            exit 0
        fi

        # Define valid transitions
        # Check if transition is valid
        if [[ -n "$new_status" && "$new_status" != "$current_status" ]]; then
            valid_transition=false
            valid_next=()

            case "$current_status" in
                "")
                    valid_next=("to do")
                    ;;
                "to do")
                    valid_next=("in progress")
                    ;;
                "in progress")
                    valid_next=("under review")
                    ;;
                "under review")
                    valid_next=("done" "in progress")
                    ;;
                "done")
                    valid_next=()
                    ;;
                *)
                    valid_next=()
                    ;;
            esac

            # Check if new_status is in valid_next array
            for allowed in "${valid_next[@]}"; do
                [[ "$new_status" == "$allowed" ]] && valid_transition=true && break
            done

            # Format expected_next for error message
            expected_next=$(IFS=' or '; echo "${valid_next[*]}")
            [[ -z "$expected_next" ]] && expected_next="<none>"

            if [[ "$valid_transition" == false ]]; then
                cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Invalid status transition: '${current_status:-<empty>}' → '$new_status'\\nExpected: '${current_status:-<empty>}' → '${expected_next}'"
  }
}
EOF
                exit 0
            fi
        fi

        # Function to extract status from file, handling quotes
        extract_file_status() {
            local file="$1"
            local raw_status=$(yq -r '.status // ""' "$file")
            # Remove surrounding quotes if present
            if [[ "$raw_status" =~ ^[\"\'](.*)[\"\']$ ]]; then
                echo "${BASH_REMATCH[1]}"
            else
                echo "$raw_status"
            fi
        }

        # Specific status validations
        case "$new_status" in
            "in progress")
                # Check if any OTHER task is in "under review" status
                # (Allow setting the same file back to "in progress" from "under review")
                current_basename=$(basename "$file_path")
                for task_file in task-*.yaml; do
                    if [[ "$task_file" != "$current_basename" && -f "$task_file" ]]; then
                        other_status=$(extract_file_status "$task_file")
                        if [[ "$other_status" == "under review" ]]; then
                            cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Cannot set task to 'in progress' while $task_file is 'under review'"
  }
}
EOF
                            exit 0
                        fi
                    fi
                done
                ;;
        esac
    fi
fi

# ============================================================================
# PART 3: Commit Changed Files When Task is Done
# ============================================================================

if [[ -n "$file_path" ]]; then
    filename=$(basename "$file_path")

    # Check if this is a task file that will be modified
    if [[ "$filename" =~ ^task-.*\.ya?ml$ ]] && [[ -f "$file_path" ]]; then
        # Extract new status from the hook JSON
        new_string=$(echo "$json" | $JSON_CMD tool_input.new_string 2>/dev/null || echo "")

        # Check if the new status will be "done"
        new_status=""
        if status_line=$(echo "$new_string" | grep -m 1 -E '^status:[[:space:]]*'); then
            # Match quoted or unquoted status values (including multi-word statuses)
            if [[ "$status_line" =~ ^status:[[:space:]]*\"([^\"]+)\" ]]; then
                new_status="${BASH_REMATCH[1]}"
            elif [[ "$status_line" =~ ^status:[[:space:]]*\'([^\']+)\' ]]; then
                new_status="${BASH_REMATCH[1]}"
            elif [[ "$status_line" =~ ^status:[[:space:]]*(.+)$ ]]; then
                # For unquoted values, capture everything after "status:" until end of line
                new_status=$(echo "${BASH_REMATCH[1]}" | sed 's/[[:space:]]*$//')
            fi
        fi

        if [[ "$new_status" == "done" ]]; then
            # Get the changed files and commit message
            changed_files_array=()
            while IFS= read -r line; do
                [[ -n "$line" ]] && changed_files_array+=("$line")
            done < <(yq -r '.changed_files[]?' "$file_path" 2>/dev/null || true)

            commit_message=$(yq -r '.commit_message // ""' "$file_path" 2>/dev/null || echo "")

            # Remove quotes from commit message if present
            if [[ "$commit_message" =~ ^[\"\'](.*)[\"\']$ ]]; then
                commit_message="${BASH_REMATCH[1]}"
            fi

            # Only proceed if we have both changed files and a commit message
            if [[ ${#changed_files_array[@]} -gt 0 ]] && [[ -n "$commit_message" ]]; then
                # Stage each changed file
                for file in "${changed_files_array[@]}"; do
                    if [[ -n "$file" ]] && [[ -f "$file" ]]; then
                        if ! git add "$file" 2>&1 >&2; then
                            cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Failed to stage file: $file"
  }
}
EOF
                            exit 0
                        fi
                    fi
                done

                # Create the commit with the task's commit message
                if ! git diff --cached --quiet 2>/dev/null; then
                    if ! git commit -m "$commit_message" > >(cat >&2) 2>&1; then
                        cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Failed to commit changes for task $filename"
  }
}
EOF
                        exit 0
                    fi
                    echo "Committed changes for task $filename"
                fi
            fi
        fi
    fi
fi

# All checks passed
exit 0
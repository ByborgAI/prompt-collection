#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# PART -1: Check if required commands are installed
# ============================================================================

if ! command -v yq &> /dev/null; then
    echo "Warning: yq is not installed. Install it to enable hook functionality." >&2
    echo "  macOS: brew install yq" >&2
    echo "  Linux: https://github.com/mikefarah/yq#install" >&2
    exit 2
fi

if ! command -v node &> /dev/null; then
    echo "Warning: Node.js is not installed. Install it to enable hook functionality." >&2
    echo "  macOS: brew install node" >&2
    echo "  Linux: https://nodejs.org/en/download/package-manager" >&2
    exit 2
fi

if ! command -v npx &> /dev/null; then
    echo "Warning: npx is not installed. Install it to enable hook functionality." >&2
    echo "  npm install -g npx" >&2
    exit 2
fi

# Determine which JSON command to use (prefer installed json, fallback to npx)
if command -v json &> /dev/null; then
    JSON_CMD="json"
else
    JSON_CMD="npx -y json"
fi

# Read JSON input
json=$(cat)

# Extract file path and tool name
file_path=$(echo "$json" | $JSON_CMD tool_response.filePath 2>/dev/null || echo "")
tool_name=$(echo "$json" | $JSON_CMD tool_name 2>/dev/null || echo "")

# ============================================================================
# PART 0: Track Changed Files in In-Progress Task
# ============================================================================

if [[ -n "$file_path" ]]; then
    # Skip tracking task yaml files and requirements.yaml
    filename=$(basename "$file_path")
    if [[ "$filename" =~ ^task-.*\.ya?ml$ ]] || [[ "$filename" == "requirements.yaml" ]]; then
        # Don't track these files
        :
    else
        # Find the task file with "status: in progress"
        in_progress_task=""
        for task_file in task-*.yaml task-*.yml; do
            if [[ -f "$task_file" ]]; then
                # Check if task has "in progress" status using yq
                task_status=$(yq -r '.status // ""' "$task_file" 2>/dev/null || echo "")
                # Remove quotes if present
                if [[ "$task_status" =~ ^[\"\'](.*)[\"\']$ ]]; then
                    task_status="${BASH_REMATCH[1]}"
                fi

                if [[ "$task_status" == "in progress" ]]; then
                    in_progress_task="$task_file"
                    break
                fi
            fi
        done

        # If we found an in-progress task, add the file to changed_files if not already there
        if [[ -n "$in_progress_task" ]]; then
            # Check if file is already in changed_files array
            file_exists=$(yq -r ".changed_files // [] | map(select(. == \"$file_path\")) | length" "$in_progress_task" 2>/dev/null || echo "0")

            if [[ "$file_exists" == "0" ]]; then
                # Add file to changed_files array
                yq -i ".changed_files += [\"$file_path\"]" "$in_progress_task"
            fi
        fi
    fi
fi

# ============================================================================
# PART 1: Verify Requirements
# ============================================================================

if [[ -n "$file_path" ]] && [[ "$file_path" == *"requirements.yaml" ]]; then
    if [[ -f "$file_path" ]]; then
        if yq -e '.complete == true' "$file_path" >/dev/null 2>&1; then
            yaml=$(claude -p "read and execute ~/.claude/plugins/marketplaces/prompt-collection/rgw/context/verify-requirements.md" | awk '/^passed:/{flag=1} flag')

            passed=$(echo "$yaml" | yq -r '.passed')
            remarks=$(echo "$yaml" | yq -r '.remarks[]?')

            if [[ "$passed" == "false" ]]; then
            echo "Requirements verification failed:" >&2
            echo "$remarks" >&2
            exit 2
            fi
        fi
    fi
fi

# ============================================================================
# PART 2: Verify Task Creation
# ============================================================================

if [[ -n "$file_path" ]] && [[ "$file_path" =~ task-[0-9]+\.yaml$ ]]; then
    # Only verify when the task file is created (Write tool used)
    if [[ "$tool_name" == "Write" ]] && [[ -f "$file_path" ]]; then
        yaml=$(claude -p "read task described in $file_path and execute ~/.claude/plugins/marketplaces/prompt-collection/rgw/context/verify-task.md" | awk '/^passed:/{flag=1} flag')

        passed=$(echo "$yaml" | yq -r '.passed')
        remarks=$(echo "$yaml" | yq -r '.remarks[]?')
        if [[ "$passed" == "false" ]]; then
            echo "Task verification failed:" >&2
            echo "$remarks" >&2
            exit 2
        fi
    fi
fi

# ============================================================================
# PART 3: Verify Content
# ============================================================================

if [[ -n "$file_path" ]]; then
    extension="${file_path##*.}"

    if [[ "$extension" == "yaml" || "$extension" == "yml" ]]; then
        commands=(
            "yq eval ."
        )
    else
        exit 0
    fi

    for cmd in "${commands[@]}"; do
        # Use timeout if available, otherwise run directly
        if command -v timeout &> /dev/null; then
            if ! timeout 30 $cmd "$file_path" 1>&2; then
                echo "Command failed: $cmd for $file_path" >&2
                exit 2
            fi
        else
            if ! $cmd "$file_path" 1>&2; then
                echo "Command failed: $cmd for $file_path" >&2
                exit 2
            fi
        fi
    done
fi

# All checks passed
exit 0

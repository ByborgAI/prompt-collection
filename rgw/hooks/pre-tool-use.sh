#!/usr/bin/env bash
set -euo pipefail

# Read JSON input
json=$(cat)

# Extract file path
file_path=$(echo "$json" | jq -r '.tool_input.file_path // empty')

# Define monitored extensions array
monitored_extensions=("js" "ts")

# ============================================================================
# PART 1: Verify Execution State
# ============================================================================

# If no file path, skip validation
if [[ -n "$file_path" ]]; then
    # Extract file extension
    file_extension="${file_path##*.}"

    # Check if extension is in monitored array
    is_monitored=false
    for ext in "${monitored_extensions[@]}"; do
        if [[ "$file_extension" == "$ext" ]]; then
            is_monitored=true
            break
        fi
    done

    # If an monitored extension, check execution state
    if [[ "$is_monitored" == true ]]; then
        # Check if any task files exist
        task_files_exist=false
        for task_file in task-*.yaml task-*.yml; do
            if [[ -f "$task_file" ]]; then
                task_files_exist=true
                break
            fi
        done

        # If task files exist, check if any have "status: in progress"
        if [[ "$task_files_exist" == true ]]; then
            task_in_progress=false
            for task_file in task-*.yaml task-*.yml; do
                if [[ -f "$task_file" ]]; then
                    if grep -q "^status:\s*in\s*progress" "$task_file" || \
                       grep -q "^status:\s*['\"]in progress['\"]" "$task_file"; then
                        task_in_progress=true
                        break
                    fi
                fi
            done

            # If task files exist but none are in progress, block the operation
            if [[ "$task_in_progress" == false ]]; then
                ext_list=$(IFS=,; echo "${monitored_extensions[*]}")
                echo "Cannot modify $file_path: Task files exist but none have 'status: in progress'." >&2
                exit 2
            fi
        fi
    fi
fi

# ============================================================================
# PART 2: Verify Task
# ============================================================================

if [[ "$file_path" =~ task-[0-9]+\.yaml$ ]]; then
    if [[ -f "$file_path" ]]; then
        # Extract old and new status from the hook JSON
        old_string=$(echo "$json" | jq -r '.tool_input.old_string // empty')
        new_string=$(echo "$json" | jq -r '.tool_input.new_string // empty')

        current_status=""
        new_status=""
        old_has_status=false
        new_has_status=false

        # Parse status from old_string (format: "status: <value>" or "status: \"<value>\"" or "status: '<value>'")
        if [[ "$old_string" =~ ^status:[[:space:]]*[\"\']*([^\"\']+)[\"\']*$ ]]; then
            current_status="${BASH_REMATCH[1]}"
            old_has_status=true
        fi

        # Parse status from new_string (format: "status: <value>" or "status: \"<value>\"" or "status: '<value>'")
        if [[ "$new_string" =~ ^status:[[:space:]]*[\"\']*([^\"\']+)[\"\']*$ ]]; then
            new_status="${BASH_REMATCH[1]}"
            new_has_status=true
        fi

        # Check for status field removal
        if [[ "$old_has_status" == true && "$new_has_status" == false ]]; then
            echo "Removal of status field is not allowed" >&2
            exit 2
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
                echo "Invalid status transition: '${current_status:-<empty>}' → '$new_status'" >&2
                echo "Expected: '${current_status:-<empty>}' → '${expected_next}'" >&2
                exit 2
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
                            echo "Cannot set task to 'in progress' while $task_file is 'under review'" >&2
                            exit 2
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
        new_string=$(echo "$json" | jq -r '.tool_input.new_string // empty')

        # Check if the new status will be "done"
        new_status=""
        if [[ "$new_string" =~ ^status:[[:space:]]*[\"\']*([^\"\']+)[\"\']*$ ]]; then
            new_status="${BASH_REMATCH[1]}"
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
                            echo "Failed to stage file: $file" >&2
                            exit 2
                        fi
                    fi
                done

                # Create the commit with the task's commit message
                if ! git diff --cached --quiet 2>/dev/null; then
                    if ! git commit -m "$commit_message" > >(cat >&2) 2>&1; then
                        echo "Failed to commit changes for task $filename" >&2
                        exit 2
                    fi
                    echo "Committed changes for task $filename" >&2
                fi
            fi
        fi
    fi
fi

# All checks passed
exit 0

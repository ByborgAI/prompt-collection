#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Load Logger Library
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/logger.sh"

# ============================================================================
# Session Start Hook - Check Required Dependencies
# ============================================================================
# This hook runs at the start of each Claude Code session to verify that
# all required dependencies are installed for the rgw workflow hooks.
# ============================================================================

missing_deps=()

# Check for yq (YAML processor)
if ! command -v yq &> /dev/null; then
    missing_deps+=("yq")
fi

# Check for node (required for json npm package)
if ! command -v node &> /dev/null; then
    missing_deps+=("node")
fi

# Check for npx (required to run json package)
if ! command -v npx &> /dev/null; then
    missing_deps+=("npx")
fi

# If there are missing dependencies, display installation instructions
if [ ${#missing_deps[@]} -gt 0 ]; then
    message="⚠️  Missing required dependencies for rgw workflow hooks:\\n\\n"

    for dep in "${missing_deps[@]}"; do
        case "$dep" in
            yq)
                message+="  📦 yq (YAML processor)\\n"
                message+="     macOS:  brew install yq\\n"
                message+="     Linux:  https://github.com/mikefarah/yq#install\\n"
                message+="\\n"
                ;;
            node)
                message+="  📦 Node.js (JavaScript runtime)\\n"
                message+="     macOS:  brew install node\\n"
                message+="     Linux:  https://nodejs.org/en/download/package-manager\\n"
                message+="\\n"
                ;;
            npx)
                message+="  📦 npx (npm package runner)\\n"
                message+="     Usually installed with Node.js\\n"
                message+="     If missing: npm install -g npx\\n"
                message+="\\n"
                ;;
        esac
    done

    message+="  ℹ️  Install the missing dependencies to enable full hook functionality."

    output=$(cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "$message"
  }
}
EOF
)
    log_hook_output "session-start" "$output"
    echo "$output"
else
    output=$(cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "✅ rgw workflow hooks: All required dependencies are installed."
  }
}
EOF
)
    log_hook_output "session-start" "$output"
    echo "$output"
fi

# Explicitly flush output
exit 0

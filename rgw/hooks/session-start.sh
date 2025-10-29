#!/usr/bin/env bash
set -euo pipefail

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
    echo "⚠️  Missing required dependencies for rgw workflow hooks:" >&2
    echo "" >&2

    for dep in "${missing_deps[@]}"; do
        case "$dep" in
            yq)
                echo "  📦 yq (YAML processor)" >&2
                echo "     macOS:  brew install yq" >&2
                echo "     Linux:  https://github.com/mikefarah/yq#install" >&2
                echo "" >&2
                ;;
            node)
                echo "  📦 Node.js (JavaScript runtime)" >&2
                echo "     macOS:  brew install node" >&2
                echo "     Linux:  https://nodejs.org/en/download/package-manager" >&2
                echo "" >&2
                ;;
            npx)
                echo "  📦 npx (npm package runner)" >&2
                echo "     Usually installed with Node.js" >&2
                echo "     If missing: npm install -g npx" >&2
                echo "" >&2
                ;;
        esac
    done

    echo "  ℹ️  Install the missing dependencies to enable full hook functionality." >&2
    echo "" >&2
fi

exit 0

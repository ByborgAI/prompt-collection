#!/bin/bash

# Install script for by-ai code review pre-commit hook
# This script installs the pre-commit hook that runs by-ai code review before commits

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HOOK_SOURCE="$SCRIPT_DIR/pre-commit-hook.sh"
GIT_HOOKS_DIR=".git/hooks"
HOOK_TARGET="$GIT_HOOKS_DIR/pre-commit"

echo "🚀 Installing by-ai code review pre-commit hook..."
echo "================================================="

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository root directory"
    echo "   Please run this script from the root of your git repository"
    exit 1
fi

# Check if git hooks directory exists
if [ ! -d "$GIT_HOOKS_DIR" ]; then
    echo "❌ Error: Git hooks directory not found"
    echo "   Expected: $GIT_HOOKS_DIR"
    exit 1
fi

# Check if claude command is available
if ! command -v claude &> /dev/null; then
    echo "❌ Error: Claude CLI not found"
    echo "   Please install Claude CLI first: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

# Check if existing pre-commit hook exists and backup if needed
if [ -f "$HOOK_TARGET" ]; then
    BACKUP_FILE="${HOOK_TARGET}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "⚠️  Existing pre-commit hook found"
    echo "   Creating backup: $BACKUP_FILE"
    cp "$HOOK_TARGET" "$BACKUP_FILE"
    echo "   ✅ Backup created successfully"
fi

# Create the pre-commit hook content
cat > "$HOOK_TARGET" << 'EOF'
#!/bin/bash

# Pre-commit hook to run by-ai code review with claude -p before committing
# This hook runs the by-ai code-review command and prompts user for confirmation

set -e

echo "🤖 Running claude command /by-ai:code-review before commit..."
echo "----------------------------------------"

# Run the by-ai code review command with claude -p
if claude -p "$(cat <<'REVIEW_EOF'
/by-ai:code-review master --depth quick --format text
REVIEW_EOF
)"; then
    echo "----------------------------------------"
    echo "✅ Code review completed successfully"
    echo ""
    
    # Prompt user for confirmation
    echo "🤔 Do you still want to proceed with this commit? (y/N)"
    read -r response < /dev/tty
    
    case "$response" in
        [yY]|[yY][eE][sS])
            echo "✅ Proceeding with commit..."
            exit 0
            ;;
        *)
            echo "❌ Commit aborted by user"
            exit 1
            ;;
    esac
else
    echo "❌ Code review failed or was interrupted"
    echo ""
    echo "🤔 Do you want to proceed with the commit anyway? (y/N)"
    read -r response < /dev/tty
    
    case "$response" in
        [yY]|[yY][eE][sS])
            echo "⚠️  Proceeding with commit despite review issues..."
            exit 0
            ;;
        *)
            echo "❌ Commit aborted due to review issues"
            exit 1
            ;;
    esac
fi
EOF

# Make the hook executable
chmod +x "$HOOK_TARGET"

echo ""
echo "✅ Pre-commit hook installed successfully!"
echo ""
echo "📋 What happens now:"
echo "   • Every time you run 'git commit', the hook will:"
echo "     1. Run by-ai code review on your staged changes"
echo "     2. Show you the review results"
echo "     3. Ask if you want to proceed with the commit"
echo ""
echo "🔧 To disable the hook temporarily:"
echo "   git commit --no-verify"
echo ""
echo "🗑️  To uninstall the hook:"
echo "   rm $HOOK_TARGET"

if [ -f "${HOOK_TARGET}.backup."* ]; then
    echo ""
    echo "📁 Your previous hook was backed up and can be restored if needed"
fi

echo ""
echo "🎉 Installation complete! Happy coding!"

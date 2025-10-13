#!/bin/bash

# Install script for aitt code review pre-commit hook
# This script installs the pre-commit hook that runs aitt code review before commits

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HOOK_SOURCE="$SCRIPT_DIR/pre-commit-hook.sh"

# Detect if we're in a submodule and find the target repository
SUPERPROJECT_ROOT="$(git rev-parse --show-superproject-working-tree 2>/dev/null || true)"
if [ -n "$SUPERPROJECT_ROOT" ]; then
    # We're in a submodule, target the parent repository
    TARGET_REPO_ROOT="$SUPERPROJECT_ROOT"
    echo "📁 Detected submodule installation"
    echo "   Submodule path: $(pwd)"
    echo "   Parent repo: $TARGET_REPO_ROOT"
else
    # We're in a regular repository
    TARGET_REPO_ROOT="$(git rev-parse --show-toplevel)"
    echo "📁 Installing in current repository"
    echo "   Repository root: $TARGET_REPO_ROOT"
fi

GIT_HOOKS_DIR="$TARGET_REPO_ROOT/.git/hooks"
HOOK_TARGET="$GIT_HOOKS_DIR/pre-commit"

echo "🚀 Installing aitt code review pre-commit hook..."
echo "================================================="

# Check if we're in a git repository (current directory)
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    echo "   Please run this script from within a git repository"
    exit 1
fi

# Check if target git hooks directory exists
if [ ! -d "$GIT_HOOKS_DIR" ]; then
    echo "❌ Error: Target git hooks directory not found"
    echo "   Expected: $GIT_HOOKS_DIR"
    echo "   Target repository: $TARGET_REPO_ROOT"
    exit 1
fi

# Check if claude command is available
if ! command -v claude &> /dev/null; then
    echo "❌ Error: Claude CLI not found"
    echo "   Please install Claude CLI first: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

# Prompt for branch name to diff against
echo ""
echo "🌿 Which branch should be used for code review comparisons?"
echo "   Common options: main, master, develop"
echo -n "   Enter branch name (default: main): "
read -r BRANCH_NAME < /dev/tty

# Set default if empty
if [ -z "$BRANCH_NAME" ]; then
    BRANCH_NAME="main"
fi

echo "   Using branch: $BRANCH_NAME"

# Check if existing pre-commit hook exists and backup if needed
if [ -f "$HOOK_TARGET" ]; then
    BACKUP_FILE="${HOOK_TARGET}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "⚠️  Existing pre-commit hook found"
    echo "   Creating backup: $BACKUP_FILE"
    cp "$HOOK_TARGET" "$BACKUP_FILE"
    echo "   ✅ Backup created successfully"
fi

# Store the submodule path for the hook to use
SUBMODULE_PATH=""
if [ -n "$SUPERPROJECT_ROOT" ]; then
    SUBMODULE_PATH="$(realpath --relative-to="$TARGET_REPO_ROOT" "$(pwd)")"
fi

# Create the pre-commit hook content
cat > "$HOOK_TARGET" << EOF
#!/bin/bash

# Pre-commit hook to run aitt code review with claude -p before committing
# This hook runs the aitt code-review command and prompts user for confirmation

set -e

echo "🤖 Running claude command /aitt:code-review before commit..."
echo "----------------------------------------"

# If this was installed from a submodule, navigate to it first
SUBMODULE_PATH="$SUBMODULE_PATH"
if [ -n "\$SUBMODULE_PATH" ]; then
    echo "📂 Navigating to submodule: \$SUBMODULE_PATH"
    cd "\$SUBMODULE_PATH"
fi

# Run the aitt code review command with claude -p
if claude -p "\\\$(cat <<'REVIEW_EOF'
/aitt:code-review $BRANCH_NAME --depth quick --format text
REVIEW_EOF
)"; then
    echo "----------------------------------------"
    echo "✅ Code review completed successfully"
    echo ""
    
    # Prompt user for confirmation
    echo "🤔 Do you still want to proceed with this commit? (y/N)"
    read -r response < /dev/tty
    
    case "\$response" in
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
    
    case "\$response" in
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
if [ -n "$SUPERPROJECT_ROOT" ]; then
echo "   • When you commit from the parent repository ($TARGET_REPO_ROOT), the hook will:"
echo "     1. Navigate to this submodule ($SUBMODULE_PATH)"
echo "     2. Run aitt code review on staged changes"
echo "     3. Show you the review results"
echo "     4. Ask if you want to proceed with the commit"
else
echo "   • Every time you run 'git commit', the hook will:"
echo "     1. Run aitt code review on your staged changes"
echo "     2. Show you the review results"
echo "     3. Ask if you want to proceed with the commit"
fi
echo ""
echo "🔧 To disable the hook temporarily:"
echo "   git commit --no-verify"
echo ""
echo "🗑️  To uninstall the hook:"
echo "   rm $HOOK_TARGET"

if ls "${HOOK_TARGET}.backup."* 1> /dev/null 2>&1; then
    echo ""
    echo "📁 Your previous hook was backed up and can be restored if needed"
fi

echo ""
echo "🎉 Installation complete! Happy coding!"

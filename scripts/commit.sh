#!/bin/bash

# Script to create a git commit with the help of AI-generated summary

# 1. Use AI to summarize changes with `claude "/by-ai:summarize-changes" -p` in the background
# 2. Find ticket number from branch name with `scripts/find-ticket-from-branch.sh`, ask for manual input if not found
#   - Allow user to specify ticket via `--ticket <ticket>` argument => skip step and use provided ticket
# 3. Prompt user to select commit type (feat, fix, docs, style, refactor, perf, test, chore)
#   - Allow user to specify type via `--type <type>` argument => skip step and use provided type
#   - Prompt defaults to "feat"
# 4. Create commit message with the initial generated summary, ticket number, and type, allowing user to edit it before finalizing
#   - If `--breaking` flag is provided, append "BREAKING CHANGE:" to the commit message
# 5. Execute the git commit with the finalized message

# Usage: ./scripts/commit.sh [--breaking] [--type <type>] [--ticket <ticket>] [-s|--short]

# Options:
#   --breaking          Mark the commit as a breaking change
#   --type <type>       Specify the commit type (feat, fix, docs, style, refactor, perf, test, chore)
#   --ticket <ticket>   Specify the ticket number manually
#   -s, --short         Generate a short summary instead of detailed bullet points
#   -h, --help          Show this help message and exit

set -e

# Initialize variables
BREAKING=false
TYPE=""
TICKET=""
SHORT=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Function to show help
show_help() {
    echo "Usage: $0 [--breaking] [--type <type>] [--ticket <ticket>] [-s|--short] [-h|--help]"
    echo ""
    echo "Create a git commit with AI-generated summary and structured format"
    echo ""
    echo "Options:"
    echo "  --breaking          Mark the commit as a breaking change"
    echo "  --type <type>       Specify the commit type (feat, fix, docs, style, refactor, perf, test, chore)"
    echo "  --ticket <ticket>   Specify the ticket number manually"
    echo "  -s, --short         Generate a short summary instead of detailed bullet points"
    echo "  -h, --help          Show this help message and exit"
    echo ""
    echo "Commit types:"
    echo "  feat     - A new feature"
    echo "  fix      - A bug fix"
    echo "  docs     - Documentation only changes"
    echo "  style    - Changes that do not affect code meaning (formatting, etc.)"
    echo "  refactor - Code change that neither fixes a bug nor adds a feature"
    echo "  perf     - A code change that improves performance"
    echo "  test     - Adding missing tests or correcting existing tests"
    echo "  chore    - Changes to build process or auxiliary tools"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --breaking)
            BREAKING=true
            shift
            ;;
        --type)
            TYPE="$2"
            shift 2
            ;;
        --ticket)
            TICKET="$2"
            shift 2
            ;;
        -s|--short)
            SHORT=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Error: Unknown option $1" >&2
            show_help
            exit 1
            ;;
    esac
done

# Validate commit type if provided
if [[ -n "$TYPE" ]]; then
    case $TYPE in
        feat|fix|docs|style|refactor|perf|test|chore)
            ;;
        *)
            echo "Error: Invalid commit type '$TYPE'" >&2
            echo "Valid types: feat, fix, docs, style, refactor, perf, test, chore" >&2
            exit 1
            ;;
    esac
fi

echo "🤖 Starting AI summary generation in background..."

# Step 1: Start AI summary generation in background
SUMMARY_FILE=$(mktemp)
trap "rm -f $SUMMARY_FILE" EXIT

# Start AI summary generation in background
if [[ "$SHORT" == "true" ]]; then
    claude "/by-ai:summarize-changes --short" -p > "$SUMMARY_FILE" 2>&1 &
else
    claude "/by-ai:summarize-changes" -p > "$SUMMARY_FILE" 2>&1 &
fi
AI_SUMMARY_PID=$!

echo "✅ AI summary generation started (PID: $AI_SUMMARY_PID)"

# Step 2: Get ticket number from branch name or user input
if [[ -z "$TICKET" ]]; then
    echo "🎫 Detecting ticket number from branch..."
    
    # Try to get ticket from branch name using the existing script
    if [[ -f "$SCRIPT_DIR/find-ticket-from-branch.sh" ]]; then
        TICKET=$("$SCRIPT_DIR/find-ticket-from-branch.sh" 2>/dev/null || true)
    fi
    
    if [[ -z "$TICKET" ]]; then
        echo "No ticket found in branch name."
        read -p "Enter ticket number (or press Enter to skip): " TICKET
        TICKET=$(echo "$TICKET" | xargs)  # Trim whitespace
    else
        echo "✅ Found ticket: $TICKET"
    fi
else
    echo "✅ Using provided ticket: $TICKET"
fi

# Step 3: Get commit type from user input if not provided
if [[ -z "$TYPE" ]]; then
    echo ""
    echo "📝 Select commit type:"
    echo "1) feat     - A new feature"
    echo "2) fix      - A bug fix" 
    echo "3) docs     - Documentation only changes"
    echo "4) style    - Changes that do not affect code meaning (formatting, etc.)"
    echo "5) refactor - Code change that neither fixes a bug nor adds a feature"
    echo "6) perf     - A code change that improves performance"
    echo "7) test     - Adding missing tests or correcting existing tests"
    echo "8) chore    - Changes to build process or auxiliary tools"
    echo ""
    
    while true; do
        read -p "Enter your choice (1-8) or type directly [default: feat]: " choice
        choice=$(echo "$choice" | xargs)  # Trim whitespace
        
        # Default to feat if empty
        if [[ -z "$choice" ]]; then
            TYPE="feat"
            break
        fi
        
        # Handle numeric choices
        case $choice in
            1)
                TYPE="feat"
                break
                ;;
            2)
                TYPE="fix"
                break
                ;;
            3)
                TYPE="docs"
                break
                ;;
            4)
                TYPE="style"
                break
                ;;
            5)
                TYPE="refactor"
                break
                ;;
            6)
                TYPE="perf"
                break
                ;;
            7)
                TYPE="test"
                break
                ;;
            8)
                TYPE="chore"
                break
                ;;
            # Handle direct type input
            feat|fix|docs|style|refactor|perf|test|chore)
                TYPE="$choice"
                break
                ;;
            *)
                echo "Invalid choice. Please enter 1-8 or a valid type name."
                ;;
        esac
    done
    
    echo "✅ Selected type: $TYPE"
else
    echo "✅ Using provided type: $TYPE"
fi

# Step 4: Create initial commit message
echo ""
echo "✍️  Creating commit message..."

# Wait for AI summary to complete
echo "⏳ Waiting for AI summary to complete..."
if wait $AI_SUMMARY_PID; then
    SUMMARY=$(cat "$SUMMARY_FILE")
    if [[ -z "$SUMMARY" ]]; then
        echo "Warning: AI summary is empty, proceeding without summary" >&2
        SUMMARY="Update code"
    fi
    echo "✅ AI summary ready"
else
    echo "Warning: AI summary generation failed, proceeding without summary" >&2
    SUMMARY="Update code"
fi

# Build the commit message components
COMMIT_PREFIX="$TYPE"
if [[ -n "$TICKET" ]]; then
    COMMIT_PREFIX="[$TICKET] $COMMIT_PREFIX"
fi
COMMIT_PREFIX="$COMMIT_PREFIX: "

# Create initial commit message
INITIAL_MESSAGE="$COMMIT_PREFIX$SUMMARY"

# Add breaking change notice if specified
if [[ "$BREAKING" == "true" ]]; then
    INITIAL_MESSAGE="$INITIAL_MESSAGE

BREAKING CHANGE: "
fi

# Create a temporary file for editing
COMMIT_MSG_FILE=$(mktemp)
trap "rm -f $COMMIT_MSG_FILE $SUMMARY_FILE" EXIT

echo "$INITIAL_MESSAGE" > "$COMMIT_MSG_FILE"

echo ""
echo "📋 Initial commit message:"
echo "----------------------------------------"
cat "$COMMIT_MSG_FILE"
echo "----------------------------------------"
echo ""

# Ask user to confirm or edit the commit message
while true; do
    read -p "Proceed with this commit? [Y/n]: " confirm_choice
    confirm_choice=$(echo "$confirm_choice" | tr '[:upper:]' '[:lower:]' | xargs)
    
    case $confirm_choice in
        y|yes|"")
            # User confirmed, proceed with commit
            FINAL_MESSAGE=$(cat "$COMMIT_MSG_FILE")
            break
            ;;
        n|no)
            # User wants to edit, open editor
            EDITOR=${EDITOR:-nano}
            if ! "$EDITOR" "$COMMIT_MSG_FILE"; then
                echo "Error: Failed to open editor" >&2
                exit 1
            fi
            
            echo ""
            echo "📋 Updated commit message:"
            echo "----------------------------------------"
            cat "$COMMIT_MSG_FILE"
            echo "----------------------------------------"
            echo ""
            # Loop back to confirmation
            ;;
        *)
            echo "Please enter y/yes or n/no"
            ;;
    esac
done

# Validate the final message is not empty
if [[ -z "$(echo "$FINAL_MESSAGE" | xargs)" ]]; then
    echo "Error: Commit message cannot be empty" >&2
    exit 1
fi

# Step 5: Execute the git commit
echo ""
echo "🚀 Committing changes..."

# Check if there are any changes to commit
if git diff --quiet 2>/dev/null && git diff --staged --quiet 2>/dev/null; then
    echo "No changes to commit." >&2
    exit 1
fi

# Stage all changes
echo "📦 Staging all changes..."
if ! git add -A; then
    echo "Error: Failed to stage changes" >&2
    exit 1
fi

# Execute the commit
if git commit -F "$COMMIT_MSG_FILE"; then
    echo ""
    echo "✅ Successfully created commit!"
else
    echo "Error: Failed to create commit" >&2
    exit 1
fi

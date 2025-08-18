#!/bin/bash

# Claude Code Session Initialization Script
# Checks for git submodule updates and notifies user

CLAUDE_DIR=".claude"
SCRIPT_NAME="session-init"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log messages
log() {
    echo -e "${BLUE}[${SCRIPT_NAME}]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[${SCRIPT_NAME}]${NC} $1"
}

error() {
    echo -e "${RED}[${SCRIPT_NAME}]${NC} $1"
}

success() {
    echo -e "${GREEN}[${SCRIPT_NAME}]${NC} $1"
}

# Check if we're in a git repository
check_git_repo() {
    if ! git -C "$CLAUDE_DIR" rev-parse --git-dir >/dev/null 2>&1; then
        warn "Claude config directory is not a git repository"
        warn "Consider setting it up as a git submodule for version control"
        return 1
    fi
    return 0
}

# Check if this is a git submodule
check_submodule() {
    if [ ! -f "$CLAUDE_DIR/.git" ]; then
        warn "Claude config directory is not a git submodule"
        return 1
    fi
    return 0
}

# Check for remote updates
check_for_updates() {
    local current_dir=$(pwd)
    cd "$CLAUDE_DIR" || return 1
    
    # Fetch latest from remote quietly
    if ! git fetch origin >/dev/null 2>&1; then
        warn "Could not fetch from remote repository"
        cd "$current_dir"
        return 1
    fi
    
    # Get current HEAD and remote HEAD
    local local_head=$(git rev-parse HEAD)
    local remote_head=$(git rev-parse origin/HEAD 2>/dev/null || git rev-parse origin/main 2>/dev/null || git rev-parse origin/master 2>/dev/null)
    
    cd "$current_dir"
    
    if [ "$local_head" != "$remote_head" ]; then
        return 0  # Updates available
    else
        return 1  # No updates
    fi
}

# Get update information
get_update_info() {
    local current_dir=$(pwd)
    cd "$CLAUDE_DIR" || return 1
    
    local commits_behind=$(git rev-list --count HEAD..origin/HEAD 2>/dev/null || git rev-list --count HEAD..origin/main 2>/dev/null || git rev-list --count HEAD..origin/master 2>/dev/null || echo "0")
    local last_update=$(git log -1 --format="%ci" origin/HEAD 2>/dev/null || git log -1 --format="%ci" origin/main 2>/dev/null || git log -1 --format="%ci" origin/master 2>/dev/null)
    
    cd "$current_dir"
    
    echo "$commits_behind|$last_update"
}

# Check if CLAUDE.md exists in project root
check_claude_md_exists() {
    if [ ! -f "CLAUDE.md" ]; then
        error ""
        error "╭─────────────────────────────────────╮"
        error "│       Missing CLAUDE.md File!       │"
        error "╰─────────────────────────────────────╯"
        error ""
        error "No CLAUDE.md found in project root folder."
        error "This file is essential for Claude Code to understand"
        error "project instructions and context."
        error ""
        error "If using this as a submodule, create CLAUDE.md that"
        error "references the submodule configuration:"
        error "  echo '@.claude/CLAUDE.md' > CLAUDE.md"
        error ""
        return 1
    fi
    return 0
}

# Check if CLAUDE.md properly references submodule config
check_claude_md_reference() {
    if [ -f "CLAUDE.md" ] && [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
        # Check if CLAUDE.md contains reference to .claude/CLAUDE.md
        if ! grep -q "@\\.claude/CLAUDE\\.md\\|@$CLAUDE_DIR/CLAUDE\\.md" "CLAUDE.md" 2>/dev/null; then
            warn ""
            warn "╭─────────────────────────────────────╮"
            warn "│    CLAUDE.md Reference Warning!     │"
            warn "╰─────────────────────────────────────╯"
            warn ""
            warn "Your CLAUDE.md does not reference the submodule"
            warn "configuration at .claude/CLAUDE.md"
            warn ""
            warn "Consider adding this line to your CLAUDE.md:"
            warn "  @.claude/CLAUDE.md"
            warn ""
            warn "This ensures Claude Code reads both the project"
            warn "and submodule configurations properly."
            warn ""
            return 1
        fi
    fi
    return 0
}

# Check if required MCP servers are available
check_required_mcp_servers() {
    local mcp_config=".mcp.json"
    
    if [ ! -f "$mcp_config" ]; then
        warn ""
        warn "╭─────────────────────────────────────╮"
        warn "│      Missing MCP Configuration!     │"
        warn "╰─────────────────────────────────────╯"
        warn ""
        warn "No .mcp.json found in project root."
        warn "This project requires the Playwright MCP server."
        warn ""
        warn "Create .mcp.json with the following content:"
        warn '{'
        warn '  "mcpServers": {'
        warn '    "playwright": {'
        warn '      "type": "stdio",'
        warn '      "command": "npx",'
        warn '      "args": ["@playwright/mcp@latest"],'
        warn '      "env": {}'
        warn '    }'
        warn '  }'
        warn '}'
        warn ""
        return 1
    fi
    
    # Check if playwright server is configured
    if ! grep -q '"playwright"' "$mcp_config" 2>/dev/null; then
        warn ""
        warn "╭─────────────────────────────────────╮"
        warn "│    Missing Playwright MCP Server!   │"
        warn "╰─────────────────────────────────────╯"
        warn ""
        warn "Your .mcp.json doesn't include the required"
        warn "Playwright MCP server configuration."
        warn ""
        warn "Add this to your mcpServers section:"
        warn '    "playwright": {'
        warn '      "type": "stdio",'
        warn '      "command": "npx",'
        warn '      "args": ["@playwright/mcp@latest"],'
        warn '      "env": {}'
        warn '    }'
        warn ""
        return 1
    fi
    
    return 0
}

# Main execution
main() {
    # Always check for CLAUDE.md existence and proper referencing first
    check_claude_md_exists
    check_claude_md_reference
    
    # Check for required MCP server configuration
    check_required_mcp_servers
    
    # Only proceed with git checks if git repo exists
    if ! check_git_repo; then
        return 0
    fi
    
    # Check if it's a submodule
    if ! check_submodule; then
        return 0
    fi
    
    # Check for updates
    if check_for_updates; then
        local update_info=$(get_update_info)
        local commits_behind=$(echo "$update_info" | cut -d'|' -f1)
        local last_update=$(echo "$update_info" | cut -d'|' -f2)
        
        echo ""
        warn ""
        warn "╭─────────────────────────────────────╮"
        warn "│  ByborgAI Config Updates Available! │"
        warn "╰─────────────────────────────────────╯"
        warn ""
        warn "Your .claude configuration is $commits_behind commits behind"
        warn "Last update: $last_update"
        warn ""
        warn "Or update the parent repository submodule:"
        warn "  git submodule update --remote .claude"
        warn ""
        echo ""
    fi
}

# Run main function
main "$@"

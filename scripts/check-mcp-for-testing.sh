#!/bin/bash

# Claude Code MCP Testing Commands Check Script
# Validates MCP server availability before running testing commands

SCRIPT_NAME="check-mcp-for-testing"

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

# Check if Playwright MCP server is configured and working
check_playwright_mcp() {
    log "Checking Playwright MCP server status..."
    
    # Use claude mcp get to check if playwright is properly configured
    local mcp_output
    mcp_output=$(claude mcp get playwright 2>&1)
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        success "✓ Playwright MCP server is configured and working"
        return 0
    else
        error ""
        error "╭─────────────────────────────────────────────╮"
        error "│        Playwright MCP Server Required       │"
        error "╰─────────────────────────────────────────────╯"
        error ""
        error "This testing command requires the Playwright MCP server."
        error "The server is either not configured or not working properly."
        error ""
        error "To set it up, run:"
        error "  claude mcp add playwright npx @playwright/mcp@latest"
        error ""
        error "Or to install globally:"
        error "  claude mcp add playwright npx @playwright/mcp@latest --scope global"
        error ""
        error "MCP check output:"
        error "$mcp_output"
        error ""
        return 1
    fi
}

# Main execution
main() {
    log "Checking MCP server requirements for testing commands..."
    
    if check_playwright_mcp; then
        success "✓ All MCP requirements satisfied for testing commands"
        return 0
    else
        error "✗ MCP requirements not met - command cannot proceed"
        return 1
    fi
}

# Run main function
main "$@"
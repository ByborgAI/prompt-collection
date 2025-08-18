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

# Check if Playwright MCP server is configured
check_playwright_mcp() {
    local mcp_config=".mcp.json"
    
    # Check if .mcp.json exists
    if [ ! -f "$mcp_config" ]; then
        error ""
        error "╭─────────────────────────────────────────────╮"
        error "│        MCP Server Required for Testing      │"
        error "╰─────────────────────────────────────────────╯"
        error ""
        error "This command requires the Playwright MCP server."
        error "Please create .mcp.json with the following content:"
        error ""
        error '{'
        error '  "mcpServers": {'
        error '    "playwright": {'
        error '      "type": "stdio",'
        error '      "command": "npx",'
        error '      "args": ["@playwright/mcp@latest"],'
        error '      "env": {}'
        error '    }'
        error '  }'
        error '}'
        error ""
        error "Then install the Playwright MCP server:"
        error "  npm install -g @playwright/mcp"
        error ""
        return 1
    fi
    
    # Check if playwright server is configured
    if ! grep -q '"playwright"' "$mcp_config" 2>/dev/null; then
        error ""
        error "╭─────────────────────────────────────────────╮"
        error "│     Playwright MCP Server Not Configured    │"
        error "╰─────────────────────────────────────────────╯"
        error ""
        error "This command requires the Playwright MCP server."
        error "Please add this to your .mcp.json mcpServers section:"
        error ""
        error '    "playwright": {'
        error '      "type": "stdio",'
        error '      "command": "npx",'
        error '      "args": ["@playwright/mcp@latest"],'
        error '      "env": {}'
        error '    }'
        error ""
        error "Then install the Playwright MCP server:"
        error "  npm install -g @playwright/mcp"
        error ""
        return 1
    fi
    
    success "✓ Playwright MCP server is configured"
    return 0
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
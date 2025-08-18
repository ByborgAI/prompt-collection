#!/bin/bash

# Byborg AI Submodule Initialization Script
# Creates required configuration files when this repo is used as a submodule

SCRIPT_NAME="init-submodule"

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

# Create .mcp.json with Playwright MCP server
create_mcp_config() {
    local mcp_file="$1/.mcp.json"
    
    if [ -f "$mcp_file" ]; then
        log "MCP configuration already exists at $mcp_file"
        
        # Check if it contains Playwright server
        if grep -q '"playwright"' "$mcp_file" 2>/dev/null; then
            success "Playwright MCP server already configured"
            return 0
        else
            warn "Existing .mcp.json found but missing Playwright server"
            warn "Please add the Playwright server manually:"
            warn '    "playwright": {'
            warn '      "type": "stdio",'
            warn '      "command": "npx",'
            warn '      "args": ["@playwright/mcp@latest"],'
            warn '      "env": {}'
            warn '    }'
            return 1
        fi
    fi
    
    log "Creating .mcp.json configuration..."
    
    cat > "$mcp_file" << 'EOF'
{
  "mcpServers": {
    "playwright": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "@playwright/mcp@latest"
      ],
      "env": {}
    }
  }
}
EOF
    
    if [ $? -eq 0 ]; then
        success "Created .mcp.json with Playwright MCP server"
        return 0
    else
        error "Failed to create .mcp.json"
        return 1
    fi
}

# Create CLAUDE.md with reference to submodule
create_claude_md() {
    local claude_file="$1/CLAUDE.md"
    local submodule_path="$2"
    
    if [ -f "$claude_file" ]; then
        # Check if it already references the submodule
        if grep -q "@${submodule_path}/CLAUDE.md" "$claude_file" 2>/dev/null; then
            success "CLAUDE.md already references submodule configuration"
            return 0
        else
            log "CLAUDE.md exists but doesn't reference submodule"
            log "Adding reference to submodule configuration..."
            echo "" >> "$claude_file"
            echo "@${submodule_path}/CLAUDE.md" >> "$claude_file"
            success "Added submodule reference to existing CLAUDE.md"
            return 0
        fi
    fi
    
    log "Creating CLAUDE.md with submodule reference..."
    
    cat > "$claude_file" << EOF
# Project Instructions

@${submodule_path}/CLAUDE.md
EOF
    
    if [ $? -eq 0 ]; then
        success "Created CLAUDE.md with reference to ${submodule_path}/CLAUDE.md"
        return 0
    else
        error "Failed to create CLAUDE.md"
        return 1
    fi
}

# Main execution
main() {
    local target_dir="${1:-.}"
    local submodule_name="${2:-.claude}"
    
    log "Initializing Byborg AI submodule configuration..."
    log "Target directory: $target_dir"
    log "Submodule path: $submodule_name"
    
    # Ensure target directory exists
    if [ ! -d "$target_dir" ]; then
        error "Target directory '$target_dir' does not exist"
        exit 1
    fi
    
    echo ""
    
    # Create MCP configuration
    create_mcp_config "$target_dir"
    mcp_result=$?
    
    echo ""
    
    # Create CLAUDE.md
    create_claude_md "$target_dir" "$submodule_name"
    claude_result=$?
    
    echo ""
    
    # Summary
    if [ $mcp_result -eq 0 ] && [ $claude_result -eq 0 ]; then
        success "✓ Submodule initialization completed successfully!"
        log ""
        log "Next steps:"
        log "1. Commit the new configuration files"
        log "2. Install Playwright MCP: npm install -g @playwright/mcp"
        log "3. Claude Code will now use both configurations"
    else
        warn "⚠ Submodule initialization completed with warnings"
        warn "Please review the messages above and fix any issues"
    fi
}

# Show usage if no arguments or help requested
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 [target_directory] [submodule_path]"
    echo ""
    echo "Creates required configuration files for Byborg AI submodule:"
    echo "  - .mcp.json with Playwright MCP server (optional, for testing commands)"
    echo "  - CLAUDE.md with reference to submodule configuration"
    echo ""
    echo "Arguments:"
    echo "  target_directory  Directory to create files in (default: current directory)"
    echo "  submodule_path    Path to submodule (default: .claude)"
    echo ""
    echo "Examples:"
    echo "  $0                           # Initialize in current directory"
    echo "  $0 /path/to/project          # Initialize in specific directory"
    echo "  $0 . .claude                 # Initialize with custom submodule path"
    exit 0
fi

# Run main function
main "$@"
#!/bin/bash

# Script to find a ticket number from the current git branch name
# Looks for patterns like ABC-1234, PROJ-123, etc. in the branch name

set -e

# Function to display usage
usage() {
    echo "Usage: $0 [branch-name]"
    echo "Find ticket number from git branch name"
    echo ""
    echo "Arguments:"
    echo "  branch-name    Optional branch name (defaults to current branch)"
    echo ""
    echo "Examples:"
    echo "  $0                           # Use current branch"
    echo "  $0 feature/ABC-1234-new-ui   # Use specified branch"
    echo ""
    echo "Supported patterns:"
    echo "  - ABC-1234"
    echo "  - PROJ-123" 
    echo "  - TICKET-5678"
    echo "  - [A-Z]+-[0-9]+"
}

# Function to extract ticket from branch name
extract_ticket() {
    local branch="$1"
    
    # Pattern 1: Standard ticket format [A-Z]+-[0-9]+
    ticket=$(echo "$branch" | grep -oE '[A-Z]+-[0-9]+' | head -1)
    
    if [ -n "$ticket" ]; then
        echo "$ticket"
        return 0
    fi
    
    # Pattern 2: Numbers only (less common but sometimes used)
    ticket=$(echo "$branch" | grep -oE '[0-9]{3,}' | head -1)
    
    if [ -n "$ticket" ]; then
        echo "TICKET-$ticket"
        return 0
    fi
    
    return 1
}

# Main script logic
main() {
    local branch_name=""
    
    # Handle command line arguments
    case "${1:-}" in
        -h|--help)
            usage
            exit 0
            ;;
        "")
            # Get current branch name
            if ! branch_name=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
                echo "Error: Not in a git repository or unable to get current branch" >&2
                exit 1
            fi
            ;;
        *)
            branch_name="$1"
            ;;
    esac
    
    # Extract ticket from branch name
    if ticket=$(extract_ticket "$branch_name"); then
        echo "$ticket"
        exit 0
    else
        echo "No ticket number found in branch: $branch_name" >&2
        exit 1
    fi
}

# Run main function with all arguments
main "$@"

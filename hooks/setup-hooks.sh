#!/usr/bin/env bash

# Setup script for installing pre-commit hooks
# This script installs pre-commit and sets up the hooks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIBRARY_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Pre-commit Hooks Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo -e "${YELLOW}pre-commit not found. Installing...${NC}"

    # Try to install with pip
    if command -v pip3 &> /dev/null; then
        echo "Installing pre-commit with pip3..."
        pip3 install pre-commit
    elif command -v pip &> /dev/null; then
        echo "Installing pre-commit with pip..."
        pip install pre-commit
    else
        echo -e "${RED}✗ Error: pip not found${NC}"
        echo "Please install pip and try again, or install pre-commit manually:"
        echo "  pip install pre-commit"
        exit 1
    fi

    # Verify installation
    if ! command -v pre-commit &> /dev/null; then
        echo -e "${RED}✗ Error: pre-commit installation failed${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ pre-commit installed successfully${NC}"
else
    echo -e "${GREEN}✓ pre-commit already installed${NC}"
    PRE_COMMIT_VERSION=$(pre-commit --version)
    echo "  Version: $PRE_COMMIT_VERSION"
fi

echo ""

# Navigate to library root
cd "$LIBRARY_ROOT"

# Check if .pre-commit-config.yaml exists
if [ ! -f ".pre-commit-config.yaml" ]; then
    echo -e "${RED}✗ Error: .pre-commit-config.yaml not found${NC}"
    echo "Make sure you're running this from the Claude Code Library root directory"
    exit 1
fi

# Install pre-commit hooks
echo -e "${YELLOW}Installing pre-commit hooks...${NC}"
if pre-commit install; then
    echo -e "${GREEN}✓ Pre-commit hooks installed${NC}"
else
    echo -e "${RED}✗ Error: Failed to install pre-commit hooks${NC}"
    exit 1
fi

echo ""

# Make hook scripts executable
echo -e "${YELLOW}Making hook scripts executable...${NC}"
chmod +x hooks/*.sh
chmod +x tests/*.sh
chmod +x scripts/*.sh
echo -e "${GREEN}✓ Scripts made executable${NC}"

echo ""

# Run pre-commit on all files (optional)
read -p "Run pre-commit checks on all files now? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Running pre-commit on all files...${NC}"
    if pre-commit run --all-files; then
        echo -e "${GREEN}✓ All checks passed${NC}"
    else
        echo -e "${YELLOW}⚠ Some checks failed or made fixes${NC}"
        echo "Review the changes and commit again"
    fi
else
    echo -e "${YELLOW}Skipped running checks. They will run automatically on next commit.${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Pre-commit hooks setup complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Hooks will now run automatically before each commit."
echo ""
echo "Useful commands:"
echo "  pre-commit run --all-files    # Run all hooks manually"
echo "  pre-commit run <hook-id>      # Run specific hook"
echo "  pre-commit autoupdate         # Update hook versions"
echo "  git commit --no-verify        # Skip hooks (not recommended)"
echo ""

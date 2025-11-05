#!/bin/bash
# feature-workflow.sh - Automate feature development workflow
# Usage: feature-workflow.sh <feature-name>
# Automates Playbook 2 (Feature Development) from ultimate-playbooks.md

set -e

VERSION="1.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

usage() {
    echo -e "${BLUE}Claude Code Library - Feature Workflow Automation${NC}"
    echo "Version: $VERSION"
    echo ""
    echo "Usage: $0 <feature-name> [options]"
    echo ""
    echo "Options:"
    echo "  --skip-branch      Skip branch creation (use current branch)"
    echo "  --skip-tests       Skip test generation prompt"
    echo "  --version          Show version"
    echo "  --help             Show this help"
    echo ""
    echo "What it does:"
    echo "  1. Creates feature branch (feature/<name>)"
    echo "  2. Adds feature to TODO.md with [P1] priority"
    echo "  3. Runs discovery (fd + rg + Serena)"
    echo "  4. Guides through implementation phases"
    echo "  5. Reminds about testing and documentation"
    echo "  6. Validates structure before commit"
    echo ""
    echo "Example: $0 user-authentication"
    exit 1
}

# Parse arguments
FEATURE_NAME=""
SKIP_BRANCH=false
SKIP_TESTS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-branch)
            SKIP_BRANCH=true
            shift
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --version)
            echo "feature-workflow.sh version $VERSION"
            exit 0
            ;;
        --help)
            usage
            ;;
        *)
            if [ -z "$FEATURE_NAME" ]; then
                FEATURE_NAME="$1"
            else
                echo -e "${RED}Unknown option: $1${NC}"
                usage
            fi
            shift
            ;;
    esac
done

# Validate feature name
if [ -z "$FEATURE_NAME" ]; then
    echo -e "${RED}❌ Feature name required!${NC}"
    usage
fi

# Validate feature name format (lowercase, hyphens, letters/numbers only)
if [[ ! "$FEATURE_NAME" =~ ^[a-z0-9-]+$ ]]; then
    echo -e "${RED}❌ Invalid feature name: $FEATURE_NAME${NC}"
    echo "Feature name must contain only lowercase letters, numbers, and hyphens"
    exit 1
fi

# Check if in git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Not in a git repository!${NC}"
    exit 1
fi

# Check if .claude directory exists
if [ ! -d ".claude" ]; then
    echo -e "${YELLOW}⚠️  No .claude directory found. Creating basic structure...${NC}"
    mkdir -p .claude/docs/patterns
    echo "# TODO" > .claude/docs/TODO.md
    echo "# HANDOFF" > .claude/docs/HANDOFF.md
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🚀 Feature Workflow: $FEATURE_NAME${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# =============================================================================
# PHASE 1: SETUP
# =============================================================================
echo -e "${BLUE}📋 Phase 1: Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 1.1: Create feature branch
if [ "$SKIP_BRANCH" = false ]; then
    BRANCH_NAME="feature/$FEATURE_NAME"

    # Check if branch already exists
    if git show-ref --quiet refs/heads/"$BRANCH_NAME"; then
        echo -e "${YELLOW}⚠️  Branch $BRANCH_NAME already exists${NC}"
        read -p "Switch to existing branch? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git checkout "$BRANCH_NAME"
            echo -e "${GREEN}✅ Switched to $BRANCH_NAME${NC}"
        fi
    else
        git checkout -b "$BRANCH_NAME"
        echo -e "${GREEN}✅ Created and switched to $BRANCH_NAME${NC}"
    fi
else
    CURRENT_BRANCH=$(git branch --show-current)
    echo -e "${CYAN}Using current branch: $CURRENT_BRANCH${NC}"
fi

# 1.2: Add to TODO.md
TODO_FILE=".claude/docs/TODO.md"
FEATURE_TODO="- [ ] [P1] Implement $FEATURE_NAME"

if ! grep -q "$FEATURE_TODO" "$TODO_FILE" 2>/dev/null; then
    echo "" >> "$TODO_FILE"
    echo "$FEATURE_TODO" >> "$TODO_FILE"
    echo -e "${GREEN}✅ Added to TODO.md${NC}"
else
    echo -e "${CYAN}Already in TODO.md${NC}"
fi

echo ""

# =============================================================================
# PHASE 2: DISCOVERY
# =============================================================================
echo -e "${BLUE}🔍 Phase 2: Discovery${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "${CYAN}Running discovery tools...${NC}"
echo ""

# 2.1: Find relevant files
echo -e "${YELLOW}📁 Finding relevant files:${NC}"
SEARCH_TERM=$(echo "$FEATURE_NAME" | tr '-' ' ' | awk '{print $1}')

if command -v fd &> /dev/null; then
    fd -t f "$SEARCH_TERM" src/ app/ 2>/dev/null | head -10 || echo "No matches found"
else
    find . -type f -name "*$SEARCH_TERM*" 2>/dev/null | head -10 || echo "No matches found"
fi
echo ""

# 2.2: Search for related code
echo -e "${YELLOW}🔎 Searching for related code:${NC}"
if command -v rg &> /dev/null; then
    rg -l "$SEARCH_TERM" src/ app/ 2>/dev/null | head -10 || echo "No matches found"
else
    grep -r "$SEARCH_TERM" src/ app/ 2>/dev/null | cut -d: -f1 | sort -u | head -10 || echo "No matches found"
fi
echo ""

# 2.3: Remind about Serena
echo -e "${YELLOW}💡 Next step: Use Serena for symbol-level exploration${NC}"
echo -e "${CYAN}   Suggested commands:${NC}"
echo -e "   ${GREEN}mcp__serena__search_for_pattern(\"$SEARCH_TERM\")${NC}"
echo -e "   ${GREEN}mcp__serena__get_symbols_overview(\"relevant_file.ts\")${NC}"
echo ""

read -p "Press Enter to continue to implementation phase..."
echo ""

# =============================================================================
# PHASE 3: IMPLEMENTATION
# =============================================================================
echo -e "${BLUE}💻 Phase 3: Implementation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "${CYAN}Implementation Checklist:${NC}"
echo ""
echo -e "  ${YELLOW}L0 - MVP (Minimum Viable Product):${NC}"
echo "    - [ ] Core functionality working"
echo "    - [ ] Basic error handling"
echo "    - [ ] Manual testing passed"
echo ""
echo -e "  ${YELLOW}L1 - Production Ready:${NC}"
echo "    - [ ] Edge cases handled"
echo "    - [ ] Automated tests written"
echo "    - [ ] Documentation updated"
echo ""
echo -e "  ${YELLOW}L2 - Polish:${NC}"
echo "    - [ ] Performance optimized"
echo "    - [ ] UX improved"
echo "    - [ ] Code reviewed"
echo ""

read -p "Have you completed L0 (MVP)? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Focus on getting L0 working first!${NC}"
    echo -e "${CYAN}Remember: Ship L0-L1, iterate on L2-L3${NC}"
    exit 0
fi

echo ""

# =============================================================================
# PHASE 4: TESTING
# =============================================================================
if [ "$SKIP_TESTS" = false ]; then
    echo -e "${BLUE}🧪 Phase 4: Testing${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    echo -e "${CYAN}Testing Checklist:${NC}"
    echo ""
    echo "  - [ ] Unit tests for core logic"
    echo "  - [ ] Integration tests for workflows"
    echo "  - [ ] Edge cases covered"
    echo "  - [ ] Error scenarios tested"
    echo ""

    read -p "Run tests now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Detect project type and run appropriate tests
        if [ -f "package.json" ]; then
            echo -e "${CYAN}Running npm tests...${NC}"
            npm test || echo -e "${RED}Tests failed!${NC}"
        elif [ -f "pyproject.toml" ]; then
            echo -e "${CYAN}Running pytest...${NC}"
            poetry run pytest || pytest || echo -e "${RED}Tests failed!${NC}"
        else
            echo -e "${YELLOW}No test runner detected. Please run tests manually.${NC}"
        fi
    fi

    echo ""
fi

# =============================================================================
# PHASE 5: VALIDATION
# =============================================================================
echo -e "${BLUE}✅ Phase 5: Validation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 5.1: Run structure validation
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/validate-structure.sh" ]; then
    echo -e "${CYAN}Running structure validation...${NC}"
    "$SCRIPT_DIR/validate-structure.sh" || echo -e "${YELLOW}Structure validation warnings${NC}"
else
    echo -e "${YELLOW}validate-structure.sh not found, skipping${NC}"
fi

echo ""

# 5.2: Run anti-pattern detection
if [ -f "$SCRIPT_DIR/anti-pattern-detector.sh" ]; then
    echo -e "${CYAN}Running anti-pattern detection...${NC}"
    "$SCRIPT_DIR/anti-pattern-detector.sh" || echo -e "${YELLOW}Anti-patterns detected${NC}"
else
    echo -e "${YELLOW}anti-pattern-detector.sh not found, skipping${NC}"
fi

echo ""

# =============================================================================
# PHASE 6: COMMIT
# =============================================================================
echo -e "${BLUE}💾 Phase 6: Commit${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "${CYAN}Ready to commit?${NC}"
echo ""
echo -e "${YELLOW}Commit Checklist:${NC}"
echo "  - [ ] All tests passing"
echo "  - [ ] No anti-patterns detected"
echo "  - [ ] Documentation updated"
echo "  - [ ] TODO.md updated"
echo ""

read -p "Create commit for $FEATURE_NAME? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git status
    echo ""
    read -p "Review changes above. Proceed with commit? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add .

        COMMIT_MSG="feat: implement $FEATURE_NAME

- Add core functionality
- Include tests
- Update documentation

🤖 Generated with Claude Code Library
"

        git commit -m "$COMMIT_MSG"
        echo -e "${GREEN}✅ Committed changes${NC}"

        # Mark as done in TODO
        sed -i "s/- \[ \] \[P1\] Implement $FEATURE_NAME/- [x] [P1] Implement $FEATURE_NAME/" "$TODO_FILE"
        git add "$TODO_FILE"
        git commit --amend --no-edit
    fi
fi

echo ""

# =============================================================================
# SUMMARY
# =============================================================================
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Feature Workflow Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo -e "  1. ${CYAN}Review changes in your editor${NC}"
echo -e "  2. ${CYAN}Create PR: gh pr create${NC}"
echo -e "  3. ${CYAN}Update HANDOFF.md with context${NC}"
echo ""
echo -e "${BLUE}Feature: $FEATURE_NAME${NC}"
echo -e "${BLUE}Branch: $(git branch --show-current)${NC}"
echo ""

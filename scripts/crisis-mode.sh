#!/bin/bash
# crisis-mode.sh - Emergency debugging checklist and automation
# Usage: crisis-mode.sh [issue-description]
# For when things are broken and you need systematic debugging

set -e

VERSION="1.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

usage() {
    echo -e "${BLUE}Claude Code Library - Crisis Mode${NC}"
    echo "Version: $VERSION"
    echo ""
    echo "Usage: $0 [issue-description]"
    echo ""
    echo "Options:"
    echo "  --auto-fix      Attempt automatic fixes"
    echo "  --save-state    Save debugging state to BUGS_FIXED.md"
    echo "  --version       Show version"
    echo "  --help          Show this help"
    echo ""
    echo "What it does:"
    echo "  1. Emergency system state capture"
    echo "  2. Systematic debugging checklist"
    echo "  3. Guided troubleshooting steps"
    echo "  4. State rollback options"
    echo "  5. Documentation of fix"
    echo ""
    echo "Example: $0 \"Server returning 500 errors\""
    exit 1
}

# Parse arguments
ISSUE_DESC=""
AUTO_FIX=false
SAVE_STATE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --auto-fix)
            AUTO_FIX=true
            shift
            ;;
        --save-state)
            SAVE_STATE=true
            shift
            ;;
        --version)
            echo "crisis-mode.sh version $VERSION"
            exit 0
            ;;
        --help)
            usage
            ;;
        *)
            if [ -z "$ISSUE_DESC" ]; then
                ISSUE_DESC="$1"
            else
                ISSUE_DESC="$ISSUE_DESC $1"
            fi
            shift
            ;;
    esac
done

# Get issue description if not provided
if [ -z "$ISSUE_DESC" ]; then
    echo -e "${YELLOW}What's the issue you're experiencing?${NC}"
    read -p "> " ISSUE_DESC
fi

echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}🚨 CRISIS MODE ACTIVATED${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Issue: $ISSUE_DESC${NC}"
echo -e "${CYAN}Timestamp: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo ""

# =============================================================================
# PHASE 1: CAPTURE SYSTEM STATE
# =============================================================================
echo -e "${BLUE}📸 Phase 1: Capturing System State${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

CRISIS_DIR=".claude/crisis-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$CRISIS_DIR"

echo -e "${CYAN}Saving state to: $CRISIS_DIR${NC}"

# 1.1: Git status
if [ -d ".git" ]; then
    echo -e "${YELLOW}Git status...${NC}"
    git status > "$CRISIS_DIR/git-status.txt"
    git diff > "$CRISIS_DIR/git-diff.txt"
    git log --oneline -10 > "$CRISIS_DIR/git-log.txt"
    echo -e "${GREEN}✅ Git state captured${NC}"
fi

# 1.2: Environment info
echo -e "${YELLOW}Environment info...${NC}"
cat > "$CRISIS_DIR/environment.txt" << EOF
Node Version: $(node --version 2>/dev/null || echo "N/A")
NPM Version: $(npm --version 2>/dev/null || echo "N/A")
Python Version: $(python --version 2>&1 || echo "N/A")
OS: $(uname -a)
Date: $(date)
EOF
echo -e "${GREEN}✅ Environment captured${NC}"

# 1.3: Process status
echo -e "${YELLOW}Process status...${NC}"
ps aux | grep -E "node|python|npm" > "$CRISIS_DIR/processes.txt" || true
echo -e "${GREEN}✅ Processes captured${NC}"

echo ""

# =============================================================================
# PHASE 2: EMERGENCY DIAGNOSTICS
# =============================================================================
echo -e "${BLUE}🔍 Phase 2: Emergency Diagnostics${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

ERRORS_FOUND=0

# 2.1: Check for running processes
echo -e "${YELLOW}Checking for port conflicts...${NC}"
if command -v lsof &> /dev/null; then
    # Check common dev ports
    for port in 3000 3001 5000 8000 8080; do
        if lsof -i :$port > /dev/null 2>&1; then
            echo -e "${RED}❌ Port $port is in use${NC}"
            lsof -i :$port >> "$CRISIS_DIR/port-conflicts.txt"
            ((ERRORS_FOUND++))
        fi
    done
else
    echo -e "${CYAN}lsof not available, skipping port check${NC}"
fi

# 2.2: Check for compilation errors
echo -e "${YELLOW}Checking for compilation errors...${NC}"
if [ -f "tsconfig.json" ]; then
    if ! npx tsc --noEmit > "$CRISIS_DIR/tsc-errors.txt" 2>&1; then
        TS_ERRORS=$(grep -c "error TS" "$CRISIS_DIR/tsc-errors.txt" || echo "0")
        echo -e "${RED}❌ Found $TS_ERRORS TypeScript errors${NC}"
        ((ERRORS_FOUND++))
    else
        echo -e "${GREEN}✅ No TypeScript errors${NC}"
    fi
fi

# 2.3: Check for dependency issues
echo -e "${YELLOW}Checking dependencies...${NC}"
if [ -f "package.json" ]; then
    if [ ! -d "node_modules" ]; then
        echo -e "${RED}❌ node_modules missing!${NC}"
        ((ERRORS_FOUND++))

        if [ "$AUTO_FIX" = true ]; then
            echo -e "${CYAN}Auto-fix: Installing dependencies...${NC}"
            npm install
        fi
    else
        echo -e "${GREEN}✅ node_modules exists${NC}"
    fi
fi

# 2.4: Check for recent changes
if [ -d ".git" ]; then
    echo -e "${YELLOW}Checking recent changes...${NC}"
    RECENT_FILES=$(git diff --name-only HEAD~1 HEAD 2>/dev/null | head -10)
    if [ -n "$RECENT_FILES" ]; then
        echo -e "${YELLOW}Recently changed files:${NC}"
        echo "$RECENT_FILES" | sed 's/^/  - /'
        echo "$RECENT_FILES" > "$CRISIS_DIR/recent-changes.txt"
    fi
fi

echo ""

# =============================================================================
# PHASE 3: SYSTEMATIC DEBUGGING CHECKLIST
# =============================================================================
echo -e "${BLUE}✅ Phase 3: Debugging Checklist${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "${CYAN}Work through this checklist:${NC}"
echo ""

echo -e "${YELLOW}1. Reproduce the Issue${NC}"
read -p "   Can you reproduce the issue consistently? (y/n) " -n 1 -r
echo

echo ""
echo -e "${YELLOW}2. Check Error Messages${NC}"
echo "   - Look in browser console (F12)"
echo "   - Check terminal output"
echo "   - Review server logs"
read -p "   Found any error messages? (y/n) " -n 1 -r
echo
HAS_ERROR_MSG=$REPLY

if [[ $HAS_ERROR_MSG =~ ^[Yy]$ ]]; then
    echo "   Enter error message (first line):"
    read -p "   > " ERROR_MESSAGE
    echo "$ERROR_MESSAGE" > "$CRISIS_DIR/error-message.txt"
fi

echo ""
echo -e "${YELLOW}3. Isolate the Problem${NC}"
echo "   - Does it happen in production or only dev?"
echo "   - Is it specific to one feature?"
echo "   - Started after recent changes?"

echo ""
echo -e "${YELLOW}4. Check Recent Changes${NC}"
if [ -d ".git" ]; then
    echo -e "${CYAN}   Last 5 commits:${NC}"
    git log --oneline -5 | sed 's/^/   /'

    echo ""
    read -p "   Is the issue related to recent commits? (y/n) " -n 1 -r
    echo
    RECENT_COMMIT_ISSUE=$REPLY

    if [[ $RECENT_COMMIT_ISSUE =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${YELLOW}   Consider:${NC}"
        echo "   - git diff HEAD~1 (review last commit)"
        echo "   - git revert <commit> (undo problematic commit)"
        echo "   - git reset --hard HEAD~1 (DANGER: lose changes)"
    fi
fi

echo ""
echo -e "${YELLOW}5. Dependency Issues${NC}"
echo "   - Try: rm -rf node_modules && npm install"
echo "   - Try: npm ci (clean install)"
echo "   - Check: package-lock.json for conflicts"

echo ""
read -p "   Try clean dependency install? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}Cleaning and reinstalling...${NC}"
    if [ "$AUTO_FIX" = true ] || [ "$REPLY" = "y" ]; then
        rm -rf node_modules
        npm install
    fi
fi

echo ""

# =============================================================================
# PHASE 4: ROLLBACK OPTIONS
# =============================================================================
echo -e "${BLUE}⏮️  Phase 4: Rollback Options${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -d ".git" ]; then
    echo -e "${CYAN}Available rollback options:${NC}"
    echo ""
    echo -e "${YELLOW}1. Stash current changes (safe):${NC}"
    echo "   git stash save \"crisis-mode-backup-$(date +%Y%m%d_%H%M%S)\""
    echo ""
    echo -e "${YELLOW}2. Revert last commit (safe):${NC}"
    echo "   git revert HEAD"
    echo ""
    echo -e "${YELLOW}3. Reset to previous commit (DANGEROUS):${NC}"
    echo "   git reset --hard HEAD~1"
    echo ""
    echo -e "${YELLOW}4. Checkout specific commit:${NC}"
    echo "   git checkout <commit-hash>"
    echo ""

    read -p "Do you want to stash current changes? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git stash save "crisis-mode-backup-$(date +%Y%m%d_%H%M%S)"
        echo -e "${GREEN}✅ Changes stashed${NC}"
    fi
fi

echo ""

# =============================================================================
# PHASE 5: SOLUTION DOCUMENTATION
# =============================================================================
if [ "$SAVE_STATE" = true ] || [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}📝 Phase 5: Document Solution${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    mkdir -p .claude/docs/patterns

    echo -e "${YELLOW}How did you fix the issue?${NC}"
    read -p "Solution: " SOLUTION

    BUGS_FIXED_FILE=".claude/docs/patterns/BUGS_FIXED.md"

    # Create if doesn't exist
    if [ ! -f "$BUGS_FIXED_FILE" ]; then
        cat > "$BUGS_FIXED_FILE" << EOF
# Bugs Fixed

Documentation of bugs encountered and how they were fixed.

---
EOF
    fi

    # Add bug entry
    cat >> "$BUGS_FIXED_FILE" << EOF

## Bug: $ISSUE_DESC

**Date:** $(date '+%Y-%m-%d')
**Severity:** (Critical/High/Medium/Low)

### Symptoms
- $ISSUE_DESC
$([ -n "$ERROR_MESSAGE" ] && echo "- Error: $ERROR_MESSAGE")

### Root Cause
(Describe root cause)

### Solution
$SOLUTION

### Prevention
- (How to prevent this in future)

### Files Changed
$(if [ -d ".git" ]; then git diff --name-only | sed 's/^/- /'; else echo "- (Manual entry required)"; fi)

---
EOF

    echo -e "${GREEN}✅ Bug documented in $BUGS_FIXED_FILE${NC}"

    # Commit if in git
    if [ -d ".git" ]; then
        git add "$BUGS_FIXED_FILE"
        git commit -m "docs: document fix for $ISSUE_DESC

Tracked in BUGS_FIXED.md for future reference.

🤖 Generated with Crisis Mode
"
        echo -e "${GREEN}✅ Solution committed${NC}"
    fi
fi

echo ""

# =============================================================================
# SUMMARY
# =============================================================================
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎯 Crisis Mode Complete${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}Summary:${NC}"
echo -e "  Issue: $ISSUE_DESC"
echo -e "  Errors Found: $ERRORS_FOUND"
echo -e "  State Saved: $CRISIS_DIR"
echo ""

echo -e "${CYAN}💡 Next steps:${NC}"
echo -e "  1. Review captured state in: $CRISIS_DIR"
echo -e "  2. Check .claude/docs/patterns/BUGS_FIXED.md"
echo -e "  3. Run ${YELLOW}bug-hunter.sh${NC} for comprehensive scan"
echo -e "  4. Run ${YELLOW}morning-setup.sh${NC} to reload context"
echo ""

if [ "$ERRORS_FOUND" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $ERRORS_FOUND issues detected. Review and fix before continuing.${NC}"
    echo ""
else
    echo -e "${GREEN}✅ No critical issues detected. System appears stable.${NC}"
    echo ""
fi

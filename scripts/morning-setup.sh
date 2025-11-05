#!/bin/bash
# morning-setup.sh - Load project context for productive Claude Code session
# Usage: morning-setup.sh [options]
# Automates Playbook 5 (Morning Setup Routine) from ultimate-playbooks.md

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
    echo -e "${BLUE}Claude Code Library - Morning Setup${NC}"
    echo "Version: $VERSION"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --auto-start    Auto-start Claude CLI after setup"
    echo "  --skip-index    Skip Serena index refresh check"
    echo "  --version       Show version"
    echo "  --help          Show this help"
    echo ""
    echo "What it does:"
    echo "  1. Checks Git status and recent commits"
    echo "  2. Shows high-priority TODOs from .claude/docs/TODO.md"
    echo "  3. Displays recent HANDOFF notes"
    echo "  4. Warns about stale documentation"
    echo "  5. Refreshes Serena index if needed"
    echo "  6. Shows summary dashboard with next steps"
    echo ""
    echo "ROI: Saves 20-35 min → 5 min per session (62.5 hours/year)"
    exit 1
}

# Parse arguments
AUTO_START=false
SKIP_INDEX=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --auto-start)
            AUTO_START=true
            shift
            ;;
        --skip-index)
            SKIP_INDEX=true
            shift
            ;;
        --version)
            echo "morning-setup.sh version $VERSION"
            exit 0
            ;;
        --help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Not in a git repository!${NC}"
    echo "Please run this script from the root of your project."
    exit 1
fi

# Check if .claude directory exists
if [ ! -d ".claude" ]; then
    echo -e "${YELLOW}⚠️  No .claude directory found.${NC}"
    echo "This doesn't appear to be a Claude Code project."
    echo ""
    read -p "Would you like to initialize .claude structure? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Creating .claude structure...${NC}"
        mkdir -p .claude/docs/patterns
        echo "# TODO" > .claude/docs/TODO.md
        echo "# HANDOFF" > .claude/docs/HANDOFF.md
        echo -e "${GREEN}✅ Created basic .claude structure${NC}"
    else
        exit 0
    fi
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🌅 Morning Setup - $(date '+%Y-%m-%d %H:%M')${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# =============================================================================
# 1. GIT STATUS & RECENT COMMITS
# =============================================================================
echo -e "${BLUE}📊 Git Status${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "Current branch: ${GREEN}$CURRENT_BRANCH${NC}"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Uncommitted changes detected:${NC}"
    git status --short | head -10
    if [ $(git status --short | wc -l) -gt 10 ]; then
        echo "... and $(( $(git status --short | wc -l) - 10 )) more files"
    fi
else
    echo -e "${GREEN}✅ Working directory clean${NC}"
fi

# Show recent commits (last 5)
echo ""
echo -e "${BLUE}Recent commits (last 5):${NC}"
git log --oneline --decorate --graph -5 --color=always

echo ""

# =============================================================================
# 2. HIGH-PRIORITY TODOs
# =============================================================================
echo -e "${BLUE}📋 High-Priority TODOs${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

TODO_FILE=".claude/docs/TODO.md"
if [ -f "$TODO_FILE" ]; then
    # Extract P0 and P1 priority items (lines containing [P0] or [P1])
    HIGH_PRIORITY=$(grep -E '\[P0\]|\[P1\]' "$TODO_FILE" 2>/dev/null || true)

    if [ -n "$HIGH_PRIORITY" ]; then
        echo "$HIGH_PRIORITY" | while IFS= read -r line; do
            if [[ $line == *"[P0]"* ]]; then
                echo -e "${RED}🔴 $line${NC}"
            elif [[ $line == *"[P1]"* ]]; then
                echo -e "${YELLOW}🟡 $line${NC}"
            fi
        done
    else
        echo -e "${GREEN}✅ No high-priority TODOs${NC}"
        echo -e "${CYAN}💡 Tip: Use [P0] or [P1] tags in TODO.md for priority items${NC}"
    fi

    # Count total TODOs
    TOTAL_TODOS=$(grep -c '- \[ \]' "$TODO_FILE" 2>/dev/null || echo "0")
    if [ "$TOTAL_TODOS" -gt 0 ]; then
        echo ""
        echo -e "${CYAN}Total open TODOs: $TOTAL_TODOS${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  TODO.md not found${NC}"
    echo -e "${CYAN}💡 Create one at: .claude/docs/TODO.md${NC}"
fi

echo ""

# =============================================================================
# 3. RECENT HANDOFF NOTES
# =============================================================================
echo -e "${BLUE}📝 Recent HANDOFF Notes${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

HANDOFF_FILE=".claude/docs/HANDOFF.md"
if [ -f "$HANDOFF_FILE" ]; then
    # Get last 2 handoff entries (sections starting with ##)
    RECENT_HANDOFFS=$(grep -A 5 '^## ' "$HANDOFF_FILE" | head -20 || true)

    if [ -n "$RECENT_HANDOFFS" ]; then
        echo "$RECENT_HANDOFFS"
    else
        echo -e "${CYAN}No recent HANDOFF notes${NC}"
    fi

    # Check last update time
    LAST_UPDATE=$(stat -c %Y "$HANDOFF_FILE" 2>/dev/null || stat -f %m "$HANDOFF_FILE" 2>/dev/null || echo "0")
    CURRENT_TIME=$(date +%s)
    DAYS_OLD=$(( (CURRENT_TIME - LAST_UPDATE) / 86400 ))

    if [ "$DAYS_OLD" -gt 1 ]; then
        echo ""
        echo -e "${YELLOW}⚠️  HANDOFF.md last updated $DAYS_OLD days ago${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  HANDOFF.md not found${NC}"
    echo -e "${CYAN}💡 Create one at: .claude/docs/HANDOFF.md${NC}"
fi

echo ""

# =============================================================================
# 4. STALE DOCUMENTATION CHECK
# =============================================================================
echo -e "${BLUE}📚 Documentation Freshness${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

STALE_FOUND=false
ONE_MONTH_AGO=$(date -d '1 month ago' +%s 2>/dev/null || date -v-1m +%s 2>/dev/null)

# Check critical documentation files
CRITICAL_DOCS=("CLAUDE.md" "ARCHITECTURE.md" "docs/patterns/CODE_PATTERNS.md")

for doc in "${CRITICAL_DOCS[@]}"; do
    DOC_PATH=".claude/$doc"
    if [ -f "$DOC_PATH" ]; then
        DOC_MTIME=$(stat -c %Y "$DOC_PATH" 2>/dev/null || stat -f %m "$DOC_PATH" 2>/dev/null || echo "0")

        if [ "$DOC_MTIME" -lt "$ONE_MONTH_AGO" ]; then
            DAYS_OLD=$(( (CURRENT_TIME - DOC_MTIME) / 86400 ))
            echo -e "${YELLOW}⚠️  $doc is $DAYS_OLD days old${NC}"
            STALE_FOUND=true
        fi
    fi
done

if [ "$STALE_FOUND" = false ]; then
    echo -e "${GREEN}✅ All critical docs updated within last month${NC}"
fi

echo ""

# =============================================================================
# 5. SERENA INDEX REFRESH
# =============================================================================
if [ "$SKIP_INDEX" = false ]; then
    echo -e "${BLUE}🔍 Serena Index Check${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    SERENA_CACHE=".serena/cache"
    if [ -d "$SERENA_CACHE" ]; then
        CACHE_MTIME=$(stat -c %Y "$SERENA_CACHE" 2>/dev/null || stat -f %m "$SERENA_CACHE" 2>/dev/null || echo "0")
        SEVEN_DAYS_AGO=$(date -d '7 days ago' +%s 2>/dev/null || date -v-7d +%s 2>/dev/null)

        if [ "$CACHE_MTIME" -lt "$SEVEN_DAYS_AGO" ]; then
            DAYS_OLD=$(( (CURRENT_TIME - CACHE_MTIME) / 86400 ))
            echo -e "${YELLOW}⚠️  Serena index is $DAYS_OLD days old${NC}"
            echo -e "${CYAN}Refreshing index...${NC}"

            if command -v uvx &> /dev/null; then
                uvx --from git+https://github.com/oraios/serena serena project index &> /dev/null &
                echo -e "${GREEN}✅ Index refresh started in background${NC}"
            else
                echo -e "${YELLOW}⚠️  uvx not found, skipping index refresh${NC}"
            fi
        else
            echo -e "${GREEN}✅ Serena index up to date${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Serena not indexed yet${NC}"
        echo -e "${CYAN}💡 Tip: Run 'uvx serena project index' to enable semantic code navigation${NC}"
    fi

    echo ""
fi

# =============================================================================
# 6. SUMMARY DASHBOARD
# =============================================================================
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Morning Setup Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Suggested next steps
echo -e "${BLUE}💡 Suggested Next Steps:${NC}"
echo ""

# Priority 1: Uncommitted changes
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo -e "  1. ${YELLOW}Review and commit uncommitted changes${NC}"
    echo -e "     ${CYAN}→ git status && git add . && git commit${NC}"
fi

# Priority 2: High-priority TODOs
if [ -f "$TODO_FILE" ] && grep -q '\[P0\]' "$TODO_FILE" 2>/dev/null; then
    echo -e "  2. ${RED}Address P0 priority TODOs${NC}"
    echo -e "     ${CYAN}→ Check .claude/docs/TODO.md${NC}"
fi

# Priority 3: Update HANDOFF if stale
if [ -f "$HANDOFF_FILE" ]; then
    HANDOFF_MTIME=$(stat -c %Y "$HANDOFF_FILE" 2>/dev/null || stat -f %m "$HANDOFF_FILE" 2>/dev/null || echo "0")
    if [ $(( (CURRENT_TIME - HANDOFF_MTIME) / 86400 )) -gt 1 ]; then
        echo -e "  3. ${YELLOW}Update HANDOFF.md with yesterday's work${NC}"
        echo -e "     ${CYAN}→ vim .claude/docs/HANDOFF.md${NC}"
    fi
fi

# Priority 4: Start Claude Code
echo -e "  4. ${GREEN}Start Claude Code session${NC}"
echo -e "     ${CYAN}→ claude${NC}"

echo ""

# =============================================================================
# AUTO-START CLAUDE CODE (OPTIONAL)
# =============================================================================
if [ "$AUTO_START" = true ]; then
    echo -e "${CYAN}Auto-starting Claude Code...${NC}"
    echo ""
    sleep 1

    if command -v claude &> /dev/null; then
        exec claude
    else
        echo -e "${RED}❌ Claude CLI not found${NC}"
        echo "Please install Claude Code CLI first"
        exit 1
    fi
fi

# Add spacing before prompt returns
echo ""

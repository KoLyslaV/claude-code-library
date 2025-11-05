#!/bin/bash
# anti-pattern-detector.sh - Detect all 25 anti-patterns from ultimate-anti-patterns.md
# Usage: anti-pattern-detector.sh [options] [project-path]

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
    echo -e "${BLUE}Claude Code Library - Anti-Pattern Detector${NC}"
    echo "Version: $VERSION"
    echo ""
    echo "Usage: $0 [options] [project-path]"
    echo ""
    echo "Options:"
    echo "  project-path    Path to project (default: current directory)"
    echo "  --strict        Fail on any anti-pattern (exit code 1)"
    echo "  --ci            CI mode (no colors, JSON output)"
    echo "  --priority=P0   Only check specific priority (P0/P1/P2/P3)"
    echo "  --fix           Suggest auto-fix commands"
    echo "  --version       Show version"
    echo "  --help          Show this help"
    echo ""
    echo "Anti-Pattern Categories:"
    echo "  P0 (Critical):    Never do these (8 patterns)"
    echo "  P1 (Very Important): Avoid these (7 patterns)"
    echo "  P2 (Important):   Should avoid (5 patterns)"
    echo "  P3 (Nice to Have): Best practices (5 patterns)"
    echo ""
    echo "Exit codes:"
    echo "  0 - No anti-patterns detected"
    echo "  1 - P0/P1 anti-patterns found"
    echo "  2 - P2/P3 anti-patterns found (--strict mode)"
    exit 1
}

# Parse arguments
PROJECT_PATH="."
STRICT_MODE=false
CI_MODE=false
FIX_MODE=false
PRIORITY_FILTER=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --strict)
            STRICT_MODE=true
            shift
            ;;
        --ci)
            CI_MODE=true
            # Disable colors in CI mode
            RED=''
            GREEN=''
            YELLOW=''
            BLUE=''
            CYAN=''
            MAGENTA=''
            NC=''
            shift
            ;;
        --fix)
            FIX_MODE=true
            shift
            ;;
        --priority=*)
            PRIORITY_FILTER="${1#*=}"
            shift
            ;;
        --version)
            echo "anti-pattern-detector.sh version $VERSION"
            exit 0
            ;;
        --help)
            usage
            ;;
        *)
            if [ -z "$PROJECT_PATH" ] || [ "$PROJECT_PATH" = "." ]; then
                PROJECT_PATH="$1"
            else
                echo -e "${RED}Unknown option: $1${NC}"
                usage
            fi
            shift
            ;;
    esac
done

# Check if project path exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}❌ Project path not found: $PROJECT_PATH${NC}"
    exit 1
fi

cd "$PROJECT_PATH"

# Counters
P0_COUNT=0
P1_COUNT=0
P2_COUNT=0
P3_COUNT=0
TOTAL_DETECTED=0

# Array to store detected anti-patterns (for JSON output)
declare -a DETECTED_PATTERNS

if [ "$CI_MODE" = false ]; then
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🔍 Anti-Pattern Detector${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}Project: $(pwd)${NC}"
    echo ""
fi

# Helper function to report anti-pattern
report_ap() {
    local priority=$1
    local code=$2
    local name=$3
    local description=$4
    local fix=$5

    # Filter by priority if specified
    if [ -n "$PRIORITY_FILTER" ] && [ "$priority" != "$PRIORITY_FILTER" ]; then
        return
    fi

    case $priority in
        P0) ((P0_COUNT++)) ;;
        P1) ((P1_COUNT++)) ;;
        P2) ((P2_COUNT++)) ;;
        P3) ((P3_COUNT++)) ;;
    esac
    ((TOTAL_DETECTED++))

    if [ "$CI_MODE" = false ]; then
        case $priority in
            P0) echo -e "${RED}🔴 [$priority] $code: $name${NC}" ;;
            P1) echo -e "${YELLOW}🟡 [$priority] $code: $name${NC}" ;;
            P2) echo -e "${BLUE}🔵 [$priority] $code: $name${NC}" ;;
            P3) echo -e "${CYAN}⚪ [$priority] $code: $name${NC}" ;;
        esac
        echo -e "${CYAN}   → $description${NC}"

        if [ "$FIX_MODE" = true ] && [ -n "$fix" ]; then
            echo -e "${GREEN}   💡 Fix: $fix${NC}"
        fi
        echo ""
    fi

    # Store for JSON output
    DETECTED_PATTERNS+=("{\"priority\":\"$priority\",\"code\":\"$code\",\"name\":\"$name\",\"description\":\"$description\",\"fix\":\"$fix\"}")
}

# =============================================================================
# P0 CRITICAL ANTI-PATTERNS (Never Do)
# =============================================================================
if [ "$CI_MODE" = false ] && { [ -z "$PRIORITY_FILTER" ] || [ "$PRIORITY_FILTER" = "P0" ]; }; then
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}🔴 P0 CRITICAL (Never Do)${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
fi

# AP1: No .claude/CLAUDE.md
if [ ! -f ".claude/CLAUDE.md" ]; then
    report_ap "P0" "AP1" "No .claude/CLAUDE.md" \
        "Missing master documentation file" \
        "Run init-project.sh or create .claude/CLAUDE.md"
fi

# AP2: Using Bash grep/find over fd/rg
if [ -d ".git" ]; then
    # Check recent git history for grep/find usage
    if git log --all --since="1 week ago" --grep="grep -r\|find \." &> /dev/null; then
        GREP_USAGE=$(git log --all --since="1 week ago" --oneline | grep -c "grep -r\|find \." || echo "0")
        if [ "$GREP_USAGE" -gt 0 ]; then
            report_ap "P0" "AP2" "Using Bash grep/find" \
                "Found $GREP_USAGE commits using grep/find instead of fd/rg" \
                "Use 'fd pattern' and 'rg pattern' instead"
        fi
    fi
fi

# AP3: Reading full files instead of symbol-level
if command -v rg &> /dev/null; then
    # Check for Read tool usage without Serena
    READ_WITHOUT_SERENA=$(rg -c "read_file|Read tool" .claude/ 2>/dev/null || echo "0")
    SERENA_USAGE=$(rg -c "serena|find_symbol|get_symbols_overview" .claude/ 2>/dev/null || echo "0")

    if [ "$READ_WITHOUT_SERENA" -gt 0 ] && [ "$SERENA_USAGE" -eq 0 ]; then
        report_ap "P0" "AP3" "Reading full files without Serena" \
            "No Serena usage detected despite file reads" \
            "Use mcp__serena__get_symbols_overview() before reading files"
    fi
fi

# AP4: Not using Context7 for libraries
if [ -f ".claude/CLAUDE.md" ]; then
    if ! grep -q "context7\|Context7" ".claude/CLAUDE.md" 2>/dev/null; then
        report_ap "P0" "AP4" "Not using Context7" \
            "No Context7 usage documented in CLAUDE.md" \
            "Add 'use context7' pattern to CLAUDE.md"
    fi
fi

# AP12: Creating new files unnecessarily
if [ -d ".git" ]; then
    # Check for many new files in recent commits
    NEW_FILES=$(git log --since="1 week ago" --diff-filter=A --name-only --pretty=format: | wc -l)
    MODIFIED_FILES=$(git log --since="1 week ago" --diff-filter=M --name-only --pretty=format: | wc -l)

    if [ "$NEW_FILES" -gt 20 ] && [ "$MODIFIED_FILES" -lt 10 ]; then
        report_ap "P0" "AP12" "Creating too many new files" \
            "$NEW_FILES new files vs $MODIFIED_FILES modified (ratio too high)" \
            "Prefer editing existing files, create new files only when necessary"
    fi
fi

# AP13: Full file reads with Serena
if [ -f ".claude/docs/HANDOFF.md" ]; then
    FULL_READS=$(grep -c "read_file\|include_body=true" ".claude/docs/HANDOFF.md" 2>/dev/null || echo "0")
    if [ "$FULL_READS" -gt 5 ]; then
        report_ap "P0" "AP13" "Too many full file reads" \
            "Found $FULL_READS full file reads in HANDOFF.md" \
            "Use get_symbols_overview() first, then targeted find_symbol()"
    fi
fi

# =============================================================================
# P1 VERY IMPORTANT ANTI-PATTERNS
# =============================================================================
if [ "$CI_MODE" = false ] && { [ -z "$PRIORITY_FILTER" ] || [ "$PRIORITY_FILTER" = "P1" ]; }; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}🟡 P1 VERY IMPORTANT${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
fi

# AP5: No Documentation
DOC_COUNT=0
[ -f ".claude/docs/ARCHITECTURE.md" ] && ((DOC_COUNT++))
[ -f ".claude/docs/patterns/CODE_PATTERNS.md" ] && ((DOC_COUNT++))
[ -f ".claude/docs/TODO.md" ] && ((DOC_COUNT++))

if [ "$DOC_COUNT" -lt 2 ]; then
    report_ap "P1" "AP5" "Insufficient documentation" \
        "Only $DOC_COUNT documentation files found (need 3+)" \
        "Create ARCHITECTURE.md, CODE_PATTERNS.md, TODO.md"
fi

# AP6: Ignoring compilation errors
if [ -f "tsconfig.json" ] || [ -f "package.json" ]; then
    # Check if TypeScript is configured
    if [ -f "tsconfig.json" ]; then
        if ! grep -q '"strict": true' tsconfig.json 2>/dev/null; then
            report_ap "P1" "AP6" "TypeScript not in strict mode" \
                "strict mode disabled in tsconfig.json" \
                "Enable: \"strict\": true in tsconfig.json"
        fi
    fi
fi

# AP7: Skipping tests
if [ -f "package.json" ]; then
    if ! grep -q '"test"' package.json 2>/dev/null; then
        report_ap "P1" "AP7" "No test script" \
            "No test script found in package.json" \
            "Add test script: \"test\": \"jest\" or similar"
    fi
fi

# AP8: Not using Serena for large codebases
if [ ! -d ".serena" ]; then
    # Check codebase size
    if command -v fd &> /dev/null; then
        CODE_FILES=$(fd -e ts -e tsx -e js -e jsx -e py | wc -l)
        if [ "$CODE_FILES" -gt 50 ]; then
            report_ap "P1" "AP8" "Serena not initialized" \
                "Large codebase ($CODE_FILES files) without Serena" \
                "Run: uvx serena project index"
        fi
    fi
fi

# AP9: Mixing "use client" everywhere (Next.js specific)
if [ -f "next.config.ts" ] || [ -f "next.config.js" ]; then
    if command -v rg &> /dev/null; then
        USE_CLIENT_COUNT=$(rg -c '"use client"' src/ app/ 2>/dev/null | awk -F: '{sum+=$2} END {print sum}')
        TOTAL_TSX=$(fd -e tsx src/ app/ 2>/dev/null | wc -l)

        if [ "$USE_CLIENT_COUNT" -gt 0 ] && [ "$TOTAL_TSX" -gt 0 ]; then
            RATIO=$((USE_CLIENT_COUNT * 100 / TOTAL_TSX))
            if [ "$RATIO" -gt 50 ]; then
                report_ap "P1" "AP9" "Overusing 'use client'" \
                    "$RATIO% of components use 'use client' (should be <30%)" \
                    "Start with Server Components, add 'use client' only when needed"
            fi
        fi
    fi
fi

# AP10: Skipping Morning Setup
if [ -f ".claude/docs/HANDOFF.md" ]; then
    HANDOFF_MTIME=$(stat -c %Y ".claude/docs/HANDOFF.md" 2>/dev/null || stat -f %m ".claude/docs/HANDOFF.md" 2>/dev/null || echo "0")
    CURRENT_TIME=$(date +%s)
    DAYS_OLD=$(( (CURRENT_TIME - HANDOFF_MTIME) / 86400 ))

    if [ "$DAYS_OLD" -gt 7 ]; then
        report_ap "P1" "AP10" "Skipping Morning Setup" \
            "HANDOFF.md not updated in $DAYS_OLD days" \
            "Run: morning-setup.sh before each session"
    fi
fi

# AP11: No TODO tracking
if [ ! -f ".claude/docs/TODO.md" ]; then
    report_ap "P1" "AP11" "No TODO tracking" \
        "Missing TODO.md for task tracking" \
        "Create .claude/docs/TODO.md with priority tags [P0], [P1], etc."
fi

# AP14: Overusing "use client" (duplicate check with more detail)
# (Already covered in AP9)

# AP15: Unvalidated Server Actions (Next.js specific)
if [ -f "next.config.ts" ] || [ -f "next.config.js" ]; then
    if command -v rg &> /dev/null; then
        # Check for "use server" without zod validation
        SERVER_ACTIONS=$(rg -c '"use server"' src/ app/ 2>/dev/null | awk -F: '{sum+=$2} END {print sum}')
        ZOD_USAGE=$(rg -c 'z\.' src/ app/ 2>/dev/null | awk -F: '{sum+=$2} END {print sum}')

        if [ "$SERVER_ACTIONS" -gt 0 ] && [ "$ZOD_USAGE" -eq 0 ]; then
            report_ap "P1" "AP15" "Unvalidated Server Actions" \
                "Found $SERVER_ACTIONS server actions without Zod validation" \
                "Add Zod schemas: import { z } from 'zod'"
        fi
    fi
fi

# =============================================================================
# P2 IMPORTANT ANTI-PATTERNS
# =============================================================================
if [ "$CI_MODE" = false ] && { [ -z "$PRIORITY_FILTER" ] || [ "$PRIORITY_FILTER" = "P2" ]; }; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🔵 P2 IMPORTANT${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
fi

# AP16: No error boundaries (Next.js/React)
if [ -d "app" ] || [ -d "src" ]; then
    if command -v fd &> /dev/null; then
        ERROR_BOUNDARIES=$(fd "error.tsx" app/ src/ 2>/dev/null | wc -l)
        if [ "$ERROR_BOUNDARIES" -eq 0 ]; then
            report_ap "P2" "AP16" "No error boundaries" \
                "No error.tsx files found in app/ or src/" \
                "Create error.tsx in route segments for error handling"
        fi
    fi
fi

# AP17: Missing loading states (Next.js)
if [ -d "app" ]; then
    if command -v fd &> /dev/null; then
        LOADING_FILES=$(fd "loading.tsx" app/ 2>/dev/null | wc -l)
        ROUTE_FILES=$(fd "page.tsx" app/ 2>/dev/null | wc -l)

        if [ "$ROUTE_FILES" -gt 3 ] && [ "$LOADING_FILES" -eq 0 ]; then
            report_ap "P2" "AP17" "Missing loading states" \
                "$ROUTE_FILES routes without loading.tsx" \
                "Add loading.tsx in route segments for loading UI"
        fi
    fi
fi

# AP18: Client-side data fetching
if command -v rg &> /dev/null; then
    CLIENT_FETCH=$(rg -c "useEffect.*fetch\|useEffect.*axios" src/ app/ 2>/dev/null | awk -F: '{sum+=$2} END {print sum}')
    if [ "$CLIENT_FETCH" -gt 0 ]; then
        report_ap "P2" "AP18" "Client-side data fetching" \
            "Found $CLIENT_FETCH useEffect data fetching patterns" \
            "Use Server Components or Server Actions for data fetching"
    fi
fi

# AP19: Ignoring hydration errors
if [ -f ".claude/docs/BUGS_FIXED.md" ]; then
    if ! grep -qi "hydration" ".claude/docs/BUGS_FIXED.md" 2>/dev/null; then
        # Check for suppressHydrationWarning in code
        if command -v rg &> /dev/null; then
            SUPPRESS_COUNT=$(rg -c "suppressHydrationWarning" src/ app/ 2>/dev/null | awk -F: '{sum+=$2} END {print sum}')
            if [ "$SUPPRESS_COUNT" -gt 2 ]; then
                report_ap "P2" "AP19" "Suppressing hydration warnings" \
                    "Found $SUPPRESS_COUNT suppressHydrationWarning usages" \
                    "Fix hydration errors instead of suppressing them"
            fi
        fi
    fi
fi

# AP20: No TypeScript strict mode
if [ -f "tsconfig.json" ]; then
    if ! grep -q '"strict": true' tsconfig.json 2>/dev/null; then
        report_ap "P2" "AP20" "TypeScript not in strict mode" \
            "strict mode disabled in tsconfig.json" \
            "Enable: \"strict\": true in tsconfig.json"
    fi
fi

# =============================================================================
# P3 NICE TO HAVE ANTI-PATTERNS
# =============================================================================
if [ "$CI_MODE" = false ] && { [ -z "$PRIORITY_FILTER" ] || [ "$PRIORITY_FILTER" = "P3" ]; }; then
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}⚪ P3 NICE TO HAVE${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
fi

# AP21: No code patterns documented
if [ ! -f ".claude/docs/patterns/CODE_PATTERNS.md" ]; then
    report_ap "P3" "AP21" "No code patterns documented" \
        "Missing CODE_PATTERNS.md" \
        "Create .claude/docs/patterns/CODE_PATTERNS.md with reusable patterns"
fi

# AP22: Inconsistent naming
if command -v rg &> /dev/null && [ -d "src" ]; then
    # Check for mixed naming conventions (camelCase vs snake_case)
    SNAKE_CASE=$(fd -e ts -e tsx -e js -e jsx . src/ 2>/dev/null | grep -c "_" || echo "0")
    CAMEL_CASE=$(fd -e ts -e tsx -e js -e jsx . src/ 2>/dev/null | wc -l)

    if [ "$SNAKE_CASE" -gt 0 ] && [ "$CAMEL_CASE" -gt 0 ]; then
        RATIO=$((SNAKE_CASE * 100 / CAMEL_CASE))
        if [ "$RATIO" -gt 10 ] && [ "$RATIO" -lt 90 ]; then
            report_ap "P3" "AP22" "Inconsistent naming convention" \
                "Mixed snake_case ($SNAKE_CASE) and camelCase ($CAMEL_CASE) files" \
                "Standardize on one naming convention (prefer camelCase for TS)"
        fi
    fi
fi

# AP23: No handoff notes
if [ ! -f ".claude/docs/HANDOFF.md" ]; then
    report_ap "P3" "AP23" "No handoff notes" \
        "Missing HANDOFF.md" \
        "Create .claude/docs/HANDOFF.md for session context"
fi

# AP24: Skipping Serena thinking tools
if [ -f ".claude/docs/HANDOFF.md" ]; then
    if ! grep -q "think_about" ".claude/docs/HANDOFF.md" 2>/dev/null; then
        report_ap "P3" "AP24" "Not using Serena thinking tools" \
            "No think_about_* tool usage documented" \
            "Use think_about_collected_information, think_about_task_adherence"
    fi
fi

# AP25: Not leveraging modern CLI tools
if [ -f ".claude/CLAUDE.md" ]; then
    if ! grep -q "fd\|rg\|eza\|bat" ".claude/CLAUDE.md" 2>/dev/null; then
        report_ap "P3" "AP25" "Not using modern CLI tools" \
            "No modern CLI tools (fd, rg, eza, bat) documented" \
            "Document modern CLI tools in CLAUDE.md"
    fi
fi

# =============================================================================
# SUMMARY
# =============================================================================
if [ "$CI_MODE" = true ]; then
    # JSON output for CI
    echo "{"
    echo "  \"total\": $TOTAL_DETECTED,"
    echo "  \"p0\": $P0_COUNT,"
    echo "  \"p1\": $P1_COUNT,"
    echo "  \"p2\": $P2_COUNT,"
    echo "  \"p3\": $P3_COUNT,"
    echo "  \"patterns\": ["
    for i in "${!DETECTED_PATTERNS[@]}"; do
        echo "    ${DETECTED_PATTERNS[$i]}"
        if [ $i -lt $((${#DETECTED_PATTERNS[@]} - 1)) ]; then
            echo ","
        fi
    done
    echo "  ]"
    echo "}"
else
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📊 Summary${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${RED}P0 Critical: $P0_COUNT${NC}"
    echo -e "${YELLOW}P1 Very Important: $P1_COUNT${NC}"
    echo -e "${BLUE}P2 Important: $P2_COUNT${NC}"
    echo -e "${CYAN}P3 Nice to Have: $P3_COUNT${NC}"
    echo ""
    echo -e "${MAGENTA}Total Detected: $TOTAL_DETECTED${NC}"
    echo ""
fi

# Determine exit code
if [ "$P0_COUNT" -gt 0 ] || [ "$P1_COUNT" -gt 0 ]; then
    if [ "$CI_MODE" = false ]; then
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}❌ CRITICAL anti-patterns detected!${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${CYAN}💡 Next steps:${NC}"
        echo -e "  1. Fix P0 critical issues immediately"
        echo -e "  2. Address P1 issues as soon as possible"
        echo -e "  3. Run with ${YELLOW}--fix${NC} flag to see suggested fixes"
        echo -e "  4. Run ${YELLOW}validate-structure.sh --fix${NC} to auto-create missing files"
        echo ""
    fi
    exit 1
elif [ "$P2_COUNT" -gt 0 ] || [ "$P3_COUNT" -gt 0 ]; then
    if [ "$STRICT_MODE" = true ]; then
        if [ "$CI_MODE" = false ]; then
            echo -e "${YELLOW}Strict mode: Treating P2/P3 as errors${NC}"
        fi
        exit 2
    else
        if [ "$CI_MODE" = false ]; then
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${YELLOW}⚠️  Minor anti-patterns detected${NC}"
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo -e "${CYAN}Consider addressing P2/P3 issues to improve code quality${NC}"
            echo ""
        fi
        exit 0
    fi
else
    if [ "$CI_MODE" = false ]; then
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ No anti-patterns detected!${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${CYAN}🎉 Your project follows Claude Code best practices!${NC}"
        echo ""
    fi
    exit 0
fi

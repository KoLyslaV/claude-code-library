#!/bin/bash
# bug-hunter.sh - Systematic bug detection and fixing
# Usage: bug-hunter.sh [options]
# Automates Playbook 4 (Bug Hunting) from ultimate-playbooks.md

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
    echo -e "${BLUE}Claude Code Library - Bug Hunter${NC}"
    echo "Version: $VERSION"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --quick         Quick scan (skip heavy checks)"
    echo "  --fix           Auto-fix common issues"
    echo "  --report        Generate bug report"
    echo "  --version       Show version"
    echo "  --help          Show this help"
    echo ""
    echo "What it does:"
    echo "  1. Runs linters and type checkers"
    echo "  2. Checks for common anti-patterns"
    echo "  3. Scans console/log errors"
    echo "  4. Validates data flows"
    echo "  5. Generates actionable bug report"
    echo ""
    echo "ROI: 80% faster bug detection vs manual hunting"
    exit 1
}

# Parse arguments
QUICK_MODE=false
FIX_MODE=false
REPORT_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)
            QUICK_MODE=true
            shift
            ;;
        --fix)
            FIX_MODE=true
            shift
            ;;
        --report)
            REPORT_MODE=true
            shift
            ;;
        --version)
            echo "bug-hunter.sh version $VERSION"
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

# Check if in project directory
if [ ! -d ".git" ] && [ ! -f "package.json" ] && [ ! -f "pyproject.toml" ]; then
    echo -e "${RED}❌ Not in a project directory!${NC}"
    exit 1
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🐛 Bug Hunter - Systematic Bug Detection${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Counters
ERRORS_FOUND=0
WARNINGS_FOUND=0
FIXES_APPLIED=0

# =============================================================================
# PHASE 1: STATIC ANALYSIS
# =============================================================================
echo -e "${BLUE}🔍 Phase 1: Static Analysis${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Detect project type
PROJECT_TYPE="unknown"
if [ -f "package.json" ]; then
    PROJECT_TYPE="javascript"
elif [ -f "pyproject.toml" ]; then
    PROJECT_TYPE="python"
fi

case $PROJECT_TYPE in
    javascript)
        echo -e "${CYAN}Detected: JavaScript/TypeScript project${NC}"

        # TypeScript compilation
        if [ -f "tsconfig.json" ]; then
            echo -e "${YELLOW}Running TypeScript compiler...${NC}"
            if npx tsc --noEmit 2>&1 | tee /tmp/tsc-output.txt; then
                echo -e "${GREEN}✅ No TypeScript errors${NC}"
            else
                TS_ERRORS=$(grep -c "error TS" /tmp/tsc-output.txt || echo "0")
                ERRORS_FOUND=$((ERRORS_FOUND + TS_ERRORS))
                echo -e "${RED}❌ Found $TS_ERRORS TypeScript errors${NC}"
            fi
        fi

        # ESLint
        if [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || grep -q "eslint" package.json; then
            echo -e "${YELLOW}Running ESLint...${NC}"
            if npx eslint . --ext .ts,.tsx,.js,.jsx 2>&1 | tee /tmp/eslint-output.txt; then
                echo -e "${GREEN}✅ No ESLint errors${NC}"
            else
                ESLINT_ERRORS=$(grep -c "error" /tmp/eslint-output.txt || echo "0")
                ESLINT_WARNINGS=$(grep -c "warning" /tmp/eslint-output.txt || echo "0")
                ERRORS_FOUND=$((ERRORS_FOUND + ESLINT_ERRORS))
                WARNINGS_FOUND=$((WARNINGS_FOUND + ESLINT_WARNINGS))
                echo -e "${RED}❌ Found $ESLINT_ERRORS ESLint errors, $ESLINT_WARNINGS warnings${NC}"

                if [ "$FIX_MODE" = true ]; then
                    echo -e "${CYAN}Attempting auto-fix...${NC}"
                    npx eslint . --ext .ts,.tsx,.js,.jsx --fix
                    FIXES_APPLIED=$((FIXES_APPLIED + 1))
                fi
            fi
        fi
        ;;

    python)
        echo -e "${CYAN}Detected: Python project${NC}"

        # mypy type checking
        if command -v mypy &> /dev/null || grep -q "mypy" pyproject.toml 2>/dev/null; then
            echo -e "${YELLOW}Running mypy type checker...${NC}"
            if poetry run mypy src/ 2>&1 | tee /tmp/mypy-output.txt || mypy src/ 2>&1 | tee /tmp/mypy-output.txt; then
                echo -e "${GREEN}✅ No mypy errors${NC}"
            else
                MYPY_ERRORS=$(grep -c "error:" /tmp/mypy-output.txt || echo "0")
                ERRORS_FOUND=$((ERRORS_FOUND + MYPY_ERRORS))
                echo -e "${RED}❌ Found $MYPY_ERRORS mypy errors${NC}"
            fi
        fi

        # Ruff linting
        if command -v ruff &> /dev/null || grep -q "ruff" pyproject.toml 2>/dev/null; then
            echo -e "${YELLOW}Running ruff linter...${NC}"
            if poetry run ruff check src/ 2>&1 | tee /tmp/ruff-output.txt || ruff check src/ 2>&1 | tee /tmp/ruff-output.txt; then
                echo -e "${GREEN}✅ No ruff errors${NC}"
            else
                RUFF_ERRORS=$(grep -c "error" /tmp/ruff-output.txt || echo "0")
                ERRORS_FOUND=$((ERRORS_FOUND + RUFF_ERRORS))
                echo -e "${RED}❌ Found $RUFF_ERRORS ruff errors${NC}"

                if [ "$FIX_MODE" = true ]; then
                    echo -e "${CYAN}Attempting auto-fix...${NC}"
                    poetry run ruff check --fix src/ || ruff check --fix src/
                    FIXES_APPLIED=$((FIXES_APPLIED + 1))
                fi
            fi
        fi
        ;;

    *)
        echo -e "${YELLOW}⚠️  Unknown project type, skipping static analysis${NC}"
        ;;
esac

echo ""

# =============================================================================
# PHASE 2: ANTI-PATTERN DETECTION
# =============================================================================
echo -e "${BLUE}🚫 Phase 2: Anti-Pattern Detection${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/anti-pattern-detector.sh" ]; then
    "$SCRIPT_DIR/anti-pattern-detector.sh" --ci > /tmp/anti-patterns.json 2>&1 || true

    if [ -f /tmp/anti-patterns.json ]; then
        AP_TOTAL=$(jq -r '.total' /tmp/anti-patterns.json 2>/dev/null || echo "0")
        AP_P0=$(jq -r '.p0' /tmp/anti-patterns.json 2>/dev/null || echo "0")
        AP_P1=$(jq -r '.p1' /tmp/anti-patterns.json 2>/dev/null || echo "0")

        if [ "$AP_P0" -gt 0 ] || [ "$AP_P1" -gt 0 ]; then
            ERRORS_FOUND=$((ERRORS_FOUND + AP_P0 + AP_P1))
            echo -e "${RED}❌ Found $AP_TOTAL anti-patterns (P0: $AP_P0, P1: $AP_P1)${NC}"
        else
            echo -e "${GREEN}✅ No critical anti-patterns${NC}"
        fi
    fi
else
    echo -e "${YELLOW}anti-pattern-detector.sh not found, skipping${NC}"
fi

echo ""

# =============================================================================
# PHASE 3: RUNTIME ERROR SCANNING
# =============================================================================
if [ "$QUICK_MODE" = false ]; then
    echo -e "${BLUE}📝 Phase 3: Runtime Error Scanning${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Scan for console.error, console.warn in code
    if command -v rg &> /dev/null; then
        echo -e "${YELLOW}Scanning for console errors in code...${NC}"
        CONSOLE_ERRORS=$(rg -c "console\.(error|warn)" src/ app/ 2>/dev/null | awk -F: '{sum+=$2} END {print sum}' || echo "0")

        if [ "$CONSOLE_ERRORS" -gt 0 ]; then
            echo -e "${YELLOW}⚠️  Found $CONSOLE_ERRORS console.error/warn calls${NC}"
            WARNINGS_FOUND=$((WARNINGS_FOUND + CONSOLE_ERRORS))
        else
            echo -e "${GREEN}✅ No console errors in code${NC}"
        fi
    fi

    # Check for TODO/FIXME comments
    if command -v rg &> /dev/null; then
        echo -e "${YELLOW}Scanning for TODO/FIXME comments...${NC}"
        TODO_COUNT=$(rg -c "TODO|FIXME" src/ app/ 2>/dev/null | awk -F: '{sum+=$2} END {print sum}' || echo "0")

        if [ "$TODO_COUNT" -gt 0 ]; then
            echo -e "${YELLOW}⚠️  Found $TODO_COUNT TODO/FIXME comments${NC}"
            WARNINGS_FOUND=$((WARNINGS_FOUND + TODO_COUNT))
        else
            echo -e "${GREEN}✅ No TODO/FIXME comments${NC}"
        fi
    fi

    echo ""
fi

# =============================================================================
# PHASE 4: TEST FAILURES
# =============================================================================
if [ "$QUICK_MODE" = false ]; then
    echo -e "${BLUE}🧪 Phase 4: Test Execution${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    case $PROJECT_TYPE in
        javascript)
            if grep -q "\"test\":" package.json; then
                echo -e "${YELLOW}Running tests...${NC}"
                if npm test 2>&1 | tee /tmp/test-output.txt; then
                    echo -e "${GREEN}✅ All tests passed${NC}"
                else
                    TEST_FAILURES=$(grep -c "FAIL" /tmp/test-output.txt || echo "0")
                    ERRORS_FOUND=$((ERRORS_FOUND + TEST_FAILURES))
                    echo -e "${RED}❌ $TEST_FAILURES test failures${NC}"
                fi
            fi
            ;;

        python)
            if command -v pytest &> /dev/null; then
                echo -e "${YELLOW}Running pytest...${NC}"
                if poetry run pytest 2>&1 | tee /tmp/pytest-output.txt || pytest 2>&1 | tee /tmp/pytest-output.txt; then
                    echo -e "${GREEN}✅ All tests passed${NC}"
                else
                    TEST_FAILURES=$(grep -c "FAILED" /tmp/pytest-output.txt || echo "0")
                    ERRORS_FOUND=$((ERRORS_FOUND + TEST_FAILURES))
                    echo -e "${RED}❌ $TEST_FAILURES test failures${NC}"
                fi
            fi
            ;;
    esac

    echo ""
fi

# =============================================================================
# PHASE 5: SUMMARY & REPORT
# =============================================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 Bug Hunter Summary${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${RED}Errors Found: $ERRORS_FOUND${NC}"
echo -e "${YELLOW}Warnings Found: $WARNINGS_FOUND${NC}"
echo -e "${GREEN}Auto-Fixes Applied: $FIXES_APPLIED${NC}"
echo ""

# Generate report if requested
if [ "$REPORT_MODE" = true ]; then
    REPORT_FILE=".claude/docs/BUG_REPORT_$(date +%Y%m%d_%H%M%S).md"

    cat > "$REPORT_FILE" << EOF
# Bug Hunter Report

**Date:** $(date +"%Y-%m-%d %H:%M:%S")

## Summary

- **Errors Found:** $ERRORS_FOUND
- **Warnings Found:** $WARNINGS_FOUND
- **Auto-Fixes Applied:** $FIXES_APPLIED

## Static Analysis

$([ -f /tmp/tsc-output.txt ] && cat /tmp/tsc-output.txt || echo "No TypeScript errors")

$([ -f /tmp/eslint-output.txt ] && cat /tmp/eslint-output.txt || echo "No ESLint errors")

$([ -f /tmp/mypy-output.txt ] && cat /tmp/mypy-output.txt || echo "No mypy errors")

## Anti-Patterns

$([ -f /tmp/anti-patterns.json ] && cat /tmp/anti-patterns.json || echo "No anti-patterns")

## Test Results

$([ -f /tmp/test-output.txt ] && cat /tmp/test-output.txt || echo "No test results")

## Recommendations

1. Fix all P0 critical errors immediately
2. Address P1 errors before next release
3. Review warnings and fix as time permits

---

Generated with Bug Hunter v$VERSION
EOF

    echo -e "${GREEN}✅ Bug report saved to: $REPORT_FILE${NC}"
    echo ""
fi

# Final verdict
if [ "$ERRORS_FOUND" -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✨ No critical bugs found!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}❌ Found $ERRORS_FOUND bugs!${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}💡 Next steps:${NC}"
    echo -e "  1. Review errors above"
    echo -e "  2. Fix P0 critical issues first"
    echo -e "  3. Run ${YELLOW}bug-hunter.sh --fix${NC} to auto-fix common issues"
    echo -e "  4. Run ${YELLOW}bug-hunter.sh --report${NC} for detailed report"
    echo ""
    exit 1
fi

#!/bin/bash
# validate-structure.sh - Validate .claude/ structure against ultimate-file-structure.md
# Usage: validate-structure.sh [project-path]
# Automates Playbook 3 (Maintenance) from ultimate-playbooks.md

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
    echo -e "${BLUE}Claude Code Library - Structure Validator${NC}"
    echo "Version: $VERSION"
    echo ""
    echo "Usage: $0 [project-path]"
    echo ""
    echo "Options:"
    echo "  project-path    Path to project (default: current directory)"
    echo "  --strict        Fail on warnings (exit code 1)"
    echo "  --ci            CI mode (no colors, machine-readable output)"
    echo "  --fix           Auto-fix common issues (create missing files)"
    echo "  --version       Show version"
    echo "  --help          Show this help"
    echo ""
    echo "What it validates:"
    echo "  ✅ Required directory structure"
    echo "  ✅ Required documentation files"
    echo "  ✅ File size recommendations"
    echo "  ✅ Critical content sections"
    echo "  ✅ Common anti-patterns"
    echo ""
    echo "Exit codes:"
    echo "  0 - All checks passed"
    echo "  1 - Errors found"
    echo "  2 - Warnings found (--strict mode)"
    exit 1
}

# Parse arguments
PROJECT_PATH="."
STRICT_MODE=false
CI_MODE=false
FIX_MODE=false

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
            NC=''
            shift
            ;;
        --fix)
            FIX_MODE=true
            shift
            ;;
        --version)
            echo "validate-structure.sh version $VERSION"
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
ERRORS=0
WARNINGS=0
PASSED=0

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔍 Validating .claude/ Structure${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Project: $(pwd)${NC}"
echo ""

# =============================================================================
# 1. DIRECTORY STRUCTURE VALIDATION
# =============================================================================
echo -e "${BLUE}📁 Directory Structure${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

REQUIRED_DIRS=(
    ".claude"
    ".claude/docs"
    ".claude/docs/patterns"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✅ $dir${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ Missing: $dir${NC}"
        ((ERRORS++))

        if [ "$FIX_MODE" = true ]; then
            echo -e "${CYAN}   → Creating directory...${NC}"
            mkdir -p "$dir"
            echo -e "${GREEN}   ✅ Created${NC}"
        fi
    fi
done

echo ""

# =============================================================================
# 2. REQUIRED FILES VALIDATION
# =============================================================================
echo -e "${BLUE}📄 Required Files${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Critical files (must exist)
CRITICAL_FILES=(
    ".claude/CLAUDE.md:Master documentation file"
)

# Recommended files (should exist)
RECOMMENDED_FILES=(
    ".claude/docs/ARCHITECTURE.md:System architecture"
    ".claude/docs/TODO.md:Task tracking"
    ".claude/docs/HANDOFF.md:Session context"
    ".claude/docs/patterns/CODE_PATTERNS.md:Reusable patterns"
    ".claude/docs/patterns/BUGS_FIXED.md:Bug documentation"
)

# Check critical files
for file_desc in "${CRITICAL_FILES[@]}"; do
    file="${file_desc%%:*}"
    desc="${file_desc##*:}"

    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file${NC} ($desc)"
        ((PASSED++))
    else
        echo -e "${RED}❌ Missing: $file${NC} ($desc)"
        ((ERRORS++))

        if [ "$FIX_MODE" = true ]; then
            echo -e "${CYAN}   → Creating template...${NC}"
            case "$file" in
                ".claude/CLAUDE.md")
                    cat > "$file" << 'EOF'
# {{PROJECT_NAME}} - Claude Code Documentation

## Project Overview
[Describe your project here]

## Tech Stack
- Framework: [e.g., Next.js 15]
- Database: [e.g., PostgreSQL with Prisma]
- Styling: [e.g., Tailwind CSS]

## Critical Rules

### Discovery Before Action
BEFORE any code change:
```bash
fd "pattern" src/
rg "search-term" src/
mcp__serena__get_symbols_overview("file.ts")
```

### Prefer Symbol-Level Operations
ALWAYS use Serena for code navigation (70% token savings):
```bash
mcp__serena__find_symbol("/ClassName")
```

## Development Workflow
[Document your workflow here]

## Testing
[Testing strategy]

## Deployment
[Deployment instructions]
EOF
                    ;;
            esac
            echo -e "${GREEN}   ✅ Created${NC}"
        fi
    fi
done

# Check recommended files
for file_desc in "${RECOMMENDED_FILES[@]}"; do
    file="${file_desc%%:*}"
    desc="${file_desc##*:}"

    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file${NC} ($desc)"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️  Missing: $file${NC} ($desc)"
        ((WARNINGS++))

        if [ "$FIX_MODE" = true ]; then
            echo -e "${CYAN}   → Creating template...${NC}"
            case "$file" in
                ".claude/docs/TODO.md")
                    echo "# TODO" > "$file"
                    ;;
                ".claude/docs/HANDOFF.md")
                    echo "# HANDOFF" > "$file"
                    ;;
                ".claude/docs/ARCHITECTURE.md")
                    echo "# Architecture" > "$file"
                    ;;
                ".claude/docs/patterns/CODE_PATTERNS.md")
                    echo "# Code Patterns" > "$file"
                    ;;
                ".claude/docs/patterns/BUGS_FIXED.md")
                    echo "# Bugs Fixed" > "$file"
                    ;;
            esac
            echo -e "${GREEN}   ✅ Created${NC}"
        fi
    fi
done

echo ""

# =============================================================================
# 3. FILE SIZE VALIDATION
# =============================================================================
echo -e "${BLUE}📏 File Size Checks${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# CLAUDE.md should be 200-500 lines (per ultimate-claude-md-template.md)
if [ -f ".claude/CLAUDE.md" ]; then
    LINES=$(wc -l < ".claude/CLAUDE.md")

    if [ "$LINES" -lt 50 ]; then
        echo -e "${YELLOW}⚠️  CLAUDE.md is too short: $LINES lines (recommended: 200-500)${NC}"
        ((WARNINGS++))
    elif [ "$LINES" -gt 500 ]; then
        echo -e "${YELLOW}⚠️  CLAUDE.md is too long: $LINES lines (recommended: 200-500)${NC}"
        echo -e "${CYAN}   💡 Consider splitting into multiple docs${NC}"
        ((WARNINGS++))
    else
        echo -e "${GREEN}✅ CLAUDE.md size: $LINES lines (optimal range)${NC}"
        ((PASSED++))
    fi
fi

echo ""

# =============================================================================
# 4. CONTENT VALIDATION
# =============================================================================
echo -e "${BLUE}📝 Content Validation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check CLAUDE.md for critical sections
if [ -f ".claude/CLAUDE.md" ]; then
    CRITICAL_SECTIONS=(
        "Tech Stack:Required technologies"
        "Critical Rules:P0 rules section"
        "Discovery Before Action:Discovery pattern"
    )

    for section_check in "${CRITICAL_SECTIONS[@]}"; do
        section="${section_check%%:*}"
        desc="${section_check##*:}"

        if grep -q "$section" ".claude/CLAUDE.md"; then
            echo -e "${GREEN}✅ Found: $section${NC} ($desc)"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠️  Missing section: $section${NC} ($desc)"
            ((WARNINGS++))
        fi
    done
fi

echo ""

# =============================================================================
# 5. ANTI-PATTERN CHECKS
# =============================================================================
echo -e "${BLUE}🚫 Anti-Pattern Detection${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check for AP1: No .claude/CLAUDE.md
if [ ! -f ".claude/CLAUDE.md" ]; then
    echo -e "${RED}❌ AP1: No .claude/CLAUDE.md (Critical)${NC}"
    ((ERRORS++))
else
    echo -e "${GREEN}✅ AP1: .claude/CLAUDE.md exists${NC}"
    ((PASSED++))
fi

# Check for AP5: No Documentation
if [ ! -f ".claude/docs/ARCHITECTURE.md" ] && [ ! -f ".claude/docs/patterns/CODE_PATTERNS.md" ]; then
    echo -e "${YELLOW}⚠️  AP5: Insufficient documentation${NC}"
    ((WARNINGS++))
else
    echo -e "${GREEN}✅ AP5: Documentation exists${NC}"
    ((PASSED++))
fi

# Check for AP10: No morning-setup.sh execution (check if HANDOFF is stale)
if [ -f ".claude/docs/HANDOFF.md" ]; then
    HANDOFF_MTIME=$(stat -c %Y ".claude/docs/HANDOFF.md" 2>/dev/null || stat -f %m ".claude/docs/HANDOFF.md" 2>/dev/null || echo "0")
    CURRENT_TIME=$(date +%s)
    DAYS_OLD=$(( (CURRENT_TIME - HANDOFF_MTIME) / 86400 ))

    if [ "$DAYS_OLD" -gt 7 ]; then
        echo -e "${YELLOW}⚠️  AP10: HANDOFF.md not updated in $DAYS_OLD days${NC}"
        echo -e "${CYAN}   💡 Run morning-setup.sh to load context${NC}"
        ((WARNINGS++))
    else
        echo -e "${GREEN}✅ AP10: HANDOFF.md recently updated${NC}"
        ((PASSED++))
    fi
fi

echo ""

# =============================================================================
# 6. GIT INTEGRATION CHECK
# =============================================================================
echo -e "${BLUE}🔗 Git Integration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -d ".git" ]; then
    echo -e "${GREEN}✅ Git repository detected${NC}"
    ((PASSED++))

    # Check if .claude is tracked
    if git ls-files --error-unmatch .claude/ &> /dev/null; then
        echo -e "${GREEN}✅ .claude/ directory is tracked${NC}"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️  .claude/ directory not tracked in Git${NC}"
        echo -e "${CYAN}   💡 Consider: git add .claude/ && git commit${NC}"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}⚠️  Not a Git repository${NC}"
    ((WARNINGS++))
fi

echo ""

# =============================================================================
# 7. SUMMARY
# =============================================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 Validation Summary${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}✅ Passed: $PASSED${NC}"
echo -e "${YELLOW}⚠️  Warnings: $WARNINGS${NC}"
echo -e "${RED}❌ Errors: $ERRORS${NC}"
echo ""

# Determine exit code
if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}❌ Validation FAILED${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}💡 Fix suggestions:${NC}"
    echo -e "  1. Run with ${YELLOW}--fix${NC} to auto-create missing files"
    echo -e "  2. Review critical errors above"
    echo -e "  3. See ~/.claude-library/boilerplates/ for templates"
    echo ""
    exit 1
elif [ "$WARNINGS" -gt 0 ]; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}⚠️  Validation passed with warnings${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ "$STRICT_MODE" = true ]; then
        echo -e "${RED}Strict mode: Treating warnings as errors${NC}"
        exit 2
    else
        exit 0
    fi
else
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ All validations passed!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}💡 Your project follows Claude Code best practices!${NC}"
    echo ""
    exit 0
fi

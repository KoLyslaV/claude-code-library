#!/usr/bin/env bash

# Pre-commit hook to validate changed example projects
# This runs structure validation only on examples that have changed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIBRARY_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get list of changed example directories
CHANGED_EXAMPLES=$(git diff --cached --name-only --diff-filter=ACM | grep "^examples/" | cut -d/ -f2 | sort -u)

if [ -z "$CHANGED_EXAMPLES" ]; then
    echo -e "${GREEN}✓${NC} No example changes to validate"
    exit 0
fi

echo -e "${YELLOW}Validating changed examples...${NC}"

VALIDATION_FAILED=0

for example in $CHANGED_EXAMPLES; do
    EXAMPLE_PATH="$LIBRARY_ROOT/examples/$example"

    if [ ! -d "$EXAMPLE_PATH" ]; then
        continue
    fi

    # Determine example type
    TYPE=""
    if [ -f "$EXAMPLE_PATH/next.config.ts" ] || [ -f "$EXAMPLE_PATH/next.config.js" ]; then
        TYPE="webapp"
    elif [ -f "$EXAMPLE_PATH/astro.config.mjs" ]; then
        TYPE="website"
    elif [ -f "$EXAMPLE_PATH/pyproject.toml" ]; then
        TYPE="python-cli"
    fi

    if [ -z "$TYPE" ]; then
        echo -e "${YELLOW}⊘${NC} Skipping $example (unknown type)"
        continue
    fi

    echo -e "\n${YELLOW}▶${NC} Validating $example ($TYPE)..."

    # Run validation
    if "$LIBRARY_ROOT/scripts/validate-project-structure.sh" "$EXAMPLE_PATH" "$TYPE" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $example structure is valid"
    else
        echo -e "${RED}✗${NC} $example structure validation failed"
        VALIDATION_FAILED=1
    fi

    # Check README exists
    if [ ! -f "$EXAMPLE_PATH/README.md" ]; then
        echo -e "${RED}✗${NC} $example missing README.md"
        VALIDATION_FAILED=1
    else
        echo -e "${GREEN}✓${NC} $example README.md exists"
    fi

    # Check for template variables
    if grep -r "{{PROJECT_NAME}}" "$EXAMPLE_PATH" --exclude-dir=node_modules --exclude-dir=.git 2>/dev/null; then
        echo -e "${RED}✗${NC} $example contains unreplaced template variables"
        VALIDATION_FAILED=1
    else
        echo -e "${GREEN}✓${NC} $example has no template variables"
    fi
done

if [ $VALIDATION_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✓ All changed examples validated successfully${NC}"
    exit 0
else
    echo -e "\n${RED}✗ Some example validations failed${NC}"
    exit 1
fi

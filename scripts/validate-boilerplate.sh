#!/bin/bash

# validate-boilerplate.sh - Validate boilerplate structure
# Usage: ./scripts/validate-boilerplate.sh boilerplates/<name>

set -e

BOILERPLATE_DIR="$1"

if [ -z "$BOILERPLATE_DIR" ]; then
    echo "❌ ERROR: Boilerplate directory not specified"
    echo "Usage: $0 <boilerplate-directory>"
    exit 1
fi

if [ ! -d "$BOILERPLATE_DIR" ]; then
    echo "❌ ERROR: Directory does not exist: $BOILERPLATE_DIR"
    exit 1
fi

BOILERPLATE_NAME=$(basename "$BOILERPLATE_DIR")
echo "Validating boilerplate: $BOILERPLATE_NAME"

# Check for required files
REQUIRED_FILES=(
    "README.md"
    ".claude/CLAUDE.md"
    ".claude/docs/TODO.md"
    ".claude/docs/HANDOFF.md"
)

ERRORS=0

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$BOILERPLATE_DIR/$file" ]; then
        echo "❌ Missing required file: $file"
        ERRORS=$((ERRORS + 1))
    else
        echo "✓ Found: $file"
    fi
done

# Type-specific validation
case "$BOILERPLATE_NAME" in
    "webapp-boilerplate")
        echo "Validating webapp boilerplate..."
        WEBAPP_FILES=(
            "package.json"
            "tsconfig.json"
            "next.config.ts"
            "prisma/schema.prisma"
        )
        for file in "${WEBAPP_FILES[@]}"; do
            if [ ! -f "$BOILERPLATE_DIR/$file" ]; then
                echo "❌ Missing webapp file: $file"
                ERRORS=$((ERRORS + 1))
            else
                echo "✓ Found: $file"
            fi
        done
        ;;
    "website-boilerplate")
        echo "Validating website boilerplate..."
        WEBSITE_FILES=(
            "package.json"
            "tsconfig.json"
            "astro.config.mjs"
        )
        for file in "${WEBSITE_FILES[@]}"; do
            if [ ! -f "$BOILERPLATE_DIR/$file" ]; then
                echo "❌ Missing website file: $file"
                ERRORS=$((ERRORS + 1))
            else
                echo "✓ Found: $file"
            fi
        done
        ;;
    "python-cli-boilerplate")
        echo "Validating python-cli boilerplate..."
        PYTHON_FILES=(
            "pyproject.toml"
        )
        for file in "${PYTHON_FILES[@]}"; do
            if [ ! -f "$BOILERPLATE_DIR/$file" ]; then
                echo "❌ Missing python-cli file: $file"
                ERRORS=$((ERRORS + 1))
            else
                echo "✓ Found: $file"
            fi
        done
        ;;
esac

if [ $ERRORS -eq 0 ]; then
    echo "✅ Boilerplate validation passed: $BOILERPLATE_NAME"
    exit 0
else
    echo "❌ Boilerplate validation failed with $ERRORS errors"
    exit 1
fi

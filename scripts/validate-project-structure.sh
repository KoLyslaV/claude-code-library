#!/bin/bash

# validate-project-structure.sh - Validate example project structure
# Usage: ./scripts/validate-project-structure.sh examples/<name> <type>

set -e

PROJECT_DIR="$1"
PROJECT_TYPE="$2"

if [ -z "$PROJECT_DIR" ] || [ -z "$PROJECT_TYPE" ]; then
    echo "❌ ERROR: Missing required arguments"
    echo "Usage: $0 <project-directory> <type>"
    echo "Types: webapp, website, python-cli"
    exit 1
fi

if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ ERROR: Directory does not exist: $PROJECT_DIR"
    exit 1
fi

PROJECT_NAME=$(basename "$PROJECT_DIR")
echo "Validating project: $PROJECT_NAME (type: $PROJECT_TYPE)"

# Check for required files
REQUIRED_FILES=(
    "README.md"
)

ERRORS=0

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$PROJECT_DIR/$file" ]; then
        echo "❌ Missing required file: $file"
        ERRORS=$((ERRORS + 1))
    else
        echo "✓ Found: $file"
    fi
done

# Type-specific validation
case "$PROJECT_TYPE" in
    "webapp")
        echo "Validating webapp project..."
        WEBAPP_FILES=(
            "package.json"
            "tsconfig.json"
            "next.config.ts"
            "src/app/page.tsx"
        )
        for file in "${WEBAPP_FILES[@]}"; do
            if [ ! -f "$PROJECT_DIR/$file" ]; then
                echo "❌ Missing webapp file: $file"
                ERRORS=$((ERRORS + 1))
            else
                echo "✓ Found: $file"
            fi
        done
        ;;
    "website")
        echo "Validating website project..."
        WEBSITE_FILES=(
            "package.json"
            "tsconfig.json"
            "astro.config.mjs"
            "src/pages/index.astro"
        )
        for file in "${WEBSITE_FILES[@]}"; do
            if [ ! -f "$PROJECT_DIR/$file" ]; then
                echo "❌ Missing website file: $file"
                ERRORS=$((ERRORS + 1))
            else
                echo "✓ Found: $file"
            fi
        done
        ;;
    "python-cli")
        echo "Validating python-cli project..."
        PYTHON_FILES=(
            "pyproject.toml"
        )
        for file in "${PYTHON_FILES[@]}"; do
            if [ ! -f "$PROJECT_DIR/$file" ]; then
                echo "❌ Missing python-cli file: $file"
                ERRORS=$((ERRORS + 1))
            else
                echo "✓ Found: $file"
            fi
        done
        # Check for source directory
        if [ ! -d "$PROJECT_DIR/src" ]; then
            echo "❌ Missing src directory"
            ERRORS=$((ERRORS + 1))
        else
            echo "✓ Found: src directory"
        fi
        ;;
    *)
        echo "❌ ERROR: Unknown project type: $PROJECT_TYPE"
        exit 1
        ;;
esac

if [ $ERRORS -eq 0 ]; then
    echo "✅ Project structure validation passed: $PROJECT_NAME"
    exit 0
else
    echo "❌ Project structure validation failed with $ERRORS errors"
    exit 1
fi

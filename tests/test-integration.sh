#!/usr/bin/env bash

# Integration tests for Claude Code Library scripts
# Tests interactions between different scripts and workflows

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test output
print_test_header() {
    echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}$1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_section() {
    echo -e "\n${YELLOW}▶ $1${NC}"
}

pass() {
    ((TESTS_PASSED++)) || :
    echo -e "${GREEN}✓ PASS${NC}: $1"
}

fail() {
    ((TESTS_FAILED++)) || :
    echo -e "${RED}✗ FAIL${NC}: $1"
}

((TESTS_RUN++)) 2>/dev/null || :

# Setup test environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIBRARY_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_TEMP_DIR="${TMPDIR:-/tmp}/claude-lib-integration-tests-$$"
mkdir -p "$TEST_TEMP_DIR"

# Cleanup function
cleanup() {
    if [ -d "$TEST_TEMP_DIR" ]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}
trap cleanup EXIT

print_test_header "Claude Code Library Integration Tests"

# ============================================================================
# TEST SUITE 1: init-project.sh + validate-boilerplate.sh
# ============================================================================

print_section "Testing init-project.sh creates valid webapp structure"
((TESTS_RUN++))

WEBAPP_TEST_DIR="$TEST_TEMP_DIR/test-webapp-init"
mkdir -p "$WEBAPP_TEST_DIR"

# Create temporary files for capturing stderr
INIT_STDERR="$TEST_TEMP_DIR/init-stderr.txt"
VALIDATE_STDERR="$TEST_TEMP_DIR/validate-stderr.txt"

# Initialize a webapp project (skip deps for faster CI testing)
echo "  → Running init-project.sh for webapp..." >&2
"$LIBRARY_ROOT/scripts/init-project.sh" --skip-deps webapp "$WEBAPP_TEST_DIR/my-webapp" "Test Webapp" >/dev/null 2>"$INIT_STDERR"
INIT_EXIT_CODE=$?

if [ $INIT_EXIT_CODE -ne 0 ]; then
    fail "Failed to initialize webapp project (exit code: $INIT_EXIT_CODE)"
    echo "  → init-project.sh stderr:" >&2
    cat "$INIT_STDERR" >&2
    echo "" >&2
else
    # Checkpoint: Verify directory was created
    if [ ! -d "$WEBAPP_TEST_DIR/my-webapp" ]; then
        fail "Webapp directory was not created: $WEBAPP_TEST_DIR/my-webapp"
    else
        echo "  ✓ Webapp directory created" >&2

        # Checkpoint: Verify key files exist
        if [ ! -f "$WEBAPP_TEST_DIR/my-webapp/package.json" ]; then
            fail "package.json not found in webapp"
            echo "  → Files in project:" >&2
            ls -la "$WEBAPP_TEST_DIR/my-webapp" >&2 || true
        else
            echo "  ✓ package.json found" >&2

            # Validate the created project using validation script
            echo "  → Directory state before validation:" >&2
            echo "    - Path: $WEBAPP_TEST_DIR/my-webapp" >&2
            echo "    - Exists: $([ -d "$WEBAPP_TEST_DIR/my-webapp" ] && echo YES || echo NO)" >&2
            echo "    - Files count: $(find "$WEBAPP_TEST_DIR/my-webapp" -type f 2>/dev/null | wc -l)" >&2
            echo "  → Running validate-project-structure.sh..." >&2
            set +e  # Temporarily disable exit on error to capture exit code
            "$LIBRARY_ROOT/scripts/validate-project-structure.sh" "$WEBAPP_TEST_DIR/my-webapp" webapp 2>&1 | tee "$VALIDATE_STDERR" >&2
            VALIDATE_EXIT_CODE=${PIPESTATUS[0]}
            set -e  # Re-enable exit on error
            echo "  → Validation exit code: $VALIDATE_EXIT_CODE" >&2
            echo "  → Checking if exit code is non-zero..." >&2

            if [ "$VALIDATE_EXIT_CODE" -ne 0 ]; then
                fail "Initialized webapp fails structure validation (exit code: $VALIDATE_EXIT_CODE)"
                echo "  → validate-project-structure.sh output:" >&2
                cat "$VALIDATE_STDERR" >&2
                echo "" >&2
            else
                pass "Initialized webapp passes structure validation"
            fi
        fi
    fi
fi

# TODO: Re-enable when website boilerplate is implemented (Phase 3)
# print_section "Testing init-project.sh creates valid website structure"
# ((TESTS_RUN++))
# echo "  ⊘ SKIPPED: website boilerplate not yet implemented" >&2

# TODO: Re-enable when python-cli boilerplate is implemented (Phase 3)
# print_section "Testing init-project.sh creates valid python-cli structure"
# ((TESTS_RUN++))
# echo "  ⊘ SKIPPED: python-cli boilerplate not yet implemented" >&2

# ============================================================================
# TEST SUITE 2: init-project.sh + validate-project-structure.sh
# ============================================================================

print_section "Testing initialized webapp passes project structure validation"
((TESTS_RUN++))

if [ -d "$WEBAPP_TEST_DIR/my-webapp" ]; then
    # Run structure validation on initialized project
    if "$LIBRARY_ROOT/scripts/validate-project-structure.sh" "$WEBAPP_TEST_DIR/my-webapp" webapp >/dev/null 2>&1; then
        pass "Initialized webapp passes structure validation"
    else
        fail "Initialized webapp fails structure validation"
    fi
else
    fail "Webapp test directory not found"
fi

# TODO: Re-enable when website boilerplate is implemented (Phase 3)
# print_section "Testing initialized website passes project structure validation"
# ((TESTS_RUN++))
# echo "  ⊘ SKIPPED: website boilerplate not yet implemented" >&2

# TODO: Re-enable when python-cli boilerplate is implemented (Phase 3)
# print_section "Testing initialized python-cli passes project structure validation"
# ((TESTS_RUN++))
# echo "  ⊘ SKIPPED: python-cli boilerplate not yet implemented" >&2

# ============================================================================
# TEST SUITE 3: Template Variable Replacement
# ============================================================================

print_section "Testing template variables are replaced in webapp"
((TESTS_RUN++))

if [ -f "$WEBAPP_TEST_DIR/my-webapp/package.json" ]; then
    # Check that {{PROJECT_NAME}} is replaced
    if ! grep -q "{{PROJECT_NAME}}" "$WEBAPP_TEST_DIR/my-webapp/package.json"; then
        pass "Template variables replaced in webapp package.json"
    else
        fail "Template variables not replaced in webapp package.json"
    fi
else
    fail "Webapp package.json not found"
fi

# TODO: Re-enable when website boilerplate is implemented (Phase 3)
# print_section "Testing template variables are replaced in website"
# ((TESTS_RUN++))
# echo "  ⊘ SKIPPED: website boilerplate not yet implemented" >&2

# TODO: Re-enable when python-cli boilerplate is implemented (Phase 3)
# print_section "Testing template variables are replaced in python-cli"
# ((TESTS_RUN++))
# echo "  ⊘ SKIPPED: python-cli boilerplate not yet implemented" >&2

# ============================================================================
# TEST SUITE 4: Full Workflow - Init + Validate + Check Examples
# ============================================================================

print_section "Testing full workflow: init webapp → validate → compare with example"
((TESTS_RUN++))

FULL_WEBAPP_DIR="$TEST_TEMP_DIR/full-workflow-webapp"
mkdir -p "$FULL_WEBAPP_DIR"

if "$LIBRARY_ROOT/scripts/init-project.sh" webapp "$FULL_WEBAPP_DIR/task-app" "Task Manager" >/dev/null 2>&1; then
    # Validate structure
    if "$LIBRARY_ROOT/scripts/validate-project-structure.sh" "$FULL_WEBAPP_DIR/task-app" webapp >/dev/null 2>&1; then
        # Check key files match example structure (not content, just existence)
        EXAMPLE_DIR="$LIBRARY_ROOT/examples/webapp-example"
        if [ -f "$EXAMPLE_DIR/package.json" ] && \
           [ -f "$FULL_WEBAPP_DIR/task-app/package.json" ] && \
           [ -f "$EXAMPLE_DIR/prisma/schema.prisma" ] && \
           [ -f "$FULL_WEBAPP_DIR/task-app/prisma/schema.prisma" ]; then
            pass "Full workflow: webapp init → validate → matches example structure"
        else
            fail "Full workflow: webapp missing files compared to example"
        fi
    else
        fail "Full workflow: webapp validation failed"
    fi
else
    fail "Full workflow: webapp initialization failed"
fi

# TODO: Re-enable when website boilerplate is implemented (Phase 3)
# print_section "Testing full workflow: init website → validate → compare with example"
# ((TESTS_RUN++))
# echo "  ⊘ SKIPPED: website boilerplate not yet implemented" >&2

# TODO: Re-enable when python-cli boilerplate is implemented (Phase 3)
# print_section "Testing full workflow: init python-cli → validate → compare with example"
# ((TESTS_RUN++))
# echo "  ⊘ SKIPPED: python-cli boilerplate not yet implemented" >&2

# ============================================================================
# TEST SUITE 5: Claude-lib CLI Integration
# ============================================================================

print_section "Testing claude-lib CLI can initialize and validate projects"
((TESTS_RUN++))

CLI_INTEGRATION_DIR="$TEST_TEMP_DIR/cli-integration"
mkdir -p "$CLI_INTEGRATION_DIR"

# Test claude-lib CLI if it exists
if command -v claude-lib >/dev/null 2>&1; then
    # Initialize project using CLI
    if claude-lib init webapp "$CLI_INTEGRATION_DIR/cli-webapp" "CLI Test" >/dev/null 2>&1; then
        # Validate using validation script
        if "$LIBRARY_ROOT/scripts/validate-project-structure.sh" "$CLI_INTEGRATION_DIR/cli-webapp" webapp >/dev/null 2>&1; then
            pass "CLI integration: claude-lib init creates valid project"
        else
            fail "CLI integration: claude-lib project fails validation"
        fi
    else
        fail "CLI integration: claude-lib init failed"
    fi
else
    echo -e "${YELLOW}⊘ SKIP${NC}: claude-lib CLI not found (optional test)"
fi

# ============================================================================
# TEST SUITE 6: Cross-Validation Between Boilerplate and Examples
# ============================================================================

print_section "Testing webapp example matches webapp boilerplate structure"
((TESTS_RUN++))

WEBAPP_BOILERPLATE="$LIBRARY_ROOT/boilerplates/webapp-boilerplate"
WEBAPP_EXAMPLE="$LIBRARY_ROOT/examples/webapp-example"

if [ -d "$WEBAPP_BOILERPLATE" ] && [ -d "$WEBAPP_EXAMPLE" ]; then
    # Check that example has same core structure as boilerplate
    STRUCTURE_MATCH=true

    # Check key directories
    for dir in "src/app" "src/components" "src/lib" "prisma"; do
        if [ -d "$WEBAPP_BOILERPLATE/$dir" ] && [ ! -d "$WEBAPP_EXAMPLE/$dir" ]; then
            STRUCTURE_MATCH=false
            break
        fi
    done

    # Check key files
    for file in "package.json" "next.config.ts" "tsconfig.json" ".env.example"; do
        if [ -f "$WEBAPP_BOILERPLATE/$file" ] && [ ! -f "$WEBAPP_EXAMPLE/$file" ]; then
            STRUCTURE_MATCH=false
            break
        fi
    done

    if [ "$STRUCTURE_MATCH" = true ]; then
        pass "Webapp example matches boilerplate structure"
    else
        fail "Webapp example missing files from boilerplate"
    fi
else
    fail "Webapp boilerplate or example directory not found"
fi

print_section "Testing website example matches website boilerplate structure"
((TESTS_RUN++))

WEBSITE_BOILERPLATE="$LIBRARY_ROOT/boilerplates/website-boilerplate"
WEBSITE_EXAMPLE="$LIBRARY_ROOT/examples/website-example"

if [ -d "$WEBSITE_BOILERPLATE" ] && [ -d "$WEBSITE_EXAMPLE" ]; then
    STRUCTURE_MATCH=true

    # Check key directories
    for dir in "src/content" "src/layouts" "src/pages" "public"; do
        if [ -d "$WEBSITE_BOILERPLATE/$dir" ] && [ ! -d "$WEBSITE_EXAMPLE/$dir" ]; then
            STRUCTURE_MATCH=false
            break
        fi
    done

    # Check key files
    for file in "package.json" "astro.config.mjs" "tsconfig.json"; do
        if [ -f "$WEBSITE_BOILERPLATE/$file" ] && [ ! -f "$WEBSITE_EXAMPLE/$file" ]; then
            STRUCTURE_MATCH=false
            break
        fi
    done

    if [ "$STRUCTURE_MATCH" = true ]; then
        pass "Website example matches boilerplate structure"
    else
        fail "Website example missing files from boilerplate"
    fi
else
    fail "Website boilerplate or example directory not found"
fi

print_section "Testing python-cli example matches python-cli boilerplate structure"
((TESTS_RUN++))

CLI_BOILERPLATE="$LIBRARY_ROOT/boilerplates/python-cli-boilerplate"
CLI_EXAMPLE="$LIBRARY_ROOT/examples/python-cli-example"

if [ -d "$CLI_BOILERPLATE" ] && [ -d "$CLI_EXAMPLE" ]; then
    STRUCTURE_MATCH=true

    # Check key directories - Note: src/{{PROJECT_NAME}} in boilerplate, src/todocli in example
    if [ -d "$CLI_BOILERPLATE/src" ] && [ ! -d "$CLI_EXAMPLE/src" ]; then
        STRUCTURE_MATCH=false
    fi

    if [ -d "$CLI_BOILERPLATE/tests" ] && [ ! -d "$CLI_EXAMPLE/tests" ]; then
        STRUCTURE_MATCH=false
    fi

    # Check key files
    for file in "pyproject.toml" "README.md"; do
        if [ -f "$CLI_BOILERPLATE/$file" ] && [ ! -f "$CLI_EXAMPLE/$file" ]; then
            STRUCTURE_MATCH=false
            break
        fi
    done

    if [ "$STRUCTURE_MATCH" = true ]; then
        pass "Python-cli example matches boilerplate structure"
    else
        fail "Python-cli example missing files from boilerplate"
    fi
else
    fail "Python-cli boilerplate or example directory not found"
fi

# ============================================================================
# TEST SUITE 7: Error Handling and Edge Cases
# ============================================================================

print_section "Testing init-project.sh handles invalid boilerplate type"
((TESTS_RUN++))

INVALID_TYPE_DIR="$TEST_TEMP_DIR/invalid-type-test"
mkdir -p "$INVALID_TYPE_DIR"

if "$LIBRARY_ROOT/scripts/init-project.sh" invalid-type "$INVALID_TYPE_DIR/test" "Test" 2>/dev/null; then
    fail "init-project.sh should fail with invalid boilerplate type"
else
    pass "init-project.sh correctly rejects invalid boilerplate type"
fi

print_section "Testing init-project.sh handles existing directory"
((TESTS_RUN++))

EXISTING_DIR="$TEST_TEMP_DIR/existing-dir-test/myproject"
mkdir -p "$EXISTING_DIR"
echo "existing content" > "$EXISTING_DIR/file.txt"

# Try to initialize in existing directory (should fail or warn)
if "$LIBRARY_ROOT/scripts/init-project.sh" webapp "$EXISTING_DIR" "Test" 2>/dev/null; then
    # Check if it preserved existing content or failed
    if [ -f "$EXISTING_DIR/file.txt" ]; then
        pass "init-project.sh handles existing directory safely"
    else
        fail "init-project.sh overwrote existing directory content"
    fi
else
    pass "init-project.sh correctly rejects existing directory"
fi

print_section "Testing validate-project-structure.sh handles missing directories"
((TESTS_RUN++))

MISSING_DIR="$TEST_TEMP_DIR/nonexistent-project"

if "$LIBRARY_ROOT/scripts/validate-project-structure.sh" "$MISSING_DIR" webapp 2>/dev/null; then
    fail "validate-project-structure.sh should fail for missing directory"
else
    pass "validate-project-structure.sh correctly rejects missing directory"
fi

# ============================================================================
# TEST SUMMARY
# ============================================================================

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Integration Test Summary${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Total tests run: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✓ All integration tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}✗ Some integration tests failed${NC}"
    exit 1
fi

#!/bin/bash
# test-runner.sh - Test runner for Claude Code Library
# Usage: ./test-runner.sh [test-file] [--verbose]
# Runs all tests or specific test file

set -e

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIBRARY_ROOT="$(dirname "$TESTS_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test statistics
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

VERBOSE=false
SPECIFIC_TEST=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            cat << EOF
${CYAN}Test Runner for Claude Code Library${NC}

${YELLOW}USAGE:${NC}
  $0 [test-file] [options]

${YELLOW}OPTIONS:${NC}
  --verbose, -v    Verbose output
  --help, -h       Show this help

${YELLOW}EXAMPLES:${NC}
  $0                           # Run all tests
  $0 test-init-project.sh      # Run specific test
  $0 --verbose                 # Run with verbose output

EOF
            exit 0
            ;;
        *)
            if [ -z "$SPECIFIC_TEST" ]; then
                SPECIFIC_TEST="$1"
            fi
            shift
            ;;
    esac
done

# Test assertion functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    ((TESTS_RUN++))

    if [ "$expected" = "$actual" ]; then
        ((TESTS_PASSED++))
        if [ "$VERBOSE" = true ]; then
            echo -e "  ${GREEN}✓${NC} $message"
        fi
        return 0
    else
        ((TESTS_FAILED++))
        echo -e "  ${RED}✗${NC} $message"
        echo -e "    Expected: ${YELLOW}$expected${NC}"
        echo -e "    Actual:   ${YELLOW}$actual${NC}"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"

    ((TESTS_RUN++))

    if [ -f "$file" ]; then
        ((TESTS_PASSED++))
        if [ "$VERBOSE" = true ]; then
            echo -e "  ${GREEN}✓${NC} $message"
        fi
        return 0
    else
        ((TESTS_FAILED++))
        echo -e "  ${RED}✗${NC} $message"
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    local message="${2:-Directory should exist: $dir}"

    ((TESTS_RUN++))

    if [ -d "$dir" ]; then
        ((TESTS_PASSED++))
        if [ "$VERBOSE" = true ]; then
            echo -e "  ${GREEN}✓${NC} $message"
        fi
        return 0
    else
        ((TESTS_FAILED++))
        echo -e "  ${RED}✗${NC} $message"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should contain: $needle}"

    ((TESTS_RUN++))

    if [[ "$haystack" == *"$needle"* ]]; then
        ((TESTS_PASSED++))
        if [ "$VERBOSE" = true ]; then
            echo -e "  ${GREEN}✓${NC} $message"
        fi
        return 0
    else
        ((TESTS_FAILED++))
        echo -e "  ${RED}✗${NC} $message"
        echo -e "    Haystack: ${YELLOW}$haystack${NC}"
        echo -e "    Needle:   ${YELLOW}$needle${NC}"
        return 1
    fi
}

assert_command_succeeds() {
    local command="$1"
    local message="${2:-Command should succeed: $command}"

    ((TESTS_RUN++))

    if eval "$command" > /dev/null 2>&1; then
        ((TESTS_PASSED++))
        if [ "$VERBOSE" = true ]; then
            echo -e "  ${GREEN}✓${NC} $message"
        fi
        return 0
    else
        ((TESTS_FAILED++))
        echo -e "  ${RED}✗${NC} $message"
        return 1
    fi
}

assert_command_fails() {
    local command="$1"
    local message="${2:-Command should fail: $command}"

    ((TESTS_RUN++))

    if ! eval "$command" > /dev/null 2>&1; then
        ((TESTS_PASSED++))
        if [ "$VERBOSE" = true ]; then
            echo -e "  ${GREEN}✓${NC} $message"
        fi
        return 0
    else
        ((TESTS_FAILED++))
        echo -e "  ${RED}✗${NC} $message"
        return 1
    fi
}

skip_test() {
    local reason="$1"
    ((TESTS_SKIPPED++))
    echo -e "  ${YELLOW}⊘${NC} Skipped: $reason"
}

# Setup and teardown helpers
setup_test_env() {
    TEST_TEMP_DIR=$(mktemp -d)
    export TEST_TEMP_DIR
    export LIBRARY_ROOT
    export TESTS_DIR
}

teardown_test_env() {
    if [ -n "$TEST_TEMP_DIR" ] && [ -d "$TEST_TEMP_DIR" ]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Run a test file
run_test_file() {
    local test_file="$1"
    local test_name
    test_name=$(basename "$test_file" .sh)

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📝 Running: $test_name${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Source test file
    # shellcheck disable=SC1090
    source "$test_file"

    # Run setup if defined
    if declare -f setup > /dev/null; then
        setup
    fi

    # Find and run all test functions
    local test_functions
    test_functions=$(declare -F | grep -o "test_[^ ]*" || true)

    if [ -z "$test_functions" ]; then
        echo -e "${YELLOW}  No test functions found${NC}"
        return
    fi

    for test_func in $test_functions; do
        if [ "$VERBOSE" = true ]; then
            echo -e "\n${BLUE}Running: $test_func${NC}"
        fi

        setup_test_env

        # Run test function
        if $test_func; then
            if [ "$VERBOSE" = false ]; then
                echo -e "  ${GREEN}✓${NC} $test_func"
            fi
        else
            if [ "$VERBOSE" = false ]; then
                echo -e "  ${RED}✗${NC} $test_func failed"
            fi
        fi

        teardown_test_env
    done

    # Run teardown if defined
    if declare -f teardown > /dev/null; then
        teardown
    fi
}

# Print summary
print_summary() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📊 Test Summary${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  Total tests:  $TESTS_RUN"
    echo -e "  ${GREEN}Passed:       $TESTS_PASSED${NC}"
    echo -e "  ${RED}Failed:       $TESTS_FAILED${NC}"
    echo -e "  ${YELLOW}Skipped:      $TESTS_SKIPPED${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✨ All tests passed!${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        return 0
    else
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}❌ Some tests failed${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        return 1
    fi
}

# Main execution
main() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🧪 Claude Code Library Test Runner${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Check if running specific test
    if [ -n "$SPECIFIC_TEST" ]; then
        if [ -f "$TESTS_DIR/$SPECIFIC_TEST" ]; then
            run_test_file "$TESTS_DIR/$SPECIFIC_TEST"
        elif [ -f "$SPECIFIC_TEST" ]; then
            run_test_file "$SPECIFIC_TEST"
        else
            echo -e "${RED}Test file not found: $SPECIFIC_TEST${NC}"
            exit 1
        fi
    else
        # Run all test files
        local test_files
        test_files=$(find "$TESTS_DIR" -name "test-*.sh" | sort)

        if [ -z "$test_files" ]; then
            echo -e "${YELLOW}No test files found in $TESTS_DIR${NC}"
            exit 0
        fi

        for test_file in $test_files; do
            run_test_file "$test_file"
        done
    fi

    print_summary
}

# Export functions for test files
export -f assert_equals
export -f assert_file_exists
export -f assert_dir_exists
export -f assert_contains
export -f assert_command_succeeds
export -f assert_command_fails
export -f skip_test
export -f setup_test_env
export -f teardown_test_env

# Run main
main "$@"

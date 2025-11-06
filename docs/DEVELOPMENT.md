# Development Guide - Claude Code Library

This guide provides comprehensive development practices, coding patterns, and technical details for contributors to Claude Code Library.

---

## 📋 Table of Contents

1. [Development Environment Setup](#development-environment-setup)
2. [Project Architecture](#project-architecture)
3. [Bash Scripting Best Practices](#bash-scripting-best-practices)
4. [Testing Methodology](#testing-methodology)
5. [Debugging Techniques](#debugging-techniques)
6. [Common Patterns](#common-patterns)
7. [Tool Usage](#tool-usage)
8. [Performance Optimization](#performance-optimization)
9. [Security Considerations](#security-considerations)
10. [Troubleshooting](#troubleshooting)

---

## 🛠️ Development Environment Setup

### Prerequisites

**Required:**
- Bash 4.0+ (check: `bash --version`)
- Git 2.20+ (check: `git --version`)
- Node.js 18+ (for webapp/website boilerplates)
- Python 3.10+ (for python-cli boilerplate)

**Optional but Recommended:**
- ShellCheck (for bash linting)
- GitHub CLI (`gh` command)
- Docker (for CI environment testing)

### Installation

```bash
# Clone repository
git clone https://github.com/KoLyslaV/claude-code-library.git
cd claude-code-library

# Install pre-commit hooks
./scripts/setup-pre-commit.sh

# Verify setup
./tests/test-runner.sh
```

### IDE Configuration

#### VS Code
```json
{
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "files.eol": "\n",
  "shellcheck.enable": true,
  "shellcheck.run": "onSave",
  "[shellscript]": {
    "editor.defaultFormatter": "foxundermoon.shell-format"
  }
}
```

#### Vim/Neovim
```vim
" In your .vimrc or init.vim
autocmd FileType sh setlocal tabstop=2 shiftwidth=2 expandtab
autocmd BufWritePost *.sh !shellcheck %
```

---

## 🏗️ Project Architecture

### Directory Structure

```
claude-code-library/
├── .claude/                    # Development documentation
│   └── CLAUDE.md              # Main development guide
├── .github/
│   └── workflows/              # CI/CD automation
│       ├── ci.yml             # Main pipeline
│       ├── build-examples.yml
│       ├── release.yml
│       └── maintenance.yml
├── boilerplates/               # Template projects
│   ├── webapp-boilerplate/    # Next.js 15 + React 19
│   ├── website-boilerplate/   # Astro 5.0
│   └── python-cli-boilerplate/ # Python CLI
├── examples/                   # Working examples
│   ├── webapp-example/
│   ├── website-example/
│   └── python-cli-example/
├── scripts/                    # Automation scripts
│   ├── init-project.sh        # Main initialization
│   ├── validate-*.sh          # Validation scripts
│   ├── morning-setup.sh       # Dev workflow
│   ├── feature-workflow.sh
│   ├── bug-hunter.sh
│   ├── doc-sprint.sh
│   ├── anti-pattern-detector.sh
│   └── crisis-mode.sh
├── tests/                      # Test suites
│   ├── test-integration.sh
│   ├── test-boilerplate-integrity.sh
│   ├── test-library-structure.sh
│   ├── test-claude-lib-cli.sh
│   └── test-runner.sh
└── docs/                       # Documentation
    ├── DEVELOPMENT.md         # This file
    ├── LESSONS_LEARNED.md     # Debugging experiences
    └── API.md                 # Script APIs
```

### Key Components

#### 1. Boilerplates
Template projects that users can initialize from. Must contain:
- Template variables: `{{PROJECT_NAME}}`, `{{PROJECT_NAME_PASCAL}}`, `{{DATE}}`
- Complete project structure
- Working configuration files
- README with setup instructions

#### 2. Examples
Fully implemented projects demonstrating boilerplate usage. Must contain:
- Real functionality (not just placeholders)
- Comprehensive README
- Implementation guide
- Best practices demonstrated

#### 3. Scripts
Automation tools for project management:
- `init-project.sh` - Creates new projects from boilerplates
- `validate-*.sh` - Validates project structure
- Workflow helpers - Morning setup, feature development, etc.

#### 4. Tests
Comprehensive test suites:
- Integration tests - Full workflow testing
- Unit tests - Component-level testing
- Structural tests - Directory/file validation
- CLI tests - Command-line interface testing

---

## 🐚 Bash Scripting Best Practices

### Script Template

```bash
#!/bin/bash

# Script name and description
# Purpose: Describe what this script does
# Usage: script.sh [options] <arguments>

set -e          # Exit on error
set -u          # Error on undefined variable
set -o pipefail # Pipe fails if any command fails

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly SCRIPT_NAME="$(basename "$0")"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Functions
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [options] <arguments>

Description of what this script does.

Options:
  -h, --help     Show this help message
  -v, --verbose  Enable verbose output
  -d, --debug    Enable debug mode

Arguments:
  arg1           Description of argument 1
  arg2           Description of argument 2

Examples:
  $SCRIPT_NAME --verbose arg1 arg2
  $SCRIPT_NAME -h

EOF
    exit 1
}

error() {
    echo -e "${RED}ERROR:${NC} $1" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}WARNING:${NC} $1" >&2
}

info() {
    echo -e "${GREEN}INFO:${NC} $1" >&2
}

debug() {
    if [ "${DEBUG:-0}" -eq 1 ]; then
        echo -e "DEBUG: $1" >&2
    fi
}

# Main logic
main() {
    # Parse arguments
    local verbose=0
    local debug=0

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                ;;
            -v|--verbose)
                verbose=1
                shift
                ;;
            -d|--debug)
                debug=1
                DEBUG=1
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    # Validate arguments
    if [ $# -lt 2 ]; then
        error "Missing required arguments"
    fi

    local arg1="$1"
    local arg2="$2"

    # Main script logic here
    info "Starting process..."

    # ... your code ...

    info "Process completed successfully"
}

# Run main function
main "$@"
exit 0
```

### Critical Patterns

#### 1. Arithmetic Expressions with `set -e`

**ALWAYS use `|| :` with arithmetic expressions:**

```bash
# ❌ WRONG - Will exit when counter is 0
((counter++))

# ✅ CORRECT - Prevents exit
((counter++)) || :

# ✅ ALSO CORRECT - Alternative patterns
: $((counter++))
((++counter))  # Pre-increment returns new value
let counter++ || :
```

**Why:** Post-increment returns old value (0 when counter=0), which with `set -e` triggers exit.

#### 2. Exit Code Handling

```bash
# ❌ WRONG - Exit code gets overwritten
command
echo "Exit code: $?"  # $? is now exit code of echo!

# ✅ CORRECT - Capture immediately
command
local exit_code=$?
echo "Exit code: $exit_code"

# ✅ ALSO CORRECT - Use set +e/set -e
set +e
command
local exit_code=$?
set -e
```

#### 3. Pipeline Exit Codes

```bash
# ❌ WRONG - Only gets exit code of last command
command1 | command2 | command3
exit_code=$?  # Only exit code of command3!

# ✅ CORRECT - Get first command's exit code
command1 | command2 | command3
exit_code=${PIPESTATUS[0]}

# ✅ ALSO CORRECT - Check all pipeline commands
command1 | command2 | command3
if [ ${PIPESTATUS[0]} -ne 0 ] || [ ${PIPESTATUS[1]} -ne 0 ] || [ ${PIPESTATUS[2]} -ne 0 ]; then
    error "Pipeline failed"
fi
```

#### 4. String Comparison

```bash
# ❌ WRONG - Word splitting issues
if [ $var = "value" ]; then  # Fails if var has spaces

# ✅ CORRECT - Always quote variables
if [ "$var" = "value" ]; then

# ✅ BEST - Use [[ for robust comparison
if [[ $var = "value" ]]; then  # No word splitting in [[

# ✅ ALSO GOOD - Pattern matching in [[
if [[ $var == value* ]]; then  # Glob pattern matching
```

#### 5. Directory Operations

```bash
# ❌ WRONG - Doesn't handle errors
cd /some/path
do_something

# ✅ CORRECT - Check if cd succeeded
cd /some/path || error "Failed to change directory"
do_something

# ✅ BETTER - Use subshell to preserve location
(
    cd /some/path || exit 1
    do_something
) || error "Operation failed"

# ✅ BEST - Explicit error handling
if ! cd /some/path; then
    error "Failed to change to /some/path"
fi
do_something
cd - >/dev/null  # Return to previous directory
```

#### 6. Special Characters

```bash
# ❌ WRONG - History expansion
echo "Success!"  # Triggers history expansion

# ✅ CORRECT - Escape exclamation mark
echo "Success\!"

# ✅ ALSO CORRECT - Use single quotes
echo 'Success!'

# Other special characters to watch:
echo "Dollar: \$"    # Escape $
echo "Backtick: \`"  # Escape `
echo "Backslash: \\" # Escape \
```

#### 7. Function Return Values

```bash
# ❌ WRONG - Confusing return with output
my_function() {
    local result="computed value"
    return $result  # ❌ return only accepts 0-255!
}

# ✅ CORRECT - Echo for output, return for exit code
my_function() {
    local result="computed value"
    echo "$result"  # Output
    return 0        # Success
}

result=$(my_function)
exit_code=$?

# ✅ ALSO CORRECT - Use global variable
declare RESULT=""
my_function() {
    RESULT="computed value"
    return 0
}
my_function
echo "$RESULT"
```

#### 8. Error Handling

```bash
# ❌ WRONG - Silent failures
command || :  # Hides all errors

# ✅ CORRECT - Explicit error handling
if ! command; then
    error "Command failed"
fi

# ✅ BETTER - Capture and log error
if ! output=$(command 2>&1); then
    error "Command failed: $output"
fi

# ✅ BEST - Comprehensive error handling
set +e
output=$(command 2>&1)
exit_code=$?
set -e

if [ $exit_code -ne 0 ]; then
    error "Command failed with exit code $exit_code: $output"
fi
```

---

## 🧪 Testing Methodology

### Test Structure

Every test script should follow this structure:

```bash
#!/usr/bin/env bash

# Test description
# Tests: List what is being tested

set -e

# Setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Helper functions
pass() {
    ((TESTS_PASSED++)) || :
    echo -e "${GREEN}✓ PASS${NC}: $1"
}

fail() {
    ((TESTS_FAILED++)) || :
    echo -e "${RED}✗ FAIL${NC}: $1"
}

# Setup function
setup() {
    # Create temp directory
    TEST_DIR=$(mktemp -d)
    # Other setup...
}

# Cleanup function
cleanup() {
    if [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
    fi
}
trap cleanup EXIT

# Test cases
test_feature_x() {
    ((TESTS_RUN++)) || :

    # Arrange
    local input="test input"
    local expected="expected output"

    # Act
    set +e
    local actual=$(command_under_test "$input" 2>&1)
    local exit_code=$?
    set -e

    # Assert
    if [ $exit_code -eq 0 ] && [ "$actual" = "$expected" ]; then
        pass "Feature X works correctly"
    else
        fail "Feature X failed: expected '$expected', got '$actual' (exit code: $exit_code)"
    fi
}

# Run tests
setup
test_feature_x
test_feature_y
test_feature_z

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total:  $TESTS_RUN"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    echo "✓ All tests passed"
    exit 0
else
    echo "✗ Some tests failed"
    exit 1
fi
```

### Testing Patterns

#### Pattern 1: Test Success and Failure Cases

```bash
test_validation_success() {
    ((TESTS_RUN++)) || :

    if command_that_should_succeed; then
        pass "Validation succeeds for valid input"
    else
        fail "Validation failed for valid input"
    fi
}

test_validation_failure() {
    ((TESTS_RUN++)) || :

    if command_that_should_fail; then
        fail "Validation should have failed for invalid input"
    else
        pass "Validation correctly rejects invalid input"
    fi
}
```

#### Pattern 2: Test Edge Cases

```bash
test_empty_input() {
    ((TESTS_RUN++)) || :

    local result=$(command "")
    if [ "$result" = "expected_for_empty" ]; then
        pass "Handles empty input correctly"
    else
        fail "Empty input not handled: got '$result'"
    fi
}

test_special_characters() {
    ((TESTS_RUN++)) || :

    local input="test!@#$%^&*()_+"
    if command "$input" >/dev/null 2>&1; then
        pass "Handles special characters"
    else
        fail "Failed on special characters"
    fi
}

test_large_input() {
    ((TESTS_RUN++)) || :

    local input=$(printf 'x%.0s' {1..10000})
    if timeout 5 command "$input" >/dev/null 2>&1; then
        pass "Handles large input"
    else
        fail "Timed out or failed on large input"
    fi
}
```

#### Pattern 3: Test Cleanup

```bash
test_cleanup_on_success() {
    ((TESTS_RUN++)) || :

    local temp_file=$(mktemp)
    command_that_should_cleanup "$temp_file"

    if [ ! -f "$temp_file" ]; then
        pass "Cleanup works on success"
    else
        fail "Temp file not cleaned up: $temp_file"
        rm -f "$temp_file"
    fi
}

test_cleanup_on_failure() {
    ((TESTS_RUN++)) || :

    local temp_file=$(mktemp)

    if ! command_that_should_fail "$temp_file" 2>/dev/null; then
        if [ ! -f "$temp_file" ]; then
            pass "Cleanup works on failure"
        else
            fail "Temp file not cleaned up after failure"
            rm -f "$temp_file"
        fi
    else
        fail "Command should have failed"
    fi
}
```

---

## 🐛 Debugging Techniques

### Technique 1: Bash Tracing

```bash
# Enable tracing for entire script
bash -x ./script.sh

# Enable tracing for specific section
set -x
critical_section
set +x

# Save trace to file
bash -x ./script.sh 2>&1 | tee trace.log

# Filter trace output
bash -x ./script.sh 2>&1 | grep "pattern"
```

### Technique 2: Strategic Echo Statements

```bash
# Use stderr for debug output
echo "DEBUG: value=$value" >&2

# Add checkpoints
echo "→ Checkpoint 1: Starting initialization" >&2
init_function
echo "→ Checkpoint 2: Initialization complete" >&2

# Show variables
echo "DEBUG: arg1='$arg1', arg2='$arg2', flag=$flag" >&2

# Show exit codes
command
echo "DEBUG: command exit code: $?" >&2
```

### Technique 3: Progressive Narrowing

```bash
# Start with coarse debugging
echo "→ Section A starting" >&2
section_a
echo "→ Section A complete" >&2

echo "→ Section B starting" >&2
section_b
echo "→ Section B complete" >&2

# Once you know which section fails, add finer detail
section_b() {
    echo "  → Step 1" >&2
    step_1
    echo "  → Step 2" >&2
    step_2
    echo "  → Step 3" >&2
    step_3
}

# Keep narrowing until you find the exact line
step_2() {
    echo "    → Step 2a" >&2
    substep_2a
    echo "    → Step 2b" >&2
    substep_2b  # Found it! Fails here
}
```

### Technique 4: Temporary Logging

```bash
# Create debug log file
DEBUG_LOG="/tmp/script-debug-$$.log"

debug_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$DEBUG_LOG"
}

# Use throughout script
debug_log "Starting process with arg: $1"
debug_log "Variable state: var1=$var1, var2=$var2"
debug_log "Command output: $(command 2>&1)"

# View log
tail -f "$DEBUG_LOG"
```

### Technique 5: Reproduce in Minimal Environment

```bash
# Use Docker to test in clean environment
docker run -it --rm -v $(pwd):/workspace ubuntu:latest bash
cd /workspace
bash ./script.sh

# Use chroot for isolated testing
# Use containers for exact CI environment reproduction
```

---

## 🔧 Tool Usage

### ShellCheck

```bash
# Check single file
shellcheck script.sh

# Check all shell scripts
find . -name "*.sh" -exec shellcheck {} +

# Exclude specific warnings
shellcheck -e SC2034 script.sh

# Set severity level
shellcheck --severity=warning script.sh

# Fix common issues automatically
shellcheck --format=diff script.sh | patch
```

### GitHub CLI (gh)

```bash
# View PRs
gh pr list
gh pr view 123
gh pr checks

# Create PR
gh pr create --fill
gh pr create --title "Title" --body "Body"

# Review PR
gh pr review 123 --approve
gh pr review 123 --request-changes -b "Comment"

# Merge PR
gh pr merge 123 --squash
gh pr merge 123 --rebase

# View CI runs
gh run list
gh run watch
gh run view <run-id> --log
```

### Git Workflows

```bash
# Interactive rebase to clean history
git rebase -i HEAD~5

# Amend last commit
git commit --amend --no-edit

# Cherry-pick specific commit
git cherry-pick <commit-hash>

# Stash changes with message
git stash push -m "WIP: feature X"

# View stash list
git stash list

# Apply specific stash
git stash apply stash@{2}

# Create patch
git format-patch HEAD~1

# Apply patch
git am < patch.patch
```

---

## ⚡ Performance Optimization

### Script Performance

```bash
# ❌ SLOW - Multiple forks
for file in $(find . -name "*.txt"); do
    process_file "$file"
done

# ✅ FAST - Single find with exec
find . -name "*.txt" -exec process_file {} +

# ❌ SLOW - Subshell per iteration
while read line; do
    count=$((count + 1))
done < file.txt

# ✅ FAST - Single process
count=$(wc -l < file.txt)
```

### Avoid Unnecessary Operations

```bash
# ❌ SLOW - Multiple checks
if [ -f "$file" ]; then
    if [ -r "$file" ]; then
        if [ -w "$file" ]; then
            process_file "$file"
        fi
    fi
fi

# ✅ FAST - Combined check
if [ -f "$file" ] && [ -r "$file" ] && [ -w "$file" ]; then
    process_file "$file"
fi
```

### Use Built-ins Over External Commands

```bash
# ❌ SLOW - External command
basename=$(basename "$path")

# ✅ FAST - Parameter expansion
basename="${path##*/}"

# ❌ SLOW - External command
dirname=$(dirname "$path")

# ✅ FAST - Parameter expansion
dirname="${path%/*}"
```

---

## 🔒 Security Considerations

### Input Validation

```bash
# Always validate user input
validate_input() {
    local input="$1"

    # Check for dangerous characters
    if [[ $input =~ [';\"$`\\] ]]; then
        error "Invalid characters in input"
    fi

    # Check length
    if [ ${#input} -gt 256 ]; then
        error "Input too long"
    fi

    # Check pattern
    if ! [[ $input =~ ^[a-zA-Z0-9_-]+$ ]]; then
        error "Input must be alphanumeric with dashes/underscores"
    fi
}
```

### Avoid Code Injection

```bash
# ❌ DANGEROUS - Code injection vulnerability
eval "echo $user_input"

# ✅ SAFE - Direct execution
echo "$user_input"

# ❌ DANGEROUS - Command injection
sh -c "process $user_input"

# ✅ SAFE - Direct command
process "$user_input"
```

### File Path Security

```bash
# ❌ DANGEROUS - Path traversal
cat "$user_provided_path"

# ✅ SAFE - Validate path
validate_path() {
    local path="$1"

    # Resolve to absolute path
    local realpath=$(readlink -f "$path")

    # Check it's within allowed directory
    if [[ $realpath != /allowed/directory/* ]]; then
        error "Path outside allowed directory"
    fi

    echo "$realpath"
}

safe_path=$(validate_path "$user_provided_path")
cat "$safe_path"
```

---

## 🔍 Troubleshooting

### Common Issues

#### Issue: "Command not found"

```bash
# Check if command exists
if ! command -v required_command >/dev/null 2>&1; then
    error "required_command not found. Please install it first."
fi

# Check PATH
echo "PATH: $PATH"

# Check if file is executable
chmod +x ./script.sh
```

#### Issue: "Permission denied"

```bash
# Check file permissions
ls -la file.txt

# Check directory permissions
ls -ld /path/to/directory

# Check sudo requirements
if [ "$EUID" -ne 0 ]; then
    error "This script requires root privileges"
fi
```

#### Issue: "Syntax error near unexpected token"

```bash
# Check for:
# 1. Unmatched quotes
echo "test'  # ❌ Missing closing quote

# 2. Unescaped special characters
echo "It's done!"  # ❌ Need to escape ' or use double quotes

# 3. DOS line endings (CRLF)
dos2unix script.sh  # Convert to Unix line endings
```

---

## 📚 Additional Resources

- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
- [ShellCheck Wiki](https://www.shellcheck.net/wiki/)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls)

---

**Last Updated:** November 6, 2025
**Maintained By:** Claude Code Library Team

---

*"Good code is its own best documentation."* - Steve McConnell

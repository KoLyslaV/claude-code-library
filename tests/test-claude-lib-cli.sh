#!/bin/bash
# test-claude-lib-cli.sh - Tests for claude-lib unified CLI

# Test: claude-lib exists and is executable
test_claude_lib_exists() {
    assert_file_exists "$LIBRARY_ROOT/scripts/claude-lib" "claude-lib exists"

    if [ -x "$LIBRARY_ROOT/scripts/claude-lib" ]; then
        assert_equals "true" "true" "claude-lib is executable"
    else
        assert_equals "true" "false" "claude-lib is executable"
    fi
}

# Test: claude-lib --version works
test_claude_lib_version() {
    local output=$("$LIBRARY_ROOT/scripts/claude-lib" --version 2>&1)
    assert_contains "$output" "claude-lib version" "Version command works"
}

# Test: claude-lib --help shows usage
test_claude_lib_help() {
    local output=$("$LIBRARY_ROOT/scripts/claude-lib" --help 2>&1)
    assert_contains "$output" "Claude Code Library" "Help shows library name"
    assert_contains "$output" "USAGE:" "Help shows usage"
    assert_contains "$output" "init" "Help shows init command"
}

# Test: claude-lib list shows resources
test_claude_lib_list() {
    local output=$("$LIBRARY_ROOT/scripts/claude-lib" list 2>&1)
    assert_contains "$output" "BOILERPLATES:" "List shows boilerplates"
    assert_contains "$output" "webapp" "List shows webapp boilerplate"
    assert_contains "$output" "AUTOMATION SCRIPTS:" "List shows scripts"
}

# Test: claude-lib doctor checks installation
test_claude_lib_doctor() {
    local output=$("$LIBRARY_ROOT/scripts/claude-lib" doctor 2>&1)
    assert_contains "$output" "Health Check" "Doctor shows health check"
}

# Test: claude-lib help init shows init help
test_claude_lib_help_init() {
    local output=$("$LIBRARY_ROOT/scripts/claude-lib" help init 2>&1)
    assert_contains "$output" "initialize" "Help init shows initialize"
    assert_contains "$output" "BOILERPLATE TYPES:" "Help init shows boilerplate types"
}

# Test: claude-lib help morning shows morning help
test_claude_lib_help_morning() {
    local output=$("$LIBRARY_ROOT/scripts/claude-lib" help morning 2>&1)
    assert_contains "$output" "Morning setup" "Help morning shows description"
}

# Test: claude-lib help feature shows feature help
test_claude_lib_help_feature() {
    local output=$("$LIBRARY_ROOT/scripts/claude-lib" help feature 2>&1)
    assert_contains "$output" "Feature development" "Help feature shows description"
}

# Test: claude-lib help bug-hunt shows bug-hunt help
test_claude_lib_help_bug_hunt() {
    local output=$("$LIBRARY_ROOT/scripts/claude-lib" help bug-hunt 2>&1)
    assert_contains "$output" "Bug hunting" "Help bug-hunt shows description"
}

# Test: claude-lib with no args shows usage
test_claude_lib_no_args() {
    local output=$("$LIBRARY_ROOT/scripts/claude-lib" 2>&1)
    assert_contains "$output" "USAGE:" "No args shows usage"
}

# Test: claude-lib with invalid command shows error
test_claude_lib_invalid_command() {
    local output=$("$LIBRARY_ROOT/scripts/claude-lib" invalid-command 2>&1 || true)
    assert_contains "$output" "Unknown command" "Invalid command shows error"
}

# Test: All documented commands exist in help
test_all_commands_in_help() {
    local output=$("$LIBRARY_ROOT/scripts/claude-lib" --help 2>&1)

    local commands=(
        "init"
        "morning"
        "validate"
        "feature"
        "bug-hunt"
        "docs"
        "crisis"
        "check"
        "anti-patterns"
        "fix"
        "list"
        "version"
        "doctor"
        "help"
    )

    for cmd in "${commands[@]}"; do
        assert_contains "$output" "$cmd" "Help includes command: $cmd"
    done
}

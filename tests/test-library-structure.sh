#!/bin/bash
# test-library-structure.sh - Tests for library structure integrity

# Test: Library directory exists
test_library_directory_exists() {
    assert_dir_exists "$LIBRARY_ROOT" "Library root directory exists"
}

# Test: Scripts directory exists
test_scripts_directory_exists() {
    assert_dir_exists "$LIBRARY_ROOT/scripts" "Scripts directory exists"
}

# Test: Boilerplates directory exists
test_boilerplates_directory_exists() {
    assert_dir_exists "$LIBRARY_ROOT/boilerplates" "Boilerplates directory exists"
}

# Test: Documentation directory exists
test_docs_directory_exists() {
    assert_dir_exists "$LIBRARY_ROOT/docs" "Documentation directory exists"
}

# Test: Completions directory exists
test_completions_directory_exists() {
    assert_dir_exists "$LIBRARY_ROOT/completions" "Completions directory exists"
}

# Test: All required scripts exist
test_all_scripts_exist() {
    local scripts=(
        "claude-lib"
        "init-project.sh"
        "morning-setup.sh"
        "validate-structure.sh"
        "anti-pattern-detector.sh"
        "feature-workflow.sh"
        "bug-hunter.sh"
        "doc-sprint.sh"
        "crisis-mode.sh"
        "metrics.sh"
    )

    for script in "${scripts[@]}"; do
        assert_file_exists "$LIBRARY_ROOT/scripts/$script" "Script exists: $script"
    done
}

# Test: All scripts are executable
test_all_scripts_executable() {
    local scripts=(
        "claude-lib"
        "init-project.sh"
        "morning-setup.sh"
        "validate-structure.sh"
        "anti-pattern-detector.sh"
        "feature-workflow.sh"
        "bug-hunter.sh"
        "doc-sprint.sh"
        "crisis-mode.sh"
        "metrics.sh"
    )

    for script in "${scripts[@]}"; do
        if [ -x "$LIBRARY_ROOT/scripts/$script" ]; then
            assert_equals "true" "true" "Script is executable: $script"
        else
            assert_equals "true" "false" "Script is executable: $script"
        fi
    done
}

# Test: All boilerplates exist
test_all_boilerplates_exist() {
    local boilerplates=(
        "webapp-boilerplate"
        "website-boilerplate"
        "python-cli-boilerplate"
    )

    for boilerplate in "${boilerplates[@]}"; do
        assert_dir_exists "$LIBRARY_ROOT/boilerplates/$boilerplate" "Boilerplate exists: $boilerplate"
    done
}

# Test: Each boilerplate has CLAUDE.md
test_boilerplates_have_claude_md() {
    local boilerplates=(
        "webapp-boilerplate"
        "website-boilerplate"
        "python-cli-boilerplate"
    )

    for boilerplate in "${boilerplates[@]}"; do
        assert_file_exists "$LIBRARY_ROOT/boilerplates/$boilerplate/.claude/CLAUDE.md" \
            "$boilerplate has CLAUDE.md"
    done
}

# Test: README exists
test_readme_exists() {
    assert_file_exists "$LIBRARY_ROOT/README.md" "README.md exists"
}

# Test: Documentation files exist
test_documentation_exists() {
    assert_file_exists "$LIBRARY_ROOT/docs/QUICK_REFERENCE.md" "Quick reference exists"
    assert_file_exists "$LIBRARY_ROOT/docs/TROUBLESHOOTING.md" "Troubleshooting guide exists"
}

# Test: Completion scripts exist
test_completions_exist() {
    assert_file_exists "$LIBRARY_ROOT/completions/claude-lib-completion.bash" "Bash completion exists"
    assert_file_exists "$LIBRARY_ROOT/completions/claude-lib-completion.zsh" "Zsh completion exists"
    assert_file_exists "$LIBRARY_ROOT/completions/install-completions.sh" "Completion installer exists"
}

# Test: Completion installer is executable
test_completion_installer_executable() {
    if [ -x "$LIBRARY_ROOT/completions/install-completions.sh" ]; then
        assert_equals "true" "true" "Completion installer is executable"
    else
        assert_equals "true" "false" "Completion installer is executable"
    fi
}

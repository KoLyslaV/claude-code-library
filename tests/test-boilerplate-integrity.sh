#!/bin/bash
# test-boilerplate-integrity.sh - Tests for boilerplate integrity

# Test: webapp-boilerplate has required files
test_webapp_required_files() {
    local boilerplate="$LIBRARY_ROOT/boilerplates/webapp-boilerplate"

    local required_files=(
        ".claude/CLAUDE.md"
        ".claude/docs/TODO.md"
        ".claude/docs/HANDOFF.md"
        "package.json"
        "tsconfig.json"
        "next.config.ts"
        ".gitignore"
        "README.md"
    )

    for file in "${required_files[@]}"; do
        assert_file_exists "$boilerplate/$file" "webapp has: $file"
    done
}

# Test: webapp-boilerplate package.json is valid JSON
test_webapp_package_json_valid() {
    local package_json="$LIBRARY_ROOT/boilerplates/webapp-boilerplate/package.json"

    if command -v jq &> /dev/null; then
        if jq empty "$package_json" 2>/dev/null; then
            assert_equals "true" "true" "webapp package.json is valid JSON"
        else
            assert_equals "true" "false" "webapp package.json is valid JSON"
        fi
    else
        skip_test "jq not installed"
    fi
}

# Test: webapp-boilerplate has Next.js 15
test_webapp_has_nextjs_15() {
    local package_json="$LIBRARY_ROOT/boilerplates/webapp-boilerplate/package.json"

    if command -v jq &> /dev/null; then
        local nextjs_version=$(jq -r '.dependencies.next' "$package_json")
        assert_contains "$nextjs_version" "15" "webapp has Next.js 15"
    else
        skip_test "jq not installed"
    fi
}

# Test: webapp-boilerplate has template variables
test_webapp_has_template_variables() {
    local package_json="$LIBRARY_ROOT/boilerplates/webapp-boilerplate/package.json"

    local content=$(cat "$package_json")
    assert_contains "$content" "{{PROJECT_NAME}}" "webapp has PROJECT_NAME variable"
}

# Test: website-boilerplate has required files
test_website_required_files() {
    local boilerplate="$LIBRARY_ROOT/boilerplates/website-boilerplate"

    local required_files=(
        ".claude/CLAUDE.md"
        ".claude/docs/TODO.md"
        ".claude/docs/HANDOFF.md"
        "package.json"
        "tsconfig.json"
        "astro.config.mjs"
        ".gitignore"
        "README.md"
    )

    for file in "${required_files[@]}"; do
        assert_file_exists "$boilerplate/$file" "website has: $file"
    done
}

# Test: website-boilerplate package.json is valid JSON
test_website_package_json_valid() {
    local package_json="$LIBRARY_ROOT/boilerplates/website-boilerplate/package.json"

    if command -v jq &> /dev/null; then
        if jq empty "$package_json" 2>/dev/null; then
            assert_equals "true" "true" "website package.json is valid JSON"
        else
            assert_equals "true" "false" "website package.json is valid JSON"
        fi
    else
        skip_test "jq not installed"
    fi
}

# Test: website-boilerplate has Astro 5.0
test_website_has_astro_5() {
    local package_json="$LIBRARY_ROOT/boilerplates/website-boilerplate/package.json"

    if command -v jq &> /dev/null; then
        local astro_version=$(jq -r '.dependencies.astro' "$package_json")
        assert_contains "$astro_version" "5" "website has Astro 5"
    else
        skip_test "jq not installed"
    fi
}

# Test: python-cli-boilerplate has required files
test_python_cli_required_files() {
    local boilerplate="$LIBRARY_ROOT/boilerplates/python-cli-boilerplate"

    local required_files=(
        ".claude/CLAUDE.md"
        ".claude/docs/TODO.md"
        ".claude/docs/HANDOFF.md"
        "pyproject.toml"
        "README.md"
        ".gitignore"
    )

    for file in "${required_files[@]}"; do
        assert_file_exists "$boilerplate/$file" "python-cli has: $file"
    done
}

# Test: python-cli-boilerplate pyproject.toml has Poetry
test_python_cli_has_poetry() {
    local pyproject="$LIBRARY_ROOT/boilerplates/python-cli-boilerplate/pyproject.toml"

    local content=$(cat "$pyproject")
    assert_contains "$content" "[tool.poetry]" "python-cli has Poetry config"
}

# Test: python-cli-boilerplate has Click dependency
test_python_cli_has_click() {
    local pyproject="$LIBRARY_ROOT/boilerplates/python-cli-boilerplate/pyproject.toml"

    local content=$(cat "$pyproject")
    assert_contains "$content" "click" "python-cli has Click dependency"
}

# Test: python-cli-boilerplate has pytest
test_python_cli_has_pytest() {
    local pyproject="$LIBRARY_ROOT/boilerplates/python-cli-boilerplate/pyproject.toml"

    local content=$(cat "$pyproject")
    assert_contains "$content" "pytest" "python-cli has pytest"
}

# Test: All boilerplates have CLAUDE.md with 5 rules
test_all_boilerplates_have_critical_rules() {
    local boilerplates=(
        "webapp-boilerplate"
        "website-boilerplate"
        "python-cli-boilerplate"
    )

    for boilerplate in "${boilerplates[@]}"; do
        local claude_md="$LIBRARY_ROOT/boilerplates/$boilerplate/.claude/CLAUDE.md"
        local content=$(cat "$claude_md")

        assert_contains "$content" "CRITICAL RULES" "$boilerplate has CRITICAL RULES"
        assert_contains "$content" "Discovery Before Action" "$boilerplate has Rule 1"
    done
}

# Test: All boilerplates have .gitignore
test_all_boilerplates_have_gitignore() {
    local boilerplates=(
        "webapp-boilerplate"
        "website-boilerplate"
        "python-cli-boilerplate"
    )

    for boilerplate in "${boilerplates[@]}"; do
        assert_file_exists "$LIBRARY_ROOT/boilerplates/$boilerplate/.gitignore" \
            "$boilerplate has .gitignore"
    done
}

# Test: All boilerplates have README.md
test_all_boilerplates_have_readme() {
    local boilerplates=(
        "webapp-boilerplate"
        "website-boilerplate"
        "python-cli-boilerplate"
    )

    for boilerplate in "${boilerplates[@]}"; do
        assert_file_exists "$LIBRARY_ROOT/boilerplates/$boilerplate/README.md" \
            "$boilerplate has README.md"
    done
}

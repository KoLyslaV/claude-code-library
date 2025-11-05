# Claude Code Library - Test Suite

**Version:** 1.0.0

## 📋 Overview

Comprehensive test suite for Claude Code Library to ensure:
- ✅ Library structure integrity
- ✅ Script functionality
- ✅ Boilerplate correctness
- ✅ CLI interface consistency
- ✅ Documentation completeness

## 🧪 Test Framework

Custom bash testing framework (`test-runner.sh`) with assertion library:

### Assertion Functions

- `assert_equals <expected> <actual> [message]` - Compare two values
- `assert_file_exists <path> [message]` - Verify file exists
- `assert_dir_exists <path> [message]` - Verify directory exists
- `assert_contains <haystack> <needle> [message]` - String contains check
- `assert_command_succeeds <command> [message]` - Command exits 0
- `assert_command_fails <command> [message]` - Command exits non-zero
- `skip_test <reason>` - Skip a test with reason

### Lifecycle Functions

- `setup()` - Runs before all tests in file
- `teardown()` - Runs after all tests in file
- `setup_test_env()` - Sets up temp environment for test
- `teardown_test_env()` - Cleans up temp environment

## 🚀 Running Tests

### Run All Tests

```bash
# From library root
./tests/test-runner.sh

# OR from tests directory
cd tests
./test-runner.sh
```

### Run Specific Test File

```bash
./tests/test-runner.sh test-claude-lib-cli.sh
```

### Run with Verbose Output

```bash
./tests/test-runner.sh --verbose
```

## 📁 Test Files

### test-library-structure.sh
Tests library directory structure and file existence.

**Tests:**
- Library directories exist (scripts, boilerplates, docs, completions)
- All required scripts exist and are executable
- All boilerplates exist
- Documentation files exist
- Completion scripts exist

**Run:** `./test-runner.sh test-library-structure.sh`

### test-claude-lib-cli.sh
Tests the unified `claude-lib` CLI interface.

**Tests:**
- CLI exists and is executable
- `--version` and `--help` work
- All commands present in help
- `list` shows resources
- `doctor` checks installation
- Help for individual commands works
- Invalid commands show error

**Run:** `./test-runner.sh test-claude-lib-cli.sh`

### test-boilerplate-integrity.sh
Tests boilerplate structure and configuration.

**Tests:**
- Required files exist in each boilerplate
- package.json/pyproject.toml are valid
- Correct framework versions (Next.js 15, Astro 5.0)
- Template variables present
- CLAUDE.md has critical rules
- Dependencies are correct

**Run:** `./test-runner.sh test-boilerplate-integrity.sh`

## 📊 Test Output

### Success
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 Claude Code Library Test Runner
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 Running: test-library-structure
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ test_library_directory_exists
  ✓ test_scripts_directory_exists
  ✓ test_all_scripts_exist
  ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Test Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Total tests:  45
  Passed:       45
  Failed:       0
  Skipped:      0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✨ All tests passed!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Failure
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 Running: test-boilerplate-integrity
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ test_webapp_required_files
  ✗ test_webapp_package_json_valid
    Expected: true
    Actual:   false
  ✓ test_webapp_has_nextjs_15
  ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Test Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Total tests:  28
  Passed:       27
  Failed:       1
  Skipped:      0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ Some tests failed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## ✍️ Writing Tests

### Test File Template

```bash
#!/bin/bash
# test-my-feature.sh - Tests for my feature

# Optional: Setup before all tests
setup() {
    export MY_VAR="value"
}

# Optional: Cleanup after all tests
teardown() {
    unset MY_VAR
}

# Test function (must start with "test_")
test_my_feature_works() {
    assert_equals "expected" "actual" "Feature works correctly"
}

# Test with command execution
test_command_succeeds() {
    assert_command_succeeds "ls /tmp" "ls command succeeds"
}

# Test with file operations
test_file_created() {
    touch "$TEST_TEMP_DIR/testfile"
    assert_file_exists "$TEST_TEMP_DIR/testfile" "File created"
}

# Skip test conditionally
test_requires_tool() {
    if ! command -v jq &> /dev/null; then
        skip_test "jq not installed"
        return
    fi

    # Test logic here
    assert_command_succeeds "jq --version" "jq works"
}
```

### Best Practices

1. **Test Names:** Use descriptive names starting with `test_`
2. **Assertions:** Use specific assertion functions for clarity
3. **Cleanup:** Use `$TEST_TEMP_DIR` for temporary files (auto-cleaned)
4. **Dependencies:** Skip tests that require unavailable tools
5. **Isolation:** Each test should be independent
6. **Messages:** Provide clear assertion messages

## 🔄 CI/CD Integration

### GitHub Actions

```yaml
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: ./tests/test-runner.sh
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running tests..."
./tests/test-runner.sh --verbose

if [ $? -ne 0 ]; then
    echo "Tests failed! Commit aborted."
    exit 1
fi
```

## 📈 Test Coverage

Current test coverage:

| Component | Tests | Coverage |
|-----------|-------|----------|
| Library Structure | 13 | 100% |
| CLI Interface | 12 | 100% |
| Boilerplate Integrity | 20 | 100% |
| **Total** | **45** | **100%** |

## 🐛 Troubleshooting

### Tests fail with "command not found"

**Issue:** Test runner or scripts not executable

**Solution:**
```bash
chmod +x tests/test-runner.sh
chmod +x tests/*.sh
```

### Tests skip due to missing tools

**Issue:** Optional tools like `jq` not installed

**Solution:**
```bash
# Install jq (Ubuntu)
sudo apt install jq

# Install jq (macOS)
brew install jq
```

### Cleanup doesn't work

**Issue:** Temp files left behind

**Solution:** Test runner auto-cleans `$TEST_TEMP_DIR`
If manual cleanup needed:
```bash
rm -rf /tmp/tmp.*
```

## 🤝 Contributing

When adding new features to the library:

1. **Write tests first** (TDD approach)
2. **Run tests** before committing
3. **Update coverage** table in this README
4. **Document test** in this file

### Adding New Test File

1. Create `tests/test-new-feature.sh`
2. Add test functions starting with `test_`
3. Run `./test-runner.sh test-new-feature.sh`
4. Update this README

## 📞 Support

- **Issues:** Report test failures in GitHub Issues
- **Questions:** Ask in GitHub Discussions

---

**Last Updated:** 2025-11-05
**Version:** 1.0.0
**Status:** ✅ Production Ready

# Contributing to Claude Code Library

Thank you for considering contributing to Claude Code Library! This document outlines our standards, workflows, and non-negotiable rules.

---

## 📋 Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Non-Negotiable Rules](#non-negotiable-rules)
3. [Getting Started](#getting-started)
4. [Development Workflow](#development-workflow)
5. [Coding Standards](#coding-standards)
6. [Testing Requirements](#testing-requirements)
7. [Commit Message Guidelines](#commit-message-guidelines)
8. [Pull Request Process](#pull-request-process)
9. [Review Process](#review-process)

---

## 🤝 Code of Conduct

### Our Pledge
We are committed to providing a welcoming and inclusive environment for all contributors, regardless of experience level, background, or identity.

### Expected Behavior
- Be respectful and professional
- Provide constructive feedback
- Focus on the code, not the person
- Welcome newcomers warmly
- Help others learn and grow

### Unacceptable Behavior
- Harassment or discrimination
- Unconstructive criticism
- Dismissive attitude toward questions
- "RTFM" responses without guidance

---

## ⚠️ Non-Negotiable Rules

### Rule #1: Zero Tolerance for Errors

**All CI checks MUST pass before merge. No exceptions.**

This means:
- ❌ **NEVER** merge with failing CI
- ❌ **NEVER** use "fix later" as an excuse
- ❌ **NEVER** disable checks to work around failures
- ❌ **NEVER** commit with the mindset "errors are ok"

**If CI is red, you debug until it's green. Period.**

Why this matters:
- Broken CI blocks everyone else
- Technical debt compounds quickly
- "Temporary" hacks become permanent
- Quality degradation is cumulative

**Example of Unacceptable:**
```
❌ "CI is failing but the code works on my machine, I'll merge and fix later"
❌ "It's just a warning, not an error, so it's fine"
❌ "The test is flaky anyway, so I'll skip it"
❌ "Let me disable this check so I can merge"
```

**Example of Acceptable:**
```
✅ "CI is failing, let me investigate and fix the root cause"
✅ "Tests are flaky, let me make them more reliable first"
✅ "This warning indicates a real issue, let me address it"
✅ "I need to update the CI configuration properly, not disable it"
```

### Rule #2: Pre-commit Hooks Are Mandatory

**You MUST run `./scripts/setup-pre-commit.sh` before your first commit.**

Pre-commit hooks will catch:
- Syntax errors (ShellCheck)
- Linting issues (ESLint, Prettier, ruff, mypy)
- Large files accidentally committed
- Secrets or credentials
- Merge conflict markers
- Trailing whitespace

**Do NOT use `--no-verify` unless:**
- Emergency hotfix for production issue
- Reverting a broken commit
- Documented exception with team approval

**If you bypass hooks without valid reason:**
- Your PR will be rejected
- You will be asked to fix and recommit
- Repeated violations may result in reduced review priority

### Rule #3: Testing Standards

**New code requires tests. Test coverage must not decrease.**

Testing requirements:
- ✅ New scripts must have integration tests
- ✅ New features must have validation tests
- ✅ Bug fixes must have regression tests
- ✅ Tests must be reliable (no flaky tests)
- ✅ Tests must be fast (< 2 minutes per suite)

**Test quality standards:**
- Test both success and failure cases
- Use descriptive test names
- Add assertions for all expected outcomes
- Clean up test artifacts in cleanup()
- Mock external dependencies appropriately

### Rule #4: Code Quality Standards

#### Bash Scripts
**Every bash script MUST:**
- Pass ShellCheck with zero warnings
- Use `#!/bin/bash` shebang
- Start with `set -e` (exit on error)
- Use `set -u` for strict mode (recommended)
- Use `set -o pipefail` for pipeline errors (recommended)
- Escape special characters (`!`, `$`, backticks)
- Add `|| :` to arithmetic expressions with `set -e`
- Include usage() function
- Add helpful error messages
- End with explicit `exit 0`

**Example template:**
```bash
#!/bin/bash
set -e
set -u
set -o pipefail

# Script description
# Usage: script.sh [options] <args>

usage() {
    echo "Usage: $0 [options] <args>"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    exit 1
}

# ... script code ...

exit 0
```

#### TypeScript/JavaScript
- ESLint must pass with zero warnings
- Prettier formatting required
- TypeScript strict mode enabled
- No `any` types without justification
- All functions have JSDoc comments

#### Python
- ruff linting must pass
- mypy type checking must pass
- Black formatting required
- Type hints on all functions
- Docstrings on all public APIs

### Rule #5: CI/CD Pipeline

**The CI pipeline is our source of truth.**

CI rules:
- ✅ Never merge while CI is red
- ✅ Debug failures immediately, don't ignore
- ✅ If CI times out, optimize (don't just increase timeout)
- ✅ Document workarounds in commit messages
- ✅ Fix flaky tests, don't skip them

**When CI fails:**
1. Read the error message completely
2. Reproduce locally if possible
3. Check recent commits for regressions
4. Review CI logs thoroughly
5. Ask for help if stuck (after reasonable investigation)
6. Document the fix in commit message

**DO NOT:**
- Restart CI hoping it passes randomly
- Merge with "CI is probably fine"
- Disable failing jobs without fixing root cause
- Add `|| true` to hide failures

---

## 🚀 Getting Started

### 1. Fork and Clone
```bash
# Fork the repository on GitHub
gh repo fork KoLyslaV/claude-code-library --clone

# Or clone directly
git clone https://github.com/YOUR_USERNAME/claude-code-library.git
cd claude-code-library
```

### 2. Set Up Development Environment
```bash
# Install pre-commit hooks (REQUIRED)
./scripts/setup-pre-commit.sh

# Verify pre-commit hooks are installed
ls -la .git/hooks/pre-commit

# Run tests to ensure everything works
./tests/test-runner.sh
```

### 3. Create a Branch
```bash
# Branch naming convention:
# - feature/description-of-feature
# - fix/description-of-bug
# - docs/what-documentation
# - refactor/what-refactoring
# - test/what-testing

git checkout -b feature/my-new-feature
```

---

## 💻 Development Workflow

### Daily Development Flow
```bash
# 1. Start with latest main
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feature/my-feature

# 3. Make changes and test locally
# Edit files...
./tests/test-runner.sh

# 4. Commit (pre-commit hooks run automatically)
git add .
git commit -m "feat: add new feature"

# 5. Push and create PR
git push origin feature/my-feature
gh pr create --fill

# 6. Wait for CI to pass
gh run watch

# 7. Address review feedback
# Make changes...
git add .
git commit -m "fix: address review feedback"
git push

# 8. Merge when approved and CI green
gh pr merge --squash
```

### Working on Large Features
```bash
# Create feature branch
git checkout -b feature/large-feature

# Commit incrementally
git commit -m "feat: implement part 1"
git commit -m "feat: implement part 2"
git commit -m "test: add tests for parts 1 and 2"

# Keep branch up to date with main
git fetch origin
git rebase origin/main

# Push for review
git push origin feature/large-feature --force-with-lease
```

---

## 📝 Coding Standards

### File Organization
```
claude-code-library/
├── boilerplates/          # Template projects
├── examples/              # Working example projects
├── scripts/               # Automation scripts
├── tests/                 # Test suites
├── docs/                  # Documentation
└── .github/workflows/     # CI/CD
```

### Naming Conventions

**Bash Scripts:**
- Use kebab-case: `init-project.sh`, `validate-structure.sh`
- Descriptive names: `bug-hunter.sh` not `bh.sh`
- Action verbs: `create-`, `validate-`, `check-`

**Functions:**
```bash
# Bash: snake_case
function_name() { ... }

# TypeScript: camelCase
function functionName() { ... }

# Python: snake_case
def function_name(): ...
```

**Variables:**
```bash
# Bash: UPPER_CASE for constants, lower_case for locals
readonly CONST_VALUE="value"
local temp_var="temp"

# TypeScript: camelCase for variables, PascalCase for types
const variableName = "value";
type TypeName = string;

# Python: UPPER_CASE for constants, snake_case for variables
CONST_VALUE = "value"
variable_name = "value"
```

### Code Comments

**When to comment:**
- Complex logic that isn't obvious
- Workarounds for known issues
- TODOs with issue numbers
- Public API documentation

**When NOT to comment:**
- Obvious code (don't state the obvious)
- Outdated comments (remove them)
- Commented-out code (use git history)

**Good comments:**
```bash
# Workaround for SC2155: separate declaration from assignment
# See: https://www.shellcheck.net/wiki/SC2155
local dir
dir=$(dirname "$file")

# TODO(#123): Refactor this to use modern API
# Current implementation uses deprecated endpoint
```

**Bad comments:**
```bash
# Increment counter
((counter++))  # This is obvious from the code

# Old implementation
# function old_way() {
#     ...
# }  # Don't keep commented code, use git

# FIXME: This is broken
# (No issue number, not tracked, will be forgotten)
```

---

## 🧪 Testing Requirements

### Test Coverage

**Required coverage:**
- Unit tests: 80% minimum
- Integration tests: All critical workflows
- E2E tests: Major user journeys

**What to test:**
- ✅ Happy path (normal operation)
- ✅ Error cases (invalid input, missing files, etc.)
- ✅ Edge cases (empty strings, special characters, large files)
- ✅ Boundary conditions (min/max values)

### Test Structure

```bash
#!/usr/bin/env bash
# tests/test-feature.sh

set -e

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
pass() {
    ((TESTS_PASSED++)) || :
    echo "✓ PASS: $1"
}

fail() {
    ((TESTS_FAILED++)) || :
    echo "✗ FAIL: $1"
}

# Test cases
test_something() {
    ((TESTS_RUN++))

    # Arrange
    local input="test"

    # Act
    local result=$(command "$input")

    # Assert
    if [ "$result" = "expected" ]; then
        pass "Something works correctly"
    else
        fail "Expected 'expected', got '$result'"
    fi
}

# Run tests
test_something
test_something_else

# Summary
echo ""
echo "Tests run: $TESTS_RUN"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi
```

### Running Tests

```bash
# Run all tests
./tests/test-runner.sh

# Run specific test
./tests/test-runner.sh test-integration.sh

# Run with verbose output
./tests/test-runner.sh --verbose

# Run in watch mode (if available)
./tests/test-runner.sh --watch
```

---

## 💬 Commit Message Guidelines

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code restructuring without behavior change
- `test`: Adding or modifying tests
- `chore`: Maintenance tasks, dependency updates

### Examples

**Good commit messages:**
```
feat(init): add --skip-deps flag for CI testing

Integration tests were timing out because npm install takes
2-5 minutes. Added flag to skip dependency installation during
testing while still validating project structure.

Fixes #123
```

```
fix(test): resolve arithmetic expansion bug in pass() function

The ((TESTS_PASSED++)) expression returns 0 when the counter
is 0, which with set -e causes immediate exit. Added || : to
prevent exit on 0 return value.

Related: #456
```

**Bad commit messages:**
```
❌ "fixed stuff"
❌ "WIP"
❌ "update"
❌ "asdfasdf"
❌ "final commit"
❌ "this should work"
```

### Commit Message Rules
- ✅ Use imperative mood ("add" not "added" or "adds")
- ✅ Don't end subject with period
- ✅ Limit subject to 50 characters
- ✅ Wrap body at 72 characters
- ✅ Separate subject from body with blank line
- ✅ Reference issues in footer

---

## 🔄 Pull Request Process

### Before Creating PR

**Checklist:**
- [ ] All tests pass locally
- [ ] Code passes linting (ShellCheck, ESLint, ruff, etc.)
- [ ] Pre-commit hooks installed and passing
- [ ] Documentation updated (if needed)
- [ ] CHANGELOG.md updated (if user-facing change)
- [ ] Commit messages follow guidelines
- [ ] Branch is up to date with main

### Creating PR

```bash
# Push your branch
git push origin feature/my-feature

# Create PR with GitHub CLI (recommended)
gh pr create --fill

# Or create PR manually on GitHub
# Go to: https://github.com/KoLyslaV/claude-code-library/pulls
```

### PR Title Format
```
<type>(<scope>): <description>
```

Examples:
- `feat(init): add support for Python CLI boilerplates`
- `fix(test): resolve integration test timeout issues`
- `docs(contributing): add commit message guidelines`

### PR Description Template
```markdown
## Summary
Brief description of what this PR does.

## Motivation
Why is this change needed? What problem does it solve?

## Changes
- Change 1
- Change 2
- Change 3

## Testing
How was this tested? What should reviewers verify?

## Screenshots (if applicable)
Add screenshots for UI changes.

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] CHANGELOG updated
- [ ] CI passing

## Related Issues
Fixes #123
Related to #456
```

### After Creating PR

1. **Wait for CI** - All checks must pass
2. **Address feedback** - Respond to review comments
3. **Update as needed** - Push additional commits
4. **Request re-review** - After addressing feedback
5. **Merge when approved** - Use squash merge

---

## 👀 Review Process

### As a Reviewer

**What to look for:**
- ✅ Code correctness and logic
- ✅ Test coverage and quality
- ✅ Error handling
- ✅ Performance implications
- ✅ Security concerns
- ✅ Documentation quality
- ✅ Code style consistency

**How to provide feedback:**
```markdown
# Good feedback ✅
"This function could benefit from error handling for the case
when the file doesn't exist. Consider adding:
if [ ! -f "$file" ]; then
    echo "Error: File not found"
    return 1
fi"

# Bad feedback ❌
"This is wrong, fix it."
```

**Review timeline:**
- Small PRs (< 100 lines): 1 business day
- Medium PRs (100-500 lines): 2 business days
- Large PRs (> 500 lines): 3-5 business days

### As a PR Author

**Responding to feedback:**
- ✅ Be respectful and grateful
- ✅ Explain your reasoning if you disagree
- ✅ Mark conversations as resolved when addressed
- ✅ Push changes in response to feedback
- ✅ Request re-review when ready

**When you disagree:**
```markdown
# Good response ✅
"I see your point about the error handling. I initially chose
to fail silently because X reason, but I agree your approach
is more robust. I'll update the code."

# Bad response ❌
"It works fine, no need to change."
```

---

## 📚 Additional Resources

- [Development Guide](./docs/DEVELOPMENT.md) - Detailed development practices
- [Lessons Learned](./docs/LESSONS_LEARNED.md) - Past debugging experiences
- [Architecture Overview](./.claude/CLAUDE.md) - Project architecture
- [Testing Guide](./docs/TESTING.md) - Comprehensive testing documentation

---

## ❓ Getting Help

### Where to Ask Questions

1. **GitHub Discussions** - General questions, ideas
2. **GitHub Issues** - Bug reports, feature requests
3. **PR Comments** - Questions about specific changes
4. **Discord/Slack** - Real-time chat (if available)

### How to Ask Good Questions

**Good question ✅:**
```
I'm trying to add a new boilerplate type, but the validation
script is failing with "Unknown type: X". I've added the type
to init-project.sh (line 45) but I'm not sure where else it
needs to be registered. I've checked validate-structure.sh but
don't see a type list there. Where should I add the new type?

What I've tried:
- Added to VALID_TYPES array (line 45)
- Created boilerplate directory
- Ran tests (failing at validation step)
```

**Bad question ❌:**
```
"It doesn't work, help!"
```

---

## 🏆 Recognition

### Contributors Wall of Fame
Outstanding contributors are recognized in:
- README.md contributors section
- Annual contributor spotlight
- Project CHANGELOG with shoutouts

### Contribution Levels
- 🌱 **Seedling** - First contribution
- 🌿 **Contributor** - 5+ merged PRs
- 🌳 **Core Contributor** - 20+ merged PRs
- ⭐ **Maintainer** - Trusted with merge access

---

## 📄 License

By contributing to Claude Code Library, you agree that your contributions will be licensed under the project's MIT License.

---

## 🙏 Thank You!

We appreciate your interest in contributing to Claude Code Library. Your efforts help make this project better for everyone!

**Remember:** Quality over speed. It's better to take time to do it right than to rush and create technical debt.

---

**Last Updated:** November 6, 2025
**Questions?** Open a GitHub Discussion or Issue

---

*"Code is read more often than it's written. Write code for the next developer, not just the compiler."*

# Pre-commit Hooks

This directory contains pre-commit hooks and setup scripts for the Claude Code Library.

## Quick Start

```bash
# Install and setup hooks
./hooks/setup-hooks.sh

# Or manually
pip install pre-commit
pre-commit install
```

## What Are Pre-commit Hooks?

Pre-commit hooks automatically run checks on your code before you commit changes. They help maintain code quality and catch issues early.

## Installed Hooks

### General Checks
- **Trailing whitespace** - Removes trailing whitespace
- **End of file fixer** - Ensures files end with newline
- **YAML/JSON/TOML syntax** - Validates configuration files
- **Large files** - Prevents committing files > 1MB
- **Merge conflicts** - Detects unresolved merge conflicts
- **Line endings** - Enforces LF line endings

### Shell Script Checks
- **ShellCheck** - Lints shell scripts for common issues
- **Executable shebangs** - Ensures executable scripts have shebangs

### Markdown Checks
- **Markdownlint** - Lints and fixes Markdown formatting

### Custom Library Checks
- **Library structure** - Validates boilerplates/examples/scripts structure
- **Boilerplate integrity** - Ensures boilerplates are complete
- **Template variables** - Checks for unreplaced {{PROJECT_NAME}} in examples
- **README existence** - Ensures all directories have READMEs
- **Example validation** - Validates changed example project structures

### Language-Specific Checks

#### Python (for python-cli examples)
- **ruff** - Fast Python linter and formatter
- **mypy** - Type checking

#### TypeScript/JavaScript (for webapp/website examples)
- **ESLint** - Lints TypeScript/JavaScript code
- **Prettier** - Formats code consistently

## Usage

### Automatic (Recommended)

Hooks run automatically when you commit:

```bash
git add .
git commit -m "Your message"
# Hooks run automatically before commit
```

### Manual

Run all hooks on all files:

```bash
pre-commit run --all-files
```

Run specific hook:

```bash
pre-commit run shellcheck
pre-commit run test-library-structure
```

Run hooks on specific files:

```bash
pre-commit run --files scripts/init-project.sh
```

### Skip Hooks (Not Recommended)

Only use when absolutely necessary:

```bash
git commit --no-verify -m "Emergency fix"
```

## Configuration

Main configuration file: `.pre-commit-config.yaml`

### Update Hook Versions

```bash
pre-commit autoupdate
```

### Disable Specific Hooks

Edit `.pre-commit-config.yaml` and comment out the hook:

```yaml
# - id: mypy
#   name: Type check Python
```

## Custom Hooks

### validate-changed-examples.sh

Validates structure of changed example projects.

**What it checks:**
- Example type detection (webapp/website/python-cli)
- Project structure validation
- README.md existence
- Template variable replacement

**When it runs:**
- Only when files in `examples/` are changed
- Before commit

### Quick Tests

Ensures all scripts are executable:

```bash
chmod +x scripts/*.sh tests/*.sh
```

## Troubleshooting

### Hook fails with "command not found"

Install the required tool:

```bash
# For shellcheck
sudo apt-get install shellcheck  # Ubuntu/Debian
brew install shellcheck          # macOS

# For markdownlint
npm install -g markdownlint-cli

# For Python tools
pip install ruff mypy
```

### Hook fails but I want to commit anyway

Use `--no-verify` (not recommended):

```bash
git commit --no-verify -m "Skip hooks"
```

Better: Fix the issue and commit normally.

### pre-commit not found

Install pre-commit:

```bash
pip install pre-commit

# Or
pip3 install pre-commit

# Or with package manager
brew install pre-commit  # macOS
```

### Hooks take too long

Some options:

1. **Run specific hooks:**
   ```bash
   pre-commit run shellcheck
   ```

2. **Skip integration tests locally** (they run in CI):
   Comment out in `.pre-commit-config.yaml`:
   ```yaml
   # - id: test-library-structure
   ```

3. **Use `--no-verify` for WIP commits:**
   ```bash
   git commit --no-verify -m "WIP"
   ```

### Python/Node dependencies missing

Install development dependencies:

```bash
# For Python examples
cd examples/python-cli-example
poetry install

# For Node examples
cd examples/webapp-example
npm install
```

## Performance Tips

### Fast Commits

Pre-commit is configured to only run relevant hooks on changed files. For example:

- Python hooks only run on `.py` files
- Shell hooks only run on `.sh` files
- Example validation only runs when examples change

### Parallel Execution

Pre-commit runs hooks in parallel when possible, using all CPU cores.

### Cache

Pre-commit caches hook environments in `~/.cache/pre-commit/`, making subsequent runs faster.

## Development

### Adding New Hooks

1. Edit `.pre-commit-config.yaml`
2. Add hook configuration under appropriate repo
3. Test with `pre-commit run --all-files`
4. Commit changes

### Creating Custom Hooks

1. Create script in `hooks/` directory
2. Make executable: `chmod +x hooks/my-hook.sh`
3. Add to `.pre-commit-config.yaml` under `repo: local`
4. Test with `pre-commit run my-hook`

Example custom hook:

```yaml
- repo: local
  hooks:
    - id: my-custom-check
      name: My custom check
      entry: ./hooks/my-hook.sh
      language: system
      pass_filenames: false
      files: '\.sh$'
```

## CI/CD Integration

Pre-commit hooks also run in GitHub Actions (see `.github/workflows/ci.yml`).

This ensures that:
- All contributors follow same standards
- No commits bypass the checks
- PRs are automatically validated

## References

- [Pre-commit documentation](https://pre-commit.com/)
- [Available hooks](https://pre-commit.com/hooks.html)
- [ShellCheck documentation](https://www.shellcheck.net/)
- [Ruff documentation](https://docs.astral.sh/ruff/)
- [ESLint documentation](https://eslint.org/)
- [Prettier documentation](https://prettier.io/)

## Support

For issues with pre-commit setup, check:

1. Run `pre-commit --version` to verify installation
2. Run `pre-commit clean` to clear cache
3. Run `pre-commit install --install-hooks` to reinstall
4. Check hook output for specific error messages

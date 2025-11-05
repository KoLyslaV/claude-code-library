# {{PROJECT_NAME}} - Python CLI Tool

**Tech Stack:** Python 3.11+, Click, pytest, Poetry

---

## **CRITICAL RULES - READ FIRST!** 🚨

### 1. **ALWAYS Discovery Before Action** 🔴

BEFORE any code change:

```bash
# Step 1: Find Python files
fd "\.py$" src/

# Step 2: Search for patterns
rg "class|def" src/

# Step 3: Get symbol overview (use Serena)
mcp__serena__get_symbols_overview("src/{{PROJECT_NAME}}/cli.py")
mcp__serena__find_symbol("/CommandGroup")
```

**WHY:** Prevents breaking existing code, saves 70% tokens vs reading full files.

### 2. **Use Type Hints Everywhere** 🔴

NEVER: Write functions without type hints
ALWAYS: Use type hints for all function signatures

```python
# ✅ GOOD: Type hints on all parameters and return
def process_file(path: str, verbose: bool = False) -> dict[str, Any]:
    """Process a file and return results."""
    ...

# ❌ BAD: No type hints
def process_file(path, verbose=False):
    ...
```

**WHY:** Better IDE support, catches bugs early, self-documenting code.

### 3. **Use Click for CLI** 🔴

NEVER: Use argparse or sys.argv directly
ALWAYS: Use Click decorators for CLI commands

```python
import click

@click.group()
@click.version_option()
def cli():
    """{{PROJECT_NAME}} - A CLI tool."""
    pass

@cli.command()
@click.argument('file', type=click.Path(exists=True))
@click.option('--verbose', '-v', is_flag=True, help='Verbose output')
def process(file: str, verbose: bool) -> None:
    """Process a file."""
    ...
```

**WHY:** Click provides automatic help, validation, testing support.

### 4. **Test Everything with pytest** 🔴

NEVER: Skip writing tests for new features
ALWAYS: Write pytest tests with proper fixtures

```python
# tests/test_cli.py
from click.testing import CliRunner
from {{PROJECT_NAME}}.cli import cli

def test_process_command():
    runner = CliRunner()
    result = runner.invoke(cli, ['process', 'test.txt'])
    assert result.exit_code == 0
```

**WHY:** CLI tools are easy to break, tests catch regressions.

### 5. **Use Context7 for Libraries** 🔴

When working with external libraries:

```bash
"How does Click option validation work? use context7"
"How to use pytest fixtures? use context7"
```

**WHY:** Always get up-to-date library documentation.

---

## Project Overview

{{PROJECT_NAME}} is a Python CLI tool built with Click and best practices.

### Key Features
- 🚀 **Fast CLI** - Click for instant command parsing
- ✅ **Type-Safe** - Full type hints with mypy validation
- 🧪 **Well-Tested** - pytest with 90%+ coverage
- 📦 **Poetry** - Modern dependency management
- 🎨 **Rich Output** - Colorful terminal output

---

## Directory Structure

```
src/{{PROJECT_NAME}}/
├── __init__.py       # Package initialization
├── __main__.py       # Entry point (python -m {{PROJECT_NAME}})
├── cli.py            # Click CLI definitions
├── commands/         # CLI command modules
│   ├── __init__.py
│   └── process.py    # Example command
└── utils/            # Utility functions
    ├── __init__.py
    └── helpers.py

tests/
├── __init__.py
├── conftest.py       # pytest fixtures
├── test_cli.py       # CLI tests
└── test_utils.py     # Utility tests

pyproject.toml        # Poetry configuration
README.md             # User documentation
.claude/              # Claude Code documentation
```

---

## Development Workflow

### Discovery Phase (ALWAYS FIRST)
```bash
# 1. Find relevant files
fd "cli" src/

# 2. Search for patterns
rg "def|class" src/

# 3. Get symbol overview (use Serena)
mcp__serena__get_symbols_overview("src/{{PROJECT_NAME}}/cli.py")
```

### Development Commands
```bash
# Install dependencies
poetry install

# Run CLI in development
poetry run {{PROJECT_NAME}} --help
# OR
python -m {{PROJECT_NAME}} --help

# Run tests
poetry run pytest

# Run tests with coverage
poetry run pytest --cov={{PROJECT_NAME}}

# Type checking
poetry run mypy src/

# Linting
poetry run ruff check src/
```

---

## Code Patterns

### Pattern 1: Click Command Group
```python
# src/{{PROJECT_NAME}}/cli.py
import click
from .commands import process

@click.group()
@click.version_option()
@click.pass_context
def cli(ctx: click.Context) -> None:
    """{{PROJECT_NAME}} - A powerful CLI tool."""
    ctx.ensure_object(dict)

# Register commands
cli.add_command(process.process_cmd)

if __name__ == '__main__':
    cli()
```

### Pattern 2: Command with Options and Arguments
```python
# src/{{PROJECT_NAME}}/commands/process.py
import click
from pathlib import Path
from typing import Optional

@click.command('process')
@click.argument('input_file', type=click.Path(exists=True, path_type=Path))
@click.option('--output', '-o', type=click.Path(path_type=Path),
              help='Output file path')
@click.option('--verbose', '-v', is_flag=True, help='Verbose output')
@click.option('--format', type=click.Choice(['json', 'csv', 'txt']),
              default='json', help='Output format')
def process_cmd(
    input_file: Path,
    output: Optional[Path],
    verbose: bool,
    format: str
) -> None:
    """Process INPUT_FILE and optionally save to OUTPUT."""
    if verbose:
        click.echo(f"Processing {input_file}...")

    # Your logic here
    result = process_file(input_file, format)

    if output:
        output.write_text(result)
        click.secho(f"Saved to {output}", fg='green')
    else:
        click.echo(result)
```

### Pattern 3: pytest with Click Testing
```python
# tests/test_cli.py
import pytest
from click.testing import CliRunner
from {{PROJECT_NAME}}.cli import cli
from pathlib import Path

@pytest.fixture
def runner():
    return CliRunner()

@pytest.fixture
def temp_input(tmp_path):
    """Create temporary input file."""
    file = tmp_path / "input.txt"
    file.write_text("test content")
    return file

def test_process_command(runner, temp_input):
    result = runner.invoke(cli, ['process', str(temp_input)])
    assert result.exit_code == 0
    assert 'Processing' not in result.output  # verbose=False by default

def test_process_verbose(runner, temp_input):
    result = runner.invoke(cli, ['process', str(temp_input), '--verbose'])
    assert result.exit_code == 0
    assert 'Processing' in result.output
```

---

## Anti-Patterns to Avoid

### AP1: No Type Hints
❌ **DON'T:** Skip type hints
✅ **DO:** Use type hints everywhere

### AP2: Manual Argument Parsing
❌ **DON'T:** Use sys.argv or argparse
✅ **DO:** Use Click decorators

### AP3: No Tests
❌ **DON'T:** Ship untested code
✅ **DO:** Write pytest tests for all commands

### AP4: Hardcoded Paths
❌ **DON'T:** Use hardcoded strings for paths
✅ **DO:** Use pathlib.Path

### AP5: Poor Error Handling
❌ **DON'T:** Let exceptions crash the CLI
✅ **DO:** Use try/except with click.echo() for user-friendly errors

---

## Testing & Quality

### Run All Checks
```bash
# Type checking
poetry run mypy src/

# Linting
poetry run ruff check src/

# Tests with coverage
poetry run pytest --cov={{PROJECT_NAME}} --cov-report=html

# All at once
poetry run pytest && poetry run mypy src/ && poetry run ruff check src/
```

### Coverage Target
- Aim for 90%+ test coverage
- 100% coverage for critical paths

---

## Deployment

### Build Package
```bash
# Build wheel and sdist
poetry build

# Output: dist/{{PROJECT_NAME}}-0.1.0.tar.gz
#         dist/{{PROJECT_NAME}}-0.1.0-py3-none-any.whl
```

### Install from Source
```bash
# Install in editable mode
poetry install

# Install from built wheel
pip install dist/{{PROJECT_NAME}}-0.1.0-py3-none-any.whl
```

### Publish to PyPI
```bash
# Configure PyPI token
poetry config pypi-token.pypi <your-token>

# Publish
poetry publish --build
```

---

## Resources

- [Click Documentation](https://click.palletsprojects.com/) - CLI framework
- [pytest Documentation](https://docs.pytest.org/) - Testing framework
- [Poetry Documentation](https://python-poetry.org/docs/) - Dependency management
- [mypy Documentation](https://mypy.readthedocs.io/) - Type checking

---

**Last Updated:** {{DATE}}
**Python Version:** 3.11+
**Poetry Version:** 1.7+

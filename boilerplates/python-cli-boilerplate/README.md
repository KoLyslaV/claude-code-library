# {{PROJECT_NAME}}

A Python CLI tool built with Click and best practices.

## Installation

```bash
# Using Poetry
poetry install

# Using pip
pip install .
```

## Usage

```bash
# Run CLI
{{PROJECT_NAME}} --help

# Example commands
{{PROJECT_NAME}} hello
{{PROJECT_NAME}} hello Alice
{{PROJECT_NAME}} demo --count 3 --verbose
```

## Development

```bash
# Install dependencies
poetry install

# Run tests
poetry run pytest

# Run tests with coverage
poetry run pytest --cov={{PROJECT_NAME}}

# Type checking
poetry run mypy src/

# Linting
poetry run ruff check src/
```

## Project Structure

```
src/{{PROJECT_NAME}}/
├── __init__.py       # Package initialization
├── __main__.py       # Entry point (python -m {{PROJECT_NAME}})
├── cli.py            # Click CLI definitions
```

## License

MIT

# HANDOFF - {{PROJECT_NAME}}

## Project Overview

**Project Name**: {{PROJECT_NAME}}
**Type**: Python CLI Tool
**Version**: {{VERSION}}
**Status**: Development
**Last Updated**: {{DATE}}

## Quick Start

```bash
# Install dependencies
poetry install

# Run CLI
poetry run {{PROJECT_NAME}} --help

# Run tests
poetry run pytest

# Type checking
poetry run mypy src/

# Linting
poetry run ruff check src/
```

## Architecture

### Project Structure
```
{{PROJECT_NAME}}/
├── src/{{PROJECT_NAME}}/
│   ├── __init__.py       # Package initialization
│   ├── __main__.py       # Entry point
│   ├── cli.py            # Click CLI commands
│   ├── commands/         # Command implementations
│   ├── utils/            # Utility functions
│   └── config.py         # Configuration management
├── tests/                # Test files
├── pyproject.toml        # Poetry configuration
└── README.md             # Documentation
```

### Key Components

1. **CLI Interface** (`cli.py`)
   - Built with Click framework
   - Command groups and subcommands
   - Options and arguments with validation

2. **Commands** (`commands/`)
   - Each command in separate module
   - Consistent error handling
   - Rich output formatting

3. **Configuration** (`config.py`)
   - Application settings
   - User preferences
   - Environment variables

4. **Utilities** (`utils/`)
   - Helper functions
   - Common operations
   - Shared logic

## Current State

### Completed
- ✅ Project structure setup
- ✅ Click integration
- ✅ Poetry configuration
- ✅ Basic test framework
- ✅ Type hints with mypy
- ✅ Linting with ruff

### In Progress
- 🔄 Core CLI commands implementation
- 🔄 Comprehensive error handling
- 🔄 Unit test coverage

### Pending
- ⏳ Integration tests
- ⏳ Documentation
- ⏳ Shell completion support

## Dependencies

### Core
- **click**: ^8.1.7 - CLI framework
- **python**: ^3.11 - Python version

### Development
- **pytest**: ^8.3.0 - Testing framework
- **mypy**: ^1.13.0 - Type checking
- **ruff**: ^0.8.0 - Linting and formatting

## Configuration

### Environment Variables
```bash
# Add your environment variables here
# EXAMPLE_VAR=value
```

### User Configuration
Default config location: `~/.{{PROJECT_NAME}}/config.json`

## Testing

### Run Tests
```bash
# All tests
poetry run pytest

# With coverage
poetry run pytest --cov={{PROJECT_NAME}}

# Specific test file
poetry run pytest tests/test_cli.py

# Verbose output
poetry run pytest -v
```

### Test Coverage
Current coverage: TBD
Target coverage: >80%

## Deployment

### Build Package
```bash
poetry build
```

### Install Locally
```bash
pip install .
```

### Publish to PyPI
```bash
poetry publish
```

## Known Issues

### Current Bugs
- None currently

### Technical Debt
- Need to refactor main CLI module
- Add more comprehensive error handling
- Improve test coverage

## Development Workflow

1. **Adding New Commands**
   - Create command function in `cli.py` or `commands/`
   - Add Click decorators (@click.command, @click.option)
   - Write tests in `tests/`
   - Update documentation

2. **Testing Changes**
   - Write tests first (TDD)
   - Run pytest to verify
   - Check type hints with mypy
   - Run ruff for code quality

3. **Before Committing**
   - Run all tests: `poetry run pytest`
   - Check types: `poetry run mypy src/`
   - Lint code: `poetry run ruff check src/`
   - Format code: `poetry run ruff format src/`

## Performance Considerations

- CLI should respond instantly (<100ms for basic commands)
- Use lazy imports for heavy dependencies
- Cache expensive operations
- Provide progress indicators for long operations

## Security Notes

- Sanitize all user inputs
- Never log sensitive information
- Use secure defaults
- Validate file paths

## Next Steps

See [TODO.md](./TODO.md) for detailed task list.

### Immediate Priorities
1. Implement core CLI commands
2. Add comprehensive error handling
3. Write unit tests for all commands
4. Update README with usage examples

### Future Enhancements
- Add shell completion
- Implement config file support
- Add output formatting options
- Create interactive mode

## Resources

- [Click Documentation](https://click.palletsprojects.com/)
- [Poetry Documentation](https://python-poetry.org/docs/)
- [pytest Documentation](https://docs.pytest.org/)
- [Python Type Hints](https://docs.python.org/3/library/typing.html)

## Contact

For questions or issues, refer to project documentation or open an issue.

---

**Handoff Date**: {{DATE}}
**Status**: Ready for development
**Priority**: Medium

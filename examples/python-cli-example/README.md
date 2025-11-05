# Todo CLI - Python CLI Example

A feature-rich command-line todo list application demonstrating professional Python CLI development with Click, Poetry, and Rich.

![Python Version](https://img.shields.io/badge/python-3.11%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- ✨ **Rich Terminal UI** - Beautiful colored output with tables and formatting
- 📝 **Full CRUD Operations** - Add, list, update, delete, and complete tasks
- 🏷️ **Categories & Priorities** - Organize tasks with custom categories and priority levels
- 📅 **Due Dates** - Set and track due dates with overdue indicators
- 📊 **Statistics Dashboard** - View task completion rates and breakdowns
- 🔍 **Filtering** - Filter tasks by status, category, and priority
- 💾 **JSON Storage** - Simple file-based persistence in `~/.todocli/todos.json`
- 🎯 **Partial ID Matching** - Use just the first few characters of task IDs

## Quick Start

```bash
# Install dependencies
poetry install

# Run the CLI
poetry run todocli --help

# Or use the shorter alias
poetry run todo --help

# Add your first task
poetry run todocli add "Complete project documentation" -p high --due 2025-01-20

# List all active tasks
poetry run todocli list

# Mark a task as complete (use partial ID)
poetry run todocli complete abc123

# View statistics
poetry run todocli stats
```

## Installation

### Using Poetry (Recommended)

```bash
# Install dependencies
poetry install

# The CLI is now available via two entry points:
poetry run todocli   # Full name
poetry run todo      # Short alias
```

### Using pip

```bash
# Install in development mode
pip install -e .

# Or install from the built package
poetry build
pip install dist/todocli-1.0.0-py3-none-any.whl
```

## Usage

### Add Tasks

```bash
# Basic task
todocli add "Buy groceries"

# Task with description
todocli add "Deploy website" -d "Update production server with latest changes"

# Task with priority
todocli add "Fix critical bug" -p high

# Task with category
todocli add "Review pull request" -c work

# Task with due date (YYYY-MM-DD format)
todocli add "Submit report" --due 2025-01-25

# Combine multiple options
todocli add "Prepare presentation" \
  -d "Create slides for quarterly review" \
  -p high \
  -c work \
  --due 2025-01-22
```

### List Tasks

```bash
# List all active (incomplete) tasks
todocli list

# List all tasks including completed
todocli list --all

# Filter by category
todocli list -c work

# Filter by priority
todocli list -p high

# Combine filters
todocli list -c work -p high --all
```

**Example Output:**
```
┏━━━━━━━━┳━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━┳━━━━━━━━━━━━┳━━━━━━━━━━━━┓
┃ ID     ┃ ✓ ┃ Title                    ┃ Priority┃ Category   ┃ Due Date   ┃
┡━━━━━━━━╇━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━╇━━━━━━━━━━━━╇━━━━━━━━━━━━┩
│ abc12345│ [ ]│ Fix critical bug         │ high   │ work       │ -          │
│ def67890│ [ ]│ Deploy website           │ medium │ work       │ 2025-01-20 │
│ ghi24680│ [ ]│ Buy groceries            │ low    │ personal   │ 2025-01-15⚠│
└────────┴───┴──────────────────────────┴────────┴────────────┴────────────┘

Total: 3 task(s) | Active: 3 | Completed: 0
```

### Complete Tasks

```bash
# Mark task as complete (use partial ID)
todocli complete abc123

# Mark task as incomplete (reopen)
todocli uncomplete abc123
```

### View Task Details

```bash
# Show full details of a specific task
todocli show abc123
```

**Example Output:**
```
ID           abc12345-6789-1011-1213-141516171819
Title        Fix critical bug
Status       ⏸ Active
Description  Memory leak in user session management
Priority     high
Category     work
Due Date     2025-01-20
Created      2025-01-15 09:30:00
```

### Delete Tasks

```bash
# Delete a task (requires confirmation)
todocli delete abc123

# The CLI will ask for confirmation:
# Are you sure you want to delete this todo? [y/N]:
```

### Clear Completed Tasks

```bash
# Remove all completed tasks (requires confirmation)
todocli clear
```

### View Statistics

```bash
# Display comprehensive task statistics
todocli stats
```

**Example Output:**
```
┏━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━┓
┃ Metric           ┃ Value        ┃
┡━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━┩
│ Total Tasks      │ 15           │
│ Active Tasks     │ 8            │
│ Completed Tasks  │ 7            │
│ Completion Rate  │ 46.7%        │
│                  │              │
│ High Priority    │ 2            │
│ Medium Priority  │ 4            │
│ Low Priority     │ 2            │
│                  │              │
│ Overdue Tasks    │ 1 ⚠          │
└──────────────────┴──────────────┘

Active Tasks by Category:
  • work: 5
  • personal: 2
  • shopping: 1
```

## What This Example Demonstrates

### Click Framework
- **Command Groups** - Organizing multiple commands under a single CLI
- **Arguments** - Required positional parameters (`title`)
- **Options** - Optional flags with defaults (`-p`, `--priority`)
- **Choices** - Enum-like validation (`type=click.Choice()`)
- **Confirmation Prompts** - User confirmation for destructive actions
- **Version Options** - Built-in version display

### Rich Library
- **Console Output** - Colored text with Rich markup (`[green]✓[/green]`)
- **Tables** - Professional-looking data tables with headers
- **Styling** - Priority-based color coding and formatting
- **Icons** - Status indicators (✓, ⚠, ⏸)
- **Progress Indicators** - Visual feedback for operations

### Python Best Practices
- **Dataclasses** - Type-safe data models with defaults
- **Enums** - Type-safe priority levels
- **Type Hints** - Full type annotations throughout
- **Properties** - Computed attributes (`is_overdue`)
- **Error Handling** - JSON corruption recovery with backups
- **File Management** - Path handling with `pathlib`

### CLI Patterns
- **Partial ID Matching** - User-friendly ID inputs
- **Multiple Filters** - Composable filter options
- **Consistent Feedback** - Clear success/error messages
- **Help Text** - Comprehensive `--help` documentation
- **Multiple Entry Points** - Both `todocli` and `todo` commands

## Key Patterns

### Data Persistence
```python
class TodoStorage:
    """Manage todo storage in JSON file."""

    def __init__(self, data_file: str = "~/.todocli/todos.json"):
        self.data_file = Path(data_file).expanduser()
        self.data_file.parent.mkdir(parents=True, exist_ok=True)

    def load(self) -> List[Todo]:
        """Load todos from JSON file with corruption recovery."""
        try:
            with open(self.data_file, "r") as f:
                data = json.load(f)
                return [Todo.from_dict(item) for item in data]
        except (json.JSONDecodeError, KeyError, ValueError):
            # Backup corrupted file
            backup = self.data_file.with_suffix(".json.bak")
            if self.data_file.exists():
                self.data_file.rename(backup)
            return []
```

### Type-Safe Models
```python
from dataclasses import dataclass, field
from enum import Enum

class Priority(str, Enum):
    """Task priority levels."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"

@dataclass
class Todo:
    """Todo item with all attributes."""
    id: str = field(default_factory=lambda: str(uuid4()))
    title: str = ""
    priority: Priority = Priority.MEDIUM
    completed: bool = False

    @property
    def is_overdue(self) -> bool:
        """Check if todo is overdue."""
        if self.completed or not self.due_date:
            return False
        due = datetime.fromisoformat(self.due_date)
        return due < datetime.now()
```

### Rich Table Output
```python
from rich.console import Console
from rich.table import Table

console = Console()

table = Table(show_header=True, header_style="bold magenta")
table.add_column("ID", style="dim", width=8)
table.add_column("✓", width=3)
table.add_column("Title")
table.add_column("Priority", width=8)

for todo in todos:
    priority_color = {
        "high": "red",
        "medium": "yellow",
        "low": "green"
    }[todo.priority.value]

    table.add_row(
        todo.id[:8],
        "[green]✓[/green]" if todo.completed else "[ ]",
        todo.title,
        f"[{priority_color}]{todo.priority.value}[/{priority_color}]"
    )

console.print(table)
```

### Partial ID Matching
```python
@cli.command()
@click.argument("todo_id")
def complete(todo_id: str) -> None:
    """Mark a todo as completed."""
    storage = TodoStorage()
    todos = storage.load()

    # Find by partial ID match
    matching = [t for t in todos if t.id.startswith(todo_id)]

    if not matching:
        console.print(f"[red]Todo not found: {todo_id}[/red]")
        return

    if len(matching) > 1:
        console.print(f"[yellow]Multiple matches found. Be more specific.[/yellow]")
        return

    todo = matching[0]
    todo.completed = True
    storage.update(todo)
```

## Development

### Setup Development Environment

```bash
# Install dependencies including dev tools
poetry install

# Activate virtual environment
poetry shell

# Install pre-commit hooks (if configured)
pre-commit install
```

### Running Tests

```bash
# Run all tests
poetry run pytest

# Run with coverage report
poetry run pytest --cov=todocli --cov-report=html

# Run with verbose output
poetry run pytest -v

# Run specific test file
poetry run pytest tests/test_cli.py
```

### Type Checking

```bash
# Check types with mypy
poetry run mypy src/

# Check specific file
poetry run mypy src/todocli/cli.py
```

### Linting

```bash
# Check code style with ruff
poetry run ruff check src/

# Auto-fix issues
poetry run ruff check --fix src/

# Format code
poetry run ruff format src/
```

## Project Structure

```
python-cli-example/
├── src/
│   └── todocli/
│       ├── __init__.py      # Package initialization
│       ├── __main__.py      # Entry point (python -m todocli)
│       ├── cli.py           # Click CLI commands (8 commands)
│       ├── models.py        # Data models (Todo, Priority, Config)
│       └── storage.py       # JSON persistence (TodoStorage, ConfigStorage)
├── tests/
│   ├── __init__.py
│   ├── test_cli.py          # CLI command tests
│   ├── test_models.py       # Model tests
│   └── test_storage.py      # Storage tests
├── pyproject.toml           # Poetry configuration
├── README.md                # This file
└── .env.example             # Environment variables template
```

## Configuration

The CLI stores data in `~/.todocli/`:
- `todos.json` - Task data
- `config.json` - User preferences (future)
- `*.json.bak` - Automatic backups of corrupted files

You can customize the data file location:
```python
storage = TodoStorage(data_file="/custom/path/todos.json")
```

## Troubleshooting

### Command not found
If `todocli` command is not found after installation:
```bash
# Use poetry run
poetry run todocli --help

# Or activate the virtual environment
poetry shell
todocli --help
```

### Permission denied on ~/.todocli
```bash
# Check directory permissions
ls -la ~/.todocli

# Fix permissions if needed
chmod 755 ~/.todocli
chmod 644 ~/.todocli/todos.json
```

### JSON corruption
The CLI automatically backs up corrupted files:
```bash
# Check for backup
ls ~/.todocli/*.bak

# Restore from backup if needed
cp ~/.todocli/todos.json.bak ~/.todocli/todos.json
```

### Invalid date format
Due dates must be in YYYY-MM-DD format:
```bash
# ✅ Correct
todocli add "Task" --due 2025-01-20

# ❌ Wrong
todocli add "Task" --due 20/01/2025
```

## Time Saved with This Boilerplate

Building this CLI from scratch typically takes:
- ⏱️ **Without boilerplate**: ~12 hours
  - Poetry setup: 1 hour
  - Click configuration: 2 hours
  - Data models: 1.5 hours
  - Storage implementation: 2 hours
  - CLI commands: 3 hours
  - Rich formatting: 1.5 hours
  - Testing setup: 1 hour

- ⚡ **With this boilerplate**: ~4 hours
  - Understanding structure: 30 min
  - Customizing models: 1 hour
  - Implementing commands: 1.5 hours
  - Adding Rich formatting: 1 hour

**Time saved: 8 hours** (66% reduction)

## Tech Stack

- **Python**: 3.11+
- **Click**: 8.1.7 - CLI framework
- **Rich**: 13.7.0 - Terminal formatting
- **Poetry**: Dependency management
- **pytest**: 8.3.0 - Testing framework
- **mypy**: 1.13.0 - Type checking
- **ruff**: 0.8.0 - Linting and formatting

## License

MIT

## Credits

Built as part of the Claude Code Library to demonstrate professional Python CLI development patterns.

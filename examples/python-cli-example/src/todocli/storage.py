"""Storage management for todos."""

import json
from pathlib import Path
from typing import List

from .models import Config, Todo


class TodoStorage:
    """Manage todo storage in JSON file."""

    def __init__(self, data_file: str = "~/.todocli/todos.json"):
        """Initialize storage with data file path."""
        self.data_file = Path(data_file).expanduser()
        self.data_file.parent.mkdir(parents=True, exist_ok=True)

    def load(self) -> List[Todo]:
        """Load todos from JSON file."""
        if not self.data_file.exists():
            return []

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

    def save(self, todos: List[Todo]) -> None:
        """Save todos to JSON file."""
        self.data_file.parent.mkdir(parents=True, exist_ok=True)

        with open(self.data_file, "w") as f:
            json.dump([todo.to_dict() for todo in todos], f, indent=2)

    def add(self, todo: Todo) -> None:
        """Add a new todo."""
        todos = self.load()
        todos.append(todo)
        self.save(todos)

    def get(self, todo_id: str) -> Todo | None:
        """Get a todo by ID."""
        todos = self.load()
        for todo in todos:
            if todo.id == todo_id:
                return todo
        return None

    def update(self, todo: Todo) -> bool:
        """Update an existing todo."""
        todos = self.load()
        for i, t in enumerate(todos):
            if t.id == todo.id:
                todos[i] = todo
                self.save(todos)
                return True
        return False

    def delete(self, todo_id: str) -> bool:
        """Delete a todo by ID."""
        todos = self.load()
        for i, todo in enumerate(todos):
            if todo.id == todo_id:
                todos.pop(i)
                self.save(todos)
                return True
        return False

    def clear_completed(self) -> int:
        """Delete all completed todos."""
        todos = self.load()
        initial_count = len(todos)
        todos = [todo for todo in todos if not todo.completed]
        self.save(todos)
        return initial_count - len(todos)


class ConfigStorage:
    """Manage application configuration."""

    def __init__(self, config_file: str = "~/.todocli/config.json"):
        """Initialize config storage."""
        self.config_file = Path(config_file).expanduser()
        self.config_file.parent.mkdir(parents=True, exist_ok=True)

    def load(self) -> Config:
        """Load config from JSON file."""
        if not self.config_file.exists():
            return Config()

        try:
            with open(self.config_file, "r") as f:
                data = json.load(f)
                return Config.from_dict(data)
        except (json.JSONDecodeError, KeyError, ValueError):
            return Config()

    def save(self, config: Config) -> None:
        """Save config to JSON file."""
        self.config_file.parent.mkdir(parents=True, exist_ok=True)

        with open(self.config_file, "w") as f:
            json.dump(config.to_dict(), f, indent=2)

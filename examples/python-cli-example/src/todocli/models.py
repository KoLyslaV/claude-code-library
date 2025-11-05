"""Data models for the Todo CLI application."""

from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from typing import Optional
from uuid import uuid4


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
    description: str = ""
    completed: bool = False
    priority: Priority = Priority.MEDIUM
    category: str = ""
    due_date: Optional[str] = None
    created_at: str = field(default_factory=lambda: datetime.now().isoformat())
    completed_at: Optional[str] = None

    def to_dict(self) -> dict:
        """Convert todo to dictionary."""
        return {
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "completed": self.completed,
            "priority": self.priority.value if isinstance(self.priority, Priority) else self.priority,
            "category": self.category,
            "due_date": self.due_date,
            "created_at": self.created_at,
            "completed_at": self.completed_at,
        }

    @classmethod
    def from_dict(cls, data: dict) -> "Todo":
        """Create todo from dictionary."""
        data_copy = data.copy()
        if "priority" in data_copy and isinstance(data_copy["priority"], str):
            data_copy["priority"] = Priority(data_copy["priority"])
        return cls(**data_copy)

    @property
    def is_overdue(self) -> bool:
        """Check if todo is overdue."""
        if self.completed or not self.due_date:
            return False
        try:
            due = datetime.fromisoformat(self.due_date)
            return due < datetime.now()
        except (ValueError, TypeError):
            return False


@dataclass
class Config:
    """Application configuration."""

    data_file: str = "~/.todocli/todos.json"
    default_priority: Priority = Priority.MEDIUM
    show_completed: bool = True
    sort_by: str = "created_at"
    sort_order: str = "desc"

    def to_dict(self) -> dict:
        """Convert config to dictionary."""
        return {
            "data_file": self.data_file,
            "default_priority": self.default_priority.value,
            "show_completed": self.show_completed,
            "sort_by": self.sort_by,
            "sort_order": self.sort_order,
        }

    @classmethod
    def from_dict(cls, data: dict) -> "Config":
        """Create config from dictionary."""
        data_copy = data.copy()
        if "default_priority" in data_copy:
            data_copy["default_priority"] = Priority(data_copy["default_priority"])
        return cls(**data_copy)

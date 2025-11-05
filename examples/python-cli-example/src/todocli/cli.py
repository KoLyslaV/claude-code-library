"""CLI interface for the Todo application."""

from datetime import datetime
from typing import Optional

import click
from rich.console import Console
from rich.table import Table

from .models import Priority, Todo
from .storage import ConfigStorage, TodoStorage

console = Console()


@click.group()
@click.version_option(version="1.0.0")
def cli() -> None:
    """A feature-rich Todo CLI application.

    Manage your tasks efficiently with priorities, categories, and due dates.
    """
    pass


@cli.command()
@click.argument("title")
@click.option(
    "-d", "--description", default="", help="Task description"
)
@click.option(
    "-p",
    "--priority",
    type=click.Choice(["low", "medium", "high"], case_sensitive=False),
    default="medium",
    help="Task priority",
)
@click.option("-c", "--category", default="", help="Task category")
@click.option("--due", help="Due date (YYYY-MM-DD)")
def add(
    title: str, description: str, priority: str, category: str, due: Optional[str]
) -> None:
    """Add a new todo item."""
    storage = TodoStorage()

    # Validate due date
    if due:
        try:
            datetime.fromisoformat(due)
        except ValueError:
            console.print("[red]Invalid date format. Use YYYY-MM-DD[/red]")
            return

    todo = Todo(
        title=title,
        description=description,
        priority=Priority(priority),
        category=category,
        due_date=due,
    )

    storage.add(todo)
    console.print(f"[green]✓[/green] Added: {title}")


@cli.command()
@click.option("-a", "--all", "show_all", is_flag=True, help="Show completed tasks")
@click.option("-c", "--category", help="Filter by category")
@click.option(
    "-p",
    "--priority",
    type=click.Choice(["low", "medium", "high"], case_sensitive=False),
    help="Filter by priority",
)
def list(show_all: bool, category: Optional[str], priority: Optional[str]) -> None:
    """List all todo items."""
    storage = TodoStorage()
    todos = storage.load()

    # Apply filters
    if not show_all:
        todos = [t for t in todos if not t.completed]
    if category:
        todos = [t for t in todos if t.category.lower() == category.lower()]
    if priority:
        todos = [t for t in todos if t.priority.value == priority.lower()]

    if not todos:
        console.print("[yellow]No tasks found[/yellow]")
        return

    # Sort by priority (high -> medium -> low) then by created date
    priority_order = {"high": 0, "medium": 1, "low": 2}
    todos.sort(
        key=lambda t: (
            t.completed,
            priority_order.get(t.priority.value, 1),
            t.created_at,
        )
    )

    # Create table
    table = Table(show_header=True, header_style="bold magenta")
    table.add_column("ID", style="dim", width=8)
    table.add_column("✓", width=3)
    table.add_column("Title")
    table.add_column("Priority", width=8)
    table.add_column("Category", width=12)
    table.add_column("Due Date", width=12)

    for todo in todos:
        # Color coding
        priority_colors = {
            "high": "red",
            "medium": "yellow",
            "low": "green",
        }
        priority_color = priority_colors.get(todo.priority.value, "white")

        # Status icon
        status = "[green]✓[/green]" if todo.completed else "[ ]"

        # Title styling
        title_style = "dim" if todo.completed else ""
        title = f"[{title_style}]{todo.title}[/{title_style}]"

        # Due date with overdue indicator
        due_date = ""
        if todo.due_date:
            due_date = todo.due_date
            if todo.is_overdue:
                due_date = f"[red]{due_date} ⚠[/red]"

        table.add_row(
            todo.id[:8],
            status,
            title,
            f"[{priority_color}]{todo.priority.value}[/{priority_color}]",
            todo.category or "-",
            due_date or "-",
        )

    console.print(table)
    console.print(
        f"\n[dim]Total: {len(todos)} task(s) | "
        f"Active: {sum(1 for t in todos if not t.completed)} | "
        f"Completed: {sum(1 for t in todos if t.completed)}[/dim]"
    )


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
    todo.completed_at = datetime.now().isoformat()

    if storage.update(todo):
        console.print(f"[green]✓[/green] Completed: {todo.title}")
    else:
        console.print(f"[red]Failed to update todo[/red]")


@cli.command()
@click.argument("todo_id")
def uncomplete(todo_id: str) -> None:
    """Mark a completed todo as incomplete."""
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
    todo.completed = False
    todo.completed_at = None

    if storage.update(todo):
        console.print(f"[green]✓[/green] Reopened: {todo.title}")
    else:
        console.print(f"[red]Failed to update todo[/red]")


@cli.command()
@click.argument("todo_id")
@click.confirmation_option(prompt="Are you sure you want to delete this todo?")
def delete(todo_id: str) -> None:
    """Delete a todo item."""
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

    if storage.delete(todo.id):
        console.print(f"[green]✓[/green] Deleted: {todo.title}")
    else:
        console.print(f"[red]Failed to delete todo[/red]")


@cli.command()
@click.confirmation_option(prompt="Are you sure you want to clear all completed todos?")
def clear() -> None:
    """Clear all completed todos."""
    storage = TodoStorage()
    count = storage.clear_completed()
    console.print(f"[green]✓[/green] Cleared {count} completed todo(s)")


@cli.command()
def stats() -> None:
    """Show todo statistics."""
    storage = TodoStorage()
    todos = storage.load()

    total = len(todos)
    completed = sum(1 for t in todos if t.completed)
    active = total - completed

    # Priority breakdown
    high = sum(1 for t in todos if t.priority == Priority.HIGH and not t.completed)
    medium = sum(1 for t in todos if t.priority == Priority.MEDIUM and not t.completed)
    low = sum(1 for t in todos if t.priority == Priority.LOW and not t.completed)

    # Overdue
    overdue = sum(1 for t in todos if t.is_overdue)

    # Categories
    categories = {}
    for todo in todos:
        if todo.category and not todo.completed:
            categories[todo.category] = categories.get(todo.category, 0) + 1

    # Completion rate
    completion_rate = (completed / total * 100) if total > 0 else 0

    # Display stats
    table = Table(show_header=True, header_style="bold cyan")
    table.add_column("Metric", style="bold")
    table.add_column("Value", justify="right")

    table.add_row("Total Tasks", str(total))
    table.add_row("Active Tasks", f"[yellow]{active}[/yellow]")
    table.add_row("Completed Tasks", f"[green]{completed}[/green]")
    table.add_row("Completion Rate", f"{completion_rate:.1f}%")
    table.add_row("", "")
    table.add_row("High Priority", f"[red]{high}[/red]")
    table.add_row("Medium Priority", f"[yellow]{medium}[/yellow]")
    table.add_row("Low Priority", f"[green]{low}[/green]")

    if overdue > 0:
        table.add_row("", "")
        table.add_row("Overdue Tasks", f"[red bold]{overdue} ⚠[/red bold]")

    console.print(table)

    if categories:
        console.print("\n[bold]Active Tasks by Category:[/bold]")
        for cat, count in sorted(categories.items(), key=lambda x: x[1], reverse=True):
            console.print(f"  • {cat}: {count}")


@cli.command()
@click.argument("todo_id")
def show(todo_id: str) -> None:
    """Show detailed information about a todo."""
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

    # Create details table
    table = Table(show_header=False, box=None, padding=(0, 2))
    table.add_column("Field", style="bold cyan")
    table.add_column("Value")

    status = "✓ Completed" if todo.completed else "⏸ Active"
    status_color = "green" if todo.completed else "yellow"

    table.add_row("ID", todo.id)
    table.add_row("Title", todo.title)
    table.add_row("Status", f"[{status_color}]{status}[/{status_color}]")

    if todo.description:
        table.add_row("Description", todo.description)

    priority_colors = {"high": "red", "medium": "yellow", "low": "green"}
    priority_color = priority_colors.get(todo.priority.value, "white")
    table.add_row("Priority", f"[{priority_color}]{todo.priority.value}[/{priority_color}]")

    if todo.category:
        table.add_row("Category", todo.category)

    if todo.due_date:
        due_text = todo.due_date
        if todo.is_overdue:
            due_text = f"[red]{due_text} (Overdue!)[/red]"
        table.add_row("Due Date", due_text)

    table.add_row("Created", todo.created_at[:19].replace("T", " "))

    if todo.completed_at:
        table.add_row("Completed", todo.completed_at[:19].replace("T", " "))

    console.print(table)


if __name__ == "__main__":
    cli()

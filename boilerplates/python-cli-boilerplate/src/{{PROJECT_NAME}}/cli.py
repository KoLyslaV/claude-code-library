"""CLI entry point for {{PROJECT_NAME}}."""

import click

from . import __version__


@click.group()
@click.version_option(version=__version__)
@click.pass_context
def cli(ctx: click.Context) -> None:
    """{{PROJECT_NAME}} - A powerful CLI tool.

    Use --help with any command to see detailed usage information.
    """
    ctx.ensure_object(dict)


@cli.command()
@click.argument("name", default="World")
def hello(name: str) -> None:
    """Say hello to NAME (default: World)."""
    click.echo(f"Hello, {name}!")
    click.secho("✨ CLI is working!", fg="green")


@cli.command()
@click.option("--count", "-c", default=1, help="Number of repetitions")
@click.option("--verbose", "-v", is_flag=True, help="Verbose output")
def demo(count: int, verbose: bool) -> None:
    """Demo command to show Click features."""
    for i in range(count):
        if verbose:
            click.echo(f"Iteration {i + 1}/{count}")
        click.secho("Demo command executed!", fg="blue")


if __name__ == "__main__":
    cli()

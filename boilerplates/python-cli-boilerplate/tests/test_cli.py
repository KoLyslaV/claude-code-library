"""Tests for CLI commands."""

from click.testing import CliRunner

from {{PROJECT_NAME}}.cli import cli


def test_cli_help(runner: CliRunner) -> None:
    """Test CLI help message."""
    result = runner.invoke(cli, ["--help"])
    assert result.exit_code == 0
    assert "{{PROJECT_NAME}}" in result.output
    assert "A powerful CLI tool" in result.output


def test_cli_version(runner: CliRunner) -> None:
    """Test CLI version option."""
    result = runner.invoke(cli, ["--version"])
    assert result.exit_code == 0
    assert "version" in result.output.lower()


def test_hello_default(runner: CliRunner) -> None:
    """Test hello command with default argument."""
    result = runner.invoke(cli, ["hello"])
    assert result.exit_code == 0
    assert "Hello, World!" in result.output
    assert "CLI is working!" in result.output


def test_hello_custom_name(runner: CliRunner) -> None:
    """Test hello command with custom name."""
    result = runner.invoke(cli, ["hello", "Alice"])
    assert result.exit_code == 0
    assert "Hello, Alice!" in result.output


def test_demo_default(runner: CliRunner) -> None:
    """Test demo command with default options."""
    result = runner.invoke(cli, ["demo"])
    assert result.exit_code == 0
    assert "Demo command executed!" in result.output


def test_demo_count(runner: CliRunner) -> None:
    """Test demo command with count option."""
    result = runner.invoke(cli, ["demo", "--count", "3"])
    assert result.exit_code == 0
    # Should appear 3 times
    assert result.output.count("Demo command executed!") == 3


def test_demo_verbose(runner: CliRunner) -> None:
    """Test demo command with verbose flag."""
    result = runner.invoke(cli, ["demo", "--verbose"])
    assert result.exit_code == 0
    assert "Iteration" in result.output

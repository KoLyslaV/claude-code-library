"""pytest configuration and fixtures."""

import pytest
from click.testing import CliRunner


@pytest.fixture
def runner():
    """Provide a Click CliRunner for testing CLI commands."""
    return CliRunner()

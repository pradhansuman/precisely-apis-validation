"""Pytest configuration and fixtures for Precisely API E2E tests."""

import pytest
import os
from dotenv import load_dotenv

from precisely_client import PreciselyAPIClient
from test_data import (
    VALID_ADDRESSES,
    VALID_COORDINATES,
    INVALID_ADDRESSES,
    INVALID_COORDINATES,
)


load_dotenv()


@pytest.fixture(scope="session")
def api_client():
    """Create Precisely API client for test session."""
    client = PreciselyAPIClient()
    yield client


@pytest.fixture
def valid_address():
    """Provide a valid address for testing."""
    return VALID_ADDRESSES[0]


@pytest.fixture
def valid_coordinates():
    """Provide valid coordinates for testing."""
    return VALID_COORDINATES[0]


@pytest.fixture
def all_valid_addresses():
    """Provide all valid addresses for parameterized testing."""
    return VALID_ADDRESSES


@pytest.fixture
def all_valid_coordinates():
    """Provide all valid coordinates for parameterized testing."""
    return VALID_COORDINATES


@pytest.fixture
def invalid_address():
    """Provide an invalid address for error case testing."""
    return INVALID_ADDRESSES[0]


@pytest.fixture
def all_invalid_addresses():
    """Provide all invalid addresses for error case testing."""
    return INVALID_ADDRESSES


@pytest.fixture
def all_invalid_coordinates():
    """Provide all invalid coordinates for error case testing."""
    return INVALID_COORDINATES


def pytest_configure(config):
    """Configure pytest with custom markers."""
    config.addinivalue_line(
        "markers", "integration: mark test as an integration test"
    )
    config.addinivalue_line(
        "markers", "happy_path: mark test as testing happy path scenario"
    )
    config.addinivalue_line(
        "markers", "error_case: mark test as testing error handling"
    )
    config.addinivalue_line(
        "markers", "slow: mark test as slow running"
    )

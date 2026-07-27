"""Test fixtures and sample data for Precisely API E2E tests."""

from dataclasses import dataclass


@dataclass
class AddressFixture:
    """Address test fixture."""
    street: str
    city: str
    state: str
    zip_code: str
    country: str = "USA"


@dataclass
class CoordinateFixture:
    """Coordinate test fixture."""
    latitude: float
    longitude: float


# Valid addresses for happy path testing (public locations)
VALID_ADDRESSES = [
    AddressFixture(
        street="1600 Pennsylvania Avenue NW",
        city="Washington",
        state="DC",
        zip_code="20500"
    ),
    AddressFixture(
        street="350 5th Avenue",
        city="New York",
        state="NY",
        zip_code="10118"
    ),
    AddressFixture(
        street="1 Apple Park Way",
        city="Cupertino",
        state="CA",
        zip_code="95014"
    ),
]

# Expected coordinates for reverse geocoding tests
VALID_COORDINATES = [
    CoordinateFixture(latitude=38.8951, longitude=-77.0369),  # Washington, DC
    CoordinateFixture(latitude=40.7489, longitude=-73.9680),  # New York, NY
    CoordinateFixture(latitude=37.3349, longitude=-122.0090),  # Cupertino, CA
]

# Invalid addresses for error case testing
INVALID_ADDRESSES = [
    AddressFixture(
        street="",
        city="",
        state="",
        zip_code=""
    ),
    AddressFixture(
        street="123 Invalid St",
        city="NonexistentCity",
        state="XX",
        zip_code="00000"
    ),
    AddressFixture(
        street="<script>alert('xss')</script>",
        city="Test",
        state="CA",
        zip_code="12345"
    ),
]

# Invalid coordinates for error case testing
INVALID_COORDINATES = [
    CoordinateFixture(latitude=91.0, longitude=0.0),      # Latitude > 90
    CoordinateFixture(latitude=-91.0, longitude=0.0),     # Latitude < -90
    CoordinateFixture(latitude=0.0, longitude=181.0),     # Longitude > 180
    CoordinateFixture(latitude=0.0, longitude=-181.0),    # Longitude < -180
]

# Edge cases
EDGE_CASE_ADDRESSES = [
    AddressFixture(
        street="123 Main St",
        city="Springfield",
        state="IL",
        zip_code="62701"
    ),
    AddressFixture(
        street="999 Long Street Name With Many Words Road",
        city="VeryLongCityNameThatMightCauseIssues",
        state="CA",
        zip_code="12345"
    ),
]

# Expected API response structure validation
EXPECTED_GEOCODING_RESPONSE_FIELDS = [
    "latitude",
    "longitude",
    "accuracy",
]

EXPECTED_ADDRESS_VALIDATION_FIELDS = [
    "street",
    "city",
    "state",
    "zip_code",
]

EXPECTED_REVERSE_GEOCODING_FIELDS = [
    "street",
    "city",
    "state",
]

"""E2E tests for Precisely API Geocoding endpoint."""

import pytest
import requests


@pytest.mark.integration
@pytest.mark.happy_path
class TestGeocodingHappyPath:
    """Happy path tests for geocoding functionality."""

    def test_geocode_single_valid_address(self, api_client, valid_address):
        """Test geocoding a single valid address."""
        result = api_client.geocode_address(valid_address)

        assert result is not None
        assert "latitude" in result
        assert "longitude" in result
        assert isinstance(result["latitude"], (int, float))
        assert isinstance(result["longitude"], (int, float))

    def test_geocode_multiple_valid_addresses(self, api_client, all_valid_addresses):
        """Test geocoding multiple valid addresses."""
        results = []
        for address in all_valid_addresses:
            result = api_client.geocode_address(address)
            results.append(result)

        assert len(results) == len(all_valid_addresses)
        for result in results:
            assert "latitude" in result
            assert "longitude" in result
            assert -90 <= result["latitude"] <= 90
            assert -180 <= result["longitude"] <= 180

    def test_coordinates_within_bounds(self, api_client, valid_address):
        """Test that returned coordinates are within valid bounds."""
        result = api_client.geocode_address(valid_address)

        lat = result["latitude"]
        lon = result["longitude"]

        assert -90 <= lat <= 90, f"Latitude {lat} out of bounds"
        assert -180 <= lon <= 180, f"Longitude {lon} out of bounds"


@pytest.mark.integration
@pytest.mark.error_case
class TestGeocodingErrorCases:
    """Error case tests for geocoding functionality."""

    def test_geocode_empty_address(self, api_client):
        """Test geocoding with empty address fields."""
        from test_data import AddressFixture

        empty_address = AddressFixture(
            street="",
            city="",
            state="",
            zip_code=""
        )

        with pytest.raises(requests.HTTPError) as exc_info:
            api_client.geocode_address(empty_address)

        assert exc_info.value.response.status_code in [400, 422]

    def test_geocode_nonexistent_address(self, api_client):
        """Test geocoding with non-existent address."""
        from test_data import AddressFixture

        fake_address = AddressFixture(
            street="123 Fake Street That Does Not Exist",
            city="FakeCityXYZ",
            state="XX",
            zip_code="99999"
        )

        with pytest.raises(requests.HTTPError) as exc_info:
            api_client.geocode_address(fake_address)

        assert exc_info.value.response.status_code in [404, 400, 422]

    def test_geocode_invalid_characters(self, api_client):
        """Test geocoding with special/invalid characters."""
        from test_data import AddressFixture

        invalid_address = AddressFixture(
            street="<script>alert('xss')</script>",
            city="Test",
            state="CA",
            zip_code="12345"
        )

        try:
            result = api_client.geocode_address(invalid_address)
            assert isinstance(result, dict)
        except requests.HTTPError as e:
            assert e.response.status_code in [400, 422]

import pytest
import requests


@pytest.mark.integration
@pytest.mark.happy_path
class TestReverseGeocodingHappyPath:

    def test_reverse_geocode_valid_coordinate(self, api_client, valid_coordinates):
        result = api_client.reverse_geocode(valid_coordinates)
        assert result is not None
        assert isinstance(result, dict)

    def test_reverse_geocode_multiple_coordinates(self, api_client, all_valid_coordinates):
        results = [api_client.reverse_geocode(coord) for coord in all_valid_coordinates]
        assert len(results) == len(all_valid_coordinates)


@pytest.mark.integration
@pytest.mark.error_case
class TestReverseGeocodingErrorCases:

    def test_reverse_geocode_invalid_latitude(self, api_client):
        from test_data import CoordinateFixture
        invalid = CoordinateFixture(latitude=91.0, longitude=0.0)
        with pytest.raises(requests.HTTPError) as exc:
            api_client.reverse_geocode(invalid)
        assert exc.value.response.status_code in [400, 422]

    def test_reverse_geocode_invalid_longitude(self, api_client):
        from test_data import CoordinateFixture
        invalid = CoordinateFixture(latitude=0.0, longitude=181.0)
        with pytest.raises(requests.HTTPError) as exc:
            api_client.reverse_geocode(invalid)
        assert exc.value.response.status_code in [400, 422]

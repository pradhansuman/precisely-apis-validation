"""E2E tests for Precisely API Address Validation endpoint."""

import pytest
import requests


@pytest.mark.integration
@pytest.mark.happy_path
class TestAddressValidationHappyPath:
    """Happy path tests for address validation."""

    def test_validate_single_valid_address(self, api_client, valid_address):
        result = api_client.validate_address(valid_address)
        assert result is not None
        assert isinstance(result, dict)

    def test_validate_multiple_valid_addresses(self, api_client, all_valid_addresses):
        results = [api_client.validate_address(addr) for addr in all_valid_addresses]
        assert len(results) == len(all_valid_addresses)
        for result in results:
            assert isinstance(result, dict)


@pytest.mark.integration
@pytest.mark.error_case
class TestAddressValidationErrorCases:
    """Error case tests for address validation."""

    def test_validate_empty_address(self, api_client):
        from test_data import AddressFixture

        empty = AddressFixture(street="", city="", state="", zip_code="")
        with pytest.raises(requests.HTTPError) as exc:
            api_client.validate_address(empty)
        assert exc.value.response.status_code in [400, 422]

    def test_validate_nonexistent_address(self, api_client):
        from test_data import AddressFixture

        fake = AddressFixture(
            street="999 Nonexistent Lane",
            city="FakeCityZZZ",
            state="XX",
            zip_code="00000"
        )
        try:
            result = api_client.validate_address(fake)
            assert isinstance(result, dict)
        except requests.HTTPError as e:
            assert e.response.status_code in [400, 404, 422]

    def test_validate_invalid_state_code(self, api_client):
        from test_data import AddressFixture

        invalid_state = AddressFixture(
            street="123 Main St",
            city="Springfield",
            state="ZZ",
            zip_code="62701"
        )
        try:
            result = api_client.validate_address(invalid_state)
            assert isinstance(result, dict)
        except requests.HTTPError as e:
            assert e.response.status_code in [400, 422]

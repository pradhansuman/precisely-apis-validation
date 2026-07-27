"""Precisely API client wrapper for E2E testing."""

import os
import requests
from typing import Dict, Any, Optional

from test_data import AddressFixture, CoordinateFixture


class PreciselyAPIClient:
    """Client for Precisely API endpoints."""

    def __init__(self, api_key: Optional[str] = None, base_url: Optional[str] = None):
        """Initialize Precisely API client.

        Args:
            api_key: Precisely API key (defaults to PRECISELY_API_KEY env var)
            base_url: Base URL for Precisely API (defaults to production)
        """
        self.api_key = api_key or os.getenv("PRECISELY_API_KEY")
        self.base_url = base_url or "https://api.precisely.com"

        if not self.api_key:
            raise ValueError("PRECISELY_API_KEY environment variable not set")

        self.headers = {
            "Authorization": f"ApiKey {self.api_key}",
            "Content-Type": "application/json",
        }

    def geocode_address(self, address: AddressFixture) -> Dict[str, Any]:
        """Geocode an address to coordinates.

        Args:
            address: AddressFixture with street, city, state, zip_code

        Returns:
            Dict with latitude, longitude, and accuracy metadata

        Raises:
            requests.HTTPError: If API returns error status
        """
        endpoint = f"{self.base_url}/geo/geocode"

        payload = {
            "street": address.street,
            "city": address.city,
            "state": address.state,
            "postalCode": address.zip_code,
            "country": address.country,
        }

        response = requests.post(
            endpoint,
            json=payload,
            headers=self.headers,
            timeout=10
        )
        response.raise_for_status()
        return response.json()

    def reverse_geocode(self, coordinate: CoordinateFixture) -> Dict[str, Any]:
        """Reverse geocode coordinates to address.

        Args:
            coordinate: CoordinateFixture with latitude and longitude

        Returns:
            Dict with address components (street, city, state, zip_code)

        Raises:
            requests.HTTPError: If API returns error status
        """
        endpoint = f"{self.base_url}/geo/reverseGeocode"

        payload = {
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
        }

        response = requests.post(
            endpoint,
            json=payload,
            headers=self.headers,
            timeout=10
        )
        response.raise_for_status()
        return response.json()

    def validate_address(self, address: AddressFixture) -> Dict[str, Any]:
        """Validate and standardize an address.

        Args:
            address: AddressFixture with address components

        Returns:
            Dict with validated/standardized address and validation status

        Raises:
            requests.HTTPError: If API returns error status
        """
        endpoint = f"{self.base_url}/address/validate"

        payload = {
            "street": address.street,
            "city": address.city,
            "state": address.state,
            "postalCode": address.zip_code,
            "country": address.country,
        }

        response = requests.post(
            endpoint,
            json=payload,
            headers=self.headers,
            timeout=10
        )
        response.raise_for_status()
        return response.json()

    def health_check(self) -> bool:
        """Check if API is accessible.

        Returns:
            True if API is reachable and authenticated
        """
        try:
            endpoint = f"{self.base_url}/health"
            response = requests.get(
                endpoint,
                headers=self.headers,
                timeout=5
            )
            return response.status_code == 200
        except requests.RequestException:
            return False

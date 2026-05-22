"""Custom API exceptions for authentication use cases."""

from rest_framework import status
from rest_framework.exceptions import APIException


class AuthServiceError(APIException):
    """Business validation error during authentication workflows."""

    status_code: int = status.HTTP_400_BAD_REQUEST
    default_detail: str = "Error de autenticacion"
    default_code: str = "auth_error"


class AuthUnauthorizedError(APIException):
    """Authentication error for invalid credentials or inactive user."""

    status_code: int = status.HTTP_401_UNAUTHORIZED
    default_detail: str = "Credenciales invalidas"
    default_code: str = "authentication_failed"

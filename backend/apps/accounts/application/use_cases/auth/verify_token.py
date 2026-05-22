"""Application use case for access token validation."""

from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.exceptions import TokenError

from apps.accounts.domain.ports.auth_ports import JwtTokenServicePort


def verify_access_token(
    access_token: str,
    *,
    token_service: JwtTokenServicePort | None = None,
) -> dict:
    """Validate an access token and return a simple validity payload."""
    if token_service is None:
        from apps.accounts.infrastructure.dependencies import get_jwt_token_service

        token_service = get_jwt_token_service()

    try:
        token_service.validate_access_token(access_token)
    except TokenError as exc:
        raise AuthenticationFailed(detail=str(exc), code="token_not_valid") from exc

    return {"valid": True}

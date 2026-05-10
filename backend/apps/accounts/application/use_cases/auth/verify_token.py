from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.exceptions import TokenError

from apps.accounts.domain.ports.auth_ports import JwtTokenServicePort
from apps.accounts.infrastructure.dependencies import get_jwt_token_service


def verify_access_token(
    access_token: str,
    token_service: JwtTokenServicePort | None = None,
) -> dict:
    token_service = token_service or get_jwt_token_service()

    try:
        token_service.validate_access_token(access_token)
    except TokenError as exc:
        raise AuthenticationFailed(detail=str(exc), code="token_not_valid")

    return {"valid": True}

"""Application use case for rotating refresh/access tokens."""

from django.utils import timezone
from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.exceptions import TokenError

from apps.accounts.domain.ports.auth_ports import (
    AccountsAuthRepositoryPort,
    JwtTokenServicePort,
    RefreshTokenRepositoryPort,
)


def refresh_access_token(
    refresh_token: str,
    *,
    auth_repository: AccountsAuthRepositoryPort | None = None,
    refresh_token_repository: RefreshTokenRepositoryPort | None = None,
    token_service: JwtTokenServicePort | None = None,
) -> dict:
    """Validate and rotate refresh token, returning a new token pair."""
    if auth_repository is None or refresh_token_repository is None or token_service is None:
        from apps.accounts.infrastructure.dependencies import (
            get_accounts_auth_repository,
            get_jwt_token_service,
            get_refresh_token_repository,
        )

        auth_repository = auth_repository or get_accounts_auth_repository()
        refresh_token_repository = refresh_token_repository or get_refresh_token_repository()
        token_service = token_service or get_jwt_token_service()

    token_row = refresh_token_repository.find_not_revoked(refresh_token)
    if not token_row:
        raise AuthenticationFailed(detail="Sesion no valida", code="token_not_valid")

    if token_row.expires_at <= timezone.now():
        refresh_token_repository.revoke(refresh_token, at=timezone.now())
        raise AuthenticationFailed(detail="Token is expired", code="token_not_valid")

    try:
        user_id = token_service.get_user_id_from_refresh_token(refresh_token)
    except TokenError as exc:
        refresh_token_repository.revoke(refresh_token, at=timezone.now())
        raise AuthenticationFailed(detail=str(exc), code="token_not_valid")

    user = auth_repository.find_active_user_by_id(user_id)
    if not user:
        raise AuthenticationFailed(detail="Usuario no encontrado", code="token_not_valid")

    issued_tokens = token_service.issue_tokens(user)

    now = timezone.now()
    refresh_token_repository.revoke(refresh_token, at=now)
    refresh_token_repository.store(
        user_id=user.id,
        refresh_token=issued_tokens.refresh_token,
        expires_at=issued_tokens.refresh_expires_at,
    )

    return {
        "access_token": issued_tokens.access_token,
        "refresh_token": issued_tokens.refresh_token,
    }

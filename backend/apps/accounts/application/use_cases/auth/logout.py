"""Application use case for revoking refresh tokens during logout."""

from django.utils import timezone

from apps.accounts.domain.ports.auth_ports import RefreshTokenRepositoryPort


def logout_user(
    refresh_token: str,
    *,
    refresh_token_repository: RefreshTokenRepositoryPort | None = None,
) -> dict[str, str]:
    """Revoke the refresh token when present and return a stable response."""
    if refresh_token_repository is None:
        from apps.accounts.infrastructure.dependencies import get_refresh_token_repository

        refresh_token_repository = get_refresh_token_repository()

    if refresh_token_repository.find_not_revoked(refresh_token) is not None:
        refresh_token_repository.revoke(refresh_token, at=timezone.now())

    return {"message": "Sesion cerrada correctamente"}

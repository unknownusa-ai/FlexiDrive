from django.utils import timezone

from apps.accounts.domain.ports.auth_ports import RefreshTokenRepositoryPort
from apps.accounts.infrastructure.dependencies import get_refresh_token_repository


def logout_user(
    refresh_token: str,
    refresh_token_repository: RefreshTokenRepositoryPort | None = None,
) -> dict:
    refresh_token_repository = refresh_token_repository or get_refresh_token_repository()
    token_row = refresh_token_repository.find_not_revoked(refresh_token)

    if token_row:
        refresh_token_repository.revoke(refresh_token, at=timezone.now())

    return {"message": "Sesion cerrada correctamente"}

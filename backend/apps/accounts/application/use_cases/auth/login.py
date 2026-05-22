"""Application use case for user login in the accounts bounded context."""

from django.contrib.auth.hashers import check_password
from django.utils import timezone

from apps.accounts.application.use_cases.auth.errors import AuthUnauthorizedError
from apps.accounts.domain.ports.auth_ports import (
    AccountsAuthRepositoryPort,
    JwtTokenServicePort,
    RefreshTokenRepositoryPort,
)


def login_user(
    data: dict,
    *,
    auth_repository: AccountsAuthRepositoryPort | None = None,
    refresh_token_repository: RefreshTokenRepositoryPort | None = None,
    token_service: JwtTokenServicePort | None = None,
) -> dict:
    """Authenticate credentials and issue JWT tokens.

    The use case depends only on domain ports and receives concrete adapters
    from the presentation layer (composition root), keeping infrastructure
    concerns outside the application core.
    """
    if auth_repository is None or refresh_token_repository is None or token_service is None:
        from apps.accounts.infrastructure.dependencies import (
            get_accounts_auth_repository,
            get_jwt_token_service,
            get_refresh_token_repository,
        )

        auth_repository = auth_repository or get_accounts_auth_repository()
        refresh_token_repository = refresh_token_repository or get_refresh_token_repository()
        token_service = token_service or get_jwt_token_service()

    correo = data["correo"].strip().lower()
    contrasena = data["contrasena"]

    user = auth_repository.find_user_by_email(correo)
    if not user:
        raise AuthUnauthorizedError()

    if not check_password(contrasena, user.password_hash):
        raise AuthUnauthorizedError()

    if not user.is_active:
        raise AuthUnauthorizedError(detail="Usuario inactivo")

    issued_tokens = token_service.issue_tokens(user)
    refresh_token_repository.store(
        user_id=user.id,
        refresh_token=issued_tokens.refresh_token,
        expires_at=issued_tokens.refresh_expires_at,
    )

    auth_repository.mark_login_success(user.id, at=timezone.now())

    ubicacion = user.city or user.address or ""

    return {
        "access_token": issued_tokens.access_token,
        "refresh_token": issued_tokens.refresh_token,
        "user": {
            "usuario_id": user.id,
            "tipo_usuario_id": user.user_type_id,
            "tipo_usuario_nombre": user.user_type_name,
            "nombre_completo": user.full_name,
            "foto_perfil": user.profile_photo_url,
            "ubicacion": ubicacion,
        },
    }

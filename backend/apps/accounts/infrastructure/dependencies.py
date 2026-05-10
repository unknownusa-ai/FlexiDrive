from __future__ import annotations

from functools import lru_cache

from apps.accounts.domain.ports.auth_ports import (
    AccountsAuthRepositoryPort,
    JwtTokenServicePort,
    RefreshTokenRepositoryPort,
)
from apps.accounts.infrastructure.repositories.auth_repository import (
    DjangoAccountsAuthRepository,
    DjangoRefreshTokenRepository,
)
from apps.accounts.infrastructure.services.jwt_token_service import SimpleJwtTokenService


@lru_cache(maxsize=1)
def get_accounts_auth_repository() -> AccountsAuthRepositoryPort:
    return DjangoAccountsAuthRepository()


@lru_cache(maxsize=1)
def get_refresh_token_repository() -> RefreshTokenRepositoryPort:
    return DjangoRefreshTokenRepository()


@lru_cache(maxsize=1)
def get_jwt_token_service() -> JwtTokenServicePort:
    return SimpleJwtTokenService()


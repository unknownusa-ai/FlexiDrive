from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import Protocol


@dataclass(frozen=True)
class AuthUser:
    id: int
    full_name: str
    email: str
    password_hash: str
    is_active: bool
    auth_provider: str
    profile_photo_url: str | None
    city: str | None
    address: str | None


@dataclass(frozen=True)
class IssuedTokens:
    access_token: str
    refresh_token: str
    refresh_expires_at: datetime


@dataclass(frozen=True)
class StoredRefreshTokenSnapshot:
    token: str
    user_id: int
    is_revoked: bool
    expires_at: datetime


class AccountsAuthRepositoryPort(Protocol):
    def find_user_by_email(self, email: str) -> AuthUser | None: ...

    def find_active_user_by_id(self, user_id: int) -> AuthUser | None: ...

    def email_exists(self, email: str) -> bool: ...

    def identification_number_exists(self, identification_number: str) -> bool: ...

    def identification_type_exists(self, identification_type_id: int) -> bool: ...

    def user_type_exists(self, user_type_id: int) -> bool: ...

    def get_default_arrendador_user_type_id(self) -> int | None: ...

    def create_local_user(
        self,
        *,
        identification_type_id: int,
        identification_number: str,
        user_type_id: int,
        full_name: str,
        email: str,
        phone: str,
        password_hash: str,
    ) -> AuthUser: ...

    def mark_login_success(self, user_id: int, at: datetime) -> None: ...


class RefreshTokenRepositoryPort(Protocol):
    def find_not_revoked(self, refresh_token: str) -> StoredRefreshTokenSnapshot | None: ...

    def store(
        self,
        *,
        user_id: int,
        refresh_token: str,
        expires_at: datetime,
    ) -> None: ...

    def revoke(self, refresh_token: str, *, at: datetime) -> None: ...


class JwtTokenServicePort(Protocol):
    def issue_tokens(self, user: AuthUser) -> IssuedTokens: ...

    def get_user_id_from_refresh_token(self, refresh_token: str) -> int: ...

    def validate_access_token(self, access_token: str) -> None: ...


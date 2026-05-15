from __future__ import annotations

from datetime import datetime

from django.utils import timezone

from apps.accounts.domain.ports.auth_ports import (
    AccountsAuthRepositoryPort,
    AuthUser,
    RefreshTokenRepositoryPort,
    StoredRefreshTokenSnapshot,
)
from apps.accounts.domain.models import IdentificationType, User, UserType
from apps.security.domain.models import RefreshToken as StoredRefreshToken


class DjangoAccountsAuthRepository(AccountsAuthRepositoryPort):
    def find_user_by_email(self, email: str) -> AuthUser | None:
        user = User.objects.filter(email=email).first()
        return self._to_auth_user(user)

    def find_active_user_by_id(self, user_id: int) -> AuthUser | None:
        user = User.objects.filter(id=user_id, is_active=True).first()
        return self._to_auth_user(user)

    def email_exists(self, email: str) -> bool:
        return User.objects.filter(email=email).exists()

    def identification_number_exists(self, identification_number: str) -> bool:
        return User.objects.filter(identification_number=identification_number).exists()

    def identification_type_exists(self, identification_type_id: int) -> bool:
        return IdentificationType.objects.filter(id=identification_type_id).exists()

    def find_identification_type_id_by_name(self, name: str) -> int | None:
        normalized_name = name.strip()
        if not normalized_name:
            return None
        identification_type = IdentificationType.objects.filter(
            name__iexact=normalized_name
        ).first()
        if not identification_type:
            return None
        return identification_type.id

    def create_identification_type(self, name: str) -> int:
        identification_type = IdentificationType.objects.create(
            name=name.strip(),
            description="Creado automaticamente durante registro de usuario",
        )
        return identification_type.id

    def user_type_exists(self, user_type_id: int) -> bool:
        return UserType.objects.filter(id=user_type_id).exists()

    def find_user_type_id_by_name(self, name: str) -> int | None:
        normalized_name = name.strip()
        if not normalized_name:
            return None
        user_type = UserType.objects.filter(name__iexact=normalized_name).first()
        if not user_type:
            return None
        return user_type.id

    def create_user_type(self, name: str) -> int:
        user_type = UserType.objects.create(
            name=name.strip(),
            description="Creado automaticamente durante registro de usuario",
        )
        return user_type.id

    def get_default_arrendador_user_type_id(self) -> int | None:
        user_type = UserType.objects.filter(name__iexact="Arrendador").first()
        if user_type:
            return user_type.id

        created = UserType.objects.create(
            name="Arrendador",
            description="Tipo de usuario predeterminado para registros",
        )
        return created.id

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
    ) -> AuthUser:
        user = User.objects.create(
            identification_type_id=identification_type_id,
            identification_number=identification_number,
            user_type_id=user_type_id,
            full_name=full_name,
            email=email,
            phone=phone,
            password_hash=password_hash,
            auth_provider=User.AUTH_PROVIDER_LOCAL,
        )
        snapshot = self._to_auth_user(user)
        if not snapshot:
            raise RuntimeError("Could not map created user to auth snapshot")
        return snapshot

    def mark_login_success(self, user_id: int, at: datetime) -> None:
        User.objects.filter(id=user_id).update(
            last_login=at,
            failed_login_attempts=0,
            updated_at=timezone.now(),
        )

    def _to_auth_user(self, user: User | None) -> AuthUser | None:
        if not user:
            return None
        profile_photo_url = user.profile_photo.url if user.profile_photo else None
        return AuthUser(
            id=user.id,
            user_type_id=user.user_type_id,
            user_type_name=user.user_type.name if user.user_type else "",
            full_name=user.full_name,
            email=user.email,
            password_hash=user.password_hash,
            is_active=user.is_active,
            auth_provider=user.auth_provider,
            profile_photo_url=profile_photo_url,
            city=user.city,
            address=user.address,
        )


class DjangoRefreshTokenRepository(RefreshTokenRepositoryPort):
    def find_not_revoked(self, refresh_token: str) -> StoredRefreshTokenSnapshot | None:
        token_row = StoredRefreshToken.objects.filter(token=refresh_token, is_revoked=False).first()
        if not token_row:
            return None
        return StoredRefreshTokenSnapshot(
            token=token_row.token,
            user_id=token_row.user_id,
            is_revoked=token_row.is_revoked,
            expires_at=token_row.expires_at,
        )

    def store(
        self,
        *,
        user_id: int,
        refresh_token: str,
        expires_at: datetime,
    ) -> None:
        StoredRefreshToken.objects.create(
            user_id=user_id,
            token=refresh_token,
            is_revoked=False,
            expires_at=expires_at,
        )

    def revoke(self, refresh_token: str, *, at: datetime) -> None:
        StoredRefreshToken.objects.filter(token=refresh_token, is_revoked=False).update(
            is_revoked=True,
            last_used_at=at,
            updated_at=timezone.now(),
        )

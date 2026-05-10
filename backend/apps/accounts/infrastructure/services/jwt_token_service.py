from __future__ import annotations

from dataclasses import dataclass
from types import SimpleNamespace

from django.conf import settings
from django.utils import timezone
from rest_framework_simplejwt.tokens import RefreshToken, UntypedToken

from apps.accounts.domain.ports.auth_ports import AuthUser, IssuedTokens, JwtTokenServicePort


@dataclass
class SimpleJwtTokenService(JwtTokenServicePort):
    def issue_tokens(self, user: AuthUser) -> IssuedTokens:
        token_user = SimpleNamespace(id=user.id)
        refresh = RefreshToken.for_user(token_user)
        refresh["email"] = user.email
        refresh["auth_provider"] = user.auth_provider

        expires_at = timezone.now() + settings.SIMPLE_JWT["REFRESH_TOKEN_LIFETIME"]
        return IssuedTokens(
            access_token=str(refresh.access_token),
            refresh_token=str(refresh),
            refresh_expires_at=expires_at,
        )

    def get_user_id_from_refresh_token(self, refresh_token: str) -> int:
        token = RefreshToken(refresh_token)
        return int(token.get("user_id"))

    def validate_access_token(self, access_token: str) -> None:
        UntypedToken(access_token)


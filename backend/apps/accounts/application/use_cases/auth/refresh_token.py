from django.conf import settings
from django.utils import timezone
from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.security.models import RefreshToken as StoredRefreshToken


def refresh_access_token(refresh_token: str) -> dict:
    token_row = StoredRefreshToken.objects.filter(token=refresh_token, is_revoked=False).first()
    if not token_row:
        raise AuthenticationFailed(detail="Sesion no valida", code="token_not_valid")

    if token_row.expires_at <= timezone.now():
        token_row.is_revoked = True
        token_row.last_used_at = timezone.now()
        token_row.save(update_fields=["is_revoked", "last_used_at", "updated_at"])
        raise AuthenticationFailed(detail="Token is expired", code="token_not_valid")

    try:
        old_token = RefreshToken(refresh_token)
    except TokenError as exc:
        token_row.is_revoked = True
        token_row.last_used_at = timezone.now()
        token_row.save(update_fields=["is_revoked", "last_used_at", "updated_at"])
        raise AuthenticationFailed(detail=str(exc), code="token_not_valid")

    user_id = old_token.get("user_id")
    user = User.objects.filter(id=user_id, is_active=True).first()
    if not user:
        raise AuthenticationFailed(detail="Usuario no encontrado", code="token_not_valid")

    new_refresh = RefreshToken.for_user(user)
    new_refresh["email"] = user.email
    new_refresh["auth_provider"] = user.auth_provider

    now = timezone.now()
    token_row.is_revoked = True
    token_row.last_used_at = now
    token_row.save(update_fields=["is_revoked", "last_used_at", "updated_at"])

    new_refresh_value = str(new_refresh)
    StoredRefreshToken.objects.create(
        user=user,
        token=new_refresh_value,
        is_revoked=False,
        expires_at=now + settings.SIMPLE_JWT["REFRESH_TOKEN_LIFETIME"],
    )

    return {
        "access_token": str(new_refresh.access_token),
        "refresh_token": new_refresh_value,
    }

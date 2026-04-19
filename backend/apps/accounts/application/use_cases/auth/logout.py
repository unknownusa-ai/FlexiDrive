from django.utils import timezone

from apps.security.models import RefreshToken as StoredRefreshToken


def logout_user(refresh_token: str) -> dict:
    token_row = StoredRefreshToken.objects.filter(token=refresh_token, is_revoked=False).first()

    if token_row:
        token_row.is_revoked = True
        token_row.last_used_at = timezone.now()
        token_row.save(update_fields=["is_revoked", "last_used_at", "updated_at"])

    return {"message": "Sesion cerrada correctamente"}

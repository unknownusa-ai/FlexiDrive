from django.contrib.auth.hashers import check_password
from django.utils import timezone
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.application.use_cases.auth.errors import AuthUnauthorizedError
from apps.accounts.models import User


def login_user(data: dict) -> dict:
    correo = data["correo"].strip().lower()
    contrasena = data["contrasena"]

    user = User.objects.filter(email=correo).first()
    if not user:
        raise AuthUnauthorizedError()

    if not check_password(contrasena, user.password_hash):
        raise AuthUnauthorizedError()

    if not user.is_active:
        raise AuthUnauthorizedError(detail="Usuario inactivo")

    refresh = RefreshToken.for_user(user)
    refresh["email"] = user.email
    refresh["auth_provider"] = user.auth_provider

    user.last_login = timezone.now()
    user.failed_login_attempts = 0
    user.save(update_fields=["last_login", "failed_login_attempts", "updated_at"])

    profile_photo_url = user.profile_photo.url if user.profile_photo else None
    ubicacion = user.city or user.address or ""

    return {
        "access_token": str(refresh.access_token),
        "refresh_token": str(refresh),
        "user": {
            "usuario_id": user.id,
            "nombre_completo": user.full_name,
            "foto_perfil": profile_photo_url,
            "ubicacion": ubicacion,
        },
    }

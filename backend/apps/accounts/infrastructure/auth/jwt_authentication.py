from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.authentication import JWTAuthentication

from apps.accounts.models import User


class AccountsJWTAuthentication(JWTAuthentication):
    def get_user(self, validated_token):
        user_id = validated_token.get("user_id")
        if user_id is None:
            raise AuthenticationFailed("Token invalido", code="token_invalid")

        user = User.objects.filter(id=user_id).first()
        if not user:
            raise AuthenticationFailed("Usuario no encontrado", code="user_not_found")

        if not user.is_active:
            raise AuthenticationFailed("Usuario inactivo", code="user_inactive")

        return user

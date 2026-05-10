from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.authentication import JWTAuthentication

from apps.accounts.domain.models import User
from apps.accounts.infrastructure.dependencies import get_accounts_auth_repository


class AccountsJWTAuthentication(JWTAuthentication):
    def get_user(self, validated_token):
        user_id = validated_token.get("user_id")
        if user_id is None:
            raise AuthenticationFailed("Token invalido", code="token_invalid")

        auth_repository = get_accounts_auth_repository()
        user = auth_repository.find_active_user_by_id(int(user_id))
        if not user:
            raise AuthenticationFailed("Usuario no encontrado", code="user_not_found")

        orm_user = User.objects.filter(id=user.id, is_active=True).first()
        if not orm_user:
            raise AuthenticationFailed("Usuario no encontrado", code="user_not_found")
        return orm_user

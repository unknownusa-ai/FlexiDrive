from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import UntypedToken


def verify_access_token(access_token: str) -> dict:
    try:
        UntypedToken(access_token)
    except TokenError as exc:
        raise AuthenticationFailed(detail=str(exc), code="token_not_valid")

    return {"valid": True}

from rest_framework import status
from rest_framework.exceptions import APIException


class AuthServiceError(APIException):
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = "Error de autenticacion"
    default_code = "auth_error"


class AuthUnauthorizedError(APIException):
    status_code = status.HTTP_401_UNAUTHORIZED
    default_detail = "Credenciales invalidas"
    default_code = "authentication_failed"

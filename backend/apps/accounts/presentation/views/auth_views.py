"""HTTP adapters for authentication use cases.

Presentation layer wires serializers + dependency composition, then delegates
business behavior to application use cases.
"""

from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.application.use_cases.auth.login import login_user
from apps.accounts.application.use_cases.auth.logout import logout_user
from apps.accounts.application.use_cases.auth.refresh_token import refresh_access_token
from apps.accounts.application.use_cases.auth.register import register_user
from apps.accounts.application.use_cases.auth.verify_token import verify_access_token
from apps.accounts.infrastructure.dependencies import (
    get_accounts_auth_repository,
    get_jwt_token_service,
    get_refresh_token_repository,
)
from apps.accounts.presentation.serializers.auth_serializers import (
    LoginSerializer,
    LogoutRequestSerializer,
    RegisterSerializer,
    TokenRefreshRequestSerializer,
    TokenVerifyRequestSerializer,
)

_auth_repository = get_accounts_auth_repository()
_refresh_token_repository = get_refresh_token_repository()
_token_service = get_jwt_token_service()


class RegisterView(APIView):
    """Register endpoint."""

    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        response_data = register_user(
            serializer.validated_data,
            auth_repository=_auth_repository,
        )
        return Response(response_data, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    """Login endpoint."""

    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        response_data = login_user(
            serializer.validated_data,
            auth_repository=_auth_repository,
            refresh_token_repository=_refresh_token_repository,
            token_service=_token_service,
        )
        return Response(response_data, status=status.HTTP_200_OK)


class TokenRefreshView(APIView):
    """Token refresh endpoint."""

    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = TokenRefreshRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        response_data = refresh_access_token(
            serializer.validated_data["refresh_token"],
            auth_repository=_auth_repository,
            refresh_token_repository=_refresh_token_repository,
            token_service=_token_service,
        )
        return Response(response_data, status=status.HTTP_200_OK)


class TokenVerifyView(APIView):
    """Token verification endpoint."""

    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = TokenVerifyRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        response_data = verify_access_token(
            serializer.validated_data["access_token"],
            token_service=_token_service,
        )
        return Response(response_data, status=status.HTTP_200_OK)


class LogoutView(APIView):
    """Logout endpoint."""

    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = LogoutRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        response_data = logout_user(
            serializer.validated_data["refresh_token"],
            refresh_token_repository=_refresh_token_repository,
        )
        return Response(response_data, status=status.HTTP_200_OK)

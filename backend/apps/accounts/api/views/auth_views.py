from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.api.serializers.auth_serializers import (
    LoginSerializer,
    LogoutRequestSerializer,
    RegisterSerializer,
    TokenRefreshRequestSerializer,
    TokenVerifyRequestSerializer,
)
from apps.accounts.application.use_cases.auth.login import login_user
from apps.accounts.application.use_cases.auth.logout import logout_user
from apps.accounts.application.use_cases.auth.refresh_token import refresh_access_token
from apps.accounts.application.use_cases.auth.register import register_user
from apps.accounts.application.use_cases.auth.verify_token import verify_access_token


class RegisterView(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        response_data = register_user(serializer.validated_data)
        return Response(response_data, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        response_data = login_user(serializer.validated_data)
        return Response(response_data, status=status.HTTP_200_OK)


class TokenRefreshView(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = TokenRefreshRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        response_data = refresh_access_token(serializer.validated_data["refresh_token"])
        return Response(response_data, status=status.HTTP_200_OK)


class TokenVerifyView(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = TokenVerifyRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        response_data = verify_access_token(serializer.validated_data["access_token"])
        return Response(response_data, status=status.HTTP_200_OK)


class LogoutView(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = LogoutRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        response_data = logout_user(serializer.validated_data["refresh_token"])
        return Response(response_data, status=status.HTTP_200_OK)

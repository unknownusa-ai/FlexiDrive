from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.api.serializers.auth_serializers import LoginSerializer, RegisterSerializer
from apps.accounts.application.use_cases.auth.login import login_user
from apps.accounts.application.use_cases.auth.register import register_user


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

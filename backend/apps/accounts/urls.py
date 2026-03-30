from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView, TokenVerifyView

from apps.accounts.api.views.auth_views import LoginView, RegisterView

urlpatterns = [
    path("auth/register", RegisterView.as_view(), name="auth-register"),
    path("auth/login", LoginView.as_view(), name="auth-login"),
    path("auth/token/refresh", TokenRefreshView.as_view(), name="auth-token-refresh"),
    path("auth/token/verify", TokenVerifyView.as_view(), name="auth-token-verify"),
]

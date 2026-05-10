from django.urls import path

from apps.accounts.presentation.views.auth_views import (
    LoginView,
    LogoutView,
    RegisterView,
    TokenRefreshView,
    TokenVerifyView,
)
from apps.accounts.presentation.views.identification_views import IdentificationTypeListView

urlpatterns = [
    path("auth/register", RegisterView.as_view(), name="auth-register"),
    path("auth/login", LoginView.as_view(), name="auth-login"),
    path("auth/token/refresh", TokenRefreshView.as_view(), name="auth-token-refresh"),
    path("auth/token/verify", TokenVerifyView.as_view(), name="auth-token-verify"),
    path("auth/logout", LogoutView.as_view(), name="auth-logout"),
    path("identification-types", IdentificationTypeListView.as_view(), name="identification-types"),
]

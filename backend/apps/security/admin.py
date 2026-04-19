from django.contrib import admin
from .models import LoginAttempt, RefreshToken, UserSession

admin.site.register(UserSession)
admin.site.register(LoginAttempt)
admin.site.register(RefreshToken)

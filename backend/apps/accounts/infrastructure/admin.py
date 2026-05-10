from django.contrib import admin

from apps.accounts.models import IdentificationType, User, UserPreference, UserSecurity, UserType

admin.site.register(IdentificationType)
admin.site.register(UserType)
admin.site.register(User)
admin.site.register(UserPreference)
admin.site.register(UserSecurity)

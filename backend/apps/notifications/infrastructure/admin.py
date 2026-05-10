from django.contrib import admin

from apps.notifications.models import Notification, NotificationCategory

admin.site.register(NotificationCategory)
admin.site.register(Notification)

from django.contrib import admin

from apps.reviews.models import Opinion, Review

admin.site.register(Opinion)
admin.site.register(Review)

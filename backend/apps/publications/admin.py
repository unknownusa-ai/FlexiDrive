from django.contrib import admin
from .models import PeriodType, Publication, PublicationImage, PublicationPrice

admin.site.register(PeriodType)
admin.site.register(Publication)
admin.site.register(PublicationPrice)
admin.site.register(PublicationImage)

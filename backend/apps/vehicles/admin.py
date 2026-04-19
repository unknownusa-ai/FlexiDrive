from django.contrib import admin
from .models import Vehicle, VehicleCategory

admin.site.register(VehicleCategory)
admin.site.register(Vehicle)

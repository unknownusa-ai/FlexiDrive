from django.contrib import admin

from apps.vehicles.models import Vehicle, VehicleCategory

admin.site.register(VehicleCategory)
admin.site.register(Vehicle)

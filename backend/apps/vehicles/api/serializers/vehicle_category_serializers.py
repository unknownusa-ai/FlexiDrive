from rest_framework import serializers

from apps.vehicles.models import VehicleCategory


class VehicleCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = VehicleCategory
        fields = ("id", "name", "description")

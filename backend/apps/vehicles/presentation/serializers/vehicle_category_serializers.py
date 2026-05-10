from rest_framework import serializers

from apps.vehicles.domain.models import VehicleCategory


class VehicleCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = VehicleCategory
        fields = ("id", "name", "description")


"""HTTP adapter for vehicle category queries."""

from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.vehicles.application.use_cases.vehicle_categories.list_vehicle_categories import (
    list_vehicle_categories,
)
from apps.vehicles.infrastructure.dependencies import get_vehicle_category_repository
from apps.vehicles.presentation.serializers.vehicle_category_serializers import (
    VehicleCategorySerializer,
)

_vehicle_category_repository = get_vehicle_category_repository()


class VehicleCategoryListView(APIView):
    """Expose the vehicle categories catalog to authenticated clients."""

    permission_classes = [IsAuthenticated]

    def get(self, request):
        categories = list_vehicle_categories(repository=_vehicle_category_repository)
        serializer = VehicleCategorySerializer(categories, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.vehicles.api.serializers.vehicle_category_serializers import (
    VehicleCategorySerializer,
)
from apps.vehicles.application.use_cases.vehicle_categories.list_vehicle_categories import (
    list_vehicle_categories,
)


class VehicleCategoryListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        categories = list_vehicle_categories()
        serializer = VehicleCategorySerializer(categories, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

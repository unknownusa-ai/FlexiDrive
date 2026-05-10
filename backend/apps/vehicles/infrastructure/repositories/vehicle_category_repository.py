from apps.vehicles.domain.ports.vehicle_category_ports import VehicleCategoryRepositoryPort
from apps.vehicles.domain.models import VehicleCategory


class DjangoVehicleCategoryRepository(VehicleCategoryRepositoryPort):
    def list_ordered_by_name(self):
        return VehicleCategory.objects.order_by("name")

from apps.vehicles.domain.ports.vehicle_category_ports import VehicleCategoryRepositoryPort
from apps.vehicles.infrastructure.dependencies import get_vehicle_category_repository


def list_vehicle_categories(
    repository: VehicleCategoryRepositoryPort | None = None,
):
    repository = repository or get_vehicle_category_repository()
    return repository.list_ordered_by_name()

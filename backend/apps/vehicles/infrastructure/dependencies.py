from functools import lru_cache

from apps.vehicles.domain.ports.vehicle_category_ports import VehicleCategoryRepositoryPort
from apps.vehicles.infrastructure.repositories.vehicle_category_repository import (
    DjangoVehicleCategoryRepository,
)


@lru_cache(maxsize=1)
def get_vehicle_category_repository() -> VehicleCategoryRepositoryPort:
    return DjangoVehicleCategoryRepository()


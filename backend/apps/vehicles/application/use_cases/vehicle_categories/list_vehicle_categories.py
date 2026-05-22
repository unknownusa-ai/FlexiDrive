"""Application use case for listing vehicle categories."""

from apps.vehicles.domain.ports.vehicle_category_ports import VehicleCategoryRepositoryPort


def list_vehicle_categories(
    *,
    repository: VehicleCategoryRepositoryPort | None = None,
):
    """Return categories ordered by name using the injected repository port."""
    if repository is None:
        from apps.vehicles.infrastructure.dependencies import get_vehicle_category_repository

        repository = get_vehicle_category_repository()

    return repository.list_ordered_by_name()

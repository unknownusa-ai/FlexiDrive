from collections.abc import Sequence

from apps.api.domain.ports.public_data_ports import PublicDataRepositoryPort
from apps.api.infrastructure.dependencies import get_public_data_repository


def get_public_queryset(
    resource: str,
    repository: PublicDataRepositoryPort | None = None,
):
    repository = repository or get_public_data_repository()
    return repository.get_queryset(resource)


def get_reference_cities(
    repository: PublicDataRepositoryPort | None = None,
) -> Sequence[str]:
    repository = repository or get_public_data_repository()
    return repository.list_reference_cities()


"""Read-only application use cases for public reference data."""

from collections.abc import Sequence

from apps.api.domain.ports.public_data_ports import PublicDataRepositoryPort


def get_public_queryset(
    resource: str,
    *,
    repository: PublicDataRepositoryPort | None = None,
):
    """Resolve a public queryset by resource name through the domain port."""
    if repository is None:
        from apps.api.infrastructure.dependencies import get_public_data_repository

        repository = get_public_data_repository()

    return repository.get_queryset(resource)


def get_reference_cities(
    *,
    repository: PublicDataRepositoryPort | None = None,
) -> Sequence[str]:
    """Return distinct reference cities exposed to frontend clients."""
    if repository is None:
        from apps.api.infrastructure.dependencies import get_public_data_repository

        repository = get_public_data_repository()

    return repository.list_reference_cities()

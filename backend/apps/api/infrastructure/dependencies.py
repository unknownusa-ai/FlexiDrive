from functools import lru_cache

from apps.api.domain.ports.public_data_ports import PublicDataRepositoryPort
from apps.api.infrastructure.repositories.public_data_repository import DjangoPublicDataRepository


@lru_cache(maxsize=1)
def get_public_data_repository() -> PublicDataRepositoryPort:
    return DjangoPublicDataRepository()


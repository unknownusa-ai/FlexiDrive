from __future__ import annotations

from typing import Protocol, Sequence


class PublicDataRepositoryPort(Protocol):
    def get_queryset(self, resource: str): ...

    def list_reference_cities(self) -> Sequence[str]: ...


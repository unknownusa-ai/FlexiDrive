from typing import Protocol


class VehicleCategoryRepositoryPort(Protocol):
    def list_ordered_by_name(self): ...


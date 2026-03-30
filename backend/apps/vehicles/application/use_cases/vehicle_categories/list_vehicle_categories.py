from apps.vehicles.models import VehicleCategory


def list_vehicle_categories():
    return VehicleCategory.objects.order_by("name")

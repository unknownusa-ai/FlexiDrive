from django.urls import path

from apps.vehicles.presentation.views.vehicle_category_views import VehicleCategoryListView

urlpatterns = [
    path("vehicles/categories", VehicleCategoryListView.as_view(), name="vehicle-category-list"),
]

from django.urls import path
from rest_framework.routers import SimpleRouter

from .views import (
    BankViewSet,
    CardBrandViewSet,
    CardViewSet,
    DocumentVerificationStatusViewSet,
    IdentificationTypeViewSet,
    NotificationCategoryViewSet,
    NotificationViewSet,
    OpinionViewSet,
    OwnerDocumentTypeViewSet,
    OwnerDocumentViewSet,
    PaymentMethodTypeViewSet,
    PaymentMethodViewSet,
    PeriodTypeViewSet,
    PersonTypeViewSet,
    PseViewSet,
    PublicationImageViewSet,
    PublicationPriceViewSet,
    PublicationViewSet,
    ReservationStatusViewSet,
    ReservationViewSet,
    ReviewViewSet,
    UserPreferenceViewSet,
    UserSecurityViewSet,
    UserSessionViewSet,
    UserTypeViewSet,
    UserViewSet,
    VehicleCategoryViewSet,
    VehicleViewSet,
    reference_cities,
)

router = SimpleRouter(trailing_slash=False)
router.register("identification-types", IdentificationTypeViewSet, basename="identification-types")
router.register("user-types", UserTypeViewSet, basename="user-types")
router.register("payment-method-types", PaymentMethodTypeViewSet, basename="payment-method-types")
router.register("banks", BankViewSet, basename="banks")
router.register("card-brands", CardBrandViewSet, basename="card-brands")
router.register("person-types", PersonTypeViewSet, basename="person-types")
router.register("vehicle-categories", VehicleCategoryViewSet, basename="vehicle-categories")
router.register("period-types", PeriodTypeViewSet, basename="period-types")
router.register("reservation-statuses", ReservationStatusViewSet, basename="reservation-statuses")
router.register("notification-categories", NotificationCategoryViewSet, basename="notification-categories")
router.register("landlord-document-types", OwnerDocumentTypeViewSet, basename="landlord-document-types")
router.register("document-verification-statuses", DocumentVerificationStatusViewSet, basename="document-verification-statuses")
router.register("users", UserViewSet, basename="users")
router.register("user-preferences", UserPreferenceViewSet, basename="user-preferences")
router.register("user-security", UserSecurityViewSet, basename="user-security")
router.register("vehicles", VehicleViewSet, basename="vehicles")
router.register("publications", PublicationViewSet, basename="publications")
router.register("publication-prices", PublicationPriceViewSet, basename="publication-prices")
router.register("publication-images", PublicationImageViewSet, basename="publication-images")
router.register("payment-methods", PaymentMethodViewSet, basename="payment-methods")
router.register("cards", CardViewSet, basename="cards")
router.register("pses", PseViewSet, basename="pses")
router.register("reservations", ReservationViewSet, basename="reservations")
router.register("notifications", NotificationViewSet, basename="notifications")
router.register("opinions", OpinionViewSet, basename="opinions")
router.register("reviews", ReviewViewSet, basename="reviews")
router.register("landlord-documents", OwnerDocumentViewSet, basename="landlord-documents")
router.register("user-sessions", UserSessionViewSet, basename="user-sessions")

urlpatterns = [
    path("reference-cities", reference_cities, name="reference-cities"),
]
urlpatterns += router.urls

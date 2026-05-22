"""Public read/write API adapters for platform entities.

This module is intentionally thin: it delegates data retrieval rules to
application use cases and keeps serializer + HTTP concerns in presentation.
"""

from django.utils import timezone
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet

from apps.api.application.use_cases.public_data import get_public_queryset, get_reference_cities
from apps.api.infrastructure.dependencies import get_public_data_repository

from .serializers import (
    BankSerializer,
    CardBrandSerializer,
    CardSerializer,
    DocumentVerificationStatusSerializer,
    IdentificationTypeSerializer,
    NotificationCategorySerializer,
    NotificationSerializer,
    OpinionSerializer,
    OwnerDocumentSerializer,
    OwnerDocumentTypeSerializer,
    PaymentMethodSerializer,
    PaymentMethodTypeSerializer,
    PeriodTypeSerializer,
    PersonTypeSerializer,
    PseSerializer,
    PublicationImageSerializer,
    PublicationPriceSerializer,
    PublicationSerializer,
    ReservationSerializer,
    ReservationStatusSerializer,
    ReviewSerializer,
    UserPreferenceSerializer,
    UserSecuritySerializer,
    UserSerializer,
    UserSessionSerializer,
    UserTypeSerializer,
    VehicleCategorySerializer,
    VehicleSerializer,
)

_public_data_repository = get_public_data_repository()


def _public_queryset(resource: str):
    """Resolve public queryset for a named resource via injected repository."""
    return get_public_queryset(resource, repository=_public_data_repository)


class PublicModelViewSet(ModelViewSet):
    authentication_classes = []
    permission_classes = [AllowAny]


class IdentificationTypeViewSet(PublicModelViewSet):
    queryset = _public_queryset("identification_types")
    serializer_class = IdentificationTypeSerializer


class UserTypeViewSet(PublicModelViewSet):
    queryset = _public_queryset("user_types")
    serializer_class = UserTypeSerializer


class PaymentMethodTypeViewSet(PublicModelViewSet):
    queryset = _public_queryset("payment_method_types")
    serializer_class = PaymentMethodTypeSerializer


class BankViewSet(PublicModelViewSet):
    queryset = _public_queryset("banks")
    serializer_class = BankSerializer


class CardBrandViewSet(PublicModelViewSet):
    queryset = _public_queryset("card_brands")
    serializer_class = CardBrandSerializer


class PersonTypeViewSet(PublicModelViewSet):
    queryset = _public_queryset("person_types")
    serializer_class = PersonTypeSerializer


class VehicleCategoryViewSet(PublicModelViewSet):
    queryset = _public_queryset("vehicle_categories")
    serializer_class = VehicleCategorySerializer


class PeriodTypeViewSet(PublicModelViewSet):
    queryset = _public_queryset("period_types")
    serializer_class = PeriodTypeSerializer


class ReservationStatusViewSet(PublicModelViewSet):
    queryset = _public_queryset("reservation_statuses")
    serializer_class = ReservationStatusSerializer


class NotificationCategoryViewSet(PublicModelViewSet):
    queryset = _public_queryset("notification_categories")
    serializer_class = NotificationCategorySerializer


class OwnerDocumentTypeViewSet(PublicModelViewSet):
    queryset = _public_queryset("owner_document_types")
    serializer_class = OwnerDocumentTypeSerializer


class DocumentVerificationStatusViewSet(PublicModelViewSet):
    queryset = _public_queryset("document_verification_statuses")
    serializer_class = DocumentVerificationStatusSerializer


class UserViewSet(PublicModelViewSet):
    queryset = _public_queryset("users")
    serializer_class = UserSerializer


class UserPreferenceViewSet(PublicModelViewSet):
    queryset = _public_queryset("user_preferences")
    serializer_class = UserPreferenceSerializer


class UserSecurityViewSet(PublicModelViewSet):
    queryset = _public_queryset("user_security")
    serializer_class = UserSecuritySerializer


class VehicleViewSet(PublicModelViewSet):
    queryset = _public_queryset("vehicles")
    serializer_class = VehicleSerializer


class PublicationViewSet(PublicModelViewSet):
    queryset = _public_queryset("publications")
    serializer_class = PublicationSerializer


class PublicationPriceViewSet(PublicModelViewSet):
    queryset = _public_queryset("publication_prices")
    serializer_class = PublicationPriceSerializer


class PublicationImageViewSet(PublicModelViewSet):
    queryset = _public_queryset("publication_images")
    serializer_class = PublicationImageSerializer


class PaymentMethodViewSet(PublicModelViewSet):
    queryset = _public_queryset("payment_methods")
    serializer_class = PaymentMethodSerializer


class CardViewSet(PublicModelViewSet):
    queryset = _public_queryset("cards")
    serializer_class = CardSerializer


class PseViewSet(PublicModelViewSet):
    queryset = _public_queryset("pses")
    serializer_class = PseSerializer


class ReservationViewSet(PublicModelViewSet):
    queryset = _public_queryset("reservations")
    serializer_class = ReservationSerializer


class NotificationViewSet(PublicModelViewSet):
    queryset = _public_queryset("notifications")
    serializer_class = NotificationSerializer


class OpinionViewSet(PublicModelViewSet):
    def get_queryset(self):
        return _public_queryset("opinions").exclude(
            description__startswith="Opinion de prueba"
        ).order_by("id")

    queryset = _public_queryset("opinions")
    serializer_class = OpinionSerializer


class ReviewViewSet(PublicModelViewSet):
    def get_queryset(self):
        return _public_queryset("reviews").exclude(
            opinion__description__startswith="Opinion de prueba"
        ).order_by("id")

    queryset = _public_queryset("reviews")
    serializer_class = ReviewSerializer


class OwnerDocumentViewSet(PublicModelViewSet):
    queryset = _public_queryset("owner_documents")
    serializer_class = OwnerDocumentSerializer


class UserSessionViewSet(PublicModelViewSet):
    queryset = _public_queryset("user_sessions")
    serializer_class = UserSessionSerializer


@api_view(["GET"])
@permission_classes([AllowAny])
def reference_cities(request):
    cities = get_reference_cities(repository=_public_data_repository)
    fallback = ["Barranquilla", "Bogota", "Medellin", "Cali", "Cartagena", "Bucaramanga"]
    return Response(list(cities) or fallback)


@api_view(["GET"])
@permission_classes([AllowAny])
def healthcheck(request):
    return Response(
        {
            "status": "ok",
            "service": "flexidrive-backend",
            "timestamp": timezone.now().isoformat(),
        }
    )

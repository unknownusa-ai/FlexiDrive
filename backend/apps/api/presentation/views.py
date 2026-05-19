from django.utils import timezone
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet

from apps.api.application.use_cases.public_data import get_public_queryset, get_reference_cities

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


class PublicModelViewSet(ModelViewSet):
    authentication_classes = []
    permission_classes = [AllowAny]


class IdentificationTypeViewSet(PublicModelViewSet):
    queryset = get_public_queryset("identification_types")
    serializer_class = IdentificationTypeSerializer


class UserTypeViewSet(PublicModelViewSet):
    queryset = get_public_queryset("user_types")
    serializer_class = UserTypeSerializer


class PaymentMethodTypeViewSet(PublicModelViewSet):
    queryset = get_public_queryset("payment_method_types")
    serializer_class = PaymentMethodTypeSerializer


class BankViewSet(PublicModelViewSet):
    queryset = get_public_queryset("banks")
    serializer_class = BankSerializer


class CardBrandViewSet(PublicModelViewSet):
    queryset = get_public_queryset("card_brands")
    serializer_class = CardBrandSerializer


class PersonTypeViewSet(PublicModelViewSet):
    queryset = get_public_queryset("person_types")
    serializer_class = PersonTypeSerializer


class VehicleCategoryViewSet(PublicModelViewSet):
    queryset = get_public_queryset("vehicle_categories")
    serializer_class = VehicleCategorySerializer


class PeriodTypeViewSet(PublicModelViewSet):
    queryset = get_public_queryset("period_types")
    serializer_class = PeriodTypeSerializer


class ReservationStatusViewSet(PublicModelViewSet):
    queryset = get_public_queryset("reservation_statuses")
    serializer_class = ReservationStatusSerializer


class NotificationCategoryViewSet(PublicModelViewSet):
    queryset = get_public_queryset("notification_categories")
    serializer_class = NotificationCategorySerializer


class OwnerDocumentTypeViewSet(PublicModelViewSet):
    queryset = get_public_queryset("owner_document_types")
    serializer_class = OwnerDocumentTypeSerializer


class DocumentVerificationStatusViewSet(PublicModelViewSet):
    queryset = get_public_queryset("document_verification_statuses")
    serializer_class = DocumentVerificationStatusSerializer


class UserViewSet(PublicModelViewSet):
    queryset = get_public_queryset("users")
    serializer_class = UserSerializer


class UserPreferenceViewSet(PublicModelViewSet):
    queryset = get_public_queryset("user_preferences")
    serializer_class = UserPreferenceSerializer


class UserSecurityViewSet(PublicModelViewSet):
    queryset = get_public_queryset("user_security")
    serializer_class = UserSecuritySerializer


class VehicleViewSet(PublicModelViewSet):
    queryset = get_public_queryset("vehicles")
    serializer_class = VehicleSerializer


class PublicationViewSet(PublicModelViewSet):
    queryset = get_public_queryset("publications")
    serializer_class = PublicationSerializer


class PublicationPriceViewSet(PublicModelViewSet):
    queryset = get_public_queryset("publication_prices")
    serializer_class = PublicationPriceSerializer


class PublicationImageViewSet(PublicModelViewSet):
    queryset = get_public_queryset("publication_images")
    serializer_class = PublicationImageSerializer


class PaymentMethodViewSet(PublicModelViewSet):
    queryset = get_public_queryset("payment_methods")
    serializer_class = PaymentMethodSerializer


class CardViewSet(PublicModelViewSet):
    queryset = get_public_queryset("cards")
    serializer_class = CardSerializer


class PseViewSet(PublicModelViewSet):
    queryset = get_public_queryset("pses")
    serializer_class = PseSerializer


class ReservationViewSet(PublicModelViewSet):
    queryset = get_public_queryset("reservations")
    serializer_class = ReservationSerializer


class NotificationViewSet(PublicModelViewSet):
    queryset = get_public_queryset("notifications")
    serializer_class = NotificationSerializer


class OpinionViewSet(PublicModelViewSet):
    def get_queryset(self):
        return get_public_queryset("opinions").exclude(
            description__startswith="Opinion de prueba"
        ).order_by("id")

    queryset = get_public_queryset("opinions")
    serializer_class = OpinionSerializer


class ReviewViewSet(PublicModelViewSet):
    def get_queryset(self):
        return get_public_queryset("reviews").exclude(
            opinion__description__startswith="Opinion de prueba"
        ).order_by("id")

    queryset = get_public_queryset("reviews")
    serializer_class = ReviewSerializer


class OwnerDocumentViewSet(PublicModelViewSet):
    queryset = get_public_queryset("owner_documents")
    serializer_class = OwnerDocumentSerializer


class UserSessionViewSet(PublicModelViewSet):
    queryset = get_public_queryset("user_sessions")
    serializer_class = UserSessionSerializer


@api_view(["GET"])
@permission_classes([AllowAny])
def reference_cities(request):
    cities = get_reference_cities()
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

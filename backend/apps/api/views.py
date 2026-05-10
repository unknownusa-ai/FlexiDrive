from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet

from apps.accounts.models import IdentificationType, User, UserPreference, UserSecurity, UserType
from apps.documents.models import DocumentVerificationStatus, OwnerDocument, OwnerDocumentType
from apps.notifications.models import Notification, NotificationCategory
from apps.payments.models import Bank, Card, CardBrand, PaymentMethod, PaymentMethodType, PersonType, PSE
from apps.publications.models import PeriodType, Publication, PublicationImage, PublicationPrice
from apps.reservations.models import Reservation, ReservationStatus
from apps.reviews.models import Opinion, Review
from apps.security.models import UserSession
from apps.vehicles.models import Vehicle, VehicleCategory

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
    queryset = (
        IdentificationType.objects.exclude(
            name__in=[
                "Documento Regional",
                "Documento Consular",
                "Documento Mercosur",
                "Documento Schengen",
                "Documento Fronterizo",
            ]
        )
        .all()
        .order_by("id")
    )
    serializer_class = IdentificationTypeSerializer


class UserTypeViewSet(PublicModelViewSet):
    queryset = UserType.objects.all().order_by("id")
    serializer_class = UserTypeSerializer


class PaymentMethodTypeViewSet(PublicModelViewSet):
    queryset = PaymentMethodType.objects.all().order_by("id")
    serializer_class = PaymentMethodTypeSerializer


class BankViewSet(PublicModelViewSet):
    queryset = Bank.objects.all().order_by("id")
    serializer_class = BankSerializer


class CardBrandViewSet(PublicModelViewSet):
    queryset = CardBrand.objects.all().order_by("id")
    serializer_class = CardBrandSerializer


class PersonTypeViewSet(PublicModelViewSet):
    queryset = PersonType.objects.all().order_by("id")
    serializer_class = PersonTypeSerializer


class VehicleCategoryViewSet(PublicModelViewSet):
    queryset = VehicleCategory.objects.all().order_by("id")
    serializer_class = VehicleCategorySerializer


class PeriodTypeViewSet(PublicModelViewSet):
    queryset = PeriodType.objects.all().order_by("id")
    serializer_class = PeriodTypeSerializer


class ReservationStatusViewSet(PublicModelViewSet):
    queryset = ReservationStatus.objects.all().order_by("id")
    serializer_class = ReservationStatusSerializer


class NotificationCategoryViewSet(PublicModelViewSet):
    queryset = NotificationCategory.objects.all().order_by("id")
    serializer_class = NotificationCategorySerializer


class OwnerDocumentTypeViewSet(PublicModelViewSet):
    queryset = OwnerDocumentType.objects.all().order_by("id")
    serializer_class = OwnerDocumentTypeSerializer


class DocumentVerificationStatusViewSet(PublicModelViewSet):
    queryset = DocumentVerificationStatus.objects.all().order_by("id")
    serializer_class = DocumentVerificationStatusSerializer


class UserViewSet(PublicModelViewSet):
    queryset = User.objects.all().order_by("id")
    serializer_class = UserSerializer


class UserPreferenceViewSet(PublicModelViewSet):
    queryset = UserPreference.objects.select_related("user").all().order_by("id")
    serializer_class = UserPreferenceSerializer


class UserSecurityViewSet(PublicModelViewSet):
    queryset = UserSecurity.objects.all().order_by("id")
    serializer_class = UserSecuritySerializer


class VehicleViewSet(PublicModelViewSet):
    queryset = Vehicle.objects.select_related("category").all().order_by("id")
    serializer_class = VehicleSerializer


class PublicationViewSet(PublicModelViewSet):
    queryset = Publication.objects.select_related("user", "vehicle").all().order_by("id")
    serializer_class = PublicationSerializer


class PublicationPriceViewSet(PublicModelViewSet):
    queryset = PublicationPrice.objects.select_related("publication", "period_type").all().order_by("id")
    serializer_class = PublicationPriceSerializer


class PublicationImageViewSet(PublicModelViewSet):
    queryset = PublicationImage.objects.select_related("publication").all().order_by("id")
    serializer_class = PublicationImageSerializer


class PaymentMethodViewSet(PublicModelViewSet):
    queryset = PaymentMethod.objects.select_related("user", "payment_method_type").all().order_by("id")
    serializer_class = PaymentMethodSerializer


class CardViewSet(PublicModelViewSet):
    queryset = Card.objects.select_related("payment_method", "card_brand").all().order_by("id")
    serializer_class = CardSerializer


class PseViewSet(PublicModelViewSet):
    queryset = PSE.objects.select_related("payment_method", "bank", "person_type").all().order_by("id")
    serializer_class = PseSerializer


class ReservationViewSet(PublicModelViewSet):
    queryset = Reservation.objects.select_related("user", "publication", "payment_method", "period_type", "status").all().order_by("id")
    serializer_class = ReservationSerializer


class NotificationViewSet(PublicModelViewSet):
    queryset = Notification.objects.select_related("user", "category").all().order_by("-sent_at", "-id")
    serializer_class = NotificationSerializer


class OpinionViewSet(PublicModelViewSet):
    def get_queryset(self):
        return Opinion.objects.exclude(
            description__startswith="Opinion de prueba"
        ).order_by("id")

    queryset = Opinion.objects.all().order_by("id")
    serializer_class = OpinionSerializer


class ReviewViewSet(PublicModelViewSet):
    def get_queryset(self):
        return (
            Review.objects.select_related("user", "publication", "opinion")
            .exclude(opinion__description__startswith="Opinion de prueba")
            .order_by("id")
        )

    queryset = Review.objects.select_related("user", "publication", "opinion").all().order_by("-review_date", "-id")
    serializer_class = ReviewSerializer


class OwnerDocumentViewSet(PublicModelViewSet):
    queryset = OwnerDocument.objects.select_related("user", "owner_document_type", "verification_status").all().order_by("id")
    serializer_class = OwnerDocumentSerializer


class UserSessionViewSet(PublicModelViewSet):
    queryset = UserSession.objects.select_related("user").all().order_by("-start_date", "-id")
    serializer_class = UserSessionSerializer


@api_view(["GET"])
@permission_classes([AllowAny])
def reference_cities(request):
    cities = (
        User.objects.exclude(city__isnull=True)
        .exclude(city="")
        .order_by("city")
        .values_list("city", flat=True)
        .distinct()
    )
    fallback = ["Barranquilla", "Bogota", "Medellin", "Cali", "Cartagena", "Bucaramanga"]
    return Response(list(cities) or fallback)

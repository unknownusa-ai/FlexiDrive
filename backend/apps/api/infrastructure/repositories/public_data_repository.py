from __future__ import annotations

from collections.abc import Callable, Sequence

from apps.accounts.domain.models import IdentificationType, User, UserPreference, UserSecurity, UserType
from apps.api.domain.ports.public_data_ports import PublicDataRepositoryPort
from apps.documents.domain.models import DocumentVerificationStatus, OwnerDocument, OwnerDocumentType
from apps.notifications.domain.models import Notification, NotificationCategory
from apps.payments.domain.models import Bank, Card, CardBrand, PaymentMethod, PaymentMethodType, PersonType, PSE
from apps.publications.domain.models import PeriodType, Publication, PublicationImage, PublicationPrice
from apps.reservations.domain.models import Reservation, ReservationStatus
from apps.reviews.domain.models import Opinion, Review
from apps.security.domain.models import UserSession
from apps.vehicles.domain.models import Vehicle, VehicleCategory


class DjangoPublicDataRepository(PublicDataRepositoryPort):
    def __init__(self) -> None:
        self._query_builders: dict[str, Callable[[], object]] = {
            "identification_types": lambda: (
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
            ),
            "user_types": lambda: UserType.objects.all().order_by("id"),
            "payment_method_types": lambda: PaymentMethodType.objects.all().order_by("id"),
            "banks": lambda: Bank.objects.all().order_by("id"),
            "card_brands": lambda: CardBrand.objects.all().order_by("id"),
            "person_types": lambda: PersonType.objects.all().order_by("id"),
            "vehicle_categories": lambda: VehicleCategory.objects.all().order_by("id"),
            "period_types": lambda: PeriodType.objects.all().order_by("id"),
            "reservation_statuses": lambda: ReservationStatus.objects.all().order_by("id"),
            "notification_categories": lambda: NotificationCategory.objects.all().order_by("id"),
            "owner_document_types": lambda: OwnerDocumentType.objects.all().order_by("id"),
            "document_verification_statuses": lambda: DocumentVerificationStatus.objects.all().order_by("id"),
            "users": lambda: User.objects.all().order_by("id"),
            "user_preferences": lambda: UserPreference.objects.select_related("user").all().order_by("id"),
            "user_security": lambda: UserSecurity.objects.all().order_by("id"),
            "vehicles": lambda: Vehicle.objects.select_related("category").all().order_by("id"),
            "publications": lambda: Publication.objects.select_related("user", "vehicle").all().order_by("id"),
            "publication_prices": lambda: PublicationPrice.objects.select_related("publication", "period_type").all().order_by("id"),
            "publication_images": lambda: PublicationImage.objects.select_related("publication").all().order_by("id"),
            "payment_methods": lambda: PaymentMethod.objects.select_related("user", "payment_method_type").all().order_by("id"),
            "cards": lambda: Card.objects.select_related("payment_method", "card_brand").all().order_by("id"),
            "pses": lambda: PSE.objects.select_related("payment_method", "bank", "person_type").all().order_by("id"),
            "reservations": lambda: Reservation.objects.select_related("user", "publication", "payment_method", "period_type", "status").all().order_by("id"),
            "notifications": lambda: Notification.objects.select_related("user", "category").all().order_by("-sent_at", "-id"),
            "opinions": lambda: Opinion.objects.all().order_by("id"),
            "reviews": lambda: Review.objects.select_related("user", "publication", "opinion").all().order_by("-review_date", "-id"),
            "owner_documents": lambda: OwnerDocument.objects.select_related("user", "owner_document_type", "verification_status").all().order_by("id"),
            "user_sessions": lambda: UserSession.objects.select_related("user").all().order_by("-start_date", "-id"),
        }

    def get_queryset(self, resource: str):
        builder = self._query_builders.get(resource)
        if not builder:
            raise KeyError(f"Unsupported public data resource: {resource}")
        return builder()

    def list_reference_cities(self) -> Sequence[str]:
        cities = (
            User.objects.exclude(city__isnull=True)
            .exclude(city="")
            .order_by("city")
            .values_list("city", flat=True)
            .distinct()
        )
        return list(cities)

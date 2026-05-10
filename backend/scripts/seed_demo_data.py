from __future__ import annotations

from datetime import timedelta

from django.contrib.auth.hashers import make_password
from django.utils import timezone

from apps.accounts.domain.models import IdentificationType, User, UserType
from apps.documents.domain.models import (
    DocumentVerificationStatus,
    OwnerDocumentType,
)
from apps.notifications.domain.models import Notification, NotificationCategory
from apps.payments.domain.models import (
    Bank,
    Card,
    CardBrand,
    PaymentMethod,
    PaymentMethodType,
    PersonType,
)
from apps.publications.domain.models import PeriodType, Publication, PublicationPrice
from apps.reservations.domain.models import Reservation, ReservationStatus
from apps.reviews.domain.models import Opinion, Review
from apps.vehicles.domain.models import Vehicle, VehicleCategory


PASSWORD_PLAIN = "123456789"
PASSWORD_HASH = make_password(PASSWORD_PLAIN)


def ensure_catalogs() -> dict:
    user_type_arrendador, _ = UserType.objects.get_or_create(
        name="Arrendador",
        defaults={"description": "Usuario que reserva/renta vehículos"},
    )
    user_type_arrendatario, _ = UserType.objects.get_or_create(
        name="Arrendatario",
        defaults={"description": "Usuario que publica vehículos"},
    )

    ident_cc, _ = IdentificationType.objects.get_or_create(
        name="Cédula de Ciudadanía",
        defaults={"description": "Documento nacional colombiano"},
    )

    vehicle_categories = {}
    for name, desc in [
        ("Sedán", "Vehículo sedán"),
        ("SUV", "Vehículo SUV"),
        ("Compacto", "Vehículo compacto"),
        ("Premium", "Vehículo premium"),
        ("Pickup", "Camioneta pickup"),
    ]:
        obj, _ = VehicleCategory.objects.get_or_create(name=name, defaults={"description": desc})
        vehicle_categories[name] = obj

    payment_types = {}
    for name, desc in [
        ("Tarjeta", "Pago con tarjeta"),
        ("PSE", "Pago por PSE"),
        ("Efectivo", "Pago en efectivo"),
    ]:
        obj, _ = PaymentMethodType.objects.get_or_create(name=name, defaults={"description": desc})
        payment_types[name] = obj

    card_brands = {}
    for name in ["Visa", "Mastercard", "Amex"]:
        obj, _ = CardBrand.objects.get_or_create(name=name, defaults={"description": f"Marca {name}"})
        card_brands[name] = obj

    for name in ["Bancolombia", "Davivienda", "Banco de Bogotá"]:
        Bank.objects.get_or_create(name=name, defaults={"description": f"Banco {name}"})

    for name in ["Natural", "Jurídica"]:
        PersonType.objects.get_or_create(name=name, defaults={"description": f"Persona {name}"})

    period_types = {}
    for name, desc in [
        ("Día", "Precio diario"),
        ("Semana", "Precio semanal"),
        ("Mes", "Precio mensual"),
    ]:
        obj, _ = PeriodType.objects.get_or_create(name=name, defaults={"description": desc})
        period_types[name] = obj

    reservation_statuses = {}
    for name, desc in [
        ("Pendiente", "Reserva pendiente"),
        ("Confirmada", "Reserva confirmada"),
        ("Completada", "Reserva completada"),
        ("Cancelada", "Reserva cancelada"),
    ]:
        obj, _ = ReservationStatus.objects.get_or_create(name=name, defaults={"description": desc})
        reservation_statuses[name] = obj

    notification_categories = {}
    for name, desc in [
        ("Reserva", "Notificaciones de reservas"),
        ("Recordatorio", "Recordatorios importantes"),
        ("Auto", "Novedades de vehículos"),
        ("Promo", "Promociones"),
    ]:
        obj, _ = NotificationCategory.objects.get_or_create(name=name, defaults={"description": desc})
        notification_categories[name] = obj

    for name, desc in [
        ("Licencia de conducción", "Documento obligatorio para publicar"),
        ("Cédula frontal", "Documento de identidad frontal"),
        ("Cédula reverso", "Documento de identidad reverso"),
        ("Tarjeta de propiedad", "Documento del vehículo"),
    ]:
        OwnerDocumentType.objects.get_or_create(name=name, defaults={"description": desc})

    for name, desc in [
        ("Pendiente", "En revisión"),
        ("Aprobado", "Documento aprobado"),
        ("Rechazado", "Documento rechazado"),
    ]:
        DocumentVerificationStatus.objects.get_or_create(name=name, defaults={"description": desc})

    return {
        "user_type_arrendador": user_type_arrendador,
        "user_type_arrendatario": user_type_arrendatario,
        "ident_cc": ident_cc,
        "vehicle_categories": vehicle_categories,
        "payment_types": payment_types,
        "card_brands": card_brands,
        "period_types": period_types,
        "reservation_statuses": reservation_statuses,
        "notification_categories": notification_categories,
    }


def ensure_user(
    *,
    full_name: str,
    email: str,
    identification_number: str,
    user_type: UserType,
    identification_type: IdentificationType,
    phone: str,
    can_publish: bool,
) -> User:
    user, created = User.objects.get_or_create(
        email=email,
        defaults={
            "full_name": full_name,
            "identification_type": identification_type,
            "identification_number": identification_number,
            "user_type": user_type,
            "phone": phone,
            "password_hash": PASSWORD_HASH,
            "can_publish": can_publish,
        },
    )
    if not created:
        user.full_name = full_name
        user.identification_type = identification_type
        user.identification_number = identification_number
        user.user_type = user_type
        user.phone = phone
        user.can_publish = can_publish
        user.password_hash = PASSWORD_HASH
        user.is_active = True
        user.save(
            update_fields=[
                "full_name",
                "identification_type",
                "identification_number",
                "user_type",
                "phone",
                "can_publish",
                "password_hash",
                "is_active",
                "updated_at",
            ]
        )
    return user


def ensure_vehicle_publications(owner_user: User, categories: dict, period_types: dict) -> list[Publication]:
    vehicles_data = [
        {
            "category": "Sedán",
            "line": "Mazda 3 Touring",
            "model_year": 2022,
            "color": "Gris",
            "seats": 5,
            "transmission_type": "Automática",
            "air_conditioning": True,
            "fuel_type": "Gasolina",
            "description": "Sedán cómodo para ciudad y carretera.",
        },
        {
            "category": "SUV",
            "line": "Toyota RAV4 XLE",
            "model_year": 2023,
            "color": "Blanco",
            "seats": 5,
            "transmission_type": "Automática",
            "air_conditioning": True,
            "fuel_type": "Híbrido",
            "description": "SUV amplia ideal para viajes familiares.",
        },
        {
            "category": "Compacto",
            "line": "Renault Sandero Zen",
            "model_year": 2021,
            "color": "Rojo",
            "seats": 5,
            "transmission_type": "Manual",
            "air_conditioning": True,
            "fuel_type": "Gasolina",
            "description": "Compacto económico para uso urbano.",
        },
        {
            "category": "Premium",
            "line": "BMW 320i Sport",
            "model_year": 2024,
            "color": "Negro",
            "seats": 5,
            "transmission_type": "Automática",
            "air_conditioning": True,
            "fuel_type": "Gasolina",
            "description": "Experiencia premium con alto confort.",
        },
        {
            "category": "Pickup",
            "line": "Ford Ranger XLT",
            "model_year": 2022,
            "color": "Azul",
            "seats": 5,
            "transmission_type": "Automática",
            "air_conditioning": True,
            "fuel_type": "Diésel",
            "description": "Pickup robusta para trabajo y turismo.",
        },
        {
            "category": "SUV",
            "line": "Kia Sportage EX",
            "model_year": 2023,
            "color": "Plateado",
            "seats": 5,
            "transmission_type": "Automática",
            "air_conditioning": True,
            "fuel_type": "Gasolina",
            "description": "SUV moderna con gran tecnología.",
        },
    ]

    publications: list[Publication] = []
    now = timezone.now()

    for index, data in enumerate(vehicles_data, start=1):
        vehicle, _ = Vehicle.objects.get_or_create(
            line=data["line"],
            model_year=data["model_year"],
            defaults={
                "category": categories[data["category"]],
                "color": data["color"],
                "seats": data["seats"],
                "transmission_type": data["transmission_type"],
                "air_conditioning": data["air_conditioning"],
                "fuel_type": data["fuel_type"],
                "description": data["description"],
            },
        )
        if vehicle.category_id != categories[data["category"]].id:
            vehicle.category = categories[data["category"]]
            vehicle.save(update_fields=["category", "updated_at"])

        publication, _ = Publication.objects.get_or_create(
            user=owner_user,
            vehicle=vehicle,
            defaults={
                "publication_date": now - timedelta(days=index),
                "is_active": True,
            },
        )
        if not publication.is_active:
            publication.is_active = True
            publication.save(update_fields=["is_active", "updated_at"])

        PublicationPrice.objects.update_or_create(
            publication=publication,
            period_type=period_types["Día"],
            defaults={"price": 120000 + (index * 15000)},
        )
        PublicationPrice.objects.update_or_create(
            publication=publication,
            period_type=period_types["Semana"],
            defaults={"price": 720000 + (index * 85000)},
        )
        PublicationPrice.objects.update_or_create(
            publication=publication,
            period_type=period_types["Mes"],
            defaults={"price": 2600000 + (index * 190000)},
        )

        publications.append(publication)

    return publications


def ensure_payment_profile(renter_user: User, payment_types: dict, card_brands: dict) -> PaymentMethod:
    payment_method = PaymentMethod.objects.filter(
        user=renter_user,
        payment_method_type=payment_types["Tarjeta"],
    ).first()

    if not payment_method:
        payment_method = PaymentMethod.objects.create(
            user=renter_user,
            payment_method_type=payment_types["Tarjeta"],
            is_default=True,
        )

    if not Card.objects.filter(payment_method=payment_method).exists():
        Card.objects.create(
            payment_method=payment_method,
            card_brand=card_brands["Visa"],
            last4="4242",
            tokenized_card_reference=f"seed_card_{renter_user.id}",
            expiration_month=12,
            expiration_year=2030,
        )

    return payment_method


def ensure_reservations_and_reviews(
    *,
    renter_user: User,
    publications: list[Publication],
    payment_method: PaymentMethod,
    period_types: dict,
    reservation_statuses: dict,
    notification_categories: dict,
) -> None:
    now = timezone.now()

    # Create a completed reservation for first publication
    completed_reservation, _ = Reservation.objects.get_or_create(
        reservation_code="FD-DEMO-0001",
        defaults={
            "user": renter_user,
            "publication": publications[0],
            "payment_method": payment_method,
            "period_type": period_types["Día"],
            "periods_quantity": 2,
            "start_date": now - timedelta(days=15),
            "end_date": now - timedelta(days=13),
            "pickup_location": "Barranquilla Centro",
            "return_location": "Barranquilla Centro",
            "total_value": 310000,
            "status": reservation_statuses["Completada"],
            "reservation_date": now - timedelta(days=20),
        },
    )
    if completed_reservation.status_id != reservation_statuses["Completada"].id:
        completed_reservation.status = reservation_statuses["Completada"]
        completed_reservation.save(update_fields=["status", "updated_at"])

    # Create a confirmed reservation for second publication
    confirmed_reservation, _ = Reservation.objects.get_or_create(
        reservation_code="FD-DEMO-0002",
        defaults={
            "user": renter_user,
            "publication": publications[1],
            "payment_method": payment_method,
            "period_type": period_types["Semana"],
            "periods_quantity": 1,
            "start_date": now + timedelta(days=2),
            "end_date": now + timedelta(days=9),
            "pickup_location": "Medellín Poblado",
            "return_location": "Medellín Poblado",
            "total_value": 980000,
            "status": reservation_statuses["Confirmada"],
            "reservation_date": now - timedelta(days=1),
        },
    )
    if confirmed_reservation.status_id != reservation_statuses["Confirmada"].id:
        confirmed_reservation.status = reservation_statuses["Confirmada"]
        confirmed_reservation.save(update_fields=["status", "updated_at"])

    # Real reviews for each publication from renter user
    review_texts = [
        ("Excelente vehículo, muy cómodo para ciudad.", 5),
        ("SUV impecable y cómoda para viaje familiar.", 5),
        ("Buen carro, económico en consumo.", 4),
        ("Conducción premium, volvería a rentarlo.", 5),
        ("Muy útil para carga y viajes fuera de la ciudad.", 4),
        ("Buen estado general y entrega puntual.", 4),
    ]

    for publication, (description, rating) in zip(publications, review_texts):
        opinion, _ = Opinion.objects.get_or_create(
            description=description,
            defaults={"rating": rating},
        )
        if opinion.rating != rating:
            opinion.rating = rating
            opinion.save(update_fields=["rating", "updated_at"])

        Review.objects.update_or_create(
            user=renter_user,
            publication=publication,
            defaults={
                "opinion": opinion,
                "review_date": now - timedelta(days=3),
            },
        )

    # Notifications for renter user
    notification_payloads = [
        {
            "category": notification_categories["Reserva"],
            "subject": "Reserva confirmada FD-DEMO-0002",
            "description": "Tu reserva fue confirmada. Recoge el vehículo en Medellín Poblado.",
            "status": "no_leida",
            "sent_at": now - timedelta(hours=4),
        },
        {
            "category": notification_categories["Recordatorio"],
            "subject": "Recordatorio de inicio de reserva",
            "description": "Tu reserva inicia en 2 días. Verifica documentos y punto de entrega.",
            "status": "no_leida",
            "sent_at": now - timedelta(hours=1),
        },
        {
            "category": notification_categories["Auto"],
            "subject": "Nuevo vehículo disponible en Barranquilla",
            "description": "Se publicó un nuevo SUV disponible para tus próximas reservas.",
            "status": "leida",
            "sent_at": now - timedelta(days=1),
        },
    ]

    for payload in notification_payloads:
        Notification.objects.get_or_create(
            user=renter_user,
            subject=payload["subject"],
            defaults={
                "category": payload["category"],
                "description": payload["description"],
                "status": payload["status"],
                "sent_at": payload["sent_at"],
            },
        )


def run() -> None:
    catalogs = ensure_catalogs()

    arrendador_user = ensure_user(
        full_name="Gabriel Padilla",
        email="gabriel.padilla@flexidrive.co",
        identification_number="1002544687",
        user_type=catalogs["user_type_arrendador"],
        identification_type=catalogs["ident_cc"],
        phone="+57 300 123 4567",
        can_publish=False,
    )

    arrendatario_user = ensure_user(
        full_name="Laura Castro",
        email="laura.castro@flexidrive.co",
        identification_number="1009988776",
        user_type=catalogs["user_type_arrendatario"],
        identification_type=catalogs["ident_cc"],
        phone="+57 301 765 4321",
        can_publish=True,
    )

    publications = ensure_vehicle_publications(
        owner_user=arrendatario_user,
        categories=catalogs["vehicle_categories"],
        period_types=catalogs["period_types"],
    )

    payment_method = ensure_payment_profile(
        renter_user=arrendador_user,
        payment_types=catalogs["payment_types"],
        card_brands=catalogs["card_brands"],
    )

    ensure_reservations_and_reviews(
        renter_user=arrendador_user,
        publications=publications,
        payment_method=payment_method,
        period_types=catalogs["period_types"],
        reservation_statuses=catalogs["reservation_statuses"],
        notification_categories=catalogs["notification_categories"],
    )

    print("=== Seed completado ===")
    print(f"Arrendador: {arrendador_user.full_name} | {arrendador_user.email}")
    print(f"Arrendatario: {arrendatario_user.full_name} | {arrendatario_user.email}")
    print(f"Publicaciones activas del arrendatario: {len(publications)}")
    print(f"Contraseña para ambas cuentas: {PASSWORD_PLAIN}")


run()

from datetime import date, timedelta
from decimal import Decimal

from django.contrib.auth.hashers import make_password
from django.db import migrations
from django.utils import timezone


def seed_all_test_data(apps, schema_editor):
    IdentificationType = apps.get_model("accounts", "IdentificationType")
    UserType = apps.get_model("accounts", "UserType")
    User = apps.get_model("accounts", "User")
    UserPreference = apps.get_model("accounts", "UserPreference")
    UserSecurity = apps.get_model("accounts", "UserSecurity")

    OwnerDocumentType = apps.get_model("documents", "OwnerDocumentType")
    DocumentVerificationStatus = apps.get_model("documents", "DocumentVerificationStatus")
    OwnerDocument = apps.get_model("documents", "OwnerDocument")

    NotificationCategory = apps.get_model("notifications", "NotificationCategory")
    Notification = apps.get_model("notifications", "Notification")

    PaymentMethodType = apps.get_model("payments", "PaymentMethodType")
    Bank = apps.get_model("payments", "Bank")
    CardBrand = apps.get_model("payments", "CardBrand")
    PersonType = apps.get_model("payments", "PersonType")
    PaymentMethod = apps.get_model("payments", "PaymentMethod")
    Card = apps.get_model("payments", "Card")
    PSE = apps.get_model("payments", "PSE")

    PeriodType = apps.get_model("publications", "PeriodType")
    Publication = apps.get_model("publications", "Publication")
    PublicationPrice = apps.get_model("publications", "PublicationPrice")
    PublicationImage = apps.get_model("publications", "PublicationImage")

    ReservationStatus = apps.get_model("reservations", "ReservationStatus")
    Reservation = apps.get_model("reservations", "Reservation")

    Opinion = apps.get_model("reviews", "Opinion")
    Review = apps.get_model("reviews", "Review")

    UserSession = apps.get_model("security", "UserSession")
    LoginAttempt = apps.get_model("security", "LoginAttempt")
    RefreshToken = apps.get_model("security", "RefreshToken")

    VehicleCategory = apps.get_model("vehicles", "VehicleCategory")
    Vehicle = apps.get_model("vehicles", "Vehicle")

    now = timezone.now()

    identification_names = [
        "Cedula Ciudadania",
        "Pasaporte",
        "Tarjeta de Identidad",
        "Cedula de Extranjeria",
        "Documento Nacional",
        "Permiso Temporal",
        "Registro Civil",
        "Carnet Diplomatico",
        "Documento Militar",
        "Licencia de Conduccion",
        "Documento Regional",
        "Documento Consular",
        "Documento Mercosur",
        "Documento Schengen",
        "Documento Fronterizo",
    ]
    identification_types = [
        IdentificationType.objects.create(name=name, description=f"Tipo de identificacion {name}")
        for name in identification_names
    ]

    user_type_names = [
        "Arrendador",
        "Arrendatario",
        "Administrador",
        "Soporte",
        "Operador",
        "Supervisor",
        "Analista",
        "Auditor",
        "Gestor",
        "Invitado",
        "Empresa",
        "Particular",
        "Moderador",
        "Conductor",
        "Aliado",
    ]
    user_types = [
        UserType.objects.create(name=name, description=f"Rol de usuario {name}")
        for name in user_type_names
    ]

    users = []
    for i in range(15):
        user = User.objects.create(
            identification_type=identification_types[i % 15],
            identification_number=f"DOC-{100000 + i}",
            user_type=user_types[0],
            full_name=f"Usuario Prueba {i + 1}",
            email=f"usuario{i + 1}@flexidrive.test",
            phone=f"300500{1000 + i}",
            password_hash=make_password(f"FlexiPass#{i + 1}A"),
            can_publish=i % 2 == 0,
            profile_photo=None,
            address=f"Calle {10 + i} # {20 + i}-{30 + i}",
            city=["Barranquilla", "Bogota", "Medellin", "Cali", "Cartagena"][i % 5],
            country="Colombia",
            date_of_birth=date(1990 + (i % 10), (i % 12) + 1, (i % 28) + 1),
            last_login=now - timedelta(hours=i),
            is_active=True,
            is_verified=i % 3 == 0,
            email_verified=i % 2 == 0,
            failed_login_attempts=0,
            account_locked_until=None,
            google_id=None,
            auth_provider="local",
            provider_uid=None,
        )
        users.append(user)

    for i in range(15):
        UserPreference.objects.create(
            user=users[i],
            dark_mode=i % 2 == 0,
            language=["es", "en", "pt"][i % 3],
        )

    for i in range(15):
        UserSecurity.objects.create(
            user=users[i],
            two_factor_verification=i % 3 == 0,
            biometric_access=i % 2 == 0,
        )

    vehicle_category_names = [
        "Sedan",
        "Hatchback",
        "SUV",
        "Pickup",
        "Van",
        "Minivan",
        "Coupe",
        "Convertible",
        "Camioneta",
        "Electrico",
        "Hibrido",
        "Campero",
        "Deportivo",
        "Familiar",
        "Comercial",
    ]
    vehicle_categories = [
        VehicleCategory.objects.create(name=name, description=f"Categoria de vehiculo {name}")
        for name in vehicle_category_names
    ]

    vehicles = []
    lines = [
        "Mazda 3",
        "Kia Picanto",
        "Renault Duster",
        "Toyota Hilux",
        "Chevrolet Tracker",
        "Nissan Versa",
        "Hyundai Tucson",
        "Volkswagen Golf",
        "Ford Ranger",
        "BMW X1",
        "Tesla Model 3",
        "Suzuki Swift",
        "Honda Civic",
        "Jeep Compass",
        "Chevrolet Onix",
    ]
    for i in range(15):
        vehicles.append(
            Vehicle.objects.create(
                category=vehicle_categories[i],
                line=lines[i],
                model_year=2016 + (i % 9),
                color=["Blanco", "Negro", "Gris", "Azul", "Rojo"][i % 5],
                seats=[4, 5, 5, 5, 7][i % 5],
                transmission_type=["Manual", "Automatica"][i % 2],
                air_conditioning=True,
                fuel_type=["Gasolina", "Diesel", "Hibrido", "Electrico"][i % 4],
                description=f"Vehiculo de prueba {i + 1} para alquiler por horas",
            )
        )

    period_type_names = [
        "Hora",
        "Dia",
        "Semana",
        "Fin de semana",
        "Quincena",
        "Mes",
        "Noche",
        "Manana",
        "Tarde",
        "Jornada laboral",
        "Bloque 3 horas",
        "Bloque 6 horas",
        "Bloque 12 horas",
        "Festivo",
        "Temporada alta",
    ]
    period_types = [
        PeriodType.objects.create(name=name, description=f"Periodo tarifario {name}")
        for name in period_type_names
    ]

    publications = []
    for i in range(15):
        publications.append(
            Publication.objects.create(
                user=users[i],
                vehicle=vehicles[i],
                publication_date=now - timedelta(days=i),
                is_active=True,
            )
        )

    for i in range(15):
        PublicationPrice.objects.create(
            publication=publications[i],
            period_type=period_types[i],
            price=Decimal("20000.00") + Decimal(i * 1500),
        )

    for i in range(15):
        PublicationImage.objects.create(
            publication=publications[i],
            image=f"publications/images/vehiculo_{i + 1}.jpg",
            order=1,
            is_main=True,
            uploaded_at=now - timedelta(days=i),
        )

    reservation_status_names = [
        "Pendiente",
        "Confirmada",
        "Pagada",
        "En curso",
        "Finalizada",
        "Cancelada",
        "Rechazada",
        "Reembolsada",
        "Expirada",
        "Reprogramada",
        "Pre-reserva",
        "Validando pago",
        "Pendiente entrega",
        "Pendiente devolucion",
        "Cerrada",
    ]
    reservation_statuses = [
        ReservationStatus.objects.create(name=name, description=f"Estado de reserva {name}")
        for name in reservation_status_names
    ]

    payment_method_type_names = [
        "Tarjeta credito",
        "Tarjeta debito",
        "PSE",
        "Transferencia",
        "Nequi",
        "Daviplata",
        "Apple Pay",
        "Google Pay",
        "PayPal",
        "Efectivo",
        "QR",
        "Billetera digital",
        "Credito interno",
        "Mixto",
        "Convenio empresarial",
    ]
    payment_method_types = [
        PaymentMethodType.objects.create(name=name, description=f"Metodo de pago {name}")
        for name in payment_method_type_names
    ]

    bank_names = [
        "Bancolombia",
        "Banco de Bogota",
        "Davivienda",
        "BBVA",
        "Banco Popular",
        "Banco AV Villas",
        "Banco de Occidente",
        "Banco Caja Social",
        "Banco Agrario",
        "Scotiabank Colpatria",
        "ItaU",
        "Nu Bank",
        "Banco Falabella",
        "Banco Pichincha",
        "Ban100",
    ]
    banks = [Bank.objects.create(name=name, description=f"Banco {name}") for name in bank_names]

    card_brand_names = [
        "Visa",
        "Mastercard",
        "American Express",
        "Diners Club",
        "Maestro",
        "UnionPay",
        "Discover",
        "JCB",
        "Elo",
        "Credencial",
        "Cabal",
        "Tarjeta Exito",
        "Tarjeta Olimpica",
        "Tarjeta Homecenter",
        "Tarjeta Cencosud",
    ]
    card_brands = [
        CardBrand.objects.create(name=name, description=f"Marca de tarjeta {name}")
        for name in card_brand_names
    ]

    person_type_names = [
        "Natural",
        "Juridica",
        "Extranjero",
        "Microempresa",
        "PYME",
        "Corporativo",
        "Emprendedor",
        "Independiente",
        "Entidad publica",
        "Fundacion",
        "Cooperativa",
        "ONG",
        "Startup",
        "Comerciante",
        "Profesional",
    ]
    person_types = [
        PersonType.objects.create(name=name, description=f"Tipo de persona {name}")
        for name in person_type_names
    ]

    payment_methods = []
    for i in range(15):
        payment_methods.append(
            PaymentMethod.objects.create(
                user=users[i],
                payment_method_type=payment_method_types[i],
                is_default=i % 3 == 0,
            )
        )

    for i in range(15):
        Card.objects.create(
            payment_method=payment_methods[i],
            card_brand=card_brands[i],
            last4=f"{1000 + i}"[-4:],
            tokenized_card_reference=f"tok_card_seed_{i + 1:03d}",
            expiration_month=(i % 12) + 1,
            expiration_year=2028 + (i % 5),
        )

    for i in range(15):
        PSE.objects.create(
            payment_method=payment_methods[i],
            bank=banks[i],
            person_type=person_types[i],
        )

    reservations = []
    for i in range(15):
        start_dt = now + timedelta(days=i)
        end_dt = start_dt + timedelta(hours=6 + (i % 6))
        reservations.append(
            Reservation.objects.create(
                reservation_code=f"RSV-{2026}{i + 1:04d}",
                user=users[i],
                publication=publications[i],
                payment_method=payment_methods[i],
                period_type=period_types[i],
                periods_quantity=1 + (i % 3),
                start_date=start_dt,
                end_date=end_dt,
                pickup_location=f"Punto de recogida #{i + 1}, Barranquilla",
                return_location=f"Punto de entrega #{i + 1}, Barranquilla",
                total_value=Decimal("80000.00") + Decimal(i * 2500),
                status=reservation_statuses[i],
                reservation_date=now - timedelta(days=i),
            )
        )

    opinions = []
    for i in range(15):
        opinions.append(
            Opinion.objects.create(
                rating=(i % 5) + 1,
                description=f"Opinion de prueba {i + 1}: servicio confiable y puntual.",
            )
        )

    for i in range(15):
        Review.objects.create(
            user=users[i],
            publication=publications[i],
            opinion=opinions[i],
            review_date=now - timedelta(days=i),
        )

    notification_category_names = [
        "Reserva",
        "Pago",
        "Sistema",
        "Promocion",
        "Recordatorio",
        "Seguridad",
        "Documento",
        "Vehiculo",
        "Cuenta",
        "Soporte",
        "Campana",
        "Novedad",
        "Alerta",
        "Operativa",
        "Comercial",
    ]
    notification_categories = [
        NotificationCategory.objects.create(name=name, description=f"Categoria de notificacion {name}")
        for name in notification_category_names
    ]

    for i in range(15):
        Notification.objects.create(
            user=users[i],
            category=notification_categories[i],
            subject=f"Notificacion de prueba {i + 1}",
            description=f"Mensaje de prueba para el usuario {users[i].full_name}",
            status="leida" if i % 2 == 0 else "no_leida",
            sent_at=now - timedelta(minutes=i * 10),
        )

    owner_document_type_names = [
        "Cedula",
        "Pasaporte",
        "Licencia conduccion",
        "SOAT",
        "Tarjeta propiedad",
        "RUT",
        "Camara comercio",
        "Certificado ingresos",
        "Recibo servicio publico",
        "Poliza todo riesgo",
        "Contrato arrendamiento",
        "Extracto bancario",
        "Foto perfil",
        "Certificado laboral",
        "Antecedentes",
    ]
    owner_document_types = [
        OwnerDocumentType.objects.create(name=name, description=f"Documento requerido: {name}")
        for name in owner_document_type_names
    ]

    verification_status_names = [
        "Pendiente",
        "En revision",
        "Aprobado",
        "Rechazado",
        "Corregir",
        "Vencido",
        "Reenviado",
        "Validado",
        "En cola",
        "Observado",
        "Anulado",
        "Suspendido",
        "Preaprobado",
        "Aprobado con observacion",
        "Bloqueado",
    ]
    verification_statuses = [
        DocumentVerificationStatus.objects.create(name=name, description=f"Estado documental {name}")
        for name in verification_status_names
    ]

    for i in range(15):
        is_verified = verification_statuses[i].name in {"Aprobado", "Validado", "Preaprobado"}
        OwnerDocument.objects.create(
            user=users[i],
            owner_document_type=owner_document_types[i],
            verification_status=verification_statuses[i],
            document_file=f"documents/owners/documento_{i + 1}.pdf",
            upload_date=now - timedelta(days=20 - i),
            verification_date=(now - timedelta(days=10 - i)) if is_verified else None,
            observations="Documento legible y completo" if is_verified else "Pendiente de validacion",
            file_size=250000 + (i * 1800),
            file_type="application/pdf",
            uploaded_by=users[i],
            verification_notes="Validado automaticamente" if is_verified else "Requiere revision manual",
            verified_by_admin=users[(i + 1) % 15] if is_verified else None,
            verified_at=(now - timedelta(days=5 - (i % 5))) if is_verified else None,
        )

    sessions = []
    for i in range(15):
        session = UserSession.objects.create(
            user=users[i],
            device=["iPhone 13", "Samsung S23", "Xiaomi 13", "Motorola Edge", "iPad"][i % 5],
            operating_system=["iOS", "Android", "Android", "Android", "iOS"][i % 5],
            ip_address=f"190.25.{10 + i}.{20 + i}",
            start_date=now - timedelta(hours=i * 3),
            is_active=i % 4 != 0,
            ended_at=(now - timedelta(hours=i)) if i % 4 == 0 else None,
        )
        sessions.append(session)

    for i in range(15):
        LoginAttempt.objects.create(
            user=users[i],
            email=users[i].email,
            ip_address=f"181.50.{30 + i}.{40 + i}",
            user_agent="PostmanRuntime/7.39.0",
            was_successful=i % 3 != 0,
        )

    for i in range(15):
        RefreshToken.objects.create(
            user=users[i],
            session=sessions[i],
            token=f"seed_refresh_token_{i + 1:03d}_flexidrive_2026",
            is_revoked=i % 5 == 0,
            expires_at=now + timedelta(days=30 - (i % 10)),
            last_used_at=now - timedelta(hours=i) if i % 2 == 0 else None,
        )


def noop_reverse(apps, schema_editor):
    pass


class Migration(migrations.Migration):

    dependencies = [
        ("accounts", "0001_initial"),
        ("documents", "0001_initial"),
        ("notifications", "0001_initial"),
        ("payments", "0001_initial"),
        ("publications", "0001_initial"),
        ("reservations", "0001_initial"),
        ("reviews", "0001_initial"),
        ("security", "0001_initial"),
        ("vehicles", "0001_initial"),
    ]

    operations = [
        migrations.RunPython(seed_all_test_data, noop_reverse),
    ]

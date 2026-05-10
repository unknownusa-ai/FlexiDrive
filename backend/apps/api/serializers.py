from django.contrib.auth.hashers import make_password
from django.utils import timezone
from rest_framework import serializers

from apps.accounts.models import IdentificationType, User, UserPreference, UserSecurity, UserType
from apps.documents.models import DocumentVerificationStatus, OwnerDocument, OwnerDocumentType
from apps.notifications.models import Notification, NotificationCategory
from apps.payments.models import Bank, Card, CardBrand, PaymentMethod, PaymentMethodType, PersonType, PSE
from apps.publications.models import PeriodType, Publication, PublicationImage, PublicationPrice
from apps.reservations.models import Reservation, ReservationStatus
from apps.reviews.models import Opinion, Review
from apps.security.models import UserSession
from apps.vehicles.models import Vehicle, VehicleCategory


class NamedCatalogSerializer(serializers.ModelSerializer):
    nombre = serializers.CharField(source="name")
    descripcion = serializers.CharField(source="description", allow_blank=True, allow_null=True, required=False)


class IdentificationTypeSerializer(NamedCatalogSerializer):
    tipo_identificacion_id = serializers.IntegerField(source="id", read_only=True)

    class Meta:
        model = IdentificationType
        fields = ("tipo_identificacion_id", "nombre", "descripcion")


class UserTypeSerializer(NamedCatalogSerializer):
    tipo_usuario_id = serializers.IntegerField(source="id", read_only=True)

    class Meta:
        model = UserType
        fields = ("tipo_usuario_id", "nombre", "descripcion")


class PaymentMethodTypeSerializer(NamedCatalogSerializer):
    tipo_metodo_pago_id = serializers.IntegerField(source="id", read_only=True)

    class Meta:
        model = PaymentMethodType
        fields = ("tipo_metodo_pago_id", "nombre", "descripcion")


class BankSerializer(NamedCatalogSerializer):
    banco_id = serializers.IntegerField(source="id", read_only=True)

    class Meta:
        model = Bank
        fields = ("banco_id", "nombre", "descripcion")


class CardBrandSerializer(NamedCatalogSerializer):
    marca_tarjeta_id = serializers.IntegerField(source="id", read_only=True)

    class Meta:
        model = CardBrand
        fields = ("marca_tarjeta_id", "nombre", "descripcion")


class PersonTypeSerializer(NamedCatalogSerializer):
    tipo_persona_id = serializers.IntegerField(source="id", read_only=True)

    class Meta:
        model = PersonType
        fields = ("tipo_persona_id", "nombre", "descripcion")


class VehicleCategorySerializer(NamedCatalogSerializer):
    categoria_vehiculo_id = serializers.IntegerField(source="id", read_only=True)

    class Meta:
        model = VehicleCategory
        fields = ("categoria_vehiculo_id", "nombre", "descripcion")


class PeriodTypeSerializer(NamedCatalogSerializer):
    tipo_periodo_id = serializers.IntegerField(source="id", read_only=True)

    class Meta:
        model = PeriodType
        fields = ("tipo_periodo_id", "nombre", "descripcion")


class ReservationStatusSerializer(NamedCatalogSerializer):
    estado_reserva_id = serializers.IntegerField(source="id", read_only=True)

    class Meta:
        model = ReservationStatus
        fields = ("estado_reserva_id", "nombre", "descripcion")


class NotificationCategorySerializer(NamedCatalogSerializer):
    categoria_notificacion_id = serializers.IntegerField(source="id", read_only=True)

    class Meta:
        model = NotificationCategory
        fields = ("categoria_notificacion_id", "nombre", "descripcion")


class OwnerDocumentTypeSerializer(NamedCatalogSerializer):
    tipo_documento_arrendador_id = serializers.IntegerField(source="id", read_only=True)

    class Meta:
        model = OwnerDocumentType
        fields = ("tipo_documento_arrendador_id", "nombre", "descripcion")


class DocumentVerificationStatusSerializer(NamedCatalogSerializer):
    estado_verificacion_documento_id = serializers.IntegerField(source="id", read_only=True)

    class Meta:
        model = DocumentVerificationStatus
        fields = ("estado_verificacion_documento_id", "nombre", "descripcion")


class UserSerializer(serializers.ModelSerializer):
    usuario_id = serializers.IntegerField(source="id", read_only=True)
    tipo_identificacion_id = serializers.PrimaryKeyRelatedField(source="identification_type", queryset=IdentificationType.objects.all())
    numero_identificacion = serializers.CharField(source="identification_number")
    tipo_usuario_id = serializers.PrimaryKeyRelatedField(source="user_type", queryset=UserType.objects.all())
    nombre_completo = serializers.CharField(source="full_name")
    correo = serializers.EmailField(source="email")
    telefono = serializers.CharField(source="phone")
    contrasena = serializers.CharField(write_only=True, required=False, allow_blank=True)
    puede_publicar = serializers.BooleanField(source="can_publish")

    class Meta:
        model = User
        fields = (
            "usuario_id",
            "tipo_identificacion_id",
            "numero_identificacion",
            "tipo_usuario_id",
            "nombre_completo",
            "correo",
            "telefono",
            "contrasena",
            "puede_publicar",
        )

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data["contrasena"] = ""
        return data

    def create(self, validated_data):
        password = validated_data.pop("contrasena", None) or "FlexiDrive#2026"
        validated_data["password_hash"] = make_password(password)
        return super().create(validated_data)

    def update(self, instance, validated_data):
        password = validated_data.pop("contrasena", None)
        if password:
            instance.password_hash = make_password(password)
        return super().update(instance, validated_data)


class UserPreferenceSerializer(serializers.ModelSerializer):
    preferencia_usuario_id = serializers.IntegerField(source="id", read_only=True)
    usuario_id = serializers.PrimaryKeyRelatedField(source="user", queryset=User.objects.all())
    modo_oscuro = serializers.BooleanField(source="dark_mode")
    idioma = serializers.CharField(source="language")
    imagen_perfil = serializers.SerializerMethodField()

    class Meta:
        model = UserPreference
        fields = ("preferencia_usuario_id", "usuario_id", "modo_oscuro", "idioma", "imagen_perfil")

    def get_imagen_perfil(self, obj):
        return obj.user.profile_photo.url if obj.user.profile_photo else None


class UserSecuritySerializer(serializers.ModelSerializer):
    seguridad_usuario_id = serializers.IntegerField(source="id", read_only=True)
    usuario_id = serializers.PrimaryKeyRelatedField(source="user", queryset=User.objects.all())
    verificacion_dos_pasos = serializers.BooleanField(source="two_factor_verification")
    acceso_biometrico = serializers.BooleanField(source="biometric_access")

    class Meta:
        model = UserSecurity
        fields = ("seguridad_usuario_id", "usuario_id", "verificacion_dos_pasos", "acceso_biometrico")


class VehicleSerializer(serializers.ModelSerializer):
    vehiculo_id = serializers.IntegerField(source="id", read_only=True)
    categoria_vehiculo_id = serializers.PrimaryKeyRelatedField(source="category", queryset=VehicleCategory.objects.all())
    linea = serializers.CharField(source="line")
    modelo = serializers.IntegerField(source="model_year")
    asientos = serializers.IntegerField(source="seats")
    tipo_transmision = serializers.CharField(source="transmission_type")
    aire_acondicionado = serializers.BooleanField(source="air_conditioning")
    tipo_combustible = serializers.CharField(source="fuel_type")
    descripcion = serializers.CharField(source="description", allow_blank=True, allow_null=True, required=False)

    class Meta:
        model = Vehicle
        fields = (
            "vehiculo_id",
            "categoria_vehiculo_id",
            "linea",
            "modelo",
            "color",
            "asientos",
            "tipo_transmision",
            "aire_acondicionado",
            "tipo_combustible",
            "descripcion",
        )


class PublicationSerializer(serializers.ModelSerializer):
    publicacion_id = serializers.IntegerField(source="id", read_only=True)
    usuario_id = serializers.PrimaryKeyRelatedField(source="user", queryset=User.objects.all())
    vehiculo_id = serializers.PrimaryKeyRelatedField(source="vehicle", queryset=Vehicle.objects.all())
    fecha_publicacion = serializers.DateTimeField(source="publication_date")
    activa = serializers.BooleanField(source="is_active")

    class Meta:
        model = Publication
        fields = ("publicacion_id", "usuario_id", "vehiculo_id", "fecha_publicacion", "activa")


class PublicationPriceSerializer(serializers.ModelSerializer):
    precio_publicacion_id = serializers.IntegerField(source="id", read_only=True)
    publicacion_id = serializers.PrimaryKeyRelatedField(source="publication", queryset=Publication.objects.all())
    tipo_periodo_id = serializers.PrimaryKeyRelatedField(source="period_type", queryset=PeriodType.objects.all())
    precio = serializers.DecimalField(source="price", max_digits=10, decimal_places=2)

    class Meta:
        model = PublicationPrice
        fields = ("precio_publicacion_id", "publicacion_id", "tipo_periodo_id", "precio")


class PublicationImageSerializer(serializers.ModelSerializer):
    imagen_publicacion_id = serializers.IntegerField(source="id", read_only=True)
    publicacion_id = serializers.PrimaryKeyRelatedField(source="publication", queryset=Publication.objects.all())
    url_imagen = serializers.CharField(source="image")
    orden = serializers.IntegerField(source="order")
    es_principal = serializers.BooleanField(source="is_main")
    fecha_subida = serializers.DateTimeField(source="uploaded_at")

    class Meta:
        model = PublicationImage
        fields = ("imagen_publicacion_id", "publicacion_id", "url_imagen", "orden", "es_principal", "fecha_subida")


class PaymentMethodSerializer(serializers.ModelSerializer):
    metodo_pago_id = serializers.IntegerField(source="id", read_only=True)
    usuario_id = serializers.PrimaryKeyRelatedField(source="user", queryset=User.objects.all())
    tipo_metodo_pago_id = serializers.PrimaryKeyRelatedField(source="payment_method_type", queryset=PaymentMethodType.objects.all())
    predeterminado = serializers.BooleanField(source="is_default")

    class Meta:
        model = PaymentMethod
        fields = ("metodo_pago_id", "usuario_id", "tipo_metodo_pago_id", "predeterminado")


class CardSerializer(serializers.ModelSerializer):
    tarjeta_id = serializers.IntegerField(source="id", read_only=True)
    metodo_pago_id = serializers.PrimaryKeyRelatedField(source="payment_method", queryset=PaymentMethod.objects.all())
    numero_tarjeta = serializers.SerializerMethodField()
    marca_tarjeta_id = serializers.PrimaryKeyRelatedField(source="card_brand", queryset=CardBrand.objects.all())
    mes_expiracion = serializers.IntegerField(source="expiration_month")
    ano_expiracion = serializers.IntegerField(source="expiration_year")
    cvc = serializers.SerializerMethodField()

    class Meta:
        model = Card
        fields = ("tarjeta_id", "metodo_pago_id", "numero_tarjeta", "marca_tarjeta_id", "mes_expiracion", "ano_expiracion", "cvc")

    def get_numero_tarjeta(self, obj):
        return f"**** **** **** {obj.last4}"

    def get_cvc(self, obj):
        return 0

    def create(self, validated_data):
        validated_data.setdefault("last4", "0000")
        validated_data.setdefault("tokenized_card_reference", f"manual_card_{timezone.now().timestamp()}")
        return super().create(validated_data)


class PseSerializer(serializers.ModelSerializer):
    pse_id = serializers.IntegerField(source="id", read_only=True)
    metodo_pago_id = serializers.PrimaryKeyRelatedField(source="payment_method", queryset=PaymentMethod.objects.all())
    banco_id = serializers.PrimaryKeyRelatedField(source="bank", queryset=Bank.objects.all())
    tipo_persona_id = serializers.PrimaryKeyRelatedField(source="person_type", queryset=PersonType.objects.all())

    class Meta:
        model = PSE
        fields = ("pse_id", "metodo_pago_id", "banco_id", "tipo_persona_id")


class ReservationSerializer(serializers.ModelSerializer):
    reserva_id = serializers.IntegerField(source="id", read_only=True)
    codigo_reserva = serializers.CharField(source="reservation_code", required=False)
    usuario_id = serializers.PrimaryKeyRelatedField(source="user", queryset=User.objects.all())
    publicacion_id = serializers.PrimaryKeyRelatedField(source="publication", queryset=Publication.objects.all())
    metodo_pago_id = serializers.PrimaryKeyRelatedField(source="payment_method", queryset=PaymentMethod.objects.all())
    tipo_periodo_id = serializers.PrimaryKeyRelatedField(source="period_type", queryset=PeriodType.objects.all())
    cantidad_periodos = serializers.IntegerField(source="periods_quantity")
    fecha_inicio = serializers.DateTimeField(source="start_date")
    fecha_fin = serializers.DateTimeField(source="end_date")
    ubicacion_recogida = serializers.CharField(source="pickup_location")
    ubicacion_entrega = serializers.CharField(source="return_location")
    valor_total = serializers.DecimalField(source="total_value", max_digits=10, decimal_places=2)
    estado_reserva_id = serializers.PrimaryKeyRelatedField(source="status", queryset=ReservationStatus.objects.all())
    fecha_reserva = serializers.DateTimeField(source="reservation_date")

    class Meta:
        model = Reservation
        fields = (
            "reserva_id",
            "codigo_reserva",
            "usuario_id",
            "publicacion_id",
            "metodo_pago_id",
            "tipo_periodo_id",
            "cantidad_periodos",
            "fecha_inicio",
            "fecha_fin",
            "ubicacion_recogida",
            "ubicacion_entrega",
            "valor_total",
            "estado_reserva_id",
            "fecha_reserva",
        )

    def create(self, validated_data):
        if not validated_data.get("reservation_code"):
            last_id = Reservation.objects.order_by("-id").values_list("id", flat=True).first() or 0
            validated_data["reservation_code"] = f"RSV-{last_id + 1:06d}"
        return super().create(validated_data)


class NotificationSerializer(serializers.ModelSerializer):
    notificacion_id = serializers.IntegerField(source="id", read_only=True)
    usuario_id = serializers.PrimaryKeyRelatedField(source="user", queryset=User.objects.all())
    categoria_notificacion_id = serializers.PrimaryKeyRelatedField(source="category", queryset=NotificationCategory.objects.all())
    asunto = serializers.CharField(source="subject")
    descripcion = serializers.CharField(source="description")
    estado = serializers.CharField(source="status")
    fecha_envio = serializers.DateTimeField(source="sent_at")

    class Meta:
        model = Notification
        fields = ("notificacion_id", "usuario_id", "categoria_notificacion_id", "asunto", "descripcion", "estado", "fecha_envio")


class OpinionSerializer(serializers.ModelSerializer):
    opinion_id = serializers.IntegerField(source="id", read_only=True)
    calificacion = serializers.IntegerField(source="rating")
    descripcion = serializers.CharField(source="description", allow_blank=True, allow_null=True, required=False)

    class Meta:
        model = Opinion
        fields = ("opinion_id", "calificacion", "descripcion")


class ReviewSerializer(serializers.ModelSerializer):
    resena_id = serializers.IntegerField(source="id", read_only=True)
    usuario_id = serializers.PrimaryKeyRelatedField(source="user", queryset=User.objects.all())
    publicacion_id = serializers.PrimaryKeyRelatedField(source="publication", queryset=Publication.objects.all())
    opinion_id = serializers.PrimaryKeyRelatedField(source="opinion", queryset=Opinion.objects.all())
    fecha = serializers.DateTimeField(source="review_date")

    class Meta:
        model = Review
        fields = ("resena_id", "usuario_id", "publicacion_id", "opinion_id", "fecha")


class OwnerDocumentSerializer(serializers.ModelSerializer):
    documento_arrendador_id = serializers.IntegerField(source="id", read_only=True)
    usuario_id = serializers.PrimaryKeyRelatedField(source="user", queryset=User.objects.all())
    tipo_documento_arrendador_id = serializers.PrimaryKeyRelatedField(source="owner_document_type", queryset=OwnerDocumentType.objects.all())
    estado_verificacion_documento_id = serializers.PrimaryKeyRelatedField(source="verification_status", queryset=DocumentVerificationStatus.objects.all())
    url_documento = serializers.CharField(source="document_file")
    fecha_subida = serializers.DateTimeField(source="upload_date")
    fecha_verificacion = serializers.DateTimeField(source="verification_date", allow_null=True, required=False)
    observaciones = serializers.CharField(source="observations", allow_blank=True, allow_null=True, required=False)

    class Meta:
        model = OwnerDocument
        fields = (
            "documento_arrendador_id",
            "usuario_id",
            "tipo_documento_arrendador_id",
            "estado_verificacion_documento_id",
            "url_documento",
            "fecha_subida",
            "fecha_verificacion",
            "observaciones",
        )

    def create(self, validated_data):
        user = validated_data.get("user")
        validated_data.setdefault("file_size", 0)
        validated_data.setdefault("file_type", "application/octet-stream")
        validated_data.setdefault("uploaded_by", user)
        return super().create(validated_data)


class UserSessionSerializer(serializers.ModelSerializer):
    sesion_usuario_id = serializers.IntegerField(source="id", read_only=True)
    usuario_id = serializers.PrimaryKeyRelatedField(source="user", queryset=User.objects.all())
    dispositivo = serializers.CharField(source="device")
    sistema_operativo = serializers.CharField(source="operating_system")
    direccion_ip = serializers.CharField(source="ip_address")
    fecha_inicio = serializers.DateTimeField(source="start_date")
    activa = serializers.BooleanField(source="is_active")

    class Meta:
        model = UserSession
        fields = ("sesion_usuario_id", "usuario_id", "dispositivo", "sistema_operativo", "direccion_ip", "fecha_inicio", "activa")

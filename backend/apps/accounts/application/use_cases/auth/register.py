from django.contrib.auth.hashers import make_password

from apps.accounts.application.use_cases.auth.errors import AuthServiceError
from apps.accounts.models import IdentificationType, User, UserType


def register_user(data: dict) -> dict:
    correo = data["correo"].strip().lower()
    numero_identificacion = data["numero_identificacion"].strip()
    tipo_identificacion_id = data["tipo_identificacion_id"]

    if User.objects.filter(email=correo).exists():
        raise AuthServiceError(detail="El correo ya existe")

    if User.objects.filter(identification_number=numero_identificacion).exists():
        raise AuthServiceError(detail="El numero de identificacion ya existe")

    identification_type = IdentificationType.objects.filter(id=tipo_identificacion_id).first()
    user_type = UserType.objects.filter(name__iexact="Arrendador").first()

    if not identification_type:
        raise AuthServiceError(detail="El tipo de identificacion no existe")

    if not user_type:
        raise AuthServiceError(
            detail="No existe el tipo de usuario por defecto Arrendador"
        )

    user = User.objects.create(
        identification_type=identification_type,
        identification_number=numero_identificacion,
        user_type=user_type,
        full_name=data["nombre_completo"].strip(),
        email=correo,
        phone=data["telefono"].strip(),
        password_hash=make_password(data["contrasena"]),
        auth_provider=User.AUTH_PROVIDER_LOCAL,
    )

    return {
        "message": "Usuario registrado correctamente",
        "usuario_id": user.id,
    }

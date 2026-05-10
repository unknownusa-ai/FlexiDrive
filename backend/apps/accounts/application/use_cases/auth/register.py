from django.contrib.auth.hashers import make_password

from apps.accounts.application.use_cases.auth.errors import AuthServiceError
from apps.accounts.domain.ports.auth_ports import AccountsAuthRepositoryPort
from apps.accounts.infrastructure.dependencies import get_accounts_auth_repository


def register_user(
    data: dict,
    auth_repository: AccountsAuthRepositoryPort | None = None,
) -> dict:
    auth_repository = auth_repository or get_accounts_auth_repository()

    correo = data["correo"].strip().lower()
    numero_identificacion = data["numero_identificacion"].strip()
    tipo_identificacion_id = data["tipo_identificacion_id"]

    if auth_repository.email_exists(correo):
        raise AuthServiceError(detail="El correo ya existe")

    if auth_repository.identification_number_exists(numero_identificacion):
        raise AuthServiceError(detail="El numero de identificacion ya existe")

    if not auth_repository.identification_type_exists(tipo_identificacion_id):
        raise AuthServiceError(detail="El tipo de identificacion no existe")

    user_type_id = auth_repository.get_default_arrendador_user_type_id()
    if user_type_id is None:
        raise AuthServiceError(
            detail="No existe el tipo de usuario por defecto Arrendador"
        )

    user = auth_repository.create_local_user(
        identification_type_id=tipo_identificacion_id,
        identification_number=numero_identificacion,
        user_type_id=user_type_id,
        full_name=data["nombre_completo"].strip(),
        email=correo,
        phone=data["telefono"].strip(),
        password_hash=make_password(data["contrasena"]),
    )

    return {
        "message": "Usuario registrado correctamente",
        "usuario_id": user.id,
    }

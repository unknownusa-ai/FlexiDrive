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
    tipo_identificacion_nombre = data.get("tipo_identificacion_nombre", "").strip()
    tipo_usuario_id = data.get("tipo_usuario_id")
    tipo_usuario_nombre = data.get("tipo_usuario_nombre", "").strip()

    if auth_repository.email_exists(correo):
        raise AuthServiceError(detail="El correo ya existe")

    if auth_repository.identification_number_exists(numero_identificacion):
        raise AuthServiceError(detail="El numero de identificacion ya existe")

    if tipo_identificacion_nombre:
        existing_type_id = auth_repository.find_identification_type_id_by_name(
            tipo_identificacion_nombre
        )
        if existing_type_id is not None:
            resolved_identification_type_id = existing_type_id
        else:
            resolved_identification_type_id = auth_repository.create_identification_type(
                tipo_identificacion_nombre
            )
    elif auth_repository.identification_type_exists(tipo_identificacion_id):
        resolved_identification_type_id = tipo_identificacion_id
    else:
        raise AuthServiceError(detail="El tipo de identificacion no existe")

    if tipo_usuario_nombre:
        existing_user_type_id = auth_repository.find_user_type_id_by_name(
            tipo_usuario_nombre
        )
        if existing_user_type_id is not None:
            user_type_id = existing_user_type_id
        else:
            user_type_id = auth_repository.create_user_type(tipo_usuario_nombre)
    elif tipo_usuario_id is not None:
        if not auth_repository.user_type_exists(tipo_usuario_id):
            raise AuthServiceError(detail="El tipo de usuario no existe")
        user_type_id = tipo_usuario_id
    else:
        user_type_id = auth_repository.get_default_arrendador_user_type_id()
    if user_type_id is None:
        raise AuthServiceError(
            detail="No existe un tipo de usuario por defecto configurado"
        )

    user = auth_repository.create_local_user(
        identification_type_id=resolved_identification_type_id,
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

"""Application use case for user registration in the accounts context."""

from collections.abc import Mapping
from typing import Any

from django.contrib.auth.hashers import make_password

from apps.accounts.application.use_cases.auth.errors import AuthServiceError
from apps.accounts.domain.ports.auth_ports import AccountsAuthRepositoryPort


def _required_str(data: Mapping[str, Any], key: str) -> str:
    value = data.get(key)
    if not isinstance(value, str) or not value.strip():
        raise AuthServiceError(detail=f"Campo invalido: {key}")
    return value.strip()


def _required_int(data: Mapping[str, Any], key: str) -> int:
    value = data.get(key)
    if isinstance(value, bool) or not isinstance(value, int):
        raise AuthServiceError(detail=f"Campo invalido: {key}")
    return value


def _optional_str(data: Mapping[str, Any], key: str) -> str:
    value = data.get(key)
    return value.strip() if isinstance(value, str) else ""


def _optional_int(data: Mapping[str, Any], key: str) -> int | None:
    value = data.get(key)
    return value if isinstance(value, int) and not isinstance(value, bool) else None


def register_user(
    data: Mapping[str, Any],
    *,
    auth_repository: AccountsAuthRepositoryPort | None = None,
) -> dict[str, Any]:
    """Create a local user after validating business constraints."""
    if auth_repository is None:
        from apps.accounts.infrastructure.dependencies import get_accounts_auth_repository

        auth_repository = get_accounts_auth_repository()

    correo = _required_str(data, "correo").lower()
    numero_identificacion = _required_str(data, "numero_identificacion")
    tipo_identificacion_id = _required_int(data, "tipo_identificacion_id")
    tipo_identificacion_nombre = _optional_str(data, "tipo_identificacion_nombre")
    tipo_usuario_id = _optional_int(data, "tipo_usuario_id")
    tipo_usuario_nombre = _optional_str(data, "tipo_usuario_nombre")

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
        full_name=_required_str(data, "nombre_completo"),
        email=correo,
        phone=_required_str(data, "telefono"),
        password_hash=make_password(_required_str(data, "contrasena")),
    )

    return {
        "message": "Usuario registrado correctamente",
        "usuario_id": user.id,
    }

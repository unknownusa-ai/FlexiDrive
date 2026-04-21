import '../../../shared/utils/json_utils.dart';
import '../../domain/entities/account_entities.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.identificationTypeId,
    required super.identificationNumber,
    required super.userTypeId,
    required super.fullName,
    required super.email,
    required super.phone,
    required super.password,
    required super.canPublish,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: JsonUtils.asInt(json['usuario_id']),
      identificationTypeId: JsonUtils.asInt(json['tipo_identificacion_id']),
      identificationNumber: JsonUtils.asString(json['numero_identificacion']),
      userTypeId: JsonUtils.asInt(json['tipo_usuario_id']),
      fullName: JsonUtils.asString(json['nombre_completo']),
      email: JsonUtils.asString(json['correo']),
      phone: JsonUtils.asString(json['telefono']),
      password: JsonUtils.asString(json['contrasena']),
      canPublish: JsonUtils.asBool(json['puede_publicar']),
    );
  }

  Map<String, dynamic> toJson() => {
    'usuario_id': id,
    'tipo_identificacion_id': identificationTypeId,
    'numero_identificacion': identificationNumber,
    'tipo_usuario_id': userTypeId,
    'nombre_completo': fullName,
    'correo': email,
    'telefono': phone,
    'contrasena': password,
    'puede_publicar': canPublish,
  };
}

class UserPreferenceModel extends UserPreference {
  const UserPreferenceModel({
    required super.id,
    required super.userId,
    required super.darkMode,
    required super.language,
    super.profileImage,
  });

  factory UserPreferenceModel.fromJson(Map<String, dynamic> json) {
    return UserPreferenceModel(
      id: JsonUtils.asInt(json['preferencia_usuario_id']),
      userId: JsonUtils.asInt(json['usuario_id']),
      darkMode: JsonUtils.asBool(json['modo_oscuro']),
      language: JsonUtils.asString(json['idioma']),
      profileImage: json['imagen_perfil'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'preferencia_usuario_id': id,
    'usuario_id': userId,
    'modo_oscuro': darkMode,
    'idioma': language,
    'imagen_perfil': profileImage,
  };
}

import 'package:flexidrive/utils/json_utils.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.identificationTypeId,
    required this.identificationNumber,
    required this.userTypeId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.canPublish,
  });

  final int id;
  final int identificationTypeId;
  final String identificationNumber;
  final int userTypeId;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final bool canPublish;

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

import 'package:flexidrive/utils/json_utils.dart';

class UserSecurityModel {
  const UserSecurityModel({
    required this.id,
    required this.userId,
    required this.twoFactorVerification,
    required this.biometricAccess,
  });

  final int id;
  final int userId;
  final bool twoFactorVerification;
  final bool biometricAccess;

  factory UserSecurityModel.fromJson(Map<String, dynamic> json) {
    return UserSecurityModel(
      id: JsonUtils.asInt(json['seguridad_usuario_id']),
      userId: JsonUtils.asInt(json['usuario_id']),
      twoFactorVerification: JsonUtils.asBool(json['verificacion_dos_pasos']),
      biometricAccess: JsonUtils.asBool(json['acceso_biometrico']),
    );
  }

  Map<String, dynamic> toJson() => {
    'seguridad_usuario_id': id,
    'usuario_id': userId,
    'verificacion_dos_pasos': twoFactorVerification,
    'acceso_biometrico': biometricAccess,
  };
}

class UserSessionModel {
  const UserSessionModel({
    required this.id,
    required this.userId,
    required this.device,
    required this.operatingSystem,
    required this.ipAddress,
    required this.startDate,
    required this.active,
  });

  final int id;
  final int userId;
  final String device;
  final String operatingSystem;
  final String ipAddress;
  final DateTime startDate;
  final bool active;

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    return UserSessionModel(
      id: JsonUtils.asInt(json['sesion_usuario_id']),
      userId: JsonUtils.asInt(json['usuario_id']),
      device: JsonUtils.asString(json['dispositivo']),
      operatingSystem: JsonUtils.asString(json['sistema_operativo']),
      ipAddress: JsonUtils.asString(json['direccion_ip']),
      startDate: JsonUtils.asDateTime(json['fecha_inicio']),
      active: JsonUtils.asBool(json['activa']),
    );
  }

  Map<String, dynamic> toJson() => {
    'sesion_usuario_id': id,
    'usuario_id': userId,
    'dispositivo': device,
    'sistema_operativo': operatingSystem,
    'direccion_ip': ipAddress,
    'fecha_inicio': startDate.toIso8601String(),
    'activa': active,
  };
}

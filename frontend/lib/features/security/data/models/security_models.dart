import '../../../shared/utils/json_utils.dart';
import '../../domain/entities/security_entities.dart';

class UserSecurityModel extends UserSecurity {
  const UserSecurityModel({
    required super.id,
    required super.userId,
    required super.twoFactorVerification,
    required super.biometricAccess,
  });

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

class UserSessionModel extends UserSession {
  const UserSessionModel({
    required super.id,
    required super.userId,
    required super.device,
    required super.operatingSystem,
    required super.ipAddress,
    required super.startDate,
    required super.active,
  });

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

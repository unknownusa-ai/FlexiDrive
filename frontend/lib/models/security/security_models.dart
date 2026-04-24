// Utilidades para convertir JSON
import 'package:flexidrive/utils/json_utils.dart';

// Modelo de seguridad de usuario
// Gestiona configuraciones de seguridad como autenticación de dos factores y biometría
class UserSecurityModel {
  // Constructor con configuraciones de seguridad
  const UserSecurityModel({
    required this.id, // ID único de la configuración de seguridad
    required this.userId, // ID del usuario dueño de la configuración
    required this.twoFactorVerification, // Si tiene autenticación de dos factores activada
    required this.biometricAccess, // Si tiene acceso biométrico habilitado
  });

  // ID en la base de datos
  final int id;
  // ID del usuario dueño de la configuración
  final int userId;
  // True si tiene autenticación de dos factores activada
  final bool twoFactorVerification;
  // True si tiene acceso biométrico habilitado
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

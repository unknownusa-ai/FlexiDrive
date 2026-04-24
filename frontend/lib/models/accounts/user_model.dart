// Utilidades para convertir JSON
import 'package:flexidrive/utils/json_utils.dart';

// Modelo de un usuario de la app
// Guarda toda la info de la cuenta (login, datos personales, etc)
class UserModel {
  // Constructor con todos los datos requeridos
  const UserModel({
    required this.id, // ID único del usuario
    required this.identificationTypeId, // Tipo de documento (CC, CE, Pasaporte)
    required this.identificationNumber, // Número de cédula o pasaporte
    required this.userTypeId, // Si es arrendador o arrendatario
    required this.fullName, // Nombre completo
    required this.email, // Correo para login
    required this.phone, // Teléfono de contacto
    required this.password, // Contraseña (debería estar encriptada!)
    required this.canPublish, // Puede publicar carros?
  });

  // ID en la base de datos
  final int id;
  // 1=CC, 2=CE, 3=Pasaporte, 4=NIT
  final int identificationTypeId;
  // Número de documento ej: "1000123456"
  final String identificationNumber;
  // 1=arrendador, 2=arrendatario
  final int userTypeId;
  // Nombre completo ej: "Carlos Rodríguez"
  final String fullName;
  // Email ej: "carlos@email.com"
  final String email;
  // Teléfono ej: "3101234567"
  final String phone;
  // Contraseña (en producción debería ser hash)
  final String password;
  // true = puede publicar vehículos
  final bool canPublish;

  // Crea un UserModel desde JSON (cuando cargamos del archivo)
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

  // Convierte el usuario a JSON (para guardar)
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

// Utilidades para convertir JSON
import 'package:flexidrive/utils/json_utils.dart';

// Modelo de preferencias de usuario
// Guarda configuraciones personalizadas como tema e idioma
class UserPreferenceModel {
  // Constructor con todas las preferencias requeridas
  const UserPreferenceModel({
    required this.id, // ID único de la preferencia
    required this.userId, // ID del usuario dueño de las preferencias
    required this.darkMode, // Si prefiere modo oscuro
    required this.language, // Código de idioma (es, en, etc)
    this.profileImage, // URL de imagen de perfil (opcional)
  });

  // ID en la base de datos
  final int id;
  // ID del usuario dueño de estas preferencias
  final int userId;
  // True si prefiere modo oscuro, false si modo claro
  final bool darkMode;
  // Código del idioma preferido (ej: 'es', 'en')
  final String language;
  // URL de la imagen de perfil (opcional)
  final String? profileImage;

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

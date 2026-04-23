import 'package:flexidrive/utils/json_utils.dart';

class UserPreferenceModel {
  const UserPreferenceModel({
    required this.id,
    required this.userId,
    required this.darkMode,
    required this.language,
    this.profileImage,
  });

  final int id;
  final int userId;
  final bool darkMode;
  final String language;
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

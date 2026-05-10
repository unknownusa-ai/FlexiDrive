import 'auth_token.dart';

/// Entidad que representa una sesión de autenticación activa
class AuthSession {
  const AuthSession({
    required this.userId,
    required this.token,
    required this.createdAt,
  });

  final int userId;
  final AuthToken token;
  final DateTime createdAt;

  bool get isValid => !token.isExpired;

  AuthSession copyWith({
    int? userId,
    AuthToken? token,
    DateTime? createdAt,
  }) {
    return AuthSession(
      userId: userId ?? this.userId,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'token': token.toJson(),
        'created_at': createdAt.toIso8601String(),
      };

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      userId: json['user_id'] as int,
      token: AuthToken.fromJson(json['token'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

import '../../../../core/api/api_client.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/auth_session.dart';

/// Servicio de API para operaciones de autenticación
class AuthApiService {
  AuthApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  /// Realiza login en el servidor
  Future<AuthSession?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.postMap('auth/login', {
        'correo': email.trim().toLowerCase(),
        'contrasena': password,
      });

      final rawUser = response['user'];
      final userMap = rawUser is Map ? rawUser : const {};
      final userId = int.tryParse('${userMap['usuario_id'] ?? ''}');

      if (userId == null) return null;

      final token = AuthToken(
        accessToken: response['access_token'] as String? ?? '',
        refreshToken: response['refresh_token'] as String? ?? '',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      return AuthSession(
        userId: userId,
        token: token,
        createdAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Refresca el token de acceso
  Future<AuthToken?> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.postMap('auth/token/refresh', {
        'refresh_token': refreshToken,
      });

      return AuthToken(
        accessToken: response['access_token'] as String,
        refreshToken: response['refresh_token'] as String,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
    } catch (_) {
      return null;
    }
  }

  /// Verifica si el token es válido
  Future<bool> verifyToken(String token) async {
    try {
      final response = await _apiClient.postMap('auth/token/verify', {
        'access_token': token,
      });
      final valid = response['valid'];
      if (valid is bool) return valid;
      return true;
    } catch (_) {
      return false;
    }
  }
}

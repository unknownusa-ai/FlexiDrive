import '../entities/auth_token.dart';
import '../entities/auth_session.dart';

/// Puerto (interfaz) para el repositorio de autenticación
abstract class AuthRepositoryPort {
  /// Inicializa el repositorio y carga datos locales
  Future<void> initialize();

  /// Realiza login con email y contraseña
  Future<AuthSession?> login({
    required String email,
    required String password,
  });

  /// Realiza logout y limpia la sesión
  Future<void> logout();

  /// Obtiene la sesión actual si existe
  Future<AuthSession?> getCurrentSession();

  /// Verifica si hay una sesión activa válida
  Future<bool> isAuthenticated();

  /// Refresca el token de acceso
  Future<AuthToken?> refreshToken(String refreshToken);

  /// Guarda la sesión localmente
  Future<void> saveSession(AuthSession session);

  /// Limpia la sesión local
  Future<void> clearSession();
}

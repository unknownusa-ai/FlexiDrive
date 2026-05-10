import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/ports/auth_repository_port.dart';
import '../datasources/local_auth_storage.dart';
import '../datasources/auth_api_service.dart';

/// Implementación del repositorio de autenticación
class AuthRepositoryImpl implements AuthRepositoryPort {
  AuthRepositoryImpl({
    LocalAuthStorage? localStorage,
    AuthApiService? apiService,
  })  : _localStorage = localStorage ?? LocalAuthStorage(),
        _apiService = apiService ?? AuthApiService();

  final LocalAuthStorage _localStorage;
  final AuthApiService _apiService;

  @override
  Future<void> initialize() async {
    // Inicialización si es necesaria
  }

  @override
  Future<AuthSession?> login({
    required String email,
    required String password,
  }) async {
    final session = await _apiService.login(
      email: email,
      password: password,
    );

    if (session != null) {
      await _localStorage.saveSession(session);
      await _localStorage.saveAccessToken(session.token.accessToken);
    }

    return session;
  }

  @override
  Future<void> logout() async {
    await _localStorage.clearSession();
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    final session = await _localStorage.getSession();
    if (session == null) return null;

    // Verificar si el token está expirado
    if (session.token.isExpired) {
      final refreshedToken = await refreshToken(session.token.refreshToken);
      if (refreshedToken == null) {
        await logout();
        return null;
      }

      final updatedSession = AuthSession(
        userId: session.userId,
        token: refreshedToken,
        createdAt: session.createdAt,
      );
      await _localStorage.saveSession(updatedSession);
      return updatedSession;
    }

    return session;
  }

  @override
  Future<bool> isAuthenticated() async {
    final session = await getCurrentSession();
    return session != null && session.isValid;
  }

  @override
  Future<AuthToken?> refreshToken(String refreshToken) async {
    return _apiService.refreshToken(refreshToken);
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    await _localStorage.saveSession(session);
    await _localStorage.saveAccessToken(session.token.accessToken);
  }

  @override
  Future<void> clearSession() async {
    await _localStorage.clearSession();
  }
}

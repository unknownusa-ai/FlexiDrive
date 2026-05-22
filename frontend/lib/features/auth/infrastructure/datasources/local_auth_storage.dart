import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/auth_session.dart';

/// Fuente de datos local para almacenar sesiones de autenticación
class LocalAuthStorage {
  LocalAuthStorage({SharedPreferences? prefs}) : _prefs = prefs;

  static const String _sessionKey = 'auth_session';
  static const String _tokenKey = 'auth_token';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Guarda la sesión de autenticación
  Future<void> saveSession(AuthSession session) async {
    final prefs = await _preferences;
    final sessionJson = jsonEncode(session.toJson());
    await prefs.setString(_sessionKey, sessionJson);
  }

  /// Obtiene la sesión guardada
  Future<AuthSession?> getSession() async {
    final prefs = await _preferences;
    final sessionJson = prefs.getString(_sessionKey);
    if (sessionJson == null) return null;

    try {
      final sessionMap = jsonDecode(sessionJson) as Map<String, dynamic>;
      return AuthSession.fromJson(sessionMap);
    } catch (_) {
      return null;
    }
  }

  /// Elimina la sesión guardada
  Future<void> clearSession() async {
    final prefs = await _preferences;
    await prefs.remove(_sessionKey);
    await prefs.remove(_tokenKey);
  }

  /// Verifica si hay una sesión guardada
  Future<bool> hasSession() async {
    final prefs = await _preferences;
    return prefs.containsKey(_sessionKey);
  }

  /// Guarda el token de acceso
  Future<void> saveAccessToken(String token) async {
    final prefs = await _preferences;
    await prefs.setString(_tokenKey, token);
  }

  /// Obtiene el token de acceso guardado
  Future<String?> getAccessToken() async {
    final prefs = await _preferences;
    return prefs.getString(_tokenKey);
  }
}

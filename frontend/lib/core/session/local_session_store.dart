// Almacenamiento local de sesión del usuario
// Maneja el estado de autenticación usando SharedPreferences
import 'package:shared_preferences/shared_preferences.dart';

// Almacén local para manejar la sesión del usuario
// Guarda el ID del usuario para mantener la sesión activa
class LocalSessionStore {
  // Constructor privado para patrón singleton
  LocalSessionStore._();

  // Instancia única de la clase (patrón singleton)
  static final LocalSessionStore instance = LocalSessionStore._();

  // Clave para guardar el ID del usuario en SharedPreferences
  static const _userIdKey = 'session_user_id';

  // ID del usuario actualmente logueado
  int? _userId;
  // Indica si el almacén ya fue inicializado
  bool _initialized = false;

  // Obtiene el ID del usuario actual
  int? get userId => _userId;
  // Verifica si hay un usuario logueado
  bool get isLoggedIn => _userId != null;

  // Inicializa el almacén cargando los datos desde SharedPreferences
  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt(_userIdKey);
    _initialized = true;
  }

  // Guarda el ID del usuario en el almacenamiento local
  Future<void> setUserId(int userId) async {
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  // Cierra la sesión eliminando el ID del usuario
  Future<void> clear() async {
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }
}

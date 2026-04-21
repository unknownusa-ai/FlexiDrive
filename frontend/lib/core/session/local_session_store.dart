import 'package:shared_preferences/shared_preferences.dart';

class LocalSessionStore {
  LocalSessionStore._();

  static final LocalSessionStore instance = LocalSessionStore._();

  static const _userIdKey = 'session_user_id';

  int? _userId;
  bool _initialized = false;

  int? get userId => _userId;
  bool get isLoggedIn => _userId != null;

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt(_userIdKey);
    _initialized = true;
  }

  Future<void> setUserId(int userId) async {
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  Future<void> clear() async {
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }
}

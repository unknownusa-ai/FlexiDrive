import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/profile_stats.dart';

/// Fuente de datos local para almacenar datos de perfil
class ProfileLocalStorage {
  ProfileLocalStorage({SharedPreferences? prefs}) : _prefs = prefs;

  static const String _profileKey = 'user_profile';
  static const String _statsKey = 'profile_stats';
  static const String _currentUserIdKey = 'current_user_id';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Guarda el perfil del usuario
  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await _preferences;
    final profileJson = jsonEncode(profile.toJson());
    await prefs.setString('${_profileKey}_${profile.id}', profileJson);
    await prefs.setInt(_currentUserIdKey, profile.id);
  }

  /// Obtiene el perfil guardado
  Future<UserProfile?> getProfile(int userId) async {
    final prefs = await _preferences;
    final profileJson = prefs.getString('${_profileKey}_$userId');
    if (profileJson == null) return null;

    try {
      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
      return UserProfile.fromJson(profileMap);
    } catch (_) {
      return null;
    }
  }

  /// Obtiene el perfil del usuario actual
  Future<UserProfile?> getCurrentProfile() async {
    final prefs = await _preferences;
    final userId = prefs.getInt(_currentUserIdKey);
    if (userId == null) return null;
    return getProfile(userId);
  }

  /// Guarda las estadísticas del perfil
  Future<void> saveStats(int userId, ProfileStats stats) async {
    final prefs = await _preferences;
    final statsJson = jsonEncode(stats.toJson());
    await prefs.setString('${_statsKey}_$userId', statsJson);
  }

  /// Obtiene las estadísticas del perfil
  Future<ProfileStats?> getStats(int userId) async {
    final prefs = await _preferences;
    final statsJson = prefs.getString('${_statsKey}_$userId');
    if (statsJson == null) return null;

    try {
      final statsMap = jsonDecode(statsJson) as Map<String, dynamic>;
      return ProfileStats.fromJson(statsMap);
    } catch (_) {
      return null;
    }
  }

  /// Elimina el perfil guardado
  Future<void> clearProfile(int userId) async {
    final prefs = await _preferences;
    await prefs.remove('${_profileKey}_$userId');
    await prefs.remove('${_statsKey}_$userId');
    await prefs.remove(_currentUserIdKey);
  }

  /// Actualiza el avatar del usuario
  Future<void> updateAvatar(int userId, String avatarUrl) async {
    final profile = await getProfile(userId);
    if (profile != null) {
      final updatedProfile = profile.copyWith(avatarUrl: avatarUrl);
      await saveProfile(updatedProfile);
    }
  }

  /// Verifica si hay un perfil guardado
  Future<bool> hasProfile(int userId) async {
    final prefs = await _preferences;
    return prefs.containsKey('${_profileKey}_$userId');
  }
}

import 'dart:convert';

import 'package:flexidrive/models/accounts/user_preference_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_account_db.dart';

class UserPreferenceService {
  UserPreferenceService({LocalAccountDb? db})
      : _db = db ?? LocalAccountDb.instance;

  final LocalAccountDb _db;

  static const _preferencesOverridesKey =
      'accounts_user_preferences_overrides_v1';
  static const _userModesKey = 'accounts_user_modes_v1';

  Future<void> init() async {
    await _db.loadIfNeeded();
  }

  Future<List<UserPreferenceModel>> getAll() async {
    await init();
    return List<UserPreferenceModel>.unmodifiable(_db.preferences);
  }

  Future<UserPreferenceModel?> findByUserId(int userId) async {
    await init();
    for (final preference in _db.preferences) {
      if (preference.userId == userId) return preference;
    }
    return null;
  }

  Future<UserPreferenceModel?> findEffectiveByUserId(int userId) async {
    final persisted = await _findPersistedPreferenceByUserId(userId);
    if (persisted != null) return persisted;
    return findByUserId(userId);
  }

  Future<void> setDarkMode({
    required int userId,
    required bool darkMode,
  }) async {
    final basePreference = await findEffectiveByUserId(userId) ??
        await _buildDefaultPreference(userId);

    final updatedPreference = UserPreferenceModel(
      id: basePreference.id,
      userId: userId,
      darkMode: darkMode,
      language: basePreference.language,
      profileImage: basePreference.profileImage,
    );

    final prefs = await SharedPreferences.getInstance();
    final items = await _readPreferenceOverrides();
    final index = items.indexWhere((item) => item.userId == userId);

    if (index == -1) {
      items.add(updatedPreference);
    } else {
      items[index] = updatedPreference;
    }

    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_preferencesOverridesKey, encoded);
  }

  Future<bool> getArrendatarioMode({
    required int userId,
    bool defaultValue = false,
  }) async {
    final modes = await _readModeOverrides();
    for (final item in modes) {
      if (item['usuario_id'] == userId) {
        final value = item['modo_arrendatario'];
        if (value is bool) return value;
      }
    }
    return defaultValue;
  }

  Future<void> setArrendatarioMode({
    required int userId,
    required bool enabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final modes = await _readModeOverrides();
    final index = modes.indexWhere((item) => item['usuario_id'] == userId);

    final updated = <String, dynamic>{
      'usuario_id': userId,
      'modo_arrendatario': enabled,
    };

    if (index == -1) {
      modes.add(updated);
    } else {
      modes[index] = updated;
    }

    await prefs.setString(_userModesKey, jsonEncode(modes));
  }

  Future<UserPreferenceModel?> _findPersistedPreferenceByUserId(
      int userId) async {
    final overrides = await _readPreferenceOverrides();
    for (final preference in overrides) {
      if (preference.userId == userId) return preference;
    }
    return null;
  }

  Future<UserPreferenceModel> _buildDefaultPreference(int userId) async {
    await init();
    return UserPreferenceModel(
      id: _db.nextPreferenceId(),
      userId: userId,
      darkMode: false,
      language: 'es',
      profileImage: null,
    );
  }

  Future<List<UserPreferenceModel>> _readPreferenceOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_preferencesOverridesKey);
    if (raw == null || raw.isEmpty) return <UserPreferenceModel>[];

    try {
      final decoded = jsonDecode(raw);
      final list = decoded is List ? decoded : const [];
      return list
          .whereType<Map>()
          .map(
            (item) => UserPreferenceModel.fromJson(
              item.map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            ),
          )
          .toList();
    } catch (_) {
      return <UserPreferenceModel>[];
    }
  }

  Future<List<Map<String, dynamic>>> _readModeOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userModesKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];

    try {
      final decoded = jsonDecode(raw);
      final list = decoded is List ? decoded : const [];
      return list
          .whereType<Map>()
          .map(
            (item) => item.map(
              (key, value) => MapEntry(key.toString(), value),
            ),
          )
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }
}

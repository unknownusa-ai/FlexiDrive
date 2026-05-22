import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flexidrive/core/api/api_client.dart';
import 'package:flexidrive/features/accounts/domain/entities/account_models.dart';

// Base de datos local para cuentas de usuario
// Maneja el almacenamiento local de usuarios y preferencias
class LocalAccountDb {
  // Constructor privado para patrón singleton
  LocalAccountDb._();

  // Instancia única de la clase (patrón singleton)
  static final LocalAccountDb instance = LocalAccountDb._();
  // Key para guardar overrides de usuarios en SharedPreferences
  static const _usersOverridesKey = 'accounts_users_overrides_v1';

  // Indica si los datos ya fueron cargados
  bool? _loaded = false;

  // Lista de usuarios almacenados localmente
  final List<UserModel> users = [];
  // Lista de preferencias de usuario
  final List<UserPreferenceModel> preferences = [];
  // Lista de ciudades de referencia
  final List<String> referenceCities = [];

  // Getter para verificar si los datos están cargados
  bool get isLoaded => _loaded == true;

  /// Carga los datos necesarios para cargar if needed.
  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;
    await reload();
  }

  /// Gestiona recargar dentro de esta parte del flujo.
  Future<void> reload() async {
    final rawUsers = await _loadList('users');
    final rawPreferences = await _loadList('user-preferences');
    final rawCities = await _loadList('reference-cities');

    users
      ..clear()
      ..addAll(
        rawUsers.map(
          (item) => UserModel.fromJson(item as Map<String, dynamic>),
        ),
      );

    final overrides = await _loadUserOverrides();
    for (final override in overrides) {
      final index = users.indexWhere((u) => u.id == override.id);
      if (index == -1) {
        users.add(override);
      } else {
        users[index] = override;
      }
    }

    preferences
      ..clear()
      ..addAll(
        rawPreferences.map(
          (item) => UserPreferenceModel.fromJson(item as Map<String, dynamic>),
        ),
      );

    referenceCities
      ..clear()
      ..addAll(rawCities.map((item) => item.toString()));

    _loaded = true;
  }

  /// Carga los datos necesarios para cargar lista.
  Future<List<dynamic>> _loadList(String assetPath) async {
    return ApiClient.instance.getList(assetPath);
  }

  Future<void> saveUserOverride(
    UserModel user, {
    bool syncRemote = true,
    bool throwOnRemoteFailure = false,
  }) async {
    await loadIfNeeded();

    final overrides = await _loadUserOverrides();
    final index = overrides.indexWhere((u) => u.id == user.id);

    if (index == -1) {
      overrides.add(user);
    } else {
      overrides[index] = user;
    }

    if (syncRemote) {
      try {
        await ApiClient.instance.patchMap('users/${user.id}', user.toJson());
      } catch (error) {
        if (throwOnRemoteFailure) rethrow;
        // Si falla la API, conservamos el override local para no perder el cambio.
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _usersOverridesKey,
      jsonEncode(overrides.map((item) => item.toJson()).toList()),
    );
  }

  /// Carga los cambios locales sobrescritos de usuario.
  Future<List<UserModel>> _loadUserOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersOverridesKey);
    if (raw == null || raw.isEmpty) return <UserModel>[];

    try {
      final decoded = jsonDecode(raw);
      final list = decoded is List ? decoded : const [];
      return list
          .whereType<Map>()
          .map(
            (item) => UserModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } catch (_) {
      return <UserModel>[];
    }
  }

  /// Gestiona siguiente usuario id dentro de esta parte del flujo.
  int nextUserId() {
    if (users.isEmpty) return 1;
    final maxId = users.map((u) => u.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  /// Gestiona siguiente preferencia id dentro de esta parte del flujo.
  int nextPreferenceId() {
    if (preferences.isEmpty) return 1;
    final maxId = preferences.map((p) => p.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }
}

import 'package:flexidrive/core/api/api_client.dart';
import 'package:flexidrive/core/session/local_session_store.dart';
import 'package:flexidrive/models/accounts/account_models.dart';

import 'local_account_db.dart';

class LocalAccountRepository {
  LocalAccountRepository({
    LocalAccountDb? db,
    LocalSessionStore? session,
  })  : _db = db ?? LocalAccountDb.instance,
        _session = session ?? LocalSessionStore.instance;

  final LocalAccountDb _db;
  final LocalSessionStore _session;

  Future<void> init() async {
    await _db.loadIfNeeded();
    await _session.init();
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    await init();

    Map<String, dynamic> response;
    try {
      response = await ApiClient.instance.postMap('auth/login', {
        'correo': email.trim().toLowerCase(),
        'contrasena': password,
      });
    } catch (_) {
      return null;
    }

    final rawUser = response['user'];
    final userMap = rawUser is Map ? rawUser : const {};
    final userId = int.tryParse('${userMap['usuario_id'] ?? ''}');
    if (userId == null) return null;

    await _db.reload();
    for (final user in _db.users) {
      if (user.id == userId) {
        await _session.setUserId(user.id);
        return user;
      }
    }
    return null;
  }

  Future<List<UserModel>> getUsers() async {
    await init();
    return List<UserModel>.unmodifiable(_db.users);
  }

  Future<UserModel> register({
    required String fullName,
    required String identificationNumber,
    required String email,
    required String phone,
    required String password,
    int identificationTypeId = 1,
    int userTypeId = 2,
    bool canPublish = false,
  }) async {
    await init();

    final normalizedEmail = email.trim().toLowerCase();
    final response = await ApiClient.instance.postMap('auth/register', {
      'tipo_identificacion_id': identificationTypeId,
      'numero_identificacion': identificationNumber.trim(),
      'nombre_completo': fullName.trim(),
      'correo': normalizedEmail,
      'telefono': phone.trim(),
      'contrasena': password,
    });
    final userId = int.tryParse('${response['usuario_id'] ?? ''}');

    await _db.reload();
    for (final user in _db.users) {
      if (user.id == userId) return user;
    }

    return UserModel(
      id: userId ?? _db.nextUserId(),
      identificationTypeId: identificationTypeId,
      identificationNumber: identificationNumber.trim(),
      userTypeId: userTypeId,
      fullName: fullName.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      password: '',
      canPublish: canPublish,
    );
  }

  Future<void> logout() async {
    await init();
    await _session.clear();
  }

  Future<UserModel?> getCurrentUser() async {
    await init();

    final currentId = _session.userId;
    if (currentId == null) return null;

    for (final user in _db.users) {
      if (user.id == currentId) return user;
    }
    return null;
  }

  Future<UserPreferenceModel?> getCurrentUserPreference() async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return null;

    for (final preference in _db.preferences) {
      if (preference.userId == currentUser.id) return preference;
    }
    return null;
  }

  Future<void> updatePreference(UserPreferenceModel newPreference) async {
    await init();
    final index = _db.preferences.indexWhere((p) => p.id == newPreference.id);
    final payload = newPreference.toJson();

    if (index == -1) {
      final created =
          await ApiClient.instance.postMap('user-preferences', payload);
      _db.preferences.add(UserPreferenceModel.fromJson(created));
      return;
    }

    final updated = await ApiClient.instance.patchMap(
      'user-preferences/${newPreference.id}',
      payload,
    );
    _db.preferences[index] = UserPreferenceModel.fromJson(updated);
  }

  Future<UserModel?> findUserByEmail(String email) async {
    await init();

    final normalizedEmail = email.trim().toLowerCase();
    for (final user in _db.users) {
      if (user.email.trim().toLowerCase() == normalizedEmail) return user;
    }
    return null;
  }

  Future<void> updatePassword(int userId, String newPassword) async {
    await init();

    final index = _db.users.indexWhere((u) => u.id == userId);
    if (index == -1) {
      throw Exception('Usuario no encontrado');
    }

    final user = _db.users[index];
    final updatedUser = UserModel(
      id: user.id,
      identificationTypeId: user.identificationTypeId,
      identificationNumber: user.identificationNumber,
      userTypeId: user.userTypeId,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      password: newPassword,
      canPublish: user.canPublish,
    );

    await _db.saveUserOverride(updatedUser);
    await _db.reload();
  }
}

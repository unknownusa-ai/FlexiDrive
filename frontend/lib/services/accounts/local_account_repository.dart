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

    final normalizedEmail = email.trim().toLowerCase();

    UserModel? user;
    for (final candidate in _db.users) {
      if (candidate.email.trim().toLowerCase() == normalizedEmail &&
          candidate.password == password) {
        user = candidate;
        break;
      }
    }

    if (user == null) return null;

    await _session.setUserId(user.id);
    return user;
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

    for (final existing in _db.users) {
      if (existing.email.trim().toLowerCase() == normalizedEmail) {
        throw Exception('El correo ya está registrado');
      }

      if (existing.identificationNumber.trim() == identificationNumber.trim()) {
        throw Exception('El número de documento ya está registrado');
      }
    }

    final newUser = UserModel(
      id: _db.nextUserId(),
      identificationTypeId: identificationTypeId,
      identificationNumber: identificationNumber.trim(),
      userTypeId: userTypeId,
      fullName: fullName.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      password: password,
      canPublish: canPublish,
    );

    _db.users.add(newUser);

    final newPreference = UserPreferenceModel(
      id: _db.nextPreferenceId(),
      userId: newUser.id,
      darkMode: false,
      language: 'es',
      profileImage: null,
    );
    _db.preferences.add(newPreference);

    return newUser;
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
    if (index == -1) {
      _db.preferences.add(newPreference);
      return;
    }

    _db.preferences[index] = newPreference;
  }

  Future<UserModel?> findUserByEmail(String email) async {
    await init();

    final normalizedEmail = email.trim().toLowerCase();

    for (final user in _db.users) {
      if (user.email.trim().toLowerCase() == normalizedEmail) {
        return user;
      }
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
    _db.users[index] = UserModel(
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
  }
}

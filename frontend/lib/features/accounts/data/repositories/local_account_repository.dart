import '../../../../core/session/local_session_store.dart';
import '../datasources/local_account_db.dart';
import '../models/account_models.dart';

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
}

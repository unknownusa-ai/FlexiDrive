import 'package:flexidrive/models/accounts/user_preference_model.dart';

import 'local_account_db.dart';

class UserPreferenceService {
  UserPreferenceService({LocalAccountDb? db}) : _db = db ?? LocalAccountDb.instance;

  final LocalAccountDb _db;

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
}

import 'package:flexidrive/models/accounts/user_model.dart';

import 'local_account_db.dart';

class UserService {
  UserService({LocalAccountDb? db}) : _db = db ?? LocalAccountDb.instance;

  final LocalAccountDb _db;

  Future<void> init() async {
    await _db.loadIfNeeded();
  }

  Future<List<UserModel>> getAll() async {
    await init();
    return List<UserModel>.unmodifiable(_db.users);
  }

  Future<UserModel?> findById(int userId) async {
    await init();
    for (final user in _db.users) {
      if (user.id == userId) return user;
    }
    return null;
  }
}

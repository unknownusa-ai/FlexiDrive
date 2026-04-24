import 'package:flexidrive/models/accounts/user_model.dart';
import 'local_account_db.dart';

// Servicio de gestión de usuarios
// Proporciona métodos para manejar cuentas de usuario
class UserService {
  // Constructor con base de datos opcional (para tests)
  UserService({LocalAccountDb? db}) : _db = db ?? LocalAccountDb.instance;

  // Base de datos local de cuentas
  final LocalAccountDb _db;

  // Inicializa el servicio cargando los datos
  Future<void> init() async {
    await _db.loadIfNeeded();
  }

  // Obtiene todos los usuarios
  Future<List<UserModel>> getAll() async {
    await init();
    return List<UserModel>.unmodifiable(_db.users);
  }

  // Busca un usuario por ID
  Future<UserModel?> findById(int userId) async {
    await init();
    for (final user in _db.users) {
      if (user.id == userId) return user;
    }
    return null;
  }
}

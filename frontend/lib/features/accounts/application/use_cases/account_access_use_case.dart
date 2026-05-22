import 'package:flexidrive/features/accounts/domain/entities/account_models.dart';
import 'package:flexidrive/features/accounts/domain/ports/repositorio_cuentas_puerto.dart';

/// Define la responsabilidad de `AccountAccessUseCase` dentro de este módulo.
class AccountAccessUseCase {
  /// Crea una instancia y prepara el estado inicial de `AccountAccessUseCase`.
  AccountAccessUseCase(this._repository);

  final RepositorioCuentasPuerto _repository;

  /// Inicializa el flujo de initialize antes de su uso.
  Future<void> initialize() => _repository.inicializar();

  Future<UserModel?> login({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }

  Future<UserModel> register({
    required String fullName,
    required String identificationNumber,
    String? identificationTypeName,
    String? userTypeName,
    required String email,
    required String phone,
    required String password,
    int identificationTypeId = 1,
    int? userTypeId,
    bool canPublish = false,
  }) {
    return _repository.register(
      fullName: fullName,
      identificationNumber: identificationNumber,
      identificationTypeName: identificationTypeName,
      userTypeName: userTypeName,
      email: email,
      phone: phone,
      password: password,
      identificationTypeId: identificationTypeId,
      userTypeId: userTypeId,
      canPublish: canPublish,
    );
  }

  /// Gestiona logout dentro de esta parte del flujo.
  Future<void> logout() => _repository.logout();

  /// Obtiene la información asociada a obtención del usuario actual.
  Future<UserModel?> getCurrentUser() => _repository.getCurrentUser();

  /// Obtiene la información asociada a obtener usuarios.
  Future<List<UserModel>> getUsers() => _repository.getUsers();

  /// Obtiene la información asociada a obtención de ciudades de referencia.
  Future<List<String>> getReferenceCities() => _repository.getReferenceCities();

  /// Gestiona búsqueda de usuario por correo dentro de esta parte del flujo.
  Future<UserModel?> findUserByEmail(String email) {
    return _repository.findUserByEmail(email);
  }

  /// Actualiza el estado relacionado con actualización de contraseña.
  Future<void> updatePassword(int userId, String newPassword) {
    return _repository.updatePassword(userId, newPassword);
  }

  /// Obtiene la información asociada a obtención del usuario actual preferencia.
  Future<UserPreferenceModel?> getCurrentUserPreference() {
    return _repository.getCurrentUserPreference();
  }

  /// Actualiza el estado relacionado con actualizar preferencia.
  Future<void> updatePreference(UserPreferenceModel newPreference) {
    return _repository.updatePreference(newPreference);
  }
}

import 'package:flexidrive/features/accounts/domain/ports/repositorio_cuentas_puerto.dart';
import 'package:flexidrive/features/accounts/domain/entities/account_models.dart';
import 'package:flexidrive/features/accounts/infrastructure/repositories/local_account_repository.dart';

/// Define la responsabilidad de `RepositorioCuentasLocal` dentro de este módulo.
class RepositorioCuentasLocal implements RepositorioCuentasPuerto {
  RepositorioCuentasLocal({LocalAccountRepository? origen})
      : _origen = origen ?? LocalAccountRepository();

  final LocalAccountRepository _origen;

  /// Gestiona inicializar dentro de esta parte del flujo.
  @override
  Future<void> inicializar() async {
    await _origen.init();
  }

  @override
  Future<UserModel?> login({
    required String email,
    required String password,
  }) {
    return _origen.login(email: email, password: password);
  }

  @override
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
    return _origen.register(
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
  @override
  Future<void> logout() {
    return _origen.logout();
  }

  /// Obtiene la información asociada a obtención del usuario actual.
  @override
  Future<UserModel?> getCurrentUser() {
    return _origen.getCurrentUser();
  }

  /// Obtiene la información asociada a obtener usuarios.
  @override
  Future<List<UserModel>> getUsers() {
    return _origen.getUsers();
  }

  /// Obtiene la información asociada a obtención de ciudades de referencia.
  @override
  Future<List<String>> getReferenceCities() {
    return _origen.getReferenceCities();
  }

  /// Gestiona búsqueda de usuario por correo dentro de esta parte del flujo.
  @override
  Future<UserModel?> findUserByEmail(String email) {
    return _origen.findUserByEmail(email);
  }

  /// Actualiza el estado relacionado con actualización de contraseña.
  @override
  Future<void> updatePassword(int userId, String newPassword) {
    return _origen.updatePassword(userId, newPassword);
  }

  /// Obtiene la información asociada a obtención del usuario actual preferencia.
  @override
  Future<UserPreferenceModel?> getCurrentUserPreference() {
    return _origen.getCurrentUserPreference();
  }

  /// Actualiza el estado relacionado con actualizar preferencia.
  @override
  Future<void> updatePreference(UserPreferenceModel newPreference) {
    return _origen.updatePreference(newPreference);
  }

  LocalAccountRepository get origen => _origen;
}

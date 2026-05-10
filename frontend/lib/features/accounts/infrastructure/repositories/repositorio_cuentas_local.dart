import 'package:flexidrive/features/accounts/domain/ports/repositorio_cuentas_puerto.dart';
import 'package:flexidrive/features/accounts/domain/entities/account_models.dart';
import 'package:flexidrive/features/accounts/infrastructure/repositories/local_account_repository.dart';

class RepositorioCuentasLocal implements RepositorioCuentasPuerto {
  RepositorioCuentasLocal({LocalAccountRepository? origen})
      : _origen = origen ?? LocalAccountRepository();

  final LocalAccountRepository _origen;

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
    required String email,
    required String phone,
    required String password,
    int identificationTypeId = 1,
    int userTypeId = 2,
    bool canPublish = false,
  }) {
    return _origen.register(
      fullName: fullName,
      identificationNumber: identificationNumber,
      email: email,
      phone: phone,
      password: password,
      identificationTypeId: identificationTypeId,
      userTypeId: userTypeId,
      canPublish: canPublish,
    );
  }

  @override
  Future<void> logout() {
    return _origen.logout();
  }

  @override
  Future<UserModel?> getCurrentUser() {
    return _origen.getCurrentUser();
  }

  @override
  Future<List<UserModel>> getUsers() {
    return _origen.getUsers();
  }

  @override
  Future<List<String>> getReferenceCities() {
    return _origen.getReferenceCities();
  }

  @override
  Future<UserModel?> findUserByEmail(String email) {
    return _origen.findUserByEmail(email);
  }

  @override
  Future<void> updatePassword(int userId, String newPassword) {
    return _origen.updatePassword(userId, newPassword);
  }

  @override
  Future<UserPreferenceModel?> getCurrentUserPreference() {
    return _origen.getCurrentUserPreference();
  }

  @override
  Future<void> updatePreference(UserPreferenceModel newPreference) {
    return _origen.updatePreference(newPreference);
  }

  LocalAccountRepository get origen => _origen;
}

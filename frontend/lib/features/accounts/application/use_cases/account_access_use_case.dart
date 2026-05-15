import 'package:flexidrive/features/accounts/domain/entities/account_models.dart';
import 'package:flexidrive/features/accounts/domain/ports/repositorio_cuentas_puerto.dart';

class AccountAccessUseCase {
  AccountAccessUseCase(this._repository);

  final RepositorioCuentasPuerto _repository;

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

  Future<void> logout() => _repository.logout();

  Future<UserModel?> getCurrentUser() => _repository.getCurrentUser();

  Future<List<UserModel>> getUsers() => _repository.getUsers();

  Future<List<String>> getReferenceCities() => _repository.getReferenceCities();

  Future<UserModel?> findUserByEmail(String email) {
    return _repository.findUserByEmail(email);
  }

  Future<void> updatePassword(int userId, String newPassword) {
    return _repository.updatePassword(userId, newPassword);
  }

  Future<UserPreferenceModel?> getCurrentUserPreference() {
    return _repository.getCurrentUserPreference();
  }

  Future<void> updatePreference(UserPreferenceModel newPreference) {
    return _repository.updatePreference(newPreference);
  }
}

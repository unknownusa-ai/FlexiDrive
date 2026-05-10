import 'package:flexidrive/features/accounts/domain/entities/account_models.dart';

abstract class RepositorioCuentasPuerto {
  Future<void> inicializar();
  Future<UserModel?> login({
    required String email,
    required String password,
  });
  Future<UserModel> register({
    required String fullName,
    required String identificationNumber,
    required String email,
    required String phone,
    required String password,
    int identificationTypeId,
    int userTypeId,
    bool canPublish,
  });
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<List<UserModel>> getUsers();
  Future<List<String>> getReferenceCities();
  Future<UserModel?> findUserByEmail(String email);
  Future<void> updatePassword(int userId, String newPassword);
  Future<UserPreferenceModel?> getCurrentUserPreference();
  Future<void> updatePreference(UserPreferenceModel newPreference);
}

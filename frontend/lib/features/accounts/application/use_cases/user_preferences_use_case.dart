import 'package:flexidrive/features/accounts/domain/entities/user_preference_model.dart';
import 'package:flexidrive/features/accounts/infrastructure/datasources/user_preference_service.dart';

class UserPreferencesUseCase {
  UserPreferencesUseCase(this._service);

  final UserPreferenceService _service;

  Future<void> initialize() => _service.init();

  Future<UserPreferenceModel?> findEffectiveByUserId(int userId) {
    return _service.findEffectiveByUserId(userId);
  }

  Future<void> setDarkMode({
    required int userId,
    required bool darkMode,
  }) {
    return _service.setDarkMode(userId: userId, darkMode: darkMode);
  }

  Future<bool> getArrendatarioMode({
    required int userId,
    bool defaultValue = false,
  }) {
    return _service.getArrendatarioMode(
      userId: userId,
      defaultValue: defaultValue,
    );
  }

  Future<void> setArrendatarioMode({
    required int userId,
    required bool enabled,
  }) {
    return _service.setArrendatarioMode(userId: userId, enabled: enabled);
  }
}

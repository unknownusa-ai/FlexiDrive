import 'package:flexidrive/features/accounts/domain/entities/user_preference_model.dart';
import 'package:flexidrive/features/accounts/domain/ports/user_preferences_repository_port.dart';

/// Casos de uso de preferencias de usuario.
///
/// La capa de aplicación solo conoce el puerto de dominio y no el datasource.
class UserPreferencesUseCase {
  /// Crea una instancia y prepara el estado inicial de `UserPreferencesUseCase`.
  UserPreferencesUseCase(this._repository);

  final UserPreferencesRepositoryPort _repository;

  /// Inicializa el flujo de initialize antes de su uso.
  Future<void> initialize() => _repository.initialize();

  /// Buscar efectiva por usuario id esta parte del flujo de trabajo.
  Future<UserPreferenceModel?> findEffectiveByUserId(int userId) {
    return _repository.findEffectiveByUserId(userId);
  }

  Future<void> setDarkMode({
    required int userId,
    required bool darkMode,
  }) {
    return _repository.setDarkMode(userId: userId, darkMode: darkMode);
  }

  Future<bool> getArrendatarioMode({
    required int userId,
    bool defaultValue = false,
  }) {
    return _repository.getArrendatarioMode(
      userId: userId,
      defaultValue: defaultValue,
    );
  }

  Future<void> setArrendatarioMode({
    required int userId,
    required bool enabled,
  }) {
    return _repository.setArrendatarioMode(userId: userId, enabled: enabled);
  }
}

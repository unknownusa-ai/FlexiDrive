import 'package:flexidrive/features/accounts/domain/entities/user_preference_model.dart';
import 'package:flexidrive/features/accounts/domain/ports/user_preferences_repository_port.dart';
import 'package:flexidrive/features/accounts/infrastructure/datasources/user_preference_service.dart';

/// Adaptador de infraestructura para preferencias de usuario.
///
/// Implementa el puerto de dominio delegando en el datasource local/remoto.
class UserPreferencesRepositoryImpl implements UserPreferencesRepositoryPort {
  UserPreferencesRepositoryImpl({UserPreferenceService? service})
      : _service = service ?? UserPreferenceService();

  final UserPreferenceService _service;

  /// Inicializa el flujo de initialize antes de su uso.
  @override
  Future<void> initialize() => _service.init();

  /// Buscar efectiva por usuario id esta parte del flujo de trabajo.
  @override
  Future<UserPreferenceModel?> findEffectiveByUserId(int userId) {
    return _service.findEffectiveByUserId(userId);
  }

  @override
  Future<void> setDarkMode({
    required int userId,
    required bool darkMode,
  }) {
    return _service.setDarkMode(userId: userId, darkMode: darkMode);
  }

  @override
  Future<bool> getArrendatarioMode({
    required int userId,
    bool defaultValue = false,
  }) {
    return _service.getArrendatarioMode(
      userId: userId,
      defaultValue: defaultValue,
    );
  }

  @override
  Future<void> setArrendatarioMode({
    required int userId,
    required bool enabled,
  }) {
    return _service.setArrendatarioMode(userId: userId, enabled: enabled);
  }
}

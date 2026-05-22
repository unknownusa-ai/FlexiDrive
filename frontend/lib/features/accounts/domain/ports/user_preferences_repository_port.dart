import 'package:flexidrive/features/accounts/domain/entities/user_preference_model.dart';

/// Contrato de dominio para gestionar preferencias de usuario.
///
/// La capa de aplicación trabaja contra esta interfaz para mantenerse
/// desacoplada de detalles de persistencia (API, caché local, etc.).
abstract class UserPreferencesRepositoryPort {
  Future<void> initialize();

  Future<UserPreferenceModel?> findEffectiveByUserId(int userId);

  Future<void> setDarkMode({
    required int userId,
    required bool darkMode,
  });

  Future<bool> getArrendatarioMode({
    required int userId,
    bool defaultValue,
  });

  Future<void> setArrendatarioMode({
    required int userId,
    required bool enabled,
  });
}

import '../entities/user_profile.dart';
import '../entities/profile_stats.dart';

/// Puerto (interfaz) para el repositorio de perfil de usuario
abstract class ProfileRepositoryPort {
  /// Inicializa el repositorio
  Future<void> initialize();

  /// Obtiene el perfil del usuario actual
  Future<UserProfile?> getCurrentProfile();

  /// Obtiene el perfil de un usuario por ID
  Future<UserProfile?> getProfileById(int userId);

  /// Actualiza el perfil del usuario
  Future<UserProfile> updateProfile(UserProfile profile);

  /// Actualiza el avatar del usuario
  Future<String?> updateAvatar(int userId, String imagePath);

  /// Obtiene las estadísticas del perfil
  Future<ProfileStats> getProfileStats(int userId);

  /// Cambia el modo de usuario (arrendatario/arrendador)
  Future<void> toggleUserMode(int userId, bool canPublish);

  /// Verifica si el usuario puede publicar vehículos
  Future<bool> canUserPublish(int userId);

  /// Actualiza la contraseña del usuario
  Future<void> updatePassword(
      int userId, String currentPassword, String newPassword);

  /// Cierra sesión y limpia datos del perfil
  Future<void> clearProfile();
}

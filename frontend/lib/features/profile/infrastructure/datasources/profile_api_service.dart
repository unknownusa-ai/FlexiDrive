import '../../../../core/api/api_client.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/profile_stats.dart';

/// Servicio de API para operaciones de perfil
class ProfileApiService {
  ProfileApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  /// Obtiene el perfil del usuario desde el servidor
  Future<UserProfile?> getProfile(int userId) async {
    try {
      final response = await _apiClient.getMap('users/$userId/profile');
      return UserProfile.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  /// Actualiza el perfil en el servidor
  Future<UserProfile?> updateProfile(UserProfile profile) async {
    try {
      final response = await _apiClient.patchMap(
        'users/${profile.id}/profile',
        profile.toJson(),
      );
      return UserProfile.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  /// Actualiza el avatar del usuario
  Future<String?> updateAvatar(int userId, String imagePath) async {
    try {
      final response = await _apiClient.postMap(
        'users/$userId/avatar',
        {'image_path': imagePath},
      );
      return response['avatar_url'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Obtiene las estadísticas del perfil
  Future<ProfileStats?> getStats(int userId) async {
    try {
      final response = await _apiClient.getMap('users/$userId/stats');
      return ProfileStats.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  /// Cambia el modo de usuario (arrendatario/arrendador)
  Future<bool> toggleUserMode(int userId, bool canPublish) async {
    try {
      await _apiClient.patchMap(
        'users/$userId/mode',
        {'can_publish': canPublish},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Actualiza la contraseña del usuario
  Future<bool> updatePassword(
    int userId,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _apiClient.postMap(
        'users/$userId/password',
        {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

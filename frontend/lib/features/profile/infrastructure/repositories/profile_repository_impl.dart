import '../../domain/entities/user_profile.dart';
import '../../domain/entities/profile_stats.dart';
import '../../domain/ports/profile_repository_port.dart';
import '../datasources/profile_local_storage.dart';
import '../datasources/profile_api_service.dart';

/// Implementación del repositorio de perfil
class ProfileRepositoryImpl implements ProfileRepositoryPort {
  ProfileRepositoryImpl({
    ProfileLocalStorage? localStorage,
    ProfileApiService? apiService,
  })  : _localStorage = localStorage ?? ProfileLocalStorage(),
        _apiService = apiService ?? ProfileApiService();

  final ProfileLocalStorage _localStorage;
  final ProfileApiService _apiService;

  @override
  Future<void> initialize() async {
    // Inicialización si es necesaria
  }

  @override
  Future<UserProfile?> getCurrentProfile() async {
    return _localStorage.getCurrentProfile();
  }

  @override
  Future<UserProfile?> getProfileById(int userId) async {
    // Intentar obtener de local primero
    var profile = await _localStorage.getProfile(userId);

    // Si no hay local o está desactualizado, obtener de API
    if (profile == null) {
      profile = await _apiService.getProfile(userId);
      if (profile != null) {
        await _localStorage.saveProfile(profile);
      }
    }

    return profile;
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    // Actualizar en API primero
    final updatedProfile = await _apiService.updateProfile(profile);

    // Guardar localmente
    final profileToSave = updatedProfile ?? profile;
    await _localStorage.saveProfile(profileToSave);

    return profileToSave;
  }

  @override
  Future<String?> updateAvatar(int userId, String imagePath) async {
    final avatarUrl = await _apiService.updateAvatar(userId, imagePath);

    if (avatarUrl != null) {
      await _localStorage.updateAvatar(userId, avatarUrl);
    }

    return avatarUrl;
  }

  @override
  Future<ProfileStats> getProfileStats(int userId) async {
    // Intentar obtener de API primero
    var stats = await _apiService.getStats(userId);

    // Si falla API, usar local
    stats ??= await _localStorage.getStats(userId);

    // Si no hay local, retornar vacío
    stats ??= const ProfileStats();

    // Guardar localmente para caché
    await _localStorage.saveStats(userId, stats);

    return stats;
  }

  @override
  Future<void> toggleUserMode(int userId, bool canPublish) async {
    final success = await _apiService.toggleUserMode(userId, canPublish);

    if (success) {
      final profile = await _localStorage.getProfile(userId);
      if (profile != null) {
        final updatedProfile = profile.copyWith(canPublish: canPublish);
        await _localStorage.saveProfile(updatedProfile);
      }
    }
  }

  @override
  Future<bool> canUserPublish(int userId) async {
    final profile = await getProfileById(userId);
    return profile?.canPublish ?? false;
  }

  @override
  Future<void> updatePassword(
    int userId,
    String currentPassword,
    String newPassword,
  ) async {
    final success = await _apiService.updatePassword(
      userId,
      currentPassword,
      newPassword,
    );

    if (!success) {
      throw Exception('No se pudo actualizar la contraseña');
    }
  }

  @override
  Future<void> clearProfile() async {
    final currentProfile = await _localStorage.getCurrentProfile();
    if (currentProfile != null) {
      await _localStorage.clearProfile(currentProfile.id);
    }
  }
}

import '../../domain/entities/user_profile.dart';
import '../../domain/entities/profile_stats.dart';
import '../../domain/ports/profile_repository_port.dart';
import '../datasources/profile_local_storage.dart';
import '../datasources/profile_api_service.dart';

/// Implementación del repositorio de perfil
class ProfileRepositoryImpl implements ProfileRepositoryPort {
  /// Crea una instancia y prepara el estado inicial de `ProfileRepositoryImpl`.
  ProfileRepositoryImpl({
    ProfileLocalStorage? localStorage,
    ProfileApiService? apiService,
  })  : _localStorage = localStorage ?? ProfileLocalStorage(),
        _apiService = apiService ?? ProfileApiService();

  final ProfileLocalStorage _localStorage;
  final ProfileApiService _apiService;

  /// Inicializa el flujo de initialize antes de su uso.
  @override
  Future<void> initialize() async {
    // Inicialización si es necesaria
  }

  /// Obtiene la información asociada a obtener actual perfil.
  @override
  Future<UserProfile?> getCurrentProfile() async {
    return _localStorage.getCurrentProfile();
  }

  /// Obtiene la información asociada a obtener perfil por id.
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

  /// Actualiza el estado relacionado con actualizar perfil.
  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    final updatedProfile = await _apiService.updateProfile(profile);

    // Guardar localmente
    final profileToSave = updatedProfile ?? profile;
    await _localStorage.saveProfile(profileToSave);

    return profileToSave;
  }

  /// Actualiza el estado relacionado con actualizar avatar.
  @override
  Future<String?> updateAvatar(int userId, String imagePath) async {
    final avatarUrl = await _apiService.updateAvatar(userId, imagePath);

    if (avatarUrl != null) {
      await _localStorage.updateAvatar(userId, avatarUrl);
    }

    return avatarUrl;
  }

  /// Obtiene la información asociada a obtener perfil estadísticas.
  @override
  Future<ProfileStats> getProfileStats(int userId) async {
    var stats = await _apiService.getStats(userId);

    // Si falla API, usar local
    stats ??= await _localStorage.getStats(userId);

    // Si no hay local, retornar vacío
    stats ??= const ProfileStats();

    // Guardar localmente para caché
    await _localStorage.saveStats(userId, stats);

    return stats;
  }

  /// Alternar usuario modo esta parte del flujo de trabajo.
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

  /// Gestiona can usuario publish dentro de esta parte del flujo.
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

  /// Gestiona clear perfil dentro de esta parte del flujo.
  @override
  Future<void> clearProfile() async {
    final currentProfile = await _localStorage.getCurrentProfile();
    if (currentProfile != null) {
      await _localStorage.clearProfile(currentProfile.id);
    }
  }
}

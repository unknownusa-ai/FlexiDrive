import '../../../../core/api/api_client.dart';
import '../../domain/entities/home_content.dart';
import '../../domain/entities/home_section.dart';

/// Servicio de API para operaciones de home
class HomeApiService {
  HomeApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  /// Obtiene el contenido de home desde el servidor
  Future<HomeContent?> getHomeContent() async {
    try {
      final response = await _apiClient.getMap('home/content');
      return HomeContent.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  /// Obtiene las secciones desde el servidor
  Future<List<HomeSection>?> getSections() async {
    try {
      final response = await _apiClient.getMap('home/sections');
      final sectionsList = response['sections'] as List<dynamic>?;
      if (sectionsList == null) return null;

      return sectionsList
          .map((e) => HomeSection.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Obtiene vehículos destacados
  Future<List<dynamic>> getFeaturedVehicles() async {
    try {
      final response = await _apiClient.getList('home/featured');
      return response;
    } catch (_) {
      return [];
    }
  }

  /// Obtiene vehículos populares
  Future<List<dynamic>> getPopularVehicles() async {
    try {
      final response = await _apiClient.getList('home/popular');
      return response;
    } catch (_) {
      return [];
    }
  }

  /// Obtiene el saludo personalizado del usuario
  Future<String?> getUserGreeting(int userId) async {
    try {
      final response = await _apiClient.getMap('users/$userId/greeting');
      return response['greeting'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Verifica notificaciones nuevas
  Future<bool> hasNewNotifications(int userId) async {
    try {
      final response = await _apiClient.getMap('users/$userId/notifications/unread');
      return (response['count'] as int? ?? 0) > 0;
    } catch (_) {
      return false;
    }
  }
}

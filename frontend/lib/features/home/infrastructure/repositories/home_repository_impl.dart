import '../../domain/entities/home_content.dart';
import '../../domain/entities/home_section.dart';
import '../../domain/ports/home_repository_port.dart';
import '../datasources/home_local_storage.dart';
import '../datasources/home_api_service.dart';

/// Implementación del repositorio de home
class HomeRepositoryImpl implements HomeRepositoryPort {
  HomeRepositoryImpl({
    HomeLocalStorage? localStorage,
    HomeApiService? apiService,
  })  : _localStorage = localStorage ?? HomeLocalStorage(),
        _apiService = apiService ?? HomeApiService();

  final HomeLocalStorage _localStorage;
  final HomeApiService _apiService;

  /// Secciones por defecto
  static List<HomeSection> get _defaultSections => [
        const HomeSection(
          id: 'featured',
          type: HomeSectionType.featured,
          title: 'Destacados',
          data: [],
          displayOrder: 0,
        ),
        const HomeSection(
          id: 'popular',
          type: HomeSectionType.popular,
          title: 'Populares',
          data: [],
          displayOrder: 1,
        ),
        const HomeSection(
          id: 'categories',
          type: HomeSectionType.categories,
          title: 'Categorías',
          data: [],
          displayOrder: 2,
        ),
      ];

  @override
  Future<void> initialize() async {
    // Verificar si existe contenido guardado
    final existing = await _localStorage.getContent();
    if (existing == null) {
      final content = HomeContent(
        sections: _defaultSections,
        lastUpdated: DateTime.now(),
      );
      await _localStorage.saveContent(content);
    }
  }

  @override
  Future<HomeContent> getHomeContent() async {
    // Intentar obtener de local primero
    var content = await _localStorage.getContent();

    // Si no hay local o el caché expiró, obtener de API
    if (content == null || await _localStorage.isCacheExpired()) {
      content = await _apiService.getHomeContent();
      if (content != null) {
        await _localStorage.saveContent(content);
      }
    }

    return content ??
        HomeContent(
          sections: _defaultSections,
          lastUpdated: DateTime.now(),
        );
  }

  @override
  Future<List<HomeSection>> getVisibleSections() async {
    final content = await getHomeContent();
    return content.visibleSections..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  @override
  Future<HomeSection?> getSectionById(String sectionId) async {
    final content = await getHomeContent();
    try {
      return content.sections.firstWhere((s) => s.id == sectionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateSection(HomeSection section) async {
    final content = await getHomeContent();
    final sections = List<HomeSection>.from(content.sections);
    final index = sections.indexWhere((s) => s.id == section.id);

    if (index >= 0) {
      sections[index] = section;
      final updatedContent = content.copyWith(sections: sections);
      await _localStorage.saveContent(updatedContent);
    }
  }

  @override
  Future<void> toggleSectionVisibility(String sectionId, bool isVisible) async {
    final section = await getSectionById(sectionId);
    if (section != null) {
      final updatedSection = section.copyWith(isVisible: isVisible);
      await updateSection(updatedSection);
    }
  }

  @override
  Future<void> reorderSections(List<String> sectionIds) async {
    final content = await getHomeContent();
    final sections = List<HomeSection>.from(content.sections);

    for (var i = 0; i < sectionIds.length; i++) {
      final index = sections.indexWhere((s) => s.id == sectionIds[i]);
      if (index >= 0) {
        sections[index] = sections[index].copyWith(displayOrder: i);
      }
    }

    final updatedContent = content.copyWith(sections: sections);
    await _localStorage.saveContent(updatedContent);
  }

  @override
  Future<String?> getUserGreeting(int userId) async {
    // Intentar obtener de API primero
    var greeting = await _apiService.getUserGreeting(userId);
    // Fallback a saludo genérico
    greeting ??= '¡Bienvenido!';
    return greeting;
  }

  @override
  Future<bool> hasNewNotifications(int userId) async {
    return _apiService.hasNewNotifications(userId);
  }

  @override
  Future<HomeContent> refreshContent() async {
    await _localStorage.clearCache();
    return getHomeContent();
  }
}

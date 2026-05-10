import '../entities/home_content.dart';
import '../entities/home_section.dart';

/// Puerto (interfaz) para el repositorio de home
abstract class HomeRepositoryPort {
  /// Inicializa el repositorio
  Future<void> initialize();

  /// Obtiene el contenido completo de la página home
  Future<HomeContent> getHomeContent();

  /// Obtiene las secciones visibles ordenadas
  Future<List<HomeSection>> getVisibleSections();

  /// Obtiene una sección específica por ID
  Future<HomeSection?> getSectionById(String sectionId);

  /// Actualiza el contenido de una sección
  Future<void> updateSection(HomeSection section);

  /// Oculta/muestra una sección
  Future<void> toggleSectionVisibility(String sectionId, bool isVisible);

  /// Reordena las secciones
  Future<void> reorderSections(List<String> sectionIds);

  /// Genera el saludo personalizado para el usuario
  Future<String?> getUserGreeting(int userId);

  /// Verifica si hay notificaciones nuevas
  Future<bool> hasNewNotifications(int userId);

  /// Fuerza la actualización del contenido desde el servidor
  Future<HomeContent> refreshContent();
}

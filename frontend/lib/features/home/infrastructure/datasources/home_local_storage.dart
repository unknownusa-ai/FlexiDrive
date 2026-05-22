import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/home_content.dart';
import '../../domain/entities/home_section.dart';

/// Fuente de datos local para almacenar contenido de home
class HomeLocalStorage {
  HomeLocalStorage({SharedPreferences? prefs}) : _prefs = prefs;

  static const String _contentKey = 'home_content';
  static const String _sectionsKey = 'home_sections';
  static const String _lastUpdateKey = 'home_last_update';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Guarda el contenido completo de home
  Future<void> saveContent(HomeContent content) async {
    final prefs = await _preferences;
    final json = jsonEncode(content.toJson());
    await prefs.setString(_contentKey, json);
    await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
  }

  /// Obtiene el contenido guardado
  Future<HomeContent?> getContent() async {
    final prefs = await _preferences;
    final json = prefs.getString(_contentKey);
    if (json == null) return null;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return HomeContent.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Guarda las secciones
  Future<void> saveSections(List<HomeSection> sections) async {
    final prefs = await _preferences;
    final json = jsonEncode(sections.map((s) => s.toJson()).toList());
    await prefs.setString(_sectionsKey, json);
  }

  /// Obtiene las secciones guardadas
  Future<List<HomeSection>?> getSections() async {
    final prefs = await _preferences;
    final json = prefs.getString(_sectionsKey);
    if (json == null) return null;

    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => HomeSection.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Obtiene la fecha de última actualización
  Future<DateTime?> getLastUpdate() async {
    final prefs = await _preferences;
    final dateStr = prefs.getString(_lastUpdateKey);
    if (dateStr == null) return null;

    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  /// Verifica si el caché está expirado (más de 1 hora)
  Future<bool> isCacheExpired() async {
    final lastUpdate = await getLastUpdate();
    if (lastUpdate == null) return true;

    final now = DateTime.now();
    final diff = now.difference(lastUpdate);
    return diff.inHours > 1;
  }

  /// Limpia el caché
  Future<void> clearCache() async {
    final prefs = await _preferences;
    await prefs.remove(_contentKey);
    await prefs.remove(_sectionsKey);
    await prefs.remove(_lastUpdateKey);
  }
}

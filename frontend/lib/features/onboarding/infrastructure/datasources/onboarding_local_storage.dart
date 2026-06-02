import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/onboarding_content.dart';

/// Fuente de datos local para almacenar estado del onboarding
class OnboardingLocalStorage {
  OnboardingLocalStorage({SharedPreferences? prefs}) : _prefs = prefs;

  // Keys de persistencia del onboarding:
  // - _contentKey: payload completo serializado (pasos + estado general).
  // - _completedKey: bandera global de onboarding completado.
  // - _skippedKey: bandera de onboarding omitido.
  // - _currentStepKey: índice de paso actual para retomar flujo.
  static const String _contentKey = 'onboarding_content';
  static const String _completedKey = 'onboarding_completed';
  static const String _skippedKey = 'onboarding_skipped';
  static const String _currentStepKey = 'onboarding_current_step';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Guarda el contenido completo del onboarding
  Future<void> saveContent(OnboardingContent content) async {
    final prefs = await _preferences;
    final json = jsonEncode(content.toJson());
    await prefs.setString(_contentKey, json);
  }

  /// Obtiene el contenido guardado
  Future<OnboardingContent?> getContent() async {
    final prefs = await _preferences;
    final json = prefs.getString(_contentKey);
    if (json == null) return null;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return OnboardingContent.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Marca un paso como completado
  Future<void> markStepCompleted(int stepId) async {
    final prefs = await _preferences;
    final completedSteps = prefs.getStringList('${_completedKey}_steps') ?? [];
    if (!completedSteps.contains(stepId.toString())) {
      completedSteps.add(stepId.toString());
      // Se persiste como lista de strings para mantener compatibilidad simple
      // con SharedPreferences entre plataformas.
      await prefs.setStringList('${_completedKey}_steps', completedSteps);
    }
  }

  /// Obtiene los IDs de pasos completados
  Future<List<int>> getCompletedSteps() async {
    final prefs = await _preferences;
    final completed = prefs.getStringList('${_completedKey}_steps') ?? [];
    return completed.map((s) => int.tryParse(s) ?? 0).toList();
  }

  /// Guarda el índice del paso actual
  Future<void> saveCurrentStepIndex(int index) async {
    final prefs = await _preferences;
    await prefs.setInt(_currentStepKey, index);
  }

  /// Obtiene el índice del paso actual
  Future<int> getCurrentStepIndex() async {
    final prefs = await _preferences;
    return prefs.getInt(_currentStepKey) ?? 0;
  }

  /// Marca el onboarding como completado
  Future<void> markAsCompleted() async {
    final prefs = await _preferences;
    await prefs.setBool(_completedKey, true);
  }

  /// Verifica si el onboarding está completado
  Future<bool> isCompleted() async {
    final prefs = await _preferences;
    return prefs.getBool(_completedKey) ?? false;
  }

  /// Marca el onboarding como saltado
  Future<void> markAsSkipped() async {
    final prefs = await _preferences;
    await prefs.setBool(_skippedKey, true);
  }

  /// Verifica si el onboarding fue saltado
  Future<bool> wasSkipped() async {
    final prefs = await _preferences;
    return prefs.getBool(_skippedKey) ?? false;
  }

  /// Reinicia todo el estado del onboarding
  Future<void> reset() async {
    final prefs = await _preferences;
    await prefs.remove(_contentKey);
    await prefs.remove(_completedKey);
    await prefs.remove(_skippedKey);
    await prefs.remove(_currentStepKey);
    await prefs.remove('${_completedKey}_steps');
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_config.dart';
import '../../domain/entities/onboarding_status.dart';

/// Fuente de datos local para almacenar configuración de la app
class LocalConfigStorage {
  LocalConfigStorage({SharedPreferences? prefs}) : _prefs = prefs;

  static const String _configKey = 'app_config';
  static const String _onboardingKey = 'onboarding_status';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Guarda la configuración de la aplicación
  Future<void> saveAppConfig(AppConfig config) async {
    final prefs = await _preferences;
    final configJson = jsonEncode(config.toJson());
    await prefs.setString(_configKey, configJson);
  }

  /// Obtiene la configuración guardada
  Future<AppConfig?> getAppConfig() async {
    final prefs = await _preferences;
    final configJson = prefs.getString(_configKey);
    if (configJson == null) return null;

    try {
      final configMap = jsonDecode(configJson) as Map<String, dynamic>;
      return AppConfig.fromJson(configMap);
    } catch (_) {
      return null;
    }
  }

  /// Guarda el estado del onboarding
  Future<void> saveOnboardingStatus(OnboardingStatus status) async {
    final prefs = await _preferences;
    final statusJson = jsonEncode(status.toJson());
    await prefs.setString(_onboardingKey, statusJson);
  }

  /// Obtiene el estado del onboarding
  Future<OnboardingStatus?> getOnboardingStatus() async {
    final prefs = await _preferences;
    final statusJson = prefs.getString(_onboardingKey);
    if (statusJson == null) return null;

    try {
      final statusMap = jsonDecode(statusJson) as Map<String, dynamic>;
      return OnboardingStatus.fromJson(statusMap);
    } catch (_) {
      return null;
    }
  }

  /// Marca el onboarding como completado
  Future<void> markOnboardingAsCompleted() async {
    final prefs = await _preferences;
    final completedStatus = OnboardingStatus(
      hasCompletedOnboarding: true,
      completedSteps: const [0, 1, 2, 3],
      currentStep: OnboardingStatus.totalSteps,
      lastShownDate: DateTime.now(),
    );
    await saveOnboardingStatus(completedStatus);
    await prefs.setBool('has_seen_onboarding', true);
  }

  /// Verifica si es el primer lanzamiento
  Future<bool> isFirstLaunch() async {
    final prefs = await _preferences;
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    return !hasSeenOnboarding;
  }

  /// Obtiene la última versión abierta
  Future<String> getLastOpenedVersion() async {
    final prefs = await _preferences;
    return prefs.getString('last_opened_version') ?? '';
  }

  /// Actualiza la última versión abierta
  Future<void> updateLastOpenedVersion(String version) async {
    final prefs = await _preferences;
    await prefs.setString('last_opened_version', version);
  }

  /// Marca los términos como aceptados
  Future<void> acceptTerms() async {
    final prefs = await _preferences;
    await prefs.setBool('has_accepted_terms', true);
  }

  /// Marca la política de privacidad como aceptada
  Future<void> acceptPrivacyPolicy() async {
    final prefs = await _preferences;
    await prefs.setBool('has_accepted_privacy_policy', true);
  }

  /// Verifica si se aceptaron los términos
  Future<bool> hasAcceptedTerms() async {
    final prefs = await _preferences;
    return prefs.getBool('has_accepted_terms') ?? false;
  }

  /// Verifica si se aceptó la política de privacidad
  Future<bool> hasAcceptedPrivacyPolicy() async {
    final prefs = await _preferences;
    return prefs.getBool('has_accepted_privacy_policy') ?? false;
  }
}

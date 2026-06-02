import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_config.dart';
import '../../domain/entities/onboarding_status.dart';

/// Fuente de datos local (Local Datasource) para almacenar configuración de la app.
///
/// En la arquitectura hexagonal de FlexiDrive, esta clase es un adaptador de
/// infraestructura de bajo nivel. Implementa el almacenamiento persistente clave-valor
/// delegando en la biblioteca [SharedPreferences].
///
/// Su principal responsabilidad es gestionar datos de configuración global (AppConfig)
/// y estados del Onboarding sin conocer las reglas de negocio de capas superiores.
class LocalConfigStorage {
  /// Recibe opcionalmente una instancia de [SharedPreferences] (útil para inyección y mocking en tests).
  LocalConfigStorage({SharedPreferences? prefs}) : _prefs = prefs;

  /// Key utilizada para persistir el objeto JSON de configuración general (AppConfig).
  static const String _configKey = 'app_config';

  /// Key utilizada para persistir el objeto JSON con el estado de avance del Onboarding (OnboardingStatus).
  static const String _onboardingKey = 'onboarding_status';

  SharedPreferences? _prefs;

  /// Obtiene o inicializa de forma asíncrona y perezosa la instancia de [SharedPreferences].
  ///
  /// Garantiza que siempre estemos operando con una instancia válida y lista.
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Guarda la configuración de la aplicación de manera local.
  ///
  /// Convierte la entidad de dominio [AppConfig] a su representación JSON y la
  /// persiste en almacenamiento asíncrono como una cadena de texto.
  Future<void> saveAppConfig(AppConfig config) async {
    final prefs = await _preferences;
    final configJson = jsonEncode(config.toJson());
    await prefs.setString(_configKey, configJson);
  }

  /// Recupera y deserializa la configuración persistida de la aplicación.
  ///
  /// Devuelve `null` si no hay ninguna configuración previa guardada en el dispositivo
  /// o si ocurre un fallo durante la decodificación del JSON.
  Future<AppConfig?> getAppConfig() async {
    final prefs = await _preferences;
    final configJson = prefs.getString(_configKey);
    if (configJson == null) return null;

    try {
      final configMap = jsonDecode(configJson) as Map<String, dynamic>;
      return AppConfig.fromJson(configMap);
    } catch (_) {
      // Retorna null como fallback si el JSON de caché está corrupto o desactualizado.
      return null;
    }
  }

  /// Guarda el estado de progreso del onboarding del usuario.
  ///
  /// Convierte el objeto [OnboardingStatus] a JSON de texto para su persistencia offline.
  Future<void> saveOnboardingStatus(OnboardingStatus status) async {
    final prefs = await _preferences;
    final statusJson = jsonEncode(status.toJson());
    await prefs.setString(_onboardingKey, statusJson);
  }

  /// Recupera y decodifica el progreso guardado del onboarding.
  ///
  /// Retorna `null` si es la primera vez que se inicia el flujo o si falla la deserialización.
  Future<OnboardingStatus?> getOnboardingStatus() async {
    final prefs = await _preferences;
    final statusJson = prefs.getString(_onboardingKey);
    if (statusJson == null) return null;

    try {
      final statusMap = jsonDecode(statusJson) as Map<String, dynamic>;
      return OnboardingStatus.fromJson(statusMap);
    } catch (_) {
      // Fallback seguro ante fallos de decodificación.
      return null;
    }
  }

  /// Marca el flujo del onboarding como totalmente finalizado por el usuario.
  ///
  /// 1. Crea y guarda un objeto persistente que registra todos los pasos como completados.
  /// 2. Registra de forma paralela una flag booleana ('has_seen_onboarding') para compatibilidad
  ///    con la lógica de enrutamiento inicial rápido de la aplicación.
  Future<void> markOnboardingAsCompleted() async {
    final prefs = await _preferences;
    final completedStatus = OnboardingStatus(
      hasCompletedOnboarding: true,
      completedSteps: const [0, 1, 2, 3],
      currentStep: OnboardingStatus.totalSteps,
      lastShownDate: DateTime.now(),
    );
    await saveOnboardingStatus(completedStatus);

    // Key booleana de compatibilidad con la lógica de ruta inicial.
    // Se usa para decidir si es primer lanzamiento en `isFirstLaunch()`.
    await prefs.setBool('has_seen_onboarding', true);
  }

  /// Determina si es la primera vez que se lanza la aplicación en este dispositivo.
  ///
  /// Se basa en la existencia de la bandera booleana 'has_seen_onboarding'. Si no existe
  /// o es `false`, se considera que el usuario está en su primer arranque y requiere onboarding.
  Future<bool> isFirstLaunch() async {
    final prefs = await _preferences;

    // Si nunca se ha marcado onboarding visto, consideramos primer arranque.
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    return !hasSeenOnboarding;
  }

  /// Recupera la cadena que representa la última versión de la aplicación que se abrió en este dispositivo.
  ///
  /// Es de utilidad para disparar notas de versión o flujos de migración de base de datos local.
  Future<String> getLastOpenedVersion() async {
    final prefs = await _preferences;
    return prefs.getString('last_opened_version') ?? '';
  }

  /// Registra la versión de la app en ejecución en SharedPreferences.
  Future<void> updateLastOpenedVersion(String version) async {
    final prefs = await _preferences;

    // Guardamos la versión para flujos de migración o avisos post-actualización.
    await prefs.setString('last_opened_version', version);
  }

  /// Registra en almacenamiento persistente que el usuario aceptó los términos legales y condiciones generales de uso.
  Future<void> acceptTerms() async {
    final prefs = await _preferences;

    // Persistencia legal: aceptación de términos por parte del usuario.
    await prefs.setBool('has_accepted_terms', true);
  }

  /// Registra en almacenamiento persistente que el usuario aceptó las políticas de tratamiento de datos personales de FlexiDrive.
  Future<void> acceptPrivacyPolicy() async {
    final prefs = await _preferences;

    // Persistencia legal: aceptación de política de privacidad.
    await prefs.setBool('has_accepted_privacy_policy', true);
  }

  /// Comprueba de forma offline si los términos y condiciones ya fueron previamente aceptados.
  Future<bool> hasAcceptedTerms() async {
    final prefs = await _preferences;
    return prefs.getBool('has_accepted_terms') ?? false;
  }

  /// Comprueba de forma offline si la política de privacidad de tratamiento de datos ya fue aceptada.
  Future<bool> hasAcceptedPrivacyPolicy() async {
    final prefs = await _preferences;
    return prefs.getBool('has_accepted_privacy_policy') ?? false;
  }
}

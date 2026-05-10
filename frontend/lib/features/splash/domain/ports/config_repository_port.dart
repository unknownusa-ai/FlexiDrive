import '../entities/app_config.dart';
import '../entities/onboarding_status.dart';

/// Puerto (interfaz) para el repositorio de configuración de la app
abstract class ConfigRepositoryPort {
  /// Inicializa el repositorio
  Future<void> initialize();

  /// Obtiene la configuración de la aplicación
  Future<AppConfig> getAppConfig();

  /// Guarda la configuración de la aplicación
  Future<void> saveAppConfig(AppConfig config);

  /// Obtiene el estado del onboarding
  Future<OnboardingStatus> getOnboardingStatus();

  /// Guarda el estado del onboarding
  Future<void> saveOnboardingStatus(OnboardingStatus status);

  /// Marca el onboarding como completado
  Future<void> markOnboardingAsCompleted();

  /// Verifica si es el primer lanzamiento de la app
  Future<bool> isFirstLaunch();

  /// Obtiene la última versión de la app que fue abierta
  Future<String> getLastOpenedVersion();

  /// Actualiza la última versión abierta
  Future<void> updateLastOpenedVersion(String version);

  /// Marca los términos y condiciones como aceptados
  Future<void> acceptTerms();

  /// Marca la política de privacidad como aceptada
  Future<void> acceptPrivacyPolicy();

  /// Verifica si el usuario ha aceptado los términos
  Future<bool> hasAcceptedTerms();

  /// Verifica si el usuario ha aceptado la política de privacidad
  Future<bool> hasAcceptedPrivacyPolicy();
}

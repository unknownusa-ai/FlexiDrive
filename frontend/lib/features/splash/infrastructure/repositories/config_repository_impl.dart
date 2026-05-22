import '../../domain/entities/app_config.dart';
import '../../domain/entities/onboarding_status.dart';
import '../../domain/ports/config_repository_port.dart';
import '../datasources/local_config_storage.dart';

/// Implementación del repositorio de configuración
class ConfigRepositoryImpl implements ConfigRepositoryPort {
  ConfigRepositoryImpl({LocalConfigStorage? localStorage})
      : _localStorage = localStorage ?? LocalConfigStorage();

  final LocalConfigStorage _localStorage;

  /// Inicializa el flujo de initialize antes de su uso.
  @override
  Future<void> initialize() async {
    // Inicialización si es necesaria
  }

  /// Obtiene la configuración general de la aplicación.
  @override
  Future<AppConfig> getAppConfig() async {
    var config = await _localStorage.getAppConfig();

    // Si no hay configuración, crear una por defecto
    config ??= AppConfig(
      hasSeenOnboarding: false,
      lastVersionOpened: '',
      firstLaunchDate: DateTime.now(),
    );

    return config;
  }

  /// Guardar app configuración esta parte del flujo de trabajo.
  @override
  Future<void> saveAppConfig(AppConfig config) async {
    await _localStorage.saveAppConfig(config);
  }

  /// Obtiene la información asociada a obtener onboarding estado.
  @override
  Future<OnboardingStatus> getOnboardingStatus() async {
    var status = await _localStorage.getOnboardingStatus();

    // Si no hay estado, crear uno por defecto
    status ??= const OnboardingStatus(
      hasCompletedOnboarding: false,
      completedSteps: [],
      currentStep: 0,
    );

    return status;
  }

  /// Guardar estado de onboarding esta parte del flujo de trabajo.
  @override
  Future<void> saveOnboardingStatus(OnboardingStatus status) async {
    await _localStorage.saveOnboardingStatus(status);
  }

  /// Marca el onboarding como completado.
  @override
  Future<void> markOnboardingAsCompleted() async {
    await _localStorage.markOnboardingAsCompleted();

    // Actualizar también la config
    final config = await getAppConfig();
    final updatedConfig = config.copyWith(hasSeenOnboarding: true);
    await saveAppConfig(updatedConfig);
  }

  /// Gestiona verificación de first launch dentro de esta parte del flujo.
  @override
  Future<bool> isFirstLaunch() async {
    return _localStorage.isFirstLaunch();
  }

  /// Obtiene la información asociada a obtener last opened version.
  @override
  Future<String> getLastOpenedVersion() async {
    return _localStorage.getLastOpenedVersion();
  }

  /// Actualiza el estado relacionado con actualizar last opened version.
  @override
  Future<void> updateLastOpenedVersion(String version) async {
    await _localStorage.updateLastOpenedVersion(version);

    final config = await getAppConfig();
    final updatedConfig = config.copyWith(lastVersionOpened: version);
    await saveAppConfig(updatedConfig);
  }

  /// Registra la aceptación de términos y condiciones.
  @override
  Future<void> acceptTerms() async {
    await _localStorage.acceptTerms();

    final config = await getAppConfig();
    final updatedConfig = config.copyWith(hasAcceptedTerms: true);
    await saveAppConfig(updatedConfig);
  }

  /// Registra la aceptación de la política de privacidad.
  @override
  Future<void> acceptPrivacyPolicy() async {
    await _localStorage.acceptPrivacyPolicy();

    final config = await getAppConfig();
    final updatedConfig = config.copyWith(hasAcceptedPrivacyPolicy: true);
    await saveAppConfig(updatedConfig);
  }

  /// Verifica si el usuario aceptó los términos y condiciones.
  @override
  Future<bool> hasAcceptedTerms() async {
    return _localStorage.hasAcceptedTerms();
  }

  /// Verifica si el usuario aceptó la política de privacidad.
  @override
  Future<bool> hasAcceptedPrivacyPolicy() async {
    return _localStorage.hasAcceptedPrivacyPolicy();
  }
}

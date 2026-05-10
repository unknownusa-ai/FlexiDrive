import '../../domain/entities/app_config.dart';
import '../../domain/entities/onboarding_status.dart';
import '../../domain/ports/config_repository_port.dart';
import '../datasources/local_config_storage.dart';

/// Implementación del repositorio de configuración
class ConfigRepositoryImpl implements ConfigRepositoryPort {
  ConfigRepositoryImpl({LocalConfigStorage? localStorage})
      : _localStorage = localStorage ?? LocalConfigStorage();

  final LocalConfigStorage _localStorage;

  @override
  Future<void> initialize() async {
    // Inicialización si es necesaria
  }

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

  @override
  Future<void> saveAppConfig(AppConfig config) async {
    await _localStorage.saveAppConfig(config);
  }

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

  @override
  Future<void> saveOnboardingStatus(OnboardingStatus status) async {
    await _localStorage.saveOnboardingStatus(status);
  }

  @override
  Future<void> markOnboardingAsCompleted() async {
    await _localStorage.markOnboardingAsCompleted();

    // Actualizar también la config
    final config = await getAppConfig();
    final updatedConfig = config.copyWith(hasSeenOnboarding: true);
    await saveAppConfig(updatedConfig);
  }

  @override
  Future<bool> isFirstLaunch() async {
    return _localStorage.isFirstLaunch();
  }

  @override
  Future<String> getLastOpenedVersion() async {
    return _localStorage.getLastOpenedVersion();
  }

  @override
  Future<void> updateLastOpenedVersion(String version) async {
    await _localStorage.updateLastOpenedVersion(version);

    final config = await getAppConfig();
    final updatedConfig = config.copyWith(lastVersionOpened: version);
    await saveAppConfig(updatedConfig);
  }

  @override
  Future<void> acceptTerms() async {
    await _localStorage.acceptTerms();

    final config = await getAppConfig();
    final updatedConfig = config.copyWith(hasAcceptedTerms: true);
    await saveAppConfig(updatedConfig);
  }

  @override
  Future<void> acceptPrivacyPolicy() async {
    await _localStorage.acceptPrivacyPolicy();

    final config = await getAppConfig();
    final updatedConfig = config.copyWith(hasAcceptedPrivacyPolicy: true);
    await saveAppConfig(updatedConfig);
  }

  @override
  Future<bool> hasAcceptedTerms() async {
    return _localStorage.hasAcceptedTerms();
  }

  @override
  Future<bool> hasAcceptedPrivacyPolicy() async {
    return _localStorage.hasAcceptedPrivacyPolicy();
  }
}

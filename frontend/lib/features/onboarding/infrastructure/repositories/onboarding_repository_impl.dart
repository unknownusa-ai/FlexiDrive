import '../../domain/entities/onboarding_step.dart';
import '../../domain/entities/onboarding_content.dart';
import '../../domain/ports/onboarding_repository_port.dart';
import '../datasources/onboarding_local_storage.dart';

/// Implementación del repositorio de onboarding
class OnboardingRepositoryImpl implements OnboardingRepositoryPort {
  OnboardingRepositoryImpl({OnboardingLocalStorage? localStorage})
      : _localStorage = localStorage ?? OnboardingLocalStorage();

  final OnboardingLocalStorage _localStorage;

  /// Pasos por defecto del onboarding
  static const List<OnboardingStep> _defaultSteps = [
    OnboardingStep(
      id: 1,
      title: 'Bienvenido a FlexiDrive',
      description: 'Descubre la forma más fácil de rentar vehículos',
      imageAsset: 'assets/images/onboarding_1.png',
      order: 0,
    ),
    OnboardingStep(
      id: 2,
      title: 'Encuentra tu vehículo ideal',
      description: 'Explora cientos de opciones disponibles cerca de ti',
      imageAsset: 'assets/images/onboarding_2.png',
      order: 1,
    ),
    OnboardingStep(
      id: 3,
      title: 'Reserva en segundos',
      description: 'Proceso simple y seguro para tu tranquilidad',
      imageAsset: 'assets/images/onboarding_3.png',
      order: 2,
    ),
  ];

  @override
  Future<void> initialize() async {
    // Verificar si ya existe contenido guardado
    final existing = await _localStorage.getContent();
    if (existing == null) {
      // Crear contenido por defecto
      final content = OnboardingContent(
        steps: _defaultSteps,
        currentStepIndex: 0,
        isCompleted: false,
      );
      await _localStorage.saveContent(content);
    }
  }

  @override
  Future<List<OnboardingStep>> getSteps() async {
    final content = await _localStorage.getContent();
    return content?.steps ?? _defaultSteps;
  }

  @override
  Future<OnboardingContent> getContent() async {
    final content = await _localStorage.getContent();
    return content ??
        OnboardingContent(
          steps: _defaultSteps,
          currentStepIndex: 0,
          isCompleted: false,
        );
  }

  @override
  Future<void> markStepAsCompleted(int stepId) async {
    await _localStorage.markStepCompleted(stepId);
  }

  @override
  Future<void> goToNextStep() async {
    final currentIndex = await _localStorage.getCurrentStepIndex();
    final content = await getContent();

    if (currentIndex < content.totalSteps - 1) {
      await _localStorage.saveCurrentStepIndex(currentIndex + 1);
    }
  }

  @override
  Future<void> goToPreviousStep() async {
    final currentIndex = await _localStorage.getCurrentStepIndex();
    if (currentIndex > 0) {
      await _localStorage.saveCurrentStepIndex(currentIndex - 1);
    }
  }

  @override
  Future<void> skipOnboarding() async {
    await _localStorage.markAsSkipped();
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return _localStorage.isCompleted();
  }

  @override
  Future<bool> wasOnboardingSkipped() async {
    return _localStorage.wasSkipped();
  }

  @override
  Future<int> getCurrentStepIndex() async {
    return _localStorage.getCurrentStepIndex();
  }

  @override
  Future<void> resetOnboarding() async {
    await _localStorage.reset();
    await initialize();
  }

  @override
  Future<void> completeOnboarding() async {
    await _localStorage.markAsCompleted();
  }
}

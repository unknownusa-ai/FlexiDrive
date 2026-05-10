import '../entities/onboarding_step.dart';
import '../entities/onboarding_content.dart';

/// Puerto (interfaz) para el repositorio de onboarding
abstract class OnboardingRepositoryPort {
  /// Inicializa el repositorio
  Future<void> initialize();

  /// Obtiene todos los pasos del onboarding
  Future<List<OnboardingStep>> getSteps();

  /// Obtiene el contenido completo del onboarding
  Future<OnboardingContent> getContent();

  /// Marca un paso como completado
  Future<void> markStepAsCompleted(int stepId);

  /// Avanza al siguiente paso
  Future<void> goToNextStep();

  /// Retrocede al paso anterior
  Future<void> goToPreviousStep();

  /// Salta el onboarding completo
  Future<void> skipOnboarding();

  /// Verifica si el onboarding fue completado
  Future<bool> isOnboardingCompleted();

  /// Verifica si el onboarding fue saltado
  Future<bool> wasOnboardingSkipped();

  /// Obtiene el índice del paso actual
  Future<int> getCurrentStepIndex();

  /// Reinicia el onboarding
  Future<void> resetOnboarding();

  /// Marca el onboarding como completado
  Future<void> completeOnboarding();
}

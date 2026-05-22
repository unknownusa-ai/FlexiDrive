import '../../domain/ports/onboarding_repository_port.dart';

/// Caso de uso para completar un paso del onboarding
class CompleteOnboardingStepUseCase {
  /// Crea una instancia y prepara el estado inicial de `CompleteOnboardingStepUseCase`.
  CompleteOnboardingStepUseCase(this._repository);

  final OnboardingRepositoryPort _repository;

  /// Marca un paso como completado y avanza al siguiente
  Future<void> execute(int stepId) async {
    await _repository.markStepAsCompleted(stepId);
    await _repository.goToNextStep();
  }
}

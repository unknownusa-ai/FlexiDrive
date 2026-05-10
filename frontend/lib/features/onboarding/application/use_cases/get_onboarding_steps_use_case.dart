import '../../domain/entities/onboarding_step.dart';
import '../../domain/ports/onboarding_repository_port.dart';

/// Caso de uso para obtener los pasos del onboarding
class GetOnboardingStepsUseCase {
  GetOnboardingStepsUseCase(this._repository);

  final OnboardingRepositoryPort _repository;

  /// Obtiene todos los pasos del onboarding
  Future<List<OnboardingStep>> execute() async {
    return _repository.getSteps();
  }
}

import '../../domain/ports/onboarding_repository_port.dart';

/// Caso de uso para saltar el onboarding
class SkipOnboardingUseCase {
  SkipOnboardingUseCase(this._repository);

  final OnboardingRepositoryPort _repository;

  /// Salta todo el onboarding
  Future<void> execute() async {
    await _repository.skipOnboarding();
  }
}

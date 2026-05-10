import '../../domain/ports/config_repository_port.dart';

/// Caso de uso para completar el onboarding
class CompleteOnboardingUseCase {
  CompleteOnboardingUseCase(this._repository);

  final ConfigRepositoryPort _repository;

  /// Marca el onboarding como completado
  Future<void> execute() async {
    await _repository.markOnboardingAsCompleted();
  }
}

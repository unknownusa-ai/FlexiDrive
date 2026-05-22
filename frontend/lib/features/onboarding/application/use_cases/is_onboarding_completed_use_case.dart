import '../../domain/ports/onboarding_repository_port.dart';

/// Caso de uso para verificar si el onboarding está completado
class IsOnboardingCompletedUseCase {
  /// Crea una instancia y prepara el estado inicial de `IsOnboardingCompletedUseCase`.
  IsOnboardingCompletedUseCase(this._repository);

  final OnboardingRepositoryPort _repository;

  /// Verifica si el onboarding fue completado o saltado
  Future<bool> execute() async {
    final isCompleted = await _repository.isOnboardingCompleted();
    final wasSkipped = await _repository.wasOnboardingSkipped();
    return isCompleted || wasSkipped;
  }
}

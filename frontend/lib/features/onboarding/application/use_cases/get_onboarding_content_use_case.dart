import '../../domain/entities/onboarding_content.dart';
import '../../domain/ports/onboarding_repository_port.dart';

/// Caso de uso para obtener el contenido completo del onboarding
class GetOnboardingContentUseCase {
  /// Crea una instancia y prepara el estado inicial de `GetOnboardingContentUseCase`.
  GetOnboardingContentUseCase(this._repository);

  final OnboardingRepositoryPort _repository;

  /// Obtiene el contenido completo del onboarding
  Future<OnboardingContent> execute() async {
    return _repository.getContent();
  }
}

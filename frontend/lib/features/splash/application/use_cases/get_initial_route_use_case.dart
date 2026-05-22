import '../../domain/ports/config_repository_port.dart';

/// Caso de uso para determinar la ruta inicial de la app
class GetInitialRouteUseCase {
  /// Crea una instancia y prepara el estado inicial de `GetInitialRouteUseCase`.
  GetInitialRouteUseCase({
    required this.configRepository,
  });

  final ConfigRepositoryPort configRepository;

  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeHome = '/home';

  /// Determina la ruta inicial basada en el estado del onboarding
  Future<String> execute() async {
    final isFirstLaunch = await configRepository.isFirstLaunch();

    if (isFirstLaunch) {
      return routeOnboarding;
    }

    return routeLogin;
  }
}

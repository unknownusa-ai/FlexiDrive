import '../../domain/ports/home_repository_port.dart';

/// Caso de uso para obtener el saludo personalizado del usuario
class GetUserGreetingUseCase {
  /// Crea una instancia y prepara el estado inicial de `GetUserGreetingUseCase`.
  GetUserGreetingUseCase(this._repository);

  final HomeRepositoryPort _repository;

  /// Obtiene el saludo personalizado
  Future<String> execute(int userId) async {
    final greeting = await _repository.getUserGreeting(userId);
    return greeting ?? '¡Hola!';
  }
}

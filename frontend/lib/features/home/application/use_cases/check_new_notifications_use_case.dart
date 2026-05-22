import '../../domain/ports/home_repository_port.dart';

/// Caso de uso para verificar notificaciones nuevas
class CheckNewNotificationsUseCase {
  /// Crea una instancia y prepara el estado inicial de `CheckNewNotificationsUseCase`.
  CheckNewNotificationsUseCase(this._repository);

  final HomeRepositoryPort _repository;

  /// Verifica si el usuario tiene notificaciones sin leer
  Future<bool> execute(int userId) async {
    return _repository.hasNewNotifications(userId);
  }
}

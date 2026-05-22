import 'package:flexidrive/features/reservations/domain/entities/reservation_models.dart';
import 'package:flexidrive/features/reservations/domain/ports/repositorio_reservas_puerto.dart';

/// Define la responsabilidad de `ReservationAccessUseCase` dentro de este módulo.
class ReservationAccessUseCase {
  /// Crea una instancia y prepara el estado inicial de `ReservationAccessUseCase`.
  ReservationAccessUseCase(this._repository);

  final RepositorioReservasPuerto _repository;

  /// Carga los datos necesarios para cargar if needed.
  Future<void> loadIfNeeded() => _repository.inicializar();

  List<ReservationModel> get reservations => _repository.obtenerReservas();

  /// Agregar reserva esta parte del flujo de trabajo.
  Future<void> addReservation(ReservationModel reservation) {
    return _repository.agregarReserva(reservation);
  }

  /// Actualiza el estado relacionado con actualizar reserva.
  Future<void> updateReservation(ReservationModel reservation) {
    return _repository.actualizarReserva(reservation);
  }

  /// Agregar reserva locally esta parte del flujo de trabajo.
  void addReservationLocally(ReservationModel reservation) {
    _repository.agregarReservaLocal(reservation);
  }
}

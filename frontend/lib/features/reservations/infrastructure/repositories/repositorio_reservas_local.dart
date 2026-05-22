import 'package:flexidrive/features/reservations/domain/ports/repositorio_reservas_puerto.dart';
import 'package:flexidrive/features/reservations/domain/entities/reservation_models.dart';
import 'package:flexidrive/features/reservations/infrastructure/datasources/local_reservation_db.dart';

/// Define la responsabilidad de `RepositorioReservasLocal` dentro de este módulo.
class RepositorioReservasLocal implements RepositorioReservasPuerto {
  RepositorioReservasLocal({LocalReservationDb? origen})
      : _origen = origen ?? LocalReservationDb.instance;

  final LocalReservationDb _origen;

  /// Gestiona inicializar dentro de esta parte del flujo.
  @override
  Future<void> inicializar() async {
    await _origen.loadIfNeeded();
  }

  /// Obtiene la información asociada a obtener reservas.
  @override
  List<ReservationModel> obtenerReservas() => _origen.reservations;

  /// Agregar reserva esta parte del flujo de trabajo.
  @override
  Future<void> agregarReserva(ReservationModel reservation) {
    return _origen.addReservation(reservation);
  }

  /// Actualiza el estado relacionado con actualizar reserva.
  @override
  Future<void> actualizarReserva(ReservationModel reservation) {
    return _origen.updateReservation(reservation);
  }

  /// Agregar reserva local esta parte del flujo de trabajo.
  @override
  void agregarReservaLocal(ReservationModel reservation) {
    _origen.addReservationLocally(reservation);
  }

  LocalReservationDb get origen => _origen;
}

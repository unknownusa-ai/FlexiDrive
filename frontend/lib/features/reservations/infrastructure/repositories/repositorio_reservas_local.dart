import 'package:flexidrive/features/reservations/domain/ports/repositorio_reservas_puerto.dart';
import 'package:flexidrive/features/reservations/domain/entities/reservation_models.dart';
import 'package:flexidrive/features/reservations/infrastructure/datasources/local_reservation_db.dart';

class RepositorioReservasLocal implements RepositorioReservasPuerto {
  RepositorioReservasLocal({LocalReservationDb? origen})
      : _origen = origen ?? LocalReservationDb.instance;

  final LocalReservationDb _origen;

  @override
  Future<void> inicializar() async {
    await _origen.loadIfNeeded();
  }

  @override
  List<ReservationModel> obtenerReservas() => _origen.reservations;

  @override
  Future<void> agregarReserva(ReservationModel reservation) {
    return _origen.addReservation(reservation);
  }

  @override
  Future<void> actualizarReserva(ReservationModel reservation) {
    return _origen.updateReservation(reservation);
  }

  @override
  void agregarReservaLocal(ReservationModel reservation) {
    _origen.addReservationLocally(reservation);
  }

  LocalReservationDb get origen => _origen;
}

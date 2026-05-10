import 'package:flexidrive/features/reservations/domain/entities/reservation_models.dart';
import 'package:flexidrive/features/reservations/domain/ports/repositorio_reservas_puerto.dart';

class ReservationAccessUseCase {
  ReservationAccessUseCase(this._repository);

  final RepositorioReservasPuerto _repository;

  Future<void> loadIfNeeded() => _repository.inicializar();

  List<ReservationModel> get reservations => _repository.obtenerReservas();

  Future<void> addReservation(ReservationModel reservation) {
    return _repository.agregarReserva(reservation);
  }

  void addReservationLocally(ReservationModel reservation) {
    _repository.agregarReservaLocal(reservation);
  }
}

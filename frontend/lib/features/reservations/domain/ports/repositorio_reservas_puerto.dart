import 'package:flexidrive/features/reservations/domain/entities/reservation_models.dart';

abstract class RepositorioReservasPuerto {
  Future<void> inicializar();
  List<ReservationModel> obtenerReservas();
  Future<void> agregarReserva(ReservationModel reservation);
  Future<void> actualizarReserva(ReservationModel reservation);
  void agregarReservaLocal(ReservationModel reservation);
}

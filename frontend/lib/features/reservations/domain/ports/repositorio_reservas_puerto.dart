import 'package:flexidrive/features/reservations/domain/entities/reservation_models.dart';

/// Define la responsabilidad de `RepositorioReservasPuerto` dentro de este módulo.
abstract class RepositorioReservasPuerto {
  Future<void> inicializar();
  List<ReservationModel> obtenerReservas();
  Future<void> agregarReserva(ReservationModel reservation);
  Future<void> actualizarReserva(ReservationModel reservation);
  void agregarReservaLocal(ReservationModel reservation);
}

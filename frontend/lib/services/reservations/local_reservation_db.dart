import 'package:flexidrive/core/api/api_client.dart';
import 'package:flexidrive/models/reservations/reservation_models.dart';

// Base de datos local para reservas
// Maneja el almacenamiento local de datos de reservas
class LocalReservationDb {
  // Constructor privado para patrón singleton
  LocalReservationDb._();

  // Instancia única de la clase (patrón singleton)
  static final LocalReservationDb instance = LocalReservationDb._();

  // Indica si los datos ya fueron cargados
  bool? _loaded = false;

  // Lista de reservas almacenadas localmente
  final List<ReservationModel> reservations = [];

  // Carga los datos solo si es necesario
  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;
    await forceReload();
  }

  // Recarga forzada desde el JSON (ignora el estado de carga)
  Future<void> forceReload() async {
    reservations
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('reservations'),
          ReservationModel.fromJson,
        ),
      );

    _loaded = true;
  }

  List<T> _parseList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) parser,
  ) {
    final raw = (source as List<dynamic>? ?? const []);
    return raw.map((item) => parser(item as Map<String, dynamic>)).toList();
  }

  Future<List<dynamic>> _loadList(String endpoint) =>
      ApiClient.instance.getList(endpoint);

  // Agrega una nueva reserva a la lista en memoria
  Future<void> addReservation(ReservationModel reservation) async {
    final created =
        await ApiClient.instance.postMap('reservations', reservation.toJson());
    reservations.add(ReservationModel.fromJson(created));
  }

  void addReservationLocally(ReservationModel reservation) {
    reservations.add(reservation);
  }
}

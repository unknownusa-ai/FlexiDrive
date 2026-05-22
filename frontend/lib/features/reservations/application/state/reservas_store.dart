import 'package:flutter/foundation.dart';

/// Define la responsabilidad de `ReservaActiva` dentro de este módulo.
class ReservaActiva {
  /// Crea una instancia y prepara el estado inicial de `ReservaActiva`.
  const ReservaActiva({
    required this.vehicleName,
    required this.code,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.imageUrl,
    this.vehicleSpecs,
    this.vehicleRating,
    this.vehicleReviews,
    this.vehiclePrice,
    this.precioDia,
    this.precioSemana,
    this.progress = 0.4,
    this.status = 'Activa',
  });

  final String vehicleName;
  final String code;
  final String price;
  final String startDate;
  final String endDate;
  final String location;
  final String imageUrl;
  final String? vehicleSpecs;
  final double? vehicleRating;
  final int? vehicleReviews;
  final int? vehiclePrice;
  final int? precioDia;
  final int? precioSemana;
  final double progress;
  final String status;
}

/// Define la responsabilidad de `ReservasStore` dentro de este módulo.
class ReservasStore {
  /// Crea una instancia y prepara el estado inicial de `ReservasStore`.
  ReservasStore._();

  static final ValueNotifier<List<ReservaActiva>> activasNotifier =
      ValueNotifier<List<ReservaActiva>>([]);

  /// Agregar activa esta parte del flujo de trabajo.
  static void addActiva(ReservaActiva reserva) {
    activasNotifier.value = [reserva, ...activasNotifier.value];
  }

  /// Elimina los datos vinculados a remover activa por code.
  static void removeActivaByCode(String code) {
    activasNotifier.value =
        activasNotifier.value.where((reserva) => reserva.code != code).toList();
  }
}

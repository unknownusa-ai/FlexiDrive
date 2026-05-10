import 'package:flutter/foundation.dart';

class ReservaActiva {
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

class ReservasStore {
  ReservasStore._();

  static final ValueNotifier<List<ReservaActiva>> activasNotifier =
      ValueNotifier<List<ReservaActiva>>([]);

  static void addActiva(ReservaActiva reserva) {
    activasNotifier.value = [reserva, ...activasNotifier.value];
  }

  static void removeActivaByCode(String code) {
    activasNotifier.value =
        activasNotifier.value.where((reserva) => reserva.code != code).toList();
  }
}

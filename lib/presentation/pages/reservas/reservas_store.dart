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
  final double progress;
  final String status;
}

class ReservasStore {
  ReservasStore._();

  static final ValueNotifier<List<ReservaActiva>> activasNotifier =
      ValueNotifier<List<ReservaActiva>>([
    const ReservaActiva(
      vehicleName: 'Mazda CX-5 2024',
      code: 'FXD-2024-0089',
      price: r'$ 440,000',
      startDate: '22 Feb 2026',
      endDate: '24 Feb 2026',
      location: 'Av. El Dorado, Bogotá',
      imageUrl: 'assets/imagenes_carros/cx5.jpg',
    ),
  ]);

  static void addActiva(ReservaActiva reserva) {
    activasNotifier.value = [reserva, ...activasNotifier.value];
  }
}

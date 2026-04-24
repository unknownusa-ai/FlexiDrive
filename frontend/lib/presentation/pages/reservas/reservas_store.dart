import 'package:flutter/foundation.dart';

// Modelo de reserva activa
// Representa una reserva que está actualmente en progreso
class ReservaActiva {
  // Constructor con datos de la reserva
  const ReservaActiva({
    required this.vehicleName, // Nombre del vehículo
    required this.code, // Código de reserva
    required this.price, // Precio total
    required this.startDate, // Fecha de inicio
    required this.endDate, // Fecha de fin
    required this.location, // Ubicación
    required this.imageUrl, // URL de la imagen
    this.vehicleSpecs, // Especificaciones del vehículo
    this.vehicleRating, // Calificación del vehículo
    this.vehicleReviews, // Número de reseñas
    this.vehiclePrice, // Precio del vehículo
    this.precioDia, // Precio por día
    this.precioSemana, // Precio por semana
    this.progress = 0.4, // Progreso de la reserva
    this.status = 'Activa', // Estado de la reserva
  });

  // Nombre del vehículo
  final String vehicleName;
  // Código único de la reserva
  final String code;
  // Precio total de la reserva
  final String price;
  // Fecha de inicio de la reserva
  final String startDate;
  // Fecha de fin de la reserva
  final String endDate;
  // Ubicación de la reserva
  final String location;
  // URL de la imagen del vehículo
  final String imageUrl;
  // Especificaciones del vehículo
  final String? vehicleSpecs;
  // Calificación del vehículo
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

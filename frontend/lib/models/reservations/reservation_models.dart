// Utilidades para convertir JSON
import 'package:flexidrive/utils/json_utils.dart';

// Modelo de una reserva/renta de vehiculo
// Cuando un usuario renta un carro, se crea una de estas
class ReservationModel {
  // Constructor con todos los datos de la reserva
  const ReservationModel({
    required this.id, // ID unico de la reserva
    required this.code, // Codigo alfanumerico ej: RES-001
    required this.userId, // ID del usuario que renta
    required this.publicationId, // ID de la publicacion del carro
    required this.paymentMethodId, // Metodo de pago usado
    required this.periodTypeId, // 1=dia, 2=semana, 3=mes
    required this.periodCount, // Cuantos dias/semanas/meses
    required this.startDate, // Fecha de recogida
    required this.endDate, // Fecha de entrega
    required this.pickupLocation, // Donde recoge el carro
    required this.returnLocation, // Donde devuelve el carro
    required this.totalValue, // Valor total en pesos
    required this.statusId, // 1=pendiente, 2=activa, 3=completada, 4=cancelada
    required this.reservationDate, // Fecha en que hizo la reserva
  });

  // ID de la reserva
  final int id;
  // Codigo legible ej: "RES-2024-001"
  final String code;
  // ID del usuario arrendatario
  final int userId;
  // ID de la publicacion (carro especifico)
  final int publicationId;
  // ID del metodo de pago
  final int paymentMethodId;
  // Tipo de periodo: 1=dia, 2=semana, 3=mes
  final int periodTypeId;
  // Cantidad de periodos ej: 3 dias
  final int periodCount;
  // Fecha y hora de inicio
  final DateTime startDate;
  // Fecha y hora de fin
  final DateTime endDate;
  // Ubicacion de recogida ej: "Aeropuerto El Dorado"
  final String pickupLocation;
  // Ubicacion de entrega
  final String returnLocation;
  // Valor total de la reserva
  final double totalValue;
  // Estado: 1=pendiente, 2=activa, 3=completada, 4=cancelada
  final int statusId;
  // Fecha en que se creo la reserva
  final DateTime reservationDate;

  // Crea una ReservationModel desde JSON
  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: JsonUtils.asInt(json['reserva_id']),
      code: JsonUtils.asString(json['codigo_reserva']),
      userId: JsonUtils.asInt(json['usuario_id']),
      publicationId: JsonUtils.asInt(json['publicacion_id']),
      paymentMethodId: JsonUtils.asInt(json['metodo_pago_id']),
      periodTypeId: JsonUtils.asInt(json['tipo_periodo_id']),
      periodCount: JsonUtils.asInt(json['cantidad_periodos']),
      startDate: JsonUtils.asDateTime(json['fecha_inicio']),
      endDate: JsonUtils.asDateTime(json['fecha_fin']),
      pickupLocation: JsonUtils.asString(json['ubicacion_recogida']),
      returnLocation: JsonUtils.asString(json['ubicacion_entrega']),
      totalValue: JsonUtils.asDouble(json['valor_total']),
      statusId: JsonUtils.asInt(json['estado_reserva_id']),
      reservationDate: JsonUtils.asDateTime(json['fecha_reserva']),
    );
  }

  Map<String, dynamic> toJson() => {
        'reserva_id': id,
        'codigo_reserva': code,
        'usuario_id': userId,
        'publicacion_id': publicationId,
        'metodo_pago_id': paymentMethodId,
        'tipo_periodo_id': periodTypeId,
        'cantidad_periodos': periodCount,
        'fecha_inicio': startDate.toIso8601String(),
        'fecha_fin': endDate.toIso8601String(),
        'ubicacion_recogida': pickupLocation,
        'ubicacion_entrega': returnLocation,
        'valor_total': totalValue,
        'estado_reserva_id': statusId,
        'fecha_reserva': reservationDate.toIso8601String(),
      };
}

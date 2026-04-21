import '../../../shared/utils/json_utils.dart';
import '../../domain/entities/reservation_entities.dart';

class ReservationModel extends Reservation {
  const ReservationModel({
    required super.id,
    required super.code,
    required super.userId,
    required super.publicationId,
    required super.paymentMethodId,
    required super.periodTypeId,
    required super.periodCount,
    required super.startDate,
    required super.endDate,
    required super.pickupLocation,
    required super.returnLocation,
    required super.totalValue,
    required super.statusId,
    required super.reservationDate,
  });

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

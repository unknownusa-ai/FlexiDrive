import '../../../shared/utils/json_utils.dart';
import '../../domain/entities/vehicle_entities.dart';

class VehicleModel extends Vehicle {
  const VehicleModel({
    required super.id,
    required super.categoryId,
    required super.line,
    required super.model,
    required super.color,
    required super.seats,
    required super.transmissionType,
    required super.airConditioning,
    required super.fuelType,
    super.description,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: JsonUtils.asInt(json['vehiculo_id']),
      categoryId: JsonUtils.asInt(json['categoria_vehiculo_id']),
      line: JsonUtils.asString(json['linea']),
      model: JsonUtils.asInt(json['modelo']),
      color: JsonUtils.asString(json['color']),
      seats: JsonUtils.asInt(json['asientos']),
      transmissionType: JsonUtils.asString(json['tipo_transmision']),
      airConditioning: JsonUtils.asBool(json['aire_acondicionado']),
      fuelType: JsonUtils.asString(json['tipo_combustible']),
      description: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'vehiculo_id': id,
    'categoria_vehiculo_id': categoryId,
    'linea': line,
    'modelo': model,
    'color': color,
    'asientos': seats,
    'tipo_transmision': transmissionType,
    'aire_acondicionado': airConditioning,
    'tipo_combustible': fuelType,
    'descripcion': description,
  };
}

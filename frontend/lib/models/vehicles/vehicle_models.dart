import 'package:flexidrive/utils/json_utils.dart';

class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.categoryId,
    required this.line,
    required this.model,
    required this.color,
    required this.seats,
    required this.transmissionType,
    required this.airConditioning,
    required this.fuelType,
    this.description,
  });

  final int id;
  final int categoryId;
  final String line;
  final int model;
  final String color;
  final int seats;
  final String transmissionType;
  final bool airConditioning;
  final String fuelType;
  final String? description;

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

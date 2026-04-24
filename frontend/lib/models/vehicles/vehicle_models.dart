// Utilidades pa' convertir JSON
import 'package:flexidrive/utils/json_utils.dart';

// Modelo de un vehículo/carro
// Guarda toda la info del carro que se puede rentar
class VehicleModel {
  // Constructor - recibe todos los datos del carro
  const VehicleModel({
    required this.id, // ID único del carro
    required this.categoryId, // Qué tipo de carro es (sedan, SUV, etc)
    required this.line, // Línea del carro (Mazda 3, Onix, etc)
    required this.model, // Año del modelo (2024, 2025)
    required this.color, // Color del carro
    required this.seats, // Cuántos puestos tiene
    required this.transmissionType, // Automático o manual
    required this.airConditioning, // Tiene aire?
    required this.fuelType, // Gasolina, diesel, eléctrico
    this.description, // Descripción opcional
  });

  // ID del vehículo en la base de datos
  final int id;
  // ID de la categoría (sedan=1, SUV=2, etc)
  final int categoryId;
  // Línea del vehículo ej: "Chevrolet Onix"
  final String line;
  // Año del modelo ej: 2024
  final int model;
  // Color del carro ej: "Rojo", "Negro"
  final String color;
  // Número de asientos ej: 5
  final int seats;
  // Tipo de transmisión ej: "Automática", "Manual"
  final String transmissionType;
  // true = tiene aire acondicionado
  final bool airConditioning;
  // Tipo de combustible ej: "Gasolina"
  final String fuelType;
  // Descripción opcional del carro
  final String? description;

  // Crea un VehicleModel desde JSON (cuando cargamos de la BD)
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: JsonUtils.asInt(json['vehiculo_id']), // Convertimos a int
      categoryId: JsonUtils.asInt(json['categoria_vehiculo_id']),
      line: JsonUtils.asString(json['linea']), // Línea del carro
      model: JsonUtils.asInt(json['modelo']), // Año
      color: JsonUtils.asString(json['color']),
      seats: JsonUtils.asInt(json['asientos']),
      transmissionType: JsonUtils.asString(json['tipo_transmision']),
      airConditioning: JsonUtils.asBool(json['aire_acondicionado']), // boolean
      fuelType: JsonUtils.asString(json['tipo_combustible']),
      description: json['descripcion'] as String?, // Puede ser null
    );
  }

  // Convierte el modelo a JSON (para guardar en BD)
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

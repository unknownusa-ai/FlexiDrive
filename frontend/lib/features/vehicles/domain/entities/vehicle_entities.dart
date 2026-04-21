class Vehicle {
  const Vehicle({
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
}

// Utilidades para convertir JSON
import 'package:flexidrive/core/utils/json_utils.dart';

// Modelo de tipo de identificacion
// Para el formulario de registro (CC, CE, Pasaporte, etc)
class IdentificationTypeModel {
  // Constructor con datos del tipo de documento
  const IdentificationTypeModel({
    required this.id, // ID unico
    required this.name, // Nombre ej: "Cédula de Ciudadanía"
    this.description, // Descripcion opcional
  });

  // ID del tipo de identificacion
  final int id;
  // Nombre legible para el usuario
  final String name;
  // Descripcion detallada (opcional)
  final String? description;

  /// Crea una instancia y prepara el estado inicial de `IdentificationTypeModel`.
  factory IdentificationTypeModel.fromJson(Map<String, dynamic> json) {
    return IdentificationTypeModel(
      id: JsonUtils.asInt(json['tipo_identificacion_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  // Convierte a JSON para guardar
  Map<String, dynamic> toJson() => {
        'tipo_identificacion_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

// Modelo de tipo de usuario
// Define si es arrendador o arrendatario
class UserTypeModel {
  // Constructor con datos del tipo de usuario
  const UserTypeModel({
    required this.id, // ID unico
    required this.name, // Nombre ej: "Arrendador"
    this.description, // Descripcion opcional
  });

  // ID del tipo de usuario
  final int id;
  // Nombre legible para el usuario
  final String name;
  // Descripcion detallada (opcional)
  final String? description;

  /// Crea una instancia y prepara el estado inicial de `UserTypeModel`.
  factory UserTypeModel.fromJson(Map<String, dynamic> json) {
    return UserTypeModel(
      id: JsonUtils.asInt(json['tipo_usuario_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  // Convierte a JSON para guardar
  Map<String, dynamic> toJson() => {
        'tipo_usuario_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

// Modelo de metodo de pago
// Para las formas de pago (tarjeta, efectivo, etc)
class PaymentMethodTypeModel {
  // Constructor con datos del metodo de pago
  const PaymentMethodTypeModel({
    required this.id, // ID unico
    required this.name, // Nombre ej: "Tarjeta de Crédito"
    this.description, // Descripcion opcional
  });

  final int id;
  final String name;
  final String? description;

  /// Crea una instancia y prepara el estado inicial de `PaymentMethodTypeModel`.
  factory PaymentMethodTypeModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodTypeModel(
      id: JsonUtils.asInt(json['tipo_metodo_pago_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
  Map<String, dynamic> toJson() => {
        'tipo_metodo_pago_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

/// Define la responsabilidad de `BankModel` dentro de este módulo.
class BankModel {
  /// Crea una instancia y prepara el estado inicial de `BankModel`.
  const BankModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  /// Crea una instancia y prepara el estado inicial de `BankModel`.
  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: JsonUtils.asInt(json['banco_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
  Map<String, dynamic> toJson() => {
        'banco_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

/// Define la responsabilidad de `CardBrandModel` dentro de este módulo.
class CardBrandModel {
  /// Crea una instancia y prepara el estado inicial de `CardBrandModel`.
  const CardBrandModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  /// Crea una instancia y prepara el estado inicial de `CardBrandModel`.
  factory CardBrandModel.fromJson(Map<String, dynamic> json) {
    return CardBrandModel(
      id: JsonUtils.asInt(json['marca_tarjeta_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
  Map<String, dynamic> toJson() => {
        'marca_tarjeta_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

/// Define la responsabilidad de `PersonTypeModel` dentro de este módulo.
class PersonTypeModel {
  /// Crea una instancia y prepara el estado inicial de `PersonTypeModel`.
  const PersonTypeModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  /// Crea una instancia y prepara el estado inicial de `PersonTypeModel`.
  factory PersonTypeModel.fromJson(Map<String, dynamic> json) {
    return PersonTypeModel(
      id: JsonUtils.asInt(json['tipo_persona_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
  Map<String, dynamic> toJson() => {
        'tipo_persona_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

/// Define la responsabilidad de `VehicleCategoryModel` dentro de este módulo.
class VehicleCategoryModel {
  /// Crea una instancia y prepara el estado inicial de `VehicleCategoryModel`.
  const VehicleCategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  /// Crea una instancia y prepara el estado inicial de `VehicleCategoryModel`.
  factory VehicleCategoryModel.fromJson(Map<String, dynamic> json) {
    return VehicleCategoryModel(
      id: JsonUtils.asInt(json['categoria_vehiculo_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
  Map<String, dynamic> toJson() => {
        'categoria_vehiculo_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

/// Define la responsabilidad de `PeriodTypeModel` dentro de este módulo.
class PeriodTypeModel {
  /// Crea una instancia y prepara el estado inicial de `PeriodTypeModel`.
  const PeriodTypeModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  /// Crea una instancia y prepara el estado inicial de `PeriodTypeModel`.
  factory PeriodTypeModel.fromJson(Map<String, dynamic> json) {
    return PeriodTypeModel(
      id: JsonUtils.asInt(json['tipo_periodo_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
  Map<String, dynamic> toJson() => {
        'tipo_periodo_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

/// Define la responsabilidad de `ReservationStatusModel` dentro de este módulo.
class ReservationStatusModel {
  /// Crea una instancia y prepara el estado inicial de `ReservationStatusModel`.
  const ReservationStatusModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  /// Crea una instancia y prepara el estado inicial de `ReservationStatusModel`.
  factory ReservationStatusModel.fromJson(Map<String, dynamic> json) {
    return ReservationStatusModel(
      id: JsonUtils.asInt(json['estado_reserva_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
  Map<String, dynamic> toJson() => {
        'estado_reserva_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

/// Define la responsabilidad de `NotificationCategoryModel` dentro de este módulo.
class NotificationCategoryModel {
  /// Crea una instancia y prepara el estado inicial de `NotificationCategoryModel`.
  const NotificationCategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  /// Crea una instancia y prepara el estado inicial de `NotificationCategoryModel`.
  factory NotificationCategoryModel.fromJson(Map<String, dynamic> json) {
    return NotificationCategoryModel(
      id: JsonUtils.asInt(json['categoria_notificacion_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
  Map<String, dynamic> toJson() => {
        'categoria_notificacion_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

/// Define la responsabilidad de `LandlordDocumentTypeModel` dentro de este módulo.
class LandlordDocumentTypeModel {
  /// Crea una instancia y prepara el estado inicial de `LandlordDocumentTypeModel`.
  const LandlordDocumentTypeModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  /// Crea una instancia y prepara el estado inicial de `LandlordDocumentTypeModel`.
  factory LandlordDocumentTypeModel.fromJson(Map<String, dynamic> json) {
    return LandlordDocumentTypeModel(
      id: JsonUtils.asInt(json['tipo_documento_arrendador_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
  Map<String, dynamic> toJson() => {
        'tipo_documento_arrendador_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

/// Define la responsabilidad de `DocumentVerificationStatusModel` dentro de este módulo.
class DocumentVerificationStatusModel {
  /// Crea una instancia y prepara el estado inicial de `DocumentVerificationStatusModel`.
  const DocumentVerificationStatusModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  /// Crea una instancia y prepara el estado inicial de `DocumentVerificationStatusModel`.
  factory DocumentVerificationStatusModel.fromJson(Map<String, dynamic> json) {
    return DocumentVerificationStatusModel(
      id: JsonUtils.asInt(json['estado_verificacion_documento_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
  Map<String, dynamic> toJson() => {
        'estado_verificacion_documento_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

// Utilidades para convertir JSON
import 'package:flexidrive/utils/json_utils.dart';

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

  // Crea IdentificationTypeModel desde JSON
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

  // Crea UserTypeModel desde JSON
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

  factory PaymentMethodTypeModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodTypeModel(
      id: JsonUtils.asInt(json['tipo_metodo_pago_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'tipo_metodo_pago_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

class BankModel {
  const BankModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: JsonUtils.asInt(json['banco_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'banco_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

class CardBrandModel {
  const CardBrandModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  factory CardBrandModel.fromJson(Map<String, dynamic> json) {
    return CardBrandModel(
      id: JsonUtils.asInt(json['marca_tarjeta_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'marca_tarjeta_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

class PersonTypeModel {
  const PersonTypeModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  factory PersonTypeModel.fromJson(Map<String, dynamic> json) {
    return PersonTypeModel(
      id: JsonUtils.asInt(json['tipo_persona_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'tipo_persona_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

class VehicleCategoryModel {
  const VehicleCategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  factory VehicleCategoryModel.fromJson(Map<String, dynamic> json) {
    return VehicleCategoryModel(
      id: JsonUtils.asInt(json['categoria_vehiculo_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'categoria_vehiculo_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

class PeriodTypeModel {
  const PeriodTypeModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  factory PeriodTypeModel.fromJson(Map<String, dynamic> json) {
    return PeriodTypeModel(
      id: JsonUtils.asInt(json['tipo_periodo_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'tipo_periodo_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

class ReservationStatusModel {
  const ReservationStatusModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  factory ReservationStatusModel.fromJson(Map<String, dynamic> json) {
    return ReservationStatusModel(
      id: JsonUtils.asInt(json['estado_reserva_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'estado_reserva_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

class NotificationCategoryModel {
  const NotificationCategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  factory NotificationCategoryModel.fromJson(Map<String, dynamic> json) {
    return NotificationCategoryModel(
      id: JsonUtils.asInt(json['categoria_notificacion_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'categoria_notificacion_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

class LandlordDocumentTypeModel {
  const LandlordDocumentTypeModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  factory LandlordDocumentTypeModel.fromJson(Map<String, dynamic> json) {
    return LandlordDocumentTypeModel(
      id: JsonUtils.asInt(json['tipo_documento_arrendador_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'tipo_documento_arrendador_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

class DocumentVerificationStatusModel {
  const DocumentVerificationStatusModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  factory DocumentVerificationStatusModel.fromJson(Map<String, dynamic> json) {
    return DocumentVerificationStatusModel(
      id: JsonUtils.asInt(json['estado_verificacion_documento_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'estado_verificacion_documento_id': id,
        'nombre': name,
        'descripcion': description,
      };
}

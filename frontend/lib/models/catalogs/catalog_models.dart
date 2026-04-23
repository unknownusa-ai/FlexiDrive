import 'package:flexidrive/utils/json_utils.dart';

class IdentificationTypeModel {
  const IdentificationTypeModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  factory IdentificationTypeModel.fromJson(Map<String, dynamic> json) {
    return IdentificationTypeModel(
      id: JsonUtils.asInt(json['tipo_identificacion_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'tipo_identificacion_id': id,
    'nombre': name,
    'descripcion': description,
  };
}

class UserTypeModel {
  const UserTypeModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  factory UserTypeModel.fromJson(Map<String, dynamic> json) {
    return UserTypeModel(
      id: JsonUtils.asInt(json['tipo_usuario_id']),
      name: JsonUtils.asString(json['nombre']),
      description: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'tipo_usuario_id': id,
    'nombre': name,
    'descripcion': description,
  };
}

class PaymentMethodTypeModel {
  const PaymentMethodTypeModel({
    required this.id,
    required this.name,
    this.description,
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

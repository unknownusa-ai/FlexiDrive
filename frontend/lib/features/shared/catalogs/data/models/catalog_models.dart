import '../../../utils/json_utils.dart';
import '../../domain/entities/catalog_entities.dart';

class IdentificationTypeModel extends IdentificationType {
  const IdentificationTypeModel({
    required super.id,
    required super.name,
    super.description,
  });

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

class UserTypeModel extends UserType {
  const UserTypeModel({
    required super.id,
    required super.name,
    super.description,
  });

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

class PaymentMethodTypeModel extends PaymentMethodType {
  const PaymentMethodTypeModel({
    required super.id,
    required super.name,
    super.description,
  });

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

class BankModel extends Bank {
  const BankModel({
    required super.id,
    required super.name,
    super.description,
  });

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

class CardBrandModel extends CardBrand {
  const CardBrandModel({
    required super.id,
    required super.name,
    super.description,
  });

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

class PersonTypeModel extends PersonType {
  const PersonTypeModel({
    required super.id,
    required super.name,
    super.description,
  });

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

class VehicleCategoryModel extends VehicleCategory {
  const VehicleCategoryModel({
    required super.id,
    required super.name,
    super.description,
  });

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

class PeriodTypeModel extends PeriodType {
  const PeriodTypeModel({
    required super.id,
    required super.name,
    super.description,
  });

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

class ReservationStatusModel extends ReservationStatus {
  const ReservationStatusModel({
    required super.id,
    required super.name,
    super.description,
  });

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

class NotificationCategoryModel extends NotificationCategory {
  const NotificationCategoryModel({
    required super.id,
    required super.name,
    super.description,
  });

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

class LandlordDocumentTypeModel extends LandlordDocumentType {
  const LandlordDocumentTypeModel({
    required super.id,
    required super.name,
    super.description,
  });

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

class DocumentVerificationStatusModel extends DocumentVerificationStatus {
  const DocumentVerificationStatusModel({
    required super.id,
    required super.name,
    super.description,
  });

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

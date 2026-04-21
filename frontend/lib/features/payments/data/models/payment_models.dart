import '../../../shared/utils/json_utils.dart';
import '../../domain/entities/payment_entities.dart';

class PaymentMethodModel extends PaymentMethod {
  const PaymentMethodModel({
    required super.id,
    required super.userId,
    required super.paymentMethodTypeId,
    required super.isDefault,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: JsonUtils.asInt(json['metodo_pago_id']),
      userId: JsonUtils.asInt(json['usuario_id']),
      paymentMethodTypeId: JsonUtils.asInt(json['tipo_metodo_pago_id']),
      isDefault: JsonUtils.asBool(json['predeterminado']),
    );
  }

  Map<String, dynamic> toJson() => {
    'metodo_pago_id': id,
    'usuario_id': userId,
    'tipo_metodo_pago_id': paymentMethodTypeId,
    'predeterminado': isDefault,
  };
}

class CardModel extends Card {
  const CardModel({
    required super.id,
    required super.paymentMethodId,
    required super.cardNumber,
    required super.cardBrandId,
    required super.expirationMonth,
    required super.expirationYear,
    required super.cvc,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: JsonUtils.asInt(json['tarjeta_id']),
      paymentMethodId: JsonUtils.asInt(json['metodo_pago_id']),
      cardNumber: JsonUtils.asString(json['numero_tarjeta']),
      cardBrandId: JsonUtils.asInt(json['marca_tarjeta_id']),
      expirationMonth: JsonUtils.asInt(json['mes_expiracion']),
      expirationYear: JsonUtils.asInt(json['ano_expiracion']),
      cvc: JsonUtils.asInt(json['cvc']),
    );
  }

  Map<String, dynamic> toJson() => {
    'tarjeta_id': id,
    'metodo_pago_id': paymentMethodId,
    'numero_tarjeta': cardNumber,
    'marca_tarjeta_id': cardBrandId,
    'mes_expiracion': expirationMonth,
    'ano_expiracion': expirationYear,
    'cvc': cvc,
  };
}

class PseModel extends Pse {
  const PseModel({
    required super.id,
    required super.paymentMethodId,
    required super.bankId,
    required super.personTypeId,
  });

  factory PseModel.fromJson(Map<String, dynamic> json) {
    return PseModel(
      id: JsonUtils.asInt(json['pse_id']),
      paymentMethodId: JsonUtils.asInt(json['metodo_pago_id']),
      bankId: JsonUtils.asInt(json['banco_id']),
      personTypeId: JsonUtils.asInt(json['tipo_persona_id']),
    );
  }

  Map<String, dynamic> toJson() => {
    'pse_id': id,
    'metodo_pago_id': paymentMethodId,
    'banco_id': bankId,
    'tipo_persona_id': personTypeId,
  };
}

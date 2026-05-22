// Utilidades para convertir JSON
import 'package:flexidrive/core/utils/json_utils.dart';

// Modelo de método de pago
// Representa un método de pago asociado a un usuario
class PaymentMethodModel {
  // Constructor con todos los datos del método de pago
  const PaymentMethodModel({
    required this.id, // ID único del método de pago
    required this.userId, // ID del usuario dueño del método
    required this.paymentMethodTypeId, // Tipo de método (tarjeta, PSE, etc)
    required this.isDefault, // Si es el método predeterminado
  });

  // ID en la base de datos
  final int id;
  // ID del usuario dueño del método de pago
  final int userId;
  // ID del tipo de método de pago
  final int paymentMethodTypeId;
  // True si es el método predeterminado
  final bool isDefault;

  /// Crea una instancia y prepara el estado inicial de `PaymentMethodModel`.
  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: JsonUtils.asInt(json['metodo_pago_id']),
      userId: JsonUtils.asInt(json['usuario_id']),
      paymentMethodTypeId: JsonUtils.asInt(json['tipo_metodo_pago_id']),
      isDefault: JsonUtils.asBool(json['predeterminado']),
    );
  }

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
  Map<String, dynamic> toJson() => {
        'metodo_pago_id': id,
        'usuario_id': userId,
        'tipo_metodo_pago_id': paymentMethodTypeId,
        'predeterminado': isDefault,
      };
}

/// Define la responsabilidad de `CardModel` dentro de este módulo.
class CardModel {
  /// Crea una instancia y prepara el estado inicial de `CardModel`.
  const CardModel({
    required this.id,
    required this.paymentMethodId,
    required this.cardNumber,
    required this.cardBrandId,
    required this.expirationMonth,
    required this.expirationYear,
    required this.cvc,
  });

  final int id;
  final int paymentMethodId;
  final String cardNumber;
  final int cardBrandId;
  final int expirationMonth;
  final int expirationYear;
  final int cvc;

  /// Crea una instancia y prepara el estado inicial de `CardModel`.
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

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
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

/// Define la responsabilidad de `PseModel` dentro de este módulo.
class PseModel {
  /// Crea una instancia y prepara el estado inicial de `PseModel`.
  const PseModel({
    required this.id,
    required this.paymentMethodId,
    required this.bankId,
    required this.personTypeId,
  });

  final int id;
  final int paymentMethodId;
  final int bankId;
  final int personTypeId;

  /// Crea una instancia y prepara el estado inicial de `PseModel`.
  factory PseModel.fromJson(Map<String, dynamic> json) {
    return PseModel(
      id: JsonUtils.asInt(json['pse_id']),
      paymentMethodId: JsonUtils.asInt(json['metodo_pago_id']),
      bankId: JsonUtils.asInt(json['banco_id']),
      personTypeId: JsonUtils.asInt(json['tipo_persona_id']),
    );
  }

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
  Map<String, dynamic> toJson() => {
        'pse_id': id,
        'metodo_pago_id': paymentMethodId,
        'banco_id': bankId,
        'tipo_persona_id': personTypeId,
      };
}

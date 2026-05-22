import 'package:flexidrive/features/payments/domain/ports/repositorio_pagos_puerto.dart';
import 'package:flexidrive/features/payments/domain/entities/payment_models.dart';
import 'package:flexidrive/features/payments/infrastructure/datasources/local_payment_db.dart';

/// Define la responsabilidad de `RepositorioPagosLocal` dentro de este módulo.
class RepositorioPagosLocal implements RepositorioPagosPuerto {
  RepositorioPagosLocal({LocalPaymentDb? origen})
      : _origen = origen ?? LocalPaymentDb.instance;

  final LocalPaymentDb _origen;

  /// Gestiona inicializar dentro de esta parte del flujo.
  @override
  Future<void> inicializar() async {
    await _origen.loadIfNeeded();
  }

  /// Obtiene la información asociada a obtener metodos pago usuario.
  @override
  List<PaymentMethodModel> obtenerMetodosPagoUsuario(int userId) {
    return _origen.getUserPaymentMethods(userId);
  }

  /// Obtiene la información asociada a obtener tarjetas usuario.
  @override
  List<CardModel> obtenerTarjetasUsuario(int userId) {
    return _origen.getUserCards(userId);
  }

  /// Obtiene la información asociada a obtener pse usuario.
  @override
  List<PseModel> obtenerPseUsuario(int userId) {
    return _origen.getUserPseAccounts(userId);
  }

  /// Obtiene la información asociada a obtener metodo pago predeterminado.
  @override
  PaymentMethodModel? obtenerMetodoPagoPredeterminado(int userId) {
    return _origen.getUserDefaultPaymentMethod(userId);
  }

  /// Obtiene la información asociada a obtener metodo pago por id.
  @override
  PaymentMethodModel? obtenerMetodoPagoPorId(int paymentMethodId) {
    return _origen.getPaymentMethodById(paymentMethodId);
  }

  /// Obtiene la información asociada a obtener tarjeta por metodo pago id.
  @override
  CardModel? obtenerTarjetaPorMetodoPagoId(int paymentMethodId) {
    return _origen.getCardByPaymentMethodId(paymentMethodId);
  }

  /// Obtiene la información asociada a obtener pse por metodo pago id.
  @override
  PseModel? obtenerPsePorMetodoPagoId(int paymentMethodId) {
    return _origen.getPseByPaymentMethodId(paymentMethodId);
  }

  /// Obtiene la información asociada a obtener ultimos4 tarjeta.
  @override
  String? obtenerUltimos4Tarjeta(int cardId) {
    return _origen.getCardLast4ById(cardId);
  }

  @override
  Future<PaymentMethodModel> crearMetodoPago({
    required int userId,
    required int paymentMethodTypeId,
    bool isDefault = false,
  }) {
    return _origen.createPaymentMethod(
      userId: userId,
      paymentMethodTypeId: paymentMethodTypeId,
      isDefault: isDefault,
    );
  }

  @override
  Future<CardModel> crearTarjeta({
    required int paymentMethodId,
    required int cardBrandId,
    required int expirationMonth,
    required int expirationYear,
    required String cardNumber,
    required int cvc,
    String? last4,
  }) {
    return _origen.createCard(
      paymentMethodId: paymentMethodId,
      cardBrandId: cardBrandId,
      expirationMonth: expirationMonth,
      expirationYear: expirationYear,
      cardNumber: cardNumber,
      cvc: cvc,
      last4: last4,
    );
  }

  LocalPaymentDb get origen => _origen;
}

import 'package:flexidrive/features/payments/domain/ports/repositorio_pagos_puerto.dart';
import 'package:flexidrive/features/payments/domain/entities/payment_models.dart';
import 'package:flexidrive/features/payments/infrastructure/datasources/local_payment_db.dart';

class RepositorioPagosLocal implements RepositorioPagosPuerto {
  RepositorioPagosLocal({LocalPaymentDb? origen})
      : _origen = origen ?? LocalPaymentDb.instance;

  final LocalPaymentDb _origen;

  @override
  Future<void> inicializar() async {
    await _origen.loadIfNeeded();
  }

  @override
  List<PaymentMethodModel> obtenerMetodosPagoUsuario(int userId) {
    return _origen.getUserPaymentMethods(userId);
  }

  @override
  List<CardModel> obtenerTarjetasUsuario(int userId) {
    return _origen.getUserCards(userId);
  }

  @override
  List<PseModel> obtenerPseUsuario(int userId) {
    return _origen.getUserPseAccounts(userId);
  }

  @override
  PaymentMethodModel? obtenerMetodoPagoPredeterminado(int userId) {
    return _origen.getUserDefaultPaymentMethod(userId);
  }

  @override
  PaymentMethodModel? obtenerMetodoPagoPorId(int paymentMethodId) {
    return _origen.getPaymentMethodById(paymentMethodId);
  }

  @override
  CardModel? obtenerTarjetaPorMetodoPagoId(int paymentMethodId) {
    return _origen.getCardByPaymentMethodId(paymentMethodId);
  }

  @override
  PseModel? obtenerPsePorMetodoPagoId(int paymentMethodId) {
    return _origen.getPseByPaymentMethodId(paymentMethodId);
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
    String? last4,
  }) {
    return _origen.createCard(
      paymentMethodId: paymentMethodId,
      cardBrandId: cardBrandId,
      expirationMonth: expirationMonth,
      expirationYear: expirationYear,
      last4: last4,
    );
  }

  LocalPaymentDb get origen => _origen;
}

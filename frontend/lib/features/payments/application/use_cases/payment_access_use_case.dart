import 'package:flexidrive/features/payments/domain/entities/payment_models.dart';
import 'package:flexidrive/features/payments/domain/ports/repositorio_pagos_puerto.dart';

class PaymentAccessUseCase {
  PaymentAccessUseCase(this._repository);

  final RepositorioPagosPuerto _repository;

  Future<void> loadIfNeeded() => _repository.inicializar();

  List<PaymentMethodModel> getUserPaymentMethods(int userId) {
    return _repository.obtenerMetodosPagoUsuario(userId);
  }

  List<CardModel> getUserCards(int userId) {
    return _repository.obtenerTarjetasUsuario(userId);
  }

  List<PseModel> getUserPseAccounts(int userId) {
    return _repository.obtenerPseUsuario(userId);
  }

  PaymentMethodModel? getUserDefaultPaymentMethod(int userId) {
    return _repository.obtenerMetodoPagoPredeterminado(userId);
  }

  PaymentMethodModel? getPaymentMethodById(int paymentMethodId) {
    return _repository.obtenerMetodoPagoPorId(paymentMethodId);
  }

  CardModel? getCardByPaymentMethodId(int paymentMethodId) {
    return _repository.obtenerTarjetaPorMetodoPagoId(paymentMethodId);
  }

  PseModel? getPseByPaymentMethodId(int paymentMethodId) {
    return _repository.obtenerPsePorMetodoPagoId(paymentMethodId);
  }

  String? getCardLast4(int cardId) {
    return _repository.obtenerUltimos4Tarjeta(cardId);
  }

  Future<PaymentMethodModel> createPaymentMethod({
    required int userId,
    required int paymentMethodTypeId,
    bool isDefault = false,
  }) {
    return _repository.crearMetodoPago(
      userId: userId,
      paymentMethodTypeId: paymentMethodTypeId,
      isDefault: isDefault,
    );
  }

  Future<CardModel> createCard({
    required int paymentMethodId,
    required int cardBrandId,
    required int expirationMonth,
    required int expirationYear,
    required String cardNumber,
    required int cvc,
    String? last4,
  }) {
    return _repository.crearTarjeta(
      paymentMethodId: paymentMethodId,
      cardBrandId: cardBrandId,
      expirationMonth: expirationMonth,
      expirationYear: expirationYear,
      cardNumber: cardNumber,
      cvc: cvc,
      last4: last4,
    );
  }
}

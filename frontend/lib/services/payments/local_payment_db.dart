import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:flexidrive/models/payments/payment_models.dart';

class LocalPaymentDb {
  LocalPaymentDb._();

  static final LocalPaymentDb instance = LocalPaymentDb._();

  bool? _loaded = false;

  final List<PaymentMethodModel> paymentMethods = [];
  final List<CardModel> cards = [];
  final List<PseModel> pses = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    paymentMethods
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/payments/payment_methods.json'),
          PaymentMethodModel.fromJson,
        ),
      );
    cards
      ..clear()
      ..addAll(
        _parseList(await _loadList('assets/data/payments/cards.json'),
            CardModel.fromJson),
      );
    pses
      ..clear()
      ..addAll(
        _parseList(await _loadList('assets/data/payments/pses.json'),
            PseModel.fromJson),
      );

    _loaded = true;
  }

  List<T> _parseList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) parser,
  ) {
    final raw = (source as List<dynamic>? ?? const []);
    return raw.map((item) => parser(item as Map<String, dynamic>)).toList();
  }

  Future<List<dynamic>> _loadList(String assetPath) async {
    final rawJson = await rootBundle.loadString(assetPath);
    return (json.decode(rawJson) as List<dynamic>? ?? const []);
  }

  // Get payment methods for the current user
  List<PaymentMethodModel> getUserPaymentMethods(int userId) {
    return paymentMethods.where((method) => method.userId == userId).toList();
  }

  // Get cards for the current user
  List<CardModel> getUserCards(int userId) {
    final userPaymentMethods = getUserPaymentMethods(userId);
    final userPaymentMethodIds =
        userPaymentMethods.map((method) => method.id).toSet();
    return cards
        .where((card) => userPaymentMethodIds.contains(card.paymentMethodId))
        .toList();
  }

  // Get PSE accounts for the current user
  List<PseModel> getUserPseAccounts(int userId) {
    final userPaymentMethods = getUserPaymentMethods(userId);
    final userPaymentMethodIds =
        userPaymentMethods.map((method) => method.id).toSet();
    return pses
        .where((pse) => userPaymentMethodIds.contains(pse.paymentMethodId))
        .toList();
  }

  // Get default payment method for user
  PaymentMethodModel? getUserDefaultPaymentMethod(int userId) {
    final userMethods = getUserPaymentMethods(userId);
    try {
      return userMethods.firstWhere((method) => method.isDefault);
    } catch (e) {
      return userMethods.isNotEmpty ? userMethods.first : null;
    }
  }

  // Get payment method details by ID
  PaymentMethodModel? getPaymentMethodById(int paymentMethodId) {
    try {
      return paymentMethods
          .firstWhere((method) => method.id == paymentMethodId);
    } catch (e) {
      return null;
    }
  }

  // Get card details by payment method ID
  CardModel? getCardByPaymentMethodId(int paymentMethodId) {
    try {
      return cards
          .firstWhere((card) => card.paymentMethodId == paymentMethodId);
    } catch (e) {
      return null;
    }
  }

  // Get PSE details by payment method ID
  PseModel? getPseByPaymentMethodId(int paymentMethodId) {
    try {
      return pses.firstWhere((pse) => pse.paymentMethodId == paymentMethodId);
    } catch (e) {
      return null;
    }
  }
}

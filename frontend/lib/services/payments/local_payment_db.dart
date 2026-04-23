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
        _parseList(await _loadList('assets/data/payments/cards.json'), CardModel.fromJson),
      );
    pses
      ..clear()
      ..addAll(
        _parseList(await _loadList('assets/data/payments/pses.json'), PseModel.fromJson),
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
}

import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/payment_models.dart';

class LocalPaymentDb {
  LocalPaymentDb._();

  static final LocalPaymentDb instance = LocalPaymentDb._();

  bool? _loaded = false;

  final List<PaymentMethodModel> paymentMethods = [];
  final List<CardModel> cards = [];
  final List<PseModel> pses = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    final rawJson =
        await rootBundle.loadString('assets/data/accounts_payments_data.json');
    final decoded = json.decode(rawJson) as Map<String, dynamic>;

    paymentMethods
      ..clear()
      ..addAll(_parseList(decoded['metodo_pago'], PaymentMethodModel.fromJson));
    cards
      ..clear()
      ..addAll(_parseList(decoded['tarjeta'], CardModel.fromJson));
    pses
      ..clear()
      ..addAll(_parseList(decoded['pse'], PseModel.fromJson));

    _loaded = true;
  }

  List<T> _parseList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) parser,
  ) {
    final raw = (source as List<dynamic>? ?? const []);
    return raw.map((item) => parser(item as Map<String, dynamic>)).toList();
  }
}

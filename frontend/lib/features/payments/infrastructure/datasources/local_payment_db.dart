import 'dart:convert';

import 'package:flexidrive/core/api/api_client.dart';
import 'package:flexidrive/features/payments/domain/entities/payment_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Define la responsabilidad de `LocalPaymentDb` dentro de este módulo.
class LocalPaymentDb {
  /// Crea una instancia y prepara el estado inicial de `LocalPaymentDb`.
  LocalPaymentDb._();

  static final LocalPaymentDb instance = LocalPaymentDb._();
  static const _paymentMethodsOverridesKey = 'payment_methods_overrides_v1';
  static const _cardsOverridesKey = 'payment_cards_overrides_v1';
  static const _cardLast4OverridesKey = 'payment_cards_last4_v1';

  bool? _loaded = false;

  final List<PaymentMethodModel> paymentMethods = [];
  final List<CardModel> cards = [];
  final List<PseModel> pses = [];
  final List<PaymentMethodModel> _createdPaymentMethods = [];
  final List<CardModel> _createdCards = [];
  final Map<int, String> _cardLast4ById = {};

  /// Carga los datos necesarios para cargar if needed.
  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    paymentMethods
      ..clear()
      ..addAll(
        _parseList(
          await _safeLoadList('payment-methods'),
          PaymentMethodModel.fromJson,
        ),
      );
    cards
      ..clear()
      ..addAll(
        _parseList(await _safeLoadList('cards'), CardModel.fromJson),
      );
    pses
      ..clear()
      ..addAll(
        _parseList(await _safeLoadList('pses'), PseModel.fromJson),
      );

    _createdPaymentMethods
      ..clear()
      ..addAll(await _loadPaymentMethodsOverrides());
    _createdCards
      ..clear()
      ..addAll(await _loadCardsOverrides());
    _cardLast4ById
      ..clear()
      ..addAll(await _loadCardLast4Overrides());

    for (final paymentMethod in _createdPaymentMethods) {
      _upsertPaymentMethod(paymentMethod);
    }
    for (final card in _createdCards) {
      _upsertCard(card);
    }

    _loaded = true;
  }

  List<T> _parseList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) parser,
  ) {
    final raw = (source as List<dynamic>? ?? const []);
    return raw.map((item) => parser(item as Map<String, dynamic>)).toList();
  }

  /// Carga los datos necesarios para cargar lista.
  Future<List<dynamic>> _loadList(String endpoint) =>
      ApiClient.instance.getList(endpoint);

  /// Gestiona carga segura de lista dentro de esta parte del flujo.
  Future<List<dynamic>> _safeLoadList(String endpoint) async {
    try {
      return await _loadList(endpoint).timeout(const Duration(seconds: 6));
    } catch (_) {
      return const [];
    }
  }

  /// Obtiene la información asociada a obtener usuario pago methods.
  List<PaymentMethodModel> getUserPaymentMethods(int userId) {
    return paymentMethods.where((method) => method.userId == userId).toList();
  }

  /// Obtiene la información asociada a obtener usuario tarjetas.
  List<CardModel> getUserCards(int userId) {
    final userPaymentMethods = getUserPaymentMethods(userId);
    final userPaymentMethodIds =
        userPaymentMethods.map((method) => method.id).toSet();
    return cards
        .where((card) => userPaymentMethodIds.contains(card.paymentMethodId))
        .toList();
  }

  /// Obtiene la información asociada a obtener usuario pse accounts.
  List<PseModel> getUserPseAccounts(int userId) {
    final userPaymentMethods = getUserPaymentMethods(userId);
    final userPaymentMethodIds =
        userPaymentMethods.map((method) => method.id).toSet();
    return pses
        .where((pse) => userPaymentMethodIds.contains(pse.paymentMethodId))
        .toList();
  }

  /// Obtiene la información asociada a obtener usuario predeterminado pago method.
  PaymentMethodModel? getUserDefaultPaymentMethod(int userId) {
    final userMethods = getUserPaymentMethods(userId);
    try {
      return userMethods.firstWhere((method) => method.isDefault);
    } catch (e) {
      return userMethods.isNotEmpty ? userMethods.first : null;
    }
  }

  /// Obtiene la información asociada a obtener pago method por id.
  PaymentMethodModel? getPaymentMethodById(int paymentMethodId) {
    try {
      return paymentMethods
          .firstWhere((method) => method.id == paymentMethodId);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene la información asociada a obtener tarjeta por pago method id.
  CardModel? getCardByPaymentMethodId(int paymentMethodId) {
    try {
      return cards
          .firstWhere((card) => card.paymentMethodId == paymentMethodId);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene la información asociada a obtener pse por pago method id.
  PseModel? getPseByPaymentMethodId(int paymentMethodId) {
    try {
      return pses.firstWhere((pse) => pse.paymentMethodId == paymentMethodId);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene la información asociada a obtener tarjeta last4 por id.
  String? getCardLast4ById(int cardId) => _cardLast4ById[cardId];

  Future<PaymentMethodModel> createPaymentMethod({
    required int userId,
    required int paymentMethodTypeId,
    bool isDefault = false,
  }) async {
    await loadIfNeeded();
    PaymentMethodModel model;
    try {
      final created = await ApiClient.instance.postMap('payment-methods', {
        'usuario_id': userId,
        'tipo_metodo_pago_id': paymentMethodTypeId,
        'predeterminado': isDefault,
      });
      model = PaymentMethodModel.fromJson(created);
    } catch (_) {
      model = PaymentMethodModel(
        id: _nextPaymentMethodId(),
        userId: userId,
        paymentMethodTypeId: paymentMethodTypeId,
        isDefault: isDefault,
      );
    }

    _upsertPaymentMethod(model);
    _upsertCreatedPaymentMethod(model);
    await _savePaymentMethodsOverrides();
    return model;
  }

  Future<CardModel> createCard({
    required int paymentMethodId,
    required int cardBrandId,
    required int expirationMonth,
    required int expirationYear,
    required String cardNumber,
    required int cvc,
    String? last4,
  }) async {
    await loadIfNeeded();
    final inputDigits = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final normalizedInputNumber =
        inputDigits.isEmpty ? cardNumber : inputDigits;
    final inputLast4 = inputDigits.length >= 4
        ? inputDigits.substring(inputDigits.length - 4)
        : (last4 ?? '');
    CardModel model;
    try {
      final created = await ApiClient.instance.postMap('cards', {
        'metodo_pago_id': paymentMethodId,
        'marca_tarjeta_id': cardBrandId,
        'mes_expiracion': expirationMonth,
        'ano_expiracion': expirationYear,
        'numero_tarjeta': cardNumber,
        'cvc': cvc,
      });
      final parsed = CardModel.fromJson(created);
      final parsedDigits = parsed.cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final parsedLooksMaskedOrInvalid =
          parsedDigits.length < 12 || RegExp(r'^0+$').hasMatch(parsedDigits);
      final resolvedCardNumber =
          (parsed.cardNumber.trim().isEmpty || parsedLooksMaskedOrInvalid)
              ? normalizedInputNumber
              : parsed.cardNumber;
      final resolvedBrandId =
          parsed.cardBrandId <= 0 ? cardBrandId : parsed.cardBrandId;
      model = CardModel(
        id: parsed.id,
        paymentMethodId: paymentMethodId,
        cardNumber: resolvedCardNumber,
        cardBrandId: resolvedBrandId,
        expirationMonth: parsed.expirationMonth,
        expirationYear: parsed.expirationYear,
        cvc: parsed.cvc,
      );
    } catch (_) {
      final resolvedCardNumber = normalizedInputNumber.isEmpty
          ? last4 ?? cardNumber
          : normalizedInputNumber;
      model = CardModel(
        id: _nextCardId(),
        paymentMethodId: paymentMethodId,
        cardNumber: resolvedCardNumber,
        cardBrandId: cardBrandId,
        expirationMonth: expirationMonth,
        expirationYear: expirationYear,
        cvc: cvc,
      );
    }

    _upsertCard(model);
    _upsertCreatedCard(model);
    final resolvedLast4 = _resolveLast4(
      explicitLast4: inputLast4,
      cardNumber: model.cardNumber,
    );
    if (resolvedLast4.isNotEmpty) {
      _cardLast4ById[model.id] = resolvedLast4;
      await _saveCardLast4Overrides();
    }
    await _saveCardsOverrides();
    return model;
  }

  String _resolveLast4({
    required String explicitLast4,
    required String cardNumber,
  }) {
    final normalizedExplicit = explicitLast4.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalizedExplicit.length >= 4) {
      return normalizedExplicit.substring(normalizedExplicit.length - 4);
    }
    final digits = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 4) return digits.substring(digits.length - 4);
    return '';
  }

  /// Gestiona upsert pago method dentro de esta parte del flujo.
  void _upsertPaymentMethod(PaymentMethodModel model) {
    final index = paymentMethods.indexWhere((item) => item.id == model.id);
    if (index == -1) {
      paymentMethods.add(model);
    } else {
      paymentMethods[index] = model;
    }
  }

  /// Gestiona upsert tarjeta dentro de esta parte del flujo.
  void _upsertCard(CardModel model) {
    final index = cards.indexWhere((item) => item.id == model.id);
    if (index == -1) {
      cards.add(model);
    } else {
      cards[index] = model;
    }
  }

  /// Gestiona upsert created pago method dentro de esta parte del flujo.
  void _upsertCreatedPaymentMethod(PaymentMethodModel model) {
    final index =
        _createdPaymentMethods.indexWhere((item) => item.id == model.id);
    if (index == -1) {
      _createdPaymentMethods.add(model);
    } else {
      _createdPaymentMethods[index] = model;
    }
  }

  /// Gestiona upsert created tarjeta dentro de esta parte del flujo.
  void _upsertCreatedCard(CardModel model) {
    final index = _createdCards.indexWhere((item) => item.id == model.id);
    if (index == -1) {
      _createdCards.add(model);
    } else {
      _createdCards[index] = model;
    }
  }

  /// Gestiona siguiente pago method id dentro de esta parte del flujo.
  int _nextPaymentMethodId() {
    if (paymentMethods.isEmpty) return 1;
    return paymentMethods
            .map((item) => item.id)
            .reduce((current, next) => current > next ? current : next) +
        1;
  }

  /// Gestiona siguiente tarjeta id dentro de esta parte del flujo.
  int _nextCardId() {
    if (cards.isEmpty) return 1;
    return cards
            .map((item) => item.id)
            .reduce((current, next) => current > next ? current : next) +
        1;
  }

  /// Carga los cambios locales sobrescritos de pago methods.
  Future<List<PaymentMethodModel>> _loadPaymentMethodsOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_paymentMethodsOverridesKey);
    if (raw == null || raw.isEmpty) return <PaymentMethodModel>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <PaymentMethodModel>[];
      return decoded
          .whereType<Map>()
          .map(
            (item) => PaymentMethodModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } catch (_) {
      return <PaymentMethodModel>[];
    }
  }

  /// Carga los cambios locales sobrescritos de tarjetas.
  Future<List<CardModel>> _loadCardsOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cardsOverridesKey);
    if (raw == null || raw.isEmpty) return <CardModel>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <CardModel>[];
      return decoded
          .whereType<Map>()
          .map(
            (item) => CardModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } catch (_) {
      return <CardModel>[];
    }
  }

  /// Carga los cambios locales sobrescritos de tarjeta last4.
  Future<Map<int, String>> _loadCardLast4Overrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cardLast4OverridesKey);
    if (raw == null || raw.isEmpty) return <int, String>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <int, String>{};
      final result = <int, String>{};
      decoded.forEach((key, value) {
        final id = int.tryParse(key.toString());
        final last4 = value?.toString() ?? '';
        if (id != null && id > 0 && last4.isNotEmpty) {
          result[id] = last4;
        }
      });
      return result;
    } catch (_) {
      return <int, String>{};
    }
  }

  /// Guardar pago methods cambios locales esta parte del flujo de trabajo.
  Future<void> _savePaymentMethodsOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final created = _createdPaymentMethods
        .map((paymentMethod) => paymentMethod.toJson())
        .toList();
    await prefs.setString(_paymentMethodsOverridesKey, jsonEncode(created));
  }

  /// Guardar tarjetas cambios locales esta parte del flujo de trabajo.
  Future<void> _saveCardsOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final created = _createdCards.map((card) => card.toJson()).toList();
    await prefs.setString(_cardsOverridesKey, jsonEncode(created));
  }

  /// Guardar tarjeta last4 cambios locales esta parte del flujo de trabajo.
  Future<void> _saveCardLast4Overrides() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = <String, String>{};
    _cardLast4ById.forEach((key, value) {
      if (key > 0 && value.isNotEmpty) {
        encoded['$key'] = value;
      }
    });
    await prefs.setString(_cardLast4OverridesKey, jsonEncode(encoded));
  }
}

import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:flexidrive/models/catalogs/catalog_models.dart';

class LocalCatalogDb {
  LocalCatalogDb._();

  static final LocalCatalogDb instance = LocalCatalogDb._();

  bool? _loaded = false;

  final List<IdentificationTypeModel> identificationTypes = [];
  final List<UserTypeModel> userTypes = [];
  final List<PaymentMethodTypeModel> paymentMethodTypes = [];
  final List<BankModel> banks = [];
  final List<CardBrandModel> cardBrands = [];
  final List<PersonTypeModel> personTypes = [];
  final List<VehicleCategoryModel> vehicleCategories = [];
  final List<PeriodTypeModel> periodTypes = [];
  final List<ReservationStatusModel> reservationStatuses = [];
  final List<NotificationCategoryModel> notificationCategories = [];
  final List<LandlordDocumentTypeModel> landlordDocumentTypes = [];
  final List<DocumentVerificationStatusModel> documentVerificationStatuses = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    identificationTypes
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/catalogs/identification_types.json'),
          IdentificationTypeModel.fromJson,
        ),
      );
    userTypes
      ..clear()
      ..addAll(
        _parseList(await _loadList('assets/data/catalogs/user_types.json'), UserTypeModel.fromJson),
      );
    paymentMethodTypes
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/catalogs/payment_method_types.json'),
          PaymentMethodTypeModel.fromJson,
        ),
      );
    banks
      ..clear()
      ..addAll(_parseList(await _loadList('assets/data/catalogs/banks.json'), BankModel.fromJson));
    cardBrands
      ..clear()
      ..addAll(
        _parseList(await _loadList('assets/data/catalogs/card_brands.json'), CardBrandModel.fromJson),
      );
    personTypes
      ..clear()
      ..addAll(
        _parseList(await _loadList('assets/data/catalogs/person_types.json'), PersonTypeModel.fromJson),
      );
    vehicleCategories
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/catalogs/vehicle_categories.json'),
          VehicleCategoryModel.fromJson,
        ),
      );
    periodTypes
      ..clear()
      ..addAll(
        _parseList(await _loadList('assets/data/catalogs/period_types.json'), PeriodTypeModel.fromJson),
      );
    reservationStatuses
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/catalogs/reservation_statuses.json'),
          ReservationStatusModel.fromJson,
        ),
      );
    notificationCategories
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/catalogs/notification_categories.json'),
          NotificationCategoryModel.fromJson,
        ),
      );
    landlordDocumentTypes
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/catalogs/landlord_document_types.json'),
          LandlordDocumentTypeModel.fromJson,
        ),
      );
    documentVerificationStatuses
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/catalogs/document_verification_statuses.json'),
          DocumentVerificationStatusModel.fromJson,
        ),
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

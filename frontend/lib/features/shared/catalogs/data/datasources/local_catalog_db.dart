import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/catalog_models.dart';

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

    final rawJson = await rootBundle.loadString('assets/data/catalogs_data.json');
    final decoded = json.decode(rawJson) as Map<String, dynamic>;

    identificationTypes
      ..clear()
      ..addAll(_parseList(decoded['tipo_identificacion'], IdentificationTypeModel.fromJson));
    userTypes
      ..clear()
      ..addAll(_parseList(decoded['tipo_usuario'], UserTypeModel.fromJson));
    paymentMethodTypes
      ..clear()
      ..addAll(_parseList(decoded['tipo_metodo_pago'], PaymentMethodTypeModel.fromJson));
    banks
      ..clear()
      ..addAll(_parseList(decoded['banco'], BankModel.fromJson));
    cardBrands
      ..clear()
      ..addAll(_parseList(decoded['marca_tarjeta'], CardBrandModel.fromJson));
    personTypes
      ..clear()
      ..addAll(_parseList(decoded['tipo_persona'], PersonTypeModel.fromJson));
    vehicleCategories
      ..clear()
      ..addAll(_parseList(decoded['categoria_vehiculo'], VehicleCategoryModel.fromJson));
    periodTypes
      ..clear()
      ..addAll(_parseList(decoded['tipo_periodo'], PeriodTypeModel.fromJson));
    reservationStatuses
      ..clear()
      ..addAll(_parseList(decoded['estado_reserva'], ReservationStatusModel.fromJson));
    notificationCategories
      ..clear()
      ..addAll(_parseList(decoded['categoria_notificacion'], NotificationCategoryModel.fromJson));
    landlordDocumentTypes
      ..clear()
      ..addAll(_parseList(decoded['tipo_documento_arrendador'], LandlordDocumentTypeModel.fromJson));
    documentVerificationStatuses
      ..clear()
      ..addAll(_parseList(decoded['estado_verificacion_documento'], DocumentVerificationStatusModel.fromJson));

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

import 'package:flexidrive/core/api/api_client.dart';
import 'package:flexidrive/features/catalogs/domain/entities/catalog_models.dart';

class LocalCatalogDb {
  LocalCatalogDb._();

  static final LocalCatalogDb instance = LocalCatalogDb._();
  static const _hiddenIdentificationTypeNames = {
    'Documento Regional',
    'Documento Consular',
    'Documento Mercosur',
    'Documento Schengen',
    'Documento Fronterizo',
  };

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
          await _loadList('identification-types'),
          IdentificationTypeModel.fromJson,
        ).where(
          (type) => !_hiddenIdentificationTypeNames.contains(type.name),
        ),
      );
    userTypes
      ..clear()
      ..addAll(
        _parseList(await _loadList('user-types'), UserTypeModel.fromJson),
      );
    paymentMethodTypes
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('payment-method-types'),
          PaymentMethodTypeModel.fromJson,
        ),
      );
    banks
      ..clear()
      ..addAll(_parseList(await _loadList('banks'), BankModel.fromJson));
    cardBrands
      ..clear()
      ..addAll(
        _parseList(await _loadList('card-brands'), CardBrandModel.fromJson),
      );
    personTypes
      ..clear()
      ..addAll(
        _parseList(await _loadList('person-types'), PersonTypeModel.fromJson),
      );
    vehicleCategories
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('vehicle-categories'),
          VehicleCategoryModel.fromJson,
        ),
      );
    periodTypes
      ..clear()
      ..addAll(
        _parseList(await _loadList('period-types'), PeriodTypeModel.fromJson),
      );
    reservationStatuses
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('reservation-statuses'),
          ReservationStatusModel.fromJson,
        ),
      );
    notificationCategories
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('notification-categories'),
          NotificationCategoryModel.fromJson,
        ),
      );
    landlordDocumentTypes
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('landlord-document-types'),
          LandlordDocumentTypeModel.fromJson,
        ),
      );
    documentVerificationStatuses
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('document-verification-statuses'),
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

  Future<List<dynamic>> _loadList(String endpoint) =>
      ApiClient.instance.getList(endpoint);
}

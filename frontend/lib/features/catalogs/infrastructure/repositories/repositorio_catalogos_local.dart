import 'package:flexidrive/features/catalogs/domain/ports/repositorio_catalogos_puerto.dart';
import 'package:flexidrive/features/catalogs/domain/entities/catalog_models.dart';
import 'package:flexidrive/features/catalogs/infrastructure/datasources/local_catalog_db.dart';

class RepositorioCatalogosLocal implements RepositorioCatalogosPuerto {
  RepositorioCatalogosLocal({LocalCatalogDb? origen})
      : _origen = origen ?? LocalCatalogDb.instance;

  final LocalCatalogDb _origen;

  @override
  Future<void> inicializar() async {
    await _origen.loadIfNeeded();
  }

  @override
  List<IdentificationTypeModel> obtenerTiposIdentificacion() {
    return _origen.identificationTypes;
  }

  @override
  List<UserTypeModel> obtenerTiposUsuario() => _origen.userTypes;

  @override
  List<PaymentMethodTypeModel> obtenerTiposMetodoPago() {
    return _origen.paymentMethodTypes;
  }

  @override
  List<BankModel> obtenerBancos() => _origen.banks;

  @override
  List<CardBrandModel> obtenerMarcasTarjeta() => _origen.cardBrands;

  @override
  List<PersonTypeModel> obtenerTiposPersona() => _origen.personTypes;

  @override
  List<VehicleCategoryModel> obtenerCategoriasVehiculo() {
    return _origen.vehicleCategories;
  }

  @override
  List<PeriodTypeModel> obtenerTiposPeriodo() => _origen.periodTypes;

  @override
  List<ReservationStatusModel> obtenerEstadosReserva() {
    return _origen.reservationStatuses;
  }

  @override
  List<NotificationCategoryModel> obtenerCategoriasNotificacion() {
    return _origen.notificationCategories;
  }

  LocalCatalogDb get origen => _origen;
}

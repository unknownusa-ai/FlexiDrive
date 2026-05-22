import 'package:flexidrive/features/catalogs/domain/ports/repositorio_catalogos_puerto.dart';
import 'package:flexidrive/features/catalogs/domain/entities/catalog_models.dart';
import 'package:flexidrive/features/catalogs/infrastructure/datasources/local_catalog_db.dart';

/// Define la responsabilidad de `RepositorioCatalogosLocal` dentro de este módulo.
class RepositorioCatalogosLocal implements RepositorioCatalogosPuerto {
  RepositorioCatalogosLocal({LocalCatalogDb? origen})
      : _origen = origen ?? LocalCatalogDb.instance;

  final LocalCatalogDb _origen;

  /// Gestiona inicializar dentro de esta parte del flujo.
  @override
  Future<void> inicializar() async {
    await _origen.loadIfNeeded();
  }

  /// Obtiene la información asociada a obtener tipos identificacion.
  @override
  List<IdentificationTypeModel> obtenerTiposIdentificacion() {
    return _origen.identificationTypes;
  }

  /// Obtiene la información asociada a obtener tipos usuario.
  @override
  List<UserTypeModel> obtenerTiposUsuario() => _origen.userTypes;

  /// Obtiene la información asociada a obtener tipos metodo pago.
  @override
  List<PaymentMethodTypeModel> obtenerTiposMetodoPago() {
    return _origen.paymentMethodTypes;
  }

  /// Obtiene la información asociada a obtener bancos.
  @override
  List<BankModel> obtenerBancos() => _origen.banks;

  /// Obtiene la información asociada a obtener marcas tarjeta.
  @override
  List<CardBrandModel> obtenerMarcasTarjeta() => _origen.cardBrands;

  /// Obtiene la información asociada a obtener tipos persona.
  @override
  List<PersonTypeModel> obtenerTiposPersona() => _origen.personTypes;

  /// Obtiene la información asociada a obtener categorias vehiculo.
  @override
  List<VehicleCategoryModel> obtenerCategoriasVehiculo() {
    return _origen.vehicleCategories;
  }

  /// Obtiene la información asociada a obtener tipos periodo.
  @override
  List<PeriodTypeModel> obtenerTiposPeriodo() => _origen.periodTypes;

  /// Obtiene la información asociada a obtener estados reserva.
  @override
  List<ReservationStatusModel> obtenerEstadosReserva() {
    return _origen.reservationStatuses;
  }

  /// Obtiene la información asociada a obtener categorias notificacion.
  @override
  List<NotificationCategoryModel> obtenerCategoriasNotificacion() {
    return _origen.notificationCategories;
  }

  LocalCatalogDb get origen => _origen;
}

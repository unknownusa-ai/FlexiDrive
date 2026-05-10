import 'package:flexidrive/features/catalogs/domain/entities/catalog_models.dart';

abstract class RepositorioCatalogosPuerto {
  Future<void> inicializar();
  List<IdentificationTypeModel> obtenerTiposIdentificacion();
  List<UserTypeModel> obtenerTiposUsuario();
  List<PaymentMethodTypeModel> obtenerTiposMetodoPago();
  List<BankModel> obtenerBancos();
  List<CardBrandModel> obtenerMarcasTarjeta();
  List<PersonTypeModel> obtenerTiposPersona();
  List<VehicleCategoryModel> obtenerCategoriasVehiculo();
  List<PeriodTypeModel> obtenerTiposPeriodo();
  List<ReservationStatusModel> obtenerEstadosReserva();
  List<NotificationCategoryModel> obtenerCategoriasNotificacion();
}

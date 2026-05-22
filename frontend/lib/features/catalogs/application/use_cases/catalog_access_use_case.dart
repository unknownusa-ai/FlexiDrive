import 'package:flexidrive/features/catalogs/domain/entities/catalog_models.dart';
import 'package:flexidrive/features/catalogs/domain/ports/repositorio_catalogos_puerto.dart';

/// Define la responsabilidad de `CatalogAccessUseCase` dentro de este módulo.
class CatalogAccessUseCase {
  /// Crea una instancia y prepara el estado inicial de `CatalogAccessUseCase`.
  CatalogAccessUseCase(this._repository);

  final RepositorioCatalogosPuerto _repository;

  /// Carga los datos necesarios para cargar if needed.
  Future<void> loadIfNeeded() => _repository.inicializar();

  List<IdentificationTypeModel> get identificationTypes {
    return _repository.obtenerTiposIdentificacion();
  }

  List<UserTypeModel> get userTypes => _repository.obtenerTiposUsuario();

  List<PaymentMethodTypeModel> get paymentMethodTypes {
    return _repository.obtenerTiposMetodoPago();
  }

  List<BankModel> get banks => _repository.obtenerBancos();

  List<CardBrandModel> get cardBrands => _repository.obtenerMarcasTarjeta();

  List<PersonTypeModel> get personTypes => _repository.obtenerTiposPersona();

  List<VehicleCategoryModel> get vehicleCategories {
    return _repository.obtenerCategoriasVehiculo();
  }

  List<PeriodTypeModel> get periodTypes => _repository.obtenerTiposPeriodo();

  List<ReservationStatusModel> get reservationStatuses {
    return _repository.obtenerEstadosReserva();
  }

  List<NotificationCategoryModel> get notificationCategories {
    return _repository.obtenerCategoriasNotificacion();
  }
}

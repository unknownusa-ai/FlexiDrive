import 'package:flexidrive/features/accounts/application/use_cases/account_access_use_case.dart';
import 'package:flexidrive/features/accounts/application/use_cases/user_preferences_use_case.dart';
import 'package:flexidrive/features/accounts/domain/ports/repositorio_cuentas_puerto.dart';
import 'package:flexidrive/features/accounts/domain/ports/user_preferences_repository_port.dart';
import 'package:flexidrive/features/accounts/infrastructure/repositories/repositorio_cuentas_local.dart';
import 'package:flexidrive/features/accounts/infrastructure/repositories/user_preferences_repository_impl.dart';

import 'package:flexidrive/features/auth/domain/ports/auth_repository_port.dart';
import 'package:flexidrive/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:flexidrive/features/auth/application/use_cases/auth_use_cases.dart';

import 'package:flexidrive/features/profile/domain/ports/profile_repository_port.dart';
import 'package:flexidrive/features/profile/infrastructure/repositories/profile_repository_impl.dart';
import 'package:flexidrive/features/profile/application/use_cases/profile_use_cases.dart';

import 'package:flexidrive/features/splash/domain/ports/config_repository_port.dart';
import 'package:flexidrive/features/splash/infrastructure/repositories/config_repository_impl.dart';
import 'package:flexidrive/features/splash/application/use_cases/splash_use_cases.dart';

import 'package:flexidrive/features/onboarding/domain/ports/onboarding_repository_port.dart';
import 'package:flexidrive/features/onboarding/infrastructure/repositories/onboarding_repository_impl.dart';
import 'package:flexidrive/features/onboarding/application/use_cases/onboarding_use_cases.dart';

import 'package:flexidrive/features/home/domain/ports/home_repository_port.dart';
import 'package:flexidrive/features/home/infrastructure/repositories/home_repository_impl.dart';
import 'package:flexidrive/features/home/application/use_cases/home_use_cases.dart';

import 'package:flexidrive/features/catalogs/application/use_cases/catalog_access_use_case.dart';
import 'package:flexidrive/features/catalogs/domain/ports/repositorio_catalogos_puerto.dart';
import 'package:flexidrive/features/catalogs/infrastructure/repositories/repositorio_catalogos_local.dart';
import 'package:flexidrive/features/notifications/application/use_cases/notification_access_use_case.dart';
import 'package:flexidrive/features/notifications/domain/ports/repositorio_notificaciones_puerto.dart';
import 'package:flexidrive/features/notifications/infrastructure/repositories/repositorio_notificaciones_local.dart';
import 'package:flexidrive/features/payments/application/use_cases/payment_access_use_case.dart';
import 'package:flexidrive/features/payments/domain/ports/repositorio_pagos_puerto.dart';
import 'package:flexidrive/features/payments/infrastructure/repositories/repositorio_pagos_local.dart';
import 'package:flexidrive/features/publications/application/use_cases/publication_access_use_case.dart';
import 'package:flexidrive/features/publications/domain/ports/repositorio_publicaciones_puerto.dart';
import 'package:flexidrive/features/publications/infrastructure/repositories/repositorio_publicaciones_local.dart';
import 'package:flexidrive/features/reservations/application/use_cases/reservation_access_use_case.dart';
import 'package:flexidrive/features/reservations/domain/ports/repositorio_reservas_puerto.dart';
import 'package:flexidrive/features/reservations/infrastructure/repositories/repositorio_reservas_local.dart';
import 'package:flexidrive/features/reviews/application/use_cases/review_access_use_case.dart';
import 'package:flexidrive/features/reviews/domain/ports/repositorio_resenas_puerto.dart';
import 'package:flexidrive/features/reviews/infrastructure/repositories/repositorio_resenas_local.dart';
import 'package:flexidrive/features/security/application/use_cases/security_access_use_case.dart';
import 'package:flexidrive/features/security/domain/ports/repositorio_seguridad_puerto.dart';
import 'package:flexidrive/features/security/infrastructure/repositories/repositorio_seguridad_local.dart';
import 'package:flexidrive/features/vehicles/application/use_cases/vehicle_catalog_use_case.dart';
import 'package:flexidrive/features/vehicles/application/use_cases/vehicle_inventory_use_case.dart';
import 'package:flexidrive/features/vehicles/domain/ports/vehicle_catalog_repository_port.dart';
import 'package:flexidrive/features/vehicles/domain/ports/repositorio_vehiculos_puerto.dart';
import 'package:flexidrive/features/vehicles/infrastructure/repositories/vehicle_catalog_repository_impl.dart';
import 'package:flexidrive/features/vehicles/infrastructure/repositories/repositorio_vehiculos_local.dart';

/// Composition root del frontend.
///
/// Este archivo es la pieza central de la arquitectura hexagonal en Flutter:
///
/// - Infraestructura: crea implementaciones concretas de repositorios.
/// - Dominio: esas implementaciones satisfacen puertos (`domain/ports`).
/// - Aplicación: construye casos de uso sobre dichos puertos.
/// - Presentación: páginas/widgets consumen casos de uso ya resueltos aquí.
///
/// Regla importante para mantener desacoplamiento:
/// la UI no debería instanciar repositorios concretos por su cuenta.
class InjectionContainer {
  /// Crea una instancia y prepara el estado inicial de `InjectionContainer`.
  InjectionContainer._();

  static final InjectionContainer instance = InjectionContainer._();

  // ===================== INFRASTRUCTURE ADAPTERS =====================
  // Implementaciones concretas que cumplen puertos de dominio.
  late final RepositorioCuentasPuerto _accountRepository =
      RepositorioCuentasLocal();
  late final RepositorioVehiculosPuerto _vehicleRepository =
      RepositorioVehiculosLocal();
  late final RepositorioPublicacionesPuerto _publicationRepository =
      RepositorioPublicacionesLocal();
  late final RepositorioResenasPuerto _reviewRepository =
      RepositorioResenasLocal();
  late final RepositorioReservasPuerto _reservationRepository =
      RepositorioReservasLocal();
  late final RepositorioCatalogosPuerto _catalogRepository =
      RepositorioCatalogosLocal();
  late final RepositorioPagosPuerto _paymentRepository =
      RepositorioPagosLocal();
  late final RepositorioNotificacionesPuerto _notificationRepository =
      RepositorioNotificacionesLocal();
  late final RepositorioSeguridadPuerto _securityRepository =
      RepositorioSeguridadLocal();
  late final UserPreferencesRepositoryPort _userPreferencesRepository =
      UserPreferencesRepositoryImpl();
  late final VehicleCatalogRepositoryPort _vehicleCatalogRepository =
      VehicleCatalogRepositoryImpl();

  // ========================== APPLICATION ============================
  // Casos de uso que orquestan reglas y son consumidos por presentación.
  late final AccountAccessUseCase accountAccessUseCase =
      AccountAccessUseCase(_accountRepository);
  late final UserPreferencesUseCase userPreferencesUseCase =
      UserPreferencesUseCase(_userPreferencesRepository);
  late final VehicleInventoryUseCase vehicleInventoryUseCase =
      VehicleInventoryUseCase(_vehicleRepository);
  late final VehicleCatalogUseCase vehicleCatalogUseCase =
      VehicleCatalogUseCase(_vehicleCatalogRepository);
  late final PublicationAccessUseCase publicationAccessUseCase =
      PublicationAccessUseCase(_publicationRepository);
  late final ReviewAccessUseCase reviewAccessUseCase =
      ReviewAccessUseCase(_reviewRepository);
  late final ReservationAccessUseCase reservationAccessUseCase =
      ReservationAccessUseCase(_reservationRepository);
  late final CatalogAccessUseCase catalogAccessUseCase =
      CatalogAccessUseCase(_catalogRepository);
  late final PaymentAccessUseCase paymentAccessUseCase =
      PaymentAccessUseCase(_paymentRepository);
  late final NotificationAccessUseCase notificationAccessUseCase =
      NotificationAccessUseCase(_notificationRepository);
  late final SecurityAccessUseCase securityAccessUseCase =
      SecurityAccessUseCase(_securityRepository);

  late final AuthRepositoryPort _authRepository = AuthRepositoryImpl();
  late final LoginUseCase authLoginUseCase = LoginUseCase(_authRepository);
  late final LogoutUseCase authLogoutUseCase = LogoutUseCase(_authRepository);
  late final CheckAuthStatusUseCase authCheckStatusUseCase =
      CheckAuthStatusUseCase(_authRepository);
  late final GetCurrentSessionUseCase authGetCurrentSessionUseCase =
      GetCurrentSessionUseCase(_authRepository);

  late final ProfileRepositoryPort _profileRepository = ProfileRepositoryImpl();
  late final GetProfileUseCase profileGetUseCase =
      GetProfileUseCase(_profileRepository);
  late final UpdateProfileUseCase profileUpdateUseCase =
      UpdateProfileUseCase(_profileRepository);
  late final UpdateAvatarUseCase profileUpdateAvatarUseCase =
      UpdateAvatarUseCase(_profileRepository);
  late final GetProfileStatsUseCase profileGetStatsUseCase =
      GetProfileStatsUseCase(_profileRepository);
  late final ToggleUserModeUseCase profileToggleModeUseCase =
      ToggleUserModeUseCase(_profileRepository);
  late final UpdatePasswordUseCase profileUpdatePasswordUseCase =
      UpdatePasswordUseCase(_profileRepository);

  late final ConfigRepositoryPort _configRepository = ConfigRepositoryImpl();
  late final CheckFirstLaunchUseCase splashCheckFirstLaunchUseCase =
      CheckFirstLaunchUseCase(_configRepository);
  late final CompleteOnboardingUseCase splashCompleteOnboardingUseCase =
      CompleteOnboardingUseCase(_configRepository);
  late final GetInitialRouteUseCase splashGetInitialRouteUseCase =
      GetInitialRouteUseCase(configRepository: _configRepository);
  late final GetAppConfigUseCase splashGetAppConfigUseCase =
      GetAppConfigUseCase(_configRepository);

  late final OnboardingRepositoryPort _onboardingRepository =
      OnboardingRepositoryImpl();
  late final GetOnboardingStepsUseCase onboardingGetStepsUseCase =
      GetOnboardingStepsUseCase(_onboardingRepository);
  late final GetOnboardingContentUseCase onboardingGetContentUseCase =
      GetOnboardingContentUseCase(_onboardingRepository);
  late final CompleteOnboardingStepUseCase onboardingCompleteStepUseCase =
      CompleteOnboardingStepUseCase(_onboardingRepository);
  late final SkipOnboardingUseCase onboardingSkipUseCase =
      SkipOnboardingUseCase(_onboardingRepository);
  late final IsOnboardingCompletedUseCase onboardingIsCompletedUseCase =
      IsOnboardingCompletedUseCase(_onboardingRepository);

  late final HomeRepositoryPort _homeRepository = HomeRepositoryImpl();
  late final GetHomeContentUseCase homeGetContentUseCase =
      GetHomeContentUseCase(_homeRepository);
  late final GetVisibleSectionsUseCase homeGetVisibleSectionsUseCase =
      GetVisibleSectionsUseCase(_homeRepository);
  late final GetUserGreetingUseCase homeGetUserGreetingUseCase =
      GetUserGreetingUseCase(_homeRepository);
  late final CheckNewNotificationsUseCase homeCheckNewNotificationsUseCase =
      CheckNewNotificationsUseCase(_homeRepository);
  late final RefreshHomeContentUseCase homeRefreshContentUseCase =
      RefreshHomeContentUseCase(_homeRepository);

  /// Inicializa dependencias críticas para dejar la app lista.
  ///
  /// Se ejecuta al arranque para cargar catálogos, caches y fuentes locales
  /// que necesitan estar preparadas antes de la navegación principal.
  Future<void> warmUp() async {
    await Future.wait([
      _accountRepository.inicializar(),
      _vehicleRepository.inicializar(),
      _publicationRepository.inicializar(),
      _reviewRepository.inicializar(),
      _reservationRepository.inicializar(),
      _catalogRepository.inicializar(),
      _paymentRepository.inicializar(),
      _notificationRepository.inicializar(),
      _securityRepository.inicializar(),
      _userPreferencesRepository.initialize(),
      _vehicleCatalogRepository.loadIfNeeded(),
      // Initialize new hexagonal repositories
      _authRepository.initialize(),
      _profileRepository.initialize(),
      _configRepository.initialize(),
      _onboardingRepository.initialize(),
      _homeRepository.initialize(),
    ]);
  }
}

// Importamos Flutter - lo básico para la UI
import 'dart:async';

import 'package:flutter/material.dart';
// Fuentes bonitas de Google
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Mapa real (OpenStreetMap) para el explorador estilo InDrive
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// El menú principal con las pestañas
import 'package:flexidrive/features/home/presentation/pages/main_page.dart';
// Para saber quién está logueado
import 'package:flexidrive/features/accounts/application/use_cases/account_access_use_case.dart';
// Base de datos local de usuarios
// Utilidades para pantallas pequeñas/grandes
import 'package:flexidrive/core/utils/responsive_utils.dart';
// Página de detalle cuando tocan un carro
import 'package:flexidrive/features/reservations/presentation/pages/reservas/reserva_detalle_page.dart';
// Servicio que carga los carros desde JSON
import 'package:flexidrive/features/vehicles/application/use_cases/vehicle_inventory_use_case.dart';
// Publicaciones de renta
import 'package:flexidrive/features/publications/application/use_cases/publication_access_use_case.dart';
// Sistema de reseñas y calificaciones
import 'package:flexidrive/features/reviews/application/use_cases/review_access_use_case.dart';
// Reservas que hacen los usuarios
import 'package:flexidrive/features/reservations/application/use_cases/reservation_access_use_case.dart';
import 'package:flexidrive/features/notifications/application/use_cases/notification_access_use_case.dart';
import 'package:flexidrive/features/catalogs/application/use_cases/catalog_access_use_case.dart';
import 'package:flexidrive/injection_container.dart';
import 'package:flexidrive/core/widgets/flexi_vehicle_image.dart';
import 'package:flexidrive/core/utils/vehicle_image_resolver.dart';
import 'package:flexidrive/core/utils/colombia_time.dart';
// Modelos de datos de publicaciones
import 'package:flexidrive/features/publications/domain/entities/publication_models.dart';
// Modelos de reseñas
import 'package:flexidrive/features/reviews/domain/entities/review_models.dart';

// Página principal - lo primero que ve el usuario
class HomePage extends StatefulWidget {
  /// Crea una instancia y prepara el estado inicial de `HomePage`.
  const HomePage({super.key});

  /// Gestiona crear estado dentro de esta parte del flujo.
  @override
  State<HomePage> createState() => _HomePageState();
}

// Estado de la página principal
class _HomePageState extends State<HomePage> {
  static const String _allCitiesOption = 'Todas las ciudades';
  static const _reminderKeysStorage = 'reservation_reminder_keys_v1';
  // Repositorio para manejar usuarios
  final AccountAccessUseCase _accountRepository =
      InjectionContainer.instance.accountAccessUseCase;
  // DB local de cuentas
  // DB de publicaciones
  final PublicationAccessUseCase _publicationDb =
      InjectionContainer.instance.publicationAccessUseCase;
  // DB de reseñas
  final ReviewAccessUseCase _reviewDb =
      InjectionContainer.instance.reviewAccessUseCase;
  // DB de reservas
  final ReservationAccessUseCase _reservationDb =
      InjectionContainer.instance.reservationAccessUseCase;
  final NotificationAccessUseCase _notificationDb =
      InjectionContainer.instance.notificationAccessUseCase;
  final CatalogAccessUseCase _catalogDb =
      InjectionContainer.instance.catalogAccessUseCase;

  // Filtro por categoría de carro
  String _selectedCategory = 'Todos';
  // Ciudad seleccionada para buscar carros
  String _selectedCity = _allCitiesOption;
  // Nombre del usuario que está usando la app
  String _currentUserName = 'Invitado';

  // Controlador del campo de búsqueda
  final TextEditingController _searchController = TextEditingController();
  // Texto que escribe el usuario en la búsqueda
  String _searchQuery = '';
  bool _hasSubmittedSearch = false;
  bool _searchFlowStarted = false;
  bool _cityChosen = false;
  bool _datesChosen = false;
  bool _categoryChosen = false;
  bool _cityConfirmed = false;
  bool _datesConfirmed = false;
  bool _categoryConfirmed = false;

  // Fechas del período de renta
  late DateTime _fechaDesde; // Fecha inicio por defecto
  late DateTime _fechaHasta; // Fecha fin por defecto
  DateTime? _rentalStartDate; // Fecha que escoge el usuario
  DateTime? _rentalEndDate; // Fecha fin que escoge el usuario

  // Servicio que trae los datos de carros
  final VehicleInventoryUseCase _vehiculoService =
      InjectionContainer.instance.vehicleInventoryUseCase;
  // Lista de todos los carros disponibles
  List<Map<String, dynamic>> _vehiculos = [];
  // Lista de carros después de aplicar filtros
  List<Map<String, dynamic>> _vehiculosFiltrados = [];
  // Está cargando los carros?
  bool _isLoading = true;
  // Está cargando las ciudades?
  bool _isLoadingCities = true;
  // Lista de ciudades disponibles
  List<String> _cities = [];
  bool _hasUnreadNotifications = false;
  Timer? _notificationSyncTimer;
  final GlobalKey _allVehiclesSectionKey = GlobalKey();

  // Caché de calificaciones: vehicleId -> {rating, count}
  // Guardamos esto para no calcular todo el tiempo
  final Map<int, Map<String, dynamic>> _vehicleRatings = {};

  // Vehículo tocado en el mapa; su detalle es lo único que se muestra abajo
  Map<String, dynamic>? _selectedVehicleOnMap;
  // Si la categoría buscada no tenía resultados y se amplió a toda la ciudad
  bool _categoryFallbackApplied = false;

  // Controlador del mapa real que sigue la ciudad buscada
  final MapController _mapController = MapController();
  // Última ciudad sobre la que se centró el mapa (evita centrar de más)
  String? _lastCenteredCity;

  // Coordenadas aproximadas del centro de cada ciudad soportada
  static const Map<String, LatLng> _cityCoordinates = {
    'Bogotá': LatLng(4.7110, -74.0721),
    'Medellín': LatLng(6.2442, -75.5812),
    'Cali': LatLng(3.4516, -76.5320),
    'Barranquilla': LatLng(10.9639, -74.7964),
    'Cartagena': LatLng(10.3910, -75.4794),
    'Bucaramanga': LatLng(7.1193, -73.1227),
  };
  static const LatLng _colombiaCenter = LatLng(4.5709, -74.2973);

  // Iconos que representan cada ciudad
  final Map<String, IconData> _cityIcons = {
    _allCitiesOption: Icons.public,
    'Bogotá': Icons.account_balance, // Capital, gobierno
    'Medellín': Icons.forest, // Ciudad de la eterna primavera
    'Cali': Icons.nightlife, // Salsa y fiesta
    'Barranquilla': Icons.waves, // Puerto, mar
    'Cartagena': Icons.deck, // Ciudad histórica, colonial
    'Bucaramanga': Icons.hiking, // Ciudad bonita, montañas
  };

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  bool get _isAllCitiesSelected => _selectedCity == _allCitiesOption;
  bool get _hasSearchText => _searchQuery.trim().isNotEmpty;
  bool get _hasSelectedCity => _selectedCity != _allCitiesOption;

  // Dark-modo aware palette helpers
  Color get _cardBg => _isDark ? const Color(0xFF161827) : Colors.white;
  Color get _borderColor =>
      _isDark ? const Color(0xFF2E3355) : Colors.grey.shade200;
  Color get _dividerColor =>
      _isDark ? const Color(0xFF252942) : Colors.grey.shade100;
  Color get _textPrimary =>
      _isDark ? const Color(0xFFF1F3FF) : const Color(0xFF1A1A1A);
  Color get _textSub =>
      _isDark ? const Color(0xFF8B93B8) : Colors.grey.shade500;

  // ─── inicialización estado - Cargar datos desde JSON ─────────────────────────
  @override
  void initState() {
    super.initState();
    final nowCo = ColombiaTime.now();
    _fechaDesde = DateTime(nowCo.year, nowCo.month, nowCo.day);
    _fechaHasta = _fechaDesde.add(const Duration(days: 7));
    _cargarVehiculos();
    _cargarUsuarioActual();
    _cargarCiudades();
    _notificationDb.changes.addListener(_onNotificationsChanged);
    _cargarEstadoNotificaciones();
    _notificationSyncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      _syncAndRefreshNotifications();
    });
    _syncAndRefreshNotifications();
  }

  /// Gestiona dispose dentro de esta parte del flujo.
  @override
  void dispose() {
    _notificationSyncTimer?.cancel();
    _notificationDb.changes.removeListener(_onNotificationsChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Gestiona scroll a all vehicles section dentro de esta parte del flujo.
  void _scrollToAllVehiclesSection() {
    final sectionContext = _allVehiclesSectionKey.currentContext;
    if (sectionContext == null) return;

    Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  /// Gestiona on notificaciones changed dentro de esta parte del flujo.
  void _onNotificationsChanged() {
    _cargarEstadoNotificaciones();
  }

  /// Sincronizar y refrescar notificaciones esta parte del flujo de trabajo.
  Future<void> _syncAndRefreshNotifications() async {
    final currentUser = await _accountRepository.getCurrentUser();
    if (currentUser != null) {
      await _syncReservationReminders(currentUser.id);
    }
    await _cargarEstadoNotificaciones();
  }

  /// Carga los datos necesarios para cargar estado notificaciones.
  Future<void> _cargarEstadoNotificaciones() async {
    await _notificationDb.loadIfNeeded();
    final currentUser = await _accountRepository.getCurrentUser();
    if (!mounted) return;

    if (currentUser == null) {
      setState(() {
        _hasUnreadNotifications = false;
      });
      return;
    }

    final hasUnread = _notificationDb.notifications.any(
      (notification) =>
          notification.userId == currentUser.id &&
          notification.status == 'no_leida',
    );

    setState(() {
      _hasUnreadNotifications = hasUnread;
    });
  }

  /// Sincronizar reserva reminders esta parte del flujo de trabajo.
  Future<void> _syncReservationReminders(int currentUserId) async {
    await Future.wait([
      _catalogDb.loadIfNeeded(),
      _reservationDb.loadIfNeeded(),
      _publicationDb.loadIfNeeded(),
    ]);

    final prefs = await SharedPreferences.getInstance();
    final sentKeys =
        (prefs.getStringList(_reminderKeysStorage) ?? <String>[]).toSet();
    final reminderCategoryId = _resolveReminderCategoryId();
    final nowColombia = ColombiaTime.now();
    var updated = false;

    final publicationsById = {
      for (final publication in _publicationDb.publications)
        publication.id: publication,
    };

    final userOwnedPublicationIds = _publicationDb.publications
        .where((publication) => publication.userId == currentUserId)
        .map((publication) => publication.id)
        .toSet();

    for (final reservation in _reservationDb.reservations) {
      if (reservation.statusId == 3) continue;

      final end = ColombiaTime.toColombia(reservation.endDate);
      final minutesToEnd = end.difference(nowColombia).inMinutes;
      final hasEnded = !end.isAfter(nowColombia);
      final publication = publicationsById[reservation.publicationId];
      final ownerId = publication?.userId;

      if (reservation.userId == currentUserId) {
        if (hasEnded) {
          final key = 'renter_ended_${reservation.id}';
          if (!sentKeys.contains(key)) {
            await _notificationDb.addNotification(
              userId: currentUserId,
              categoryId: reminderCategoryId,
              subject: 'Reserva finalizada ✅',
              description:
                  'Tu reserva ${reservation.code} ya finalizó. Gracias por usar FlexiDrive.',
            );
            sentKeys.add(key);
            updated = true;
          }
        } else if (minutesToEnd > 0 && minutesToEnd <= 30) {
          final key = 'renter_ending_${reservation.id}';
          if (!sentKeys.contains(key)) {
            await _notificationDb.addNotification(
              userId: currentUserId,
              categoryId: reminderCategoryId,
              subject: 'Recordatorio de reserva ⏰',
              description:
                  'Tu reserva ${reservation.code} finaliza pronto. Queda ${_formatRemainingTime(minutesToEnd)}.',
            );
            sentKeys.add(key);
            updated = true;
          }
        }
      }

      if (ownerId != null &&
          ownerId == currentUserId &&
          userOwnedPublicationIds.contains(reservation.publicationId)) {
        if (hasEnded) {
          final key = 'owner_ended_${reservation.id}';
          if (!sentKeys.contains(key)) {
            await _notificationDb.addNotification(
              userId: currentUserId,
              categoryId: reminderCategoryId,
              subject: 'Renta finalizada ✅',
              description:
                  'La renta ${reservation.code} de tu vehículo ya finalizó.',
            );
            sentKeys.add(key);
            updated = true;
          }
        } else if (minutesToEnd > 0 && minutesToEnd <= 30) {
          final key = 'owner_ending_${reservation.id}';
          if (!sentKeys.contains(key)) {
            await _notificationDb.addNotification(
              userId: currentUserId,
              categoryId: reminderCategoryId,
              subject: 'Recordatorio de entrega 🚗',
              description:
                  'La renta ${reservation.code} de tu vehículo finaliza pronto. Queda ${_formatRemainingTime(minutesToEnd)}.',
            );
            sentKeys.add(key);
            updated = true;
          }
        }
      }
    }

    if (updated) {
      await prefs.setStringList(_reminderKeysStorage, sentKeys.toList());
    }
  }

  /// Gestiona resolve reminder category id dentro de esta parte del flujo.
  int _resolveReminderCategoryId() {
    for (final category in _catalogDb.notificationCategories) {
      final name = category.name.toLowerCase();
      if (name.contains('recordatorio')) return category.id;
    }
    return _catalogDb.notificationCategories.isEmpty
        ? 1
        : _catalogDb.notificationCategories.first.id;
  }

  /// Gestiona format remaining time dentro de esta parte del flujo.
  String _formatRemainingTime(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (remaining == 0) return '$hours h';
    return '$hours h $remaining min';
  }

  /// Carga los datos necesarios para cargar ciudades.
  Future<void> _cargarCiudades() async {
    final cities = await _accountRepository.getReferenceCities();
    if (!mounted) return;
    setState(() {
      _cities = cities;
      if (_cities.isNotEmpty &&
          _selectedCity != _allCitiesOption &&
          !_cities.contains(_selectedCity)) {
        _selectedCity = _cities.first;
      }
      _isLoadingCities = false;
    });
  }

  /// Gestiona contar vehiculos por ciudad dentro de esta parte del flujo.
  int _contarVehiculosPorCiudad(String city) {
    if (city == _allCitiesOption) return _vehiculos.length;
    final normalizedCity = _normalizeCity(city);
    return _vehiculos
        .where(
            (v) => _normalizeCity('${v['ubicacion'] ?? ''}') == normalizedCity)
        .length;
  }

  /// Gestiona normalize ciudad dentro de esta parte del flujo.
  String _normalizeCity(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }

  /// Verifica si un vehículo está disponible en el rango de fechas seleccionado
  bool _isVehicleAvailable(int vehicleId) {
    // Si no hay fechas seleccionadas, mostrar todos los vehículos
    if (_rentalStartDate == null || _rentalEndDate == null) {
      return true;
    }

    // Buscar la publicación de este vehículo
    final publication = _publicationDb.publications
        .where((p) => p.vehicleId == vehicleId && p.active)
        .firstOrNull;

    if (publication == null) return true;

    // Buscar reservas para esta publicación
    final reservations = _reservationDb.reservations
        .where((r) =>
            r.publicationId == publication.id &&
            r.statusId == 1) // Solo reservas activas
        .toList();

    // Verificar si alguna reserva se cruza con las fechas seleccionadas
    for (var reservation in reservations) {
      if (_datesOverlap(
        _rentalStartDate!,
        _rentalEndDate!,
        reservation.startDate,
        reservation.endDate,
      )) {
        return false; // Vehículo no disponible
      }
    }

    return true; // Vehículo disponible
  }

  /// Verifica si dos rangos de fechas se cruzan
  bool _datesOverlap(
      DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    // Si el rango 1 termina antes de que comience el rango 2
    if (end1.isBefore(start2)) return false;

    // Si el rango 1 comienza después de que termine el rango 2
    if (start1.isAfter(end2)) return false;

    // Hay cruce de fechas
    return true;
  }

  /// Gestiona filtrar vehiculos dentro de esta parte del flujo.
  void _filtrarVehiculos() {
    final base = _vehiculos.where((v) {
      // Filtro por ciudad
      final matchesCity = _isAllCitiesSelected
          ? true
          : _normalizeCity('${v['ubicacion'] ?? ''}') ==
              _normalizeCity(_selectedCity);

      // Filtro por búsqueda de texto
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final marca = v['marca'].toString().toLowerCase();
        final modelo = v['modelo'].toString().toLowerCase();
        final linea = v['linea']?.toString().toLowerCase() ?? '';
        final precioHora = v['precio_hora'].toString();
        final precioDia = v['precio_dia'].toString();

        matchesSearch = marca.contains(query) ||
            modelo.contains(query) ||
            linea.contains(query) ||
            precioHora.contains(query) ||
            precioDia.contains(query);
      }

      // Filtro por disponibilidad de fechas
      final isAvailable = _isVehicleAvailable(v['id'] as int);

      return matchesCity && matchesSearch && isAvailable;
    }).toList();

    // Filtro por categoría, con retroceso automático si no hay resultados
    // para esa categoría puntual en la ciudad (mostramos todos en su lugar).
    var filtrados = base;
    var fallbackApplied = false;
    if (_selectedCategory != 'Todos') {
      final porCategoria =
          base.where((v) => v['categoria'] == _selectedCategory).toList();
      if (porCategoria.isEmpty && base.isNotEmpty) {
        fallbackApplied = true;
      } else {
        filtrados = porCategoria;
      }
    }

    // Los más cercanos al punto de recogida (centro de la ciudad) primero.
    if (!_isAllCitiesSelected) {
      final center = _cityCoordinates[_selectedCity] ?? _colombiaCenter;
      const distanceCalc = Distance();
      filtrados.sort((a, b) {
        final da = distanceCalc(center, _vehiclePseudoLocation(a));
        final db = distanceCalc(center, _vehiclePseudoLocation(b));
        return da.compareTo(db);
      });
    }

    setState(() {
      _vehiculosFiltrados = filtrados;
      _categoryFallbackApplied = fallbackApplied;
    });
  }

  void _executeSearch() {
    FocusScope.of(context).unfocus();
    setState(() {
      _rentalStartDate = _fechaDesde;
      _rentalEndDate = _fechaHasta;
      _hasSubmittedSearch = true;
      _selectedVehicleOnMap = null;
    });
    _filtrarVehiculos();
    setState(() {
      // El más cercano al punto de recogida queda preseleccionado.
      _selectedVehicleOnMap =
          _vehiculosFiltrados.isNotEmpty ? _vehiculosFiltrados.first : null;
    });
  }

  int get _guidedSearchStep {
    if (!_cityConfirmed) return 0;
    if (!_datesConfirmed) return 1;
    if (!_categoryConfirmed) return 2;
    return 3;
  }

  void _handleCitySelected(String city) {
    setState(() {
      _searchFlowStarted = true;
      _selectedCity = city;
      _cityChosen = true;
      _cityConfirmed = false;
      _datesChosen = false;
      _categoryChosen = false;
      _datesConfirmed = false;
      _categoryConfirmed = false;
      _hasSubmittedSearch = false;
      _selectedVehicleOnMap = null;
    });
  }

  void _confirmCityStep() {
    setState(() {
      _cityConfirmed = true;
      _hasSubmittedSearch = false;
    });
  }

  void _confirmDatesStep() {
    setState(() {
      _datesConfirmed = true;
      _hasSubmittedSearch = false;
    });
  }

  void _confirmCategoryStep() {
    setState(() {
      _categoryConfirmed = true;
      _hasSubmittedSearch = false;
    });
  }

  void _editSearchStep(int step) {
    setState(() {
      if (step <= 0) {
        _cityChosen = false;
        _cityConfirmed = false;
        _selectedCity = _allCitiesOption;
        _datesChosen = false;
        _categoryChosen = false;
        _datesConfirmed = false;
        _categoryConfirmed = false;
      } else if (step == 1) {
        _datesChosen = false;
        _categoryChosen = false;
        _datesConfirmed = false;
        _categoryConfirmed = false;
      } else if (step == 2) {
        _categoryChosen = false;
        _categoryConfirmed = false;
      }
      _hasSubmittedSearch = false;
    });
  }

  void _handlePrimarySearchAction() {
    switch (_guidedSearchStep) {
      case 0:
        if (!_cityChosen) return;
        _confirmCityStep();
        break;
      case 1:
        if (!_datesChosen) return;
        _confirmDatesStep();
        break;
      case 2:
        if (!_categoryChosen) return;
        _confirmCategoryStep();
        break;
      default:
        _executeSearch();
    }
  }

  String get _primarySearchCtaLabel {
    switch (_guidedSearchStep) {
      case 0:
        return 'Elegir ciudad';
      case 1:
        return 'Elegir fechas';
      case 2:
        return 'Elegir categoría';
      default:
        return _hasSubmittedSearch ? 'Actualizar búsqueda' : 'Buscar vehículos';
    }
  }

  bool get _isCurrentStepReady {
    switch (_guidedSearchStep) {
      case 0:
        return _cityChosen;
      case 1:
        return _datesChosen;
      case 2:
        return _categoryChosen;
      default:
        return true;
    }
  }

  void _clearSearchFlow() {
    final nowCo = ColombiaTime.now();
    final defaultStart = DateTime(nowCo.year, nowCo.month, nowCo.day);
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCity = _allCitiesOption;
      _selectedCategory = 'Todos';
      _fechaDesde = defaultStart;
      _fechaHasta = defaultStart.add(const Duration(days: 7));
      _rentalStartDate = null;
      _rentalEndDate = null;
      _hasSubmittedSearch = false;
      _searchFlowStarted = false;
      _cityChosen = false;
      _cityConfirmed = false;
      _datesChosen = false;
      _categoryChosen = false;
      _datesConfirmed = false;
      _categoryConfirmed = false;
      _vehiculosFiltrados = _vehiculos;
      _selectedVehicleOnMap = null;
      _categoryFallbackApplied = false;
    });
  }

  // ignore: unused_element
  String _searchSummaryText() {
    final parts = <String>[];
    if (_hasSearchText) parts.add(_searchQuery.trim());
    if (_selectedCity != _allCitiesOption) parts.add(_selectedCity);
    if (_selectedCategory != 'Todos') parts.add(_selectedCategory);
    parts.add('${_formatFecha(_fechaDesde)} - ${_formatFecha(_fechaHasta)}');
    return parts.join(' • ');
  }

  // ignore: unused_element
  int get _searchDurationDays =>
      _fechaHasta.difference(_fechaDesde).inDays.abs() + 1;

  /// Gestiona select fecha desde dentro de esta parte del flujo.
  Future<void> _selectFechaDesde() async {
    final nowCo = ColombiaTime.now();
    final firstAllowed = DateTime(nowCo.year, nowCo.month, nowCo.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaDesde,
      firstDate: firstAllowed,
      lastDate: DateTime(2027, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4F46E5),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaDesde) {
      setState(() {
        _fechaDesde = picked;
        _datesChosen = true;
        _rentalStartDate = picked;
        if (_fechaHasta.isBefore(_fechaDesde)) {
          _fechaHasta = _fechaDesde.add(const Duration(days: 1));
          _rentalEndDate = _fechaHasta;
        }
      });
      _filtrarVehiculos(); // Filtrar vehicles cuando cambian las fechas
    }
  }

  /// Gestiona select fecha hasta dentro de esta parte del flujo.
  Future<void> _selectFechaHasta() async {
    final nowCo = ColombiaTime.now();
    final firstAllowed = DateTime(nowCo.year, nowCo.month, nowCo.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaHasta,
      firstDate: _fechaDesde.isAfter(firstAllowed) ? _fechaDesde : firstAllowed,
      lastDate: DateTime(2027, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4F46E5),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaHasta) {
      setState(() {
        _fechaHasta = picked;
        _datesChosen = true;
        _rentalEndDate = picked;
      });
      _filtrarVehiculos(); // Filtrar vehicles cuando cambian las fechas
    }
  }

  /// Gestiona format fecha dentro de esta parte del flujo.
  String _formatFecha(DateTime fecha) {
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]}';
  }

  /// Carga los datos necesarios para cargar usuario actual.
  Future<void> _cargarUsuarioActual() async {
    final currentUser = await _accountRepository.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _currentUserName = currentUser?.fullName.split(' ').first ?? 'Invitado';
    });
  }

  /// Carga vehículos desde el JSON usando dart:convert y calcula ratings reales
  Future<void> _cargarVehiculos() async {
    await _vehiculoService.init();
    await _publicationDb.reload();
    await _reviewDb.loadIfNeeded();
    await _reservationDb.loadIfNeeded();

    final allVehiculos = _vehiculoService.getVehiculos();
    final publishedVehicleIds = _publicationDb.publications
        .where((publication) => publication.active)
        .map((publication) => publication.vehicleId)
        .toSet();
    final vehiculos = allVehiculos.where((vehicle) {
      final vehicleId = int.tryParse(
            '${vehicle['vehiculo_id'] ?? vehicle['id'] ?? 0}',
          ) ??
          0;
      return publishedVehicleIds.contains(vehicleId);
    }).toList();

    if (vehiculos.isEmpty) {
      setState(() {
        _vehiculos = [];
        _vehiculosFiltrados = [];
        _isLoading = false;
      });
      return;
    }

    // Calificar ratings reales para cada vehículo
    for (var v in vehiculos) {
      final vehicleId = v['id'] as int;
      final ratingData = _calcularRatingVehiculo(vehicleId);
      _vehicleRatings[vehicleId] = ratingData;
    }

    setState(() {
      _vehiculos = vehiculos;
      _vehiculosFiltrados = vehiculos;
      _isLoading = false;
    });
    _filtrarVehiculos();
  }

  /// Calcula el rating real de un vehículo desde las reseñas de la BD
  /// Si no tiene reseñas: rating = 5.0, count = 0
  Map<String, dynamic> _calcularRatingVehiculo(int vehicleId) {
    // Buscar publicación del vehículo
    final publication = _publicationDb.publications.firstWhere(
      (p) => p.vehicleId == vehicleId && p.active,
      orElse: () => PublicationModel(
        id: 0,
        userId: 0,
        vehicleId: 0,
        publishDate: DateTime.now(),
        active: false,
      ),
    );

    if (publication.id == 0) {
      // Sin publicación = sin reseñas = 5.0 por defecto
      return {'rating': 5.0, 'count': 0};
    }

    // Obtener reseñas de esta publicación
    final reviews = _reviewDb.reviews
        .where((r) => r.publicationId == publication.id)
        .toList();

    if (reviews.isEmpty) {
      // Sin reseñas = 5.0 por defecto
      return {'rating': 5.0, 'count': 0};
    }

    // Calcular promedio de calificaciones
    double totalRating = 0;
    int validOpinions = 0;

    for (var review in reviews) {
      final opinion = _reviewDb.opinions.firstWhere(
        (o) => o.id == review.opinionId,
        orElse: () => OpinionModel(id: 0, rating: 0),
      );
      if (opinion.id != 0) {
        totalRating += opinion.rating;
        validOpinions++;
      }
    }

    if (validOpinions == 0) {
      return {'rating': 5.0, 'count': 0};
    }

    final averageRating = totalRating / validOpinions;
    return {'rating': averageRating, 'count': validOpinions};
  }

  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topInset = MediaQuery.of(context).padding.top;

    // Recentra el mapa exactamente una vez por cada cambio real de ciudad,
    // sin depender de que cada punto que la modifique recuerde hacerlo.
    if (!_isAllCitiesSelected && _lastCenteredCity != _selectedCity) {
      _lastCenteredCity = _selectedCity;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final target = _cityCoordinates[_selectedCity] ?? _colombiaCenter;
        try {
          _mapController.move(target, 13.0);
        } catch (_) {
          // El mapa recién se está montando en este frame; se ignora.
        }
      });
    } else if (_isAllCitiesSelected) {
      _lastCenteredCity = null;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: _isAllCitiesSelected
                ? _buildColombiaPlaceholder()
                : _buildRealMap(),
          ),
          Positioned(
            top: topInset + 12,
            left: 16,
            child: _buildTopCircleButton(
              icon: Icons.more_vert_rounded,
              onTap: _showMainMenu,
            ),
          ),
          Positioned(
            top: topInset + 12,
            right: 16,
            child: _buildTopCircleButton(
              icon: Icons.notifications_none_rounded,
              badge: _hasUnreadNotifications,
              onTap: () => MainPage.of(context).setIndex(2),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.30,
            minChildSize: 0.22,
            maxChildSize: 0.88,
            snap: true,
            snapSizes: const [0.22, 0.30, 0.88],
            builder: (context, sheetController) =>
                _buildSearchSheet(sheetController),
          ),
        ],
      ),
    );
  }

  /// Vista de bienvenida cuando aún no hay una ciudad concreta elegida:
  /// no tiene sentido un mapa real con "todas las ciudades" a la vez.
  Widget _buildColombiaPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/imagenes_carros/imagen_fondo_explorar.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          colorFilter: ColorFilter.mode(
            Color(0x88521FD4),
            BlendMode.srcATop,
          ),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF1F2235)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 84, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.22)),
                ),
                child: const Icon(
                  Icons.public_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Explora Colombia',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Elige la ciudad a la que viajas para ver el mapa real y '
                'los vehículos disponibles cerca de ti.',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _cityCoordinates.keys
                    .map((city) => _buildCityQuickChip(city))
                    .toList(),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(22),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.route_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Búsqueda guiada',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ciudad → fechas → categoría → detalle final antes de mostrar resultados.',
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityQuickChip(String city) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _handleCitySelected(city),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_cityIcons[city] ?? Icons.location_city,
                color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                city,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mapa real (OpenStreetMap) que ocupa toda la pantalla detrás del panel
  /// de búsqueda, centrado en la ciudad activa o en Colombia si aplica a todas.
  Widget _buildRealMap() {
    final center = _cityCoordinates[_selectedCity] ?? _colombiaCenter;
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: _isAllCitiesSelected ? 5.2 : 12.5,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom |
              InteractiveFlag.drag |
              InteractiveFlag.doubleTapZoom,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
          userAgentPackageName: 'co.flexidrive.app',
        ),
        MarkerLayer(markers: [
          Marker(
            point: center,
            width: 26,
            height: 26,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ]),
        MarkerLayer(markers: _buildVehicleMarkers()),
        RichAttributionWidget(
          alignment: AttributionAlignment.bottomLeft,
          showFlutterMapAttribution: false,
          attributions: [
            TextSourceAttribution('© OpenStreetMap contributors © CARTO'),
          ],
        ),
      ],
    );
  }

  /// Marcadores de los vehículos filtrados, distribuidos alrededor del
  /// centro de la ciudad (los datos de muestra no traen lat/lng reales).
  /// Tocar un marcador lo selecciona: eso es lo único que baja al panel.
  List<Marker> _buildVehicleMarkers() {
    if (!_hasSubmittedSearch || _vehiculosFiltrados.isEmpty) return [];
    final preview = _vehiculosFiltrados.take(10).toList();
    final selectedId = _selectedVehicleOnMap?['id'];

    return preview.map((vehicle) {
      final point = _vehiclePseudoLocation(vehicle);
      final price = vehicle['precio_hora'] as int? ?? 0;
      final isSelected = selectedId != null && vehicle['id'] == selectedId;

      return Marker(
        point: point,
        width: 92,
        height: 58,
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () => setState(() => _selectedVehicleOnMap = vehicle),
          child: _buildMapMarkerBubble(price, isSelected: isSelected),
        ),
      );
    }).toList();
  }

  /// Coordenada estable (no cambia entre rebuilds) para un vehículo dado,
  /// derivada de su id, ya que los datos de muestra no traen lat/lng reales.
  LatLng _vehiclePseudoLocation(Map<String, dynamic> vehicle) {
    final cityName = vehicle['ubicacion'] as String? ?? _selectedCity;
    final base = _cityCoordinates[cityName] ??
        _cityCoordinates[_selectedCity] ??
        _colombiaCenter;
    final jitter = _markerJitter(vehicle['id'] as int? ?? 0);
    return LatLng(base.latitude + jitter.$1, base.longitude + jitter.$2);
  }

  (double, double) _markerJitter(int seed) {
    const offsets = <(double, double)>[
      (0.015, -0.020),
      (-0.020, 0.015),
      (0.030, 0.020),
      (-0.025, -0.030),
      (0.010, 0.035),
      (-0.035, 0.010),
      (0.020, -0.040),
      (0.040, 0.005),
    ];
    return offsets[seed % offsets.length];
  }

  Widget _buildMapMarkerBubble(int price, {bool isSelected = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.directions_car_filled_rounded,
                size: 14,
                color: isSelected ? Colors.white : const Color(0xFF4F46E5),
              ),
              const SizedBox(width: 6),
              Text(
                '\$${_formatPrice(price)}',
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : const Color(0xFF111827),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFF4F46E5),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  /// Botón circular flotante para las acciones fijas sobre el mapa
  /// (menú de navegación y notificaciones), estilo InDrive.
  Widget _buildTopCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool badge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: _cardBg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: _textPrimary, size: 22),
            if (badge)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Menú de navegación (equivalente a los "tres puntos" de InDrive) con
  /// acceso rápido a perfil, reservas y alertas.
  void _showMainMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    _currentUserName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Ver mi perfil',
                    style: GoogleFonts.inter(color: _textSub, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    MainPage.of(context).setIndex(3);
                  },
                ),
                Divider(color: _dividerColor, height: 1),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined,
                      color: Color(0xFF4F46E5)),
                  title: Text('Mis reservas',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, color: _textPrimary)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    MainPage.of(context).setIndex(1);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_none_rounded,
                      color: Color(0xFF4F46E5)),
                  title: Text('Alertas',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, color: _textPrimary)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    MainPage.of(context).setIndex(2);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Panel inferior anclado y desplegable (estilo InDrive) que concentra,
  /// en un único flujo secuencial, la búsqueda y luego sus resultados.
  Widget _buildSearchSheet(ScrollController sheetController) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.4 : 0.16),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: sheetController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                _hasSubmittedSearch
                    ? 'Vehículos disponibles'
                    : '¿A dónde vas hoy, $_currentUserName?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildUnifiedSearchPanel(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: _hasSubmittedSearch
                  ? _buildMapResultsPanel()
                  : const SizedBox(key: ValueKey('no-results'), height: 24),
            ),
          ],
        ),
      ),
    );
  }

  /// Resultado de la búsqueda: no aparece como listado, aparece como
  /// puntos en el mapa. Aquí solo se muestra el detalle del vehículo
  /// tocado (el más cercano al punto de recogida queda preseleccionado).
  Widget _buildMapResultsPanel() {
    final count = _vehiculosFiltrados.length;
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);

    return Padding(
      key: ValueKey('results-${_selectedVehicleOnMap?['id']}-$count'),
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 16, color: _textSub),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$count disponible${count == 1 ? '' : 's'} en $_selectedCity',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textSub,
                  ),
                ),
              ),
            ],
          ),
          if (_categoryFallbackApplied) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Text(
                'No hay $_selectedCategory disponibles en $_selectedCity. '
                'Te mostramos todos los vehículos de la ciudad.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF92400E),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_vehiculosFiltrados.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 40, color: _textSub),
                    const SizedBox(height: 12),
                    Text(
                      'No se encontraron vehículos',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Intenta con otra ciudad o fechas',
                      style: GoogleFonts.inter(fontSize: 13, color: _textSub),
                    ),
                  ],
                ),
              ),
            )
          else if (_selectedVehicleOnMap == null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    _isDark ? const Color(0xFF1F2235) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_outlined,
                      color: Color(0xFF4F46E5)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Toca un punto en el mapa para ver el detalle de ese '
                      'vehículo.',
                      style:
                          GoogleFonts.inter(fontSize: 13, color: _textPrimary),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vehículo más cercano',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedVehicleOnMap = null),
                  child: Text(
                    'Ver mapa',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4F46E5),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildVehicleListItem(_selectedVehicleOnMap!, isSmallPhone),
          ],
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildLegacySearchBar() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 52,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.30)
                : Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search_rounded, color: theme.hintColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filtrarVehiculos();
              },
              decoration: InputDecoration(
                hintText: 'Buscar vehículo, marca, precio...',
                hintStyle: GoogleFonts.inter(
                  color: theme.hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: GoogleFonts.inter(
                  fontSize: 14, color: theme.textTheme.bodyLarge?.color),
            ),
          ),
          GestureDetector(
            onTap: _showCitySelector,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF4F46E5).withValues(alpha: 0.2)
                    : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                        color: Color(0xFF4F46E5), shape: BoxShape.circle),
                    child: Icon(_cityIcons[_selectedCity] ?? Icons.location_on,
                        color: Colors.white, size: 12),
                  ),
                  const SizedBox(width: 5),
                  Text(_selectedCity,
                      style: GoogleFonts.inter(
                          color: const Color(0xFF4F46E5),
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedSearchPanel() {
    final theme = Theme.of(context);
    if (!_searchFlowStarted) {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF1F2235)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inicia una búsqueda',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pulsa el botón y te iremos pidiendo ciudad, fechas y categoría en orden.',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            height: 1.4,
                            color: _textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchFlowStarted = true;
                  });
                },
                icon: const Icon(Icons.search_rounded),
                label: Text(
                  'Buscar vehículo',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF1F2235)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: theme.hintColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onSubmitted: (_) {
                      if (_guidedSearchStep == 3) {
                        _executeSearch();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Marca, modelo o referencia',
                      hintStyle: GoogleFonts.inter(
                        color: theme.hintColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _showAdvancedSearchSheet,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSearchSegmentedBar(),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: _buildGuidedSearchStage(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        _isCurrentStepReady ? _handlePrimarySearchAction : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      disabledBackgroundColor: const Color(0xFFCBD5E1),
                      disabledForegroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      _primarySearchCtaLabel,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              if (_hasSubmittedSearch || _searchFlowStarted) ...[
                const SizedBox(width: 10),
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _clearSearchFlow,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      side: BorderSide(color: _borderColor),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Barra única y conectada (estilo InDrive) que agrupa ciudad, fechas y
  /// categoría como tramos de un mismo control, en vez de chips sueltos.
  Widget _buildSearchSegmentedBar() {
    return Container(
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF1F2235) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildSearchSegment(
                icon: Icons.location_on_outlined,
                label: _hasSelectedCity ? _selectedCity : 'Ciudad',
                active: _cityConfirmed || _cityChosen,
                enabled: _searchFlowStarted,
                onTap: () => _editSearchStep(0),
              ),
            ),
            _buildSegmentDivider(),
            Expanded(
              flex: 2,
              child: _buildSearchSegment(
                icon: Icons.calendar_today_outlined,
                label: _datesConfirmed
                    ? '${_formatFecha(_fechaDesde)} - ${_formatFecha(_fechaHasta)}'
                    : 'Fechas',
                active: _datesConfirmed,
                enabled: _cityConfirmed,
                onTap: () => _editSearchStep(1),
              ),
            ),
            _buildSegmentDivider(),
            Expanded(
              child: _buildSearchSegment(
                icon: Icons.directions_car_outlined,
                label: _categoryConfirmed ? _selectedCategory : 'Categoría',
                active: _categoryConfirmed,
                enabled: _datesConfirmed,
                onTap: () => _editSearchStep(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: VerticalDivider(width: 1, thickness: 1, color: _borderColor),
    );
  }

  Widget _buildSearchSegment({
    required IconData icon,
    required String label,
    required bool active,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: !enabled
                  ? _textSub.withValues(alpha: 0.45)
                  : active
                      ? const Color(0xFF4F46E5)
                      : _textSub,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: !enabled
                    ? _textSub.withValues(alpha: 0.55)
                    : active
                        ? const Color(0xFF4F46E5)
                        : _textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidedSearchStage() {
    switch (_guidedSearchStep) {
      case 0:
        return _buildCityStage();
      case 1:
        return _buildDatesStage();
      case 2:
        return _buildCategoryStage();
      default:
        return _buildSearchReviewStage();
    }
  }

  Widget _buildCityStage() {
    final topCities = _cityCoordinates.keys.toList();
    return Container(
      key: const ValueKey('city-stage'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF1F2235) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final city in topCities)
                ChoiceChip(
                  label: Text(city),
                  selected: city == _selectedCity,
                  onSelected: (_) => _handleCitySelected(city),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_hasSelectedCity)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF4F46E5),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedCity,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.search_rounded, size: 16),
                label: const Text('Más ciudades'),
                onPressed: _showCitySelector,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatesStage() {
    return Container(
      key: const ValueKey('dates-stage'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF1F2235) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasSelectedCity) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF4F46E5),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedCity,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: _buildAdvancedDateCard(
                  label: 'Desde',
                  value: _formatFecha(_fechaDesde),
                  onTap: _selectFechaDesde,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAdvancedDateCard(
                  label: 'Hasta',
                  value: _formatFecha(_fechaHasta),
                  onTap: _selectFechaHasta,
                  highlighted: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStage() {
    const categories = [
      'Todos',
      'Sedán',
      'SUV',
      'Compacto',
      'Premium',
      'Pickup'
    ];
    return Container(
      key: const ValueKey('category-stage'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF1F2235) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF4F46E5),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_selectedCity.isEmpty ? 'Ciudad' : _selectedCity} · ${_formatFecha(_fechaDesde)} - ${_formatFecha(_fechaHasta)}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map(
                  (category) => ChoiceChip(
                    label: Text(category),
                    selected: category == _selectedCategory,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                        _categoryChosen = true;
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchReviewStage() {
    return Container(
      key: const ValueKey('review-stage'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF1F2235) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewRow(
            title: 'Ciudad',
            value: _selectedCity,
            onEdit: () {
              _editSearchStep(0);
              _showCitySelector();
            },
          ),
          const SizedBox(height: 10),
          _buildReviewRow(
            title: 'Fechas',
            value:
                '${_formatFecha(_fechaDesde)} - ${_formatFecha(_fechaHasta)}',
            onEdit: () => _editSearchStep(1),
          ),
          const SizedBox(height: 10),
          _buildReviewRow(
            title: 'Categoría',
            value: _selectedCategory,
            onEdit: () => _editSearchStep(2),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow({
    required String title,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _textSub,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onEdit, child: const Text('Cambiar')),
        ],
      ),
    );
  }

  // ─── DATE SELECTOR ───────────────────────────────────────────────
  // ignore: unused_element
  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Fecha Desde (izquierda)
          Expanded(
            child: GestureDetector(
              onTap: _selectFechaDesde,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Desde',
                        style: GoogleFonts.poppins(
                          color: _textSub,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        )),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: const Color(0xFF4F46E5), size: 16),
                        const SizedBox(width: 8),
                        Text(_formatFecha(_fechaDesde),
                            style: GoogleFonts.inter(
                              color: _textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Fecha Hasta (derecha)
          Expanded(
            child: GestureDetector(
              onTap: _selectFechaHasta,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hasta',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        )),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(_formatFecha(_fechaHasta),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CATEGORIES ──────────────────────────────────────────────────
  // ignore: unused_element
  Widget _buildCategories() {
    final categories = [
      {'name': 'Todos', 'icon': null},
      {'name': 'Sedán', 'icon': '🚗'},
      {'name': 'SUV', 'icon': '🚙'},
      {'name': 'Compacto', 'icon': '🚗'},
      {'name': 'Premium', 'icon': '✨'},
      {'name': 'Pickup', 'icon': '🛻'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Categorías',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary)),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: categories
                .map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _buildCategoryButton(cat['name']!, cat['icon']),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildCategoryButton(String category, String? emoji) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = category);
        _filtrarVehiculos();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? null : Border.all(color: _borderColor),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF4F46E5).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: _isDark ? 0.2 : 0.04),
              blurRadius: isSelected ? 12 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6)
            ],
            Text(category,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : _textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                )),
          ],
        ),
      ),
    );
  }

  // ─── DESTACADOS ──────────────────────────────────────────────────
  // ignore: unused_element
  Widget _buildDestacadosSection() {
    final destacados = _vehiculosFiltrados.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('✨ Destacados',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary)),
              GestureDetector(
                onTap: _scrollToAllVehiclesSection,
                child: Text('Ver todos',
                    style: GoogleFonts.inter(
                        color: const Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_isLoading)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ))
        else if (destacados.isEmpty)
          const Center(child: Text('No hay vehículos destacados'))
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: destacados.map((v) {
                final typeColor = _getTypeColor(v['categoria']);
                final vehicleId = v['id'] as int;
                final ratingData =
                    _vehicleRatings[vehicleId] ?? {'rating': 5.0, 'count': 0};
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildFeaturedCard(
                    vehicleId: vehicleId,
                    title: _vehicleDisplayName(v),
                    type: v['categoria'],
                    typeColor: typeColor,
                    rating: ratingData['rating'],
                    reviews: ratingData['count'],
                    price: v['precio_hora'],
                    precioDia: v['precio_dia'],
                    precioSemana: v['precio_semana'],
                    image: _resolveVehicleImage(v),
                    location: v['ubicacion'],
                    year: v['anio'],
                    transmission: v['transmision'],
                    seats: v['puertos'],
                    description: v['descripcion'],
                    fuelType: v['combustible'] ?? 'Gasolina',
                    hasAC: v['aire_acondicionado'] ?? true,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  /// Obtiene la información asociada a obtener tipo color.
  Color _getTypeColor(String categoria) {
    switch (categoria) {
      case 'SUV':
        return const Color(0xFF4F46E5);
      case 'Sedán':
        return const Color(0xFFE53935);
      case 'Compacto':
        return const Color(0xFF10B981);
      case 'Premium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF4F46E5);
    }
  }

  /// Gestiona normalize vehicle text dentro de esta parte del flujo.
  String _normalizeVehicleText(dynamic value) {
    return '$value'.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Gestiona vehicle display name dentro de esta parte del flujo.
  String _vehicleDisplayName(Map<String, dynamic> v) {
    final marca = _normalizeVehicleText(v['marca']);
    final rawModel = _normalizeVehicleText(v['modelo'] ?? v['linea']);
    final year = _normalizeVehicleText(v['anio']);

    var model = rawModel;
    if (marca.isNotEmpty &&
        model.toLowerCase().startsWith(marca.toLowerCase())) {
      model = model.substring(marca.length).trimLeft();
    }

    var base = [if (marca.isNotEmpty) marca, if (model.isNotEmpty) model]
        .join(' ')
        .trim();
    if (base.isEmpty) base = rawModel.isEmpty ? 'Vehiculo' : rawModel;

    final hasYear = RegExp(r'^\d{4}$').hasMatch(year);
    if (hasYear && !base.contains(year)) {
      return '$base $year';
    }
    return base;
  }

  /// Gestiona resolve vehicle imagen dentro de esta parte del flujo.
  String _resolveVehicleImage(Map<String, dynamic> vehicle) {
    return VehicleImageResolver.resolveFromVehicle(
      vehicle,
      preferredImage: vehicle['imagen']?.toString(),
      fallback: 'assets/imagenes_carros/cx5.jpg',
    );
  }

  Widget _buildFeaturedCard({
    required int vehicleId,
    required String title,
    required String type,
    required Color typeColor,
    required double rating,
    required int reviews,
    required int price,
    required int precioDia,
    required int precioSemana,
    required String image,
    required String location,
    required int year,
    required String transmission,
    required int seats,
    required String description,
    required String fuelType,
    required bool hasAC,
  }) {
    return Container(
      width: 210,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: _isDark ? Border.all(color: _borderColor) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: Stack(
              children: [
                FlexiVehicleImage(
                  imagePath: image,
                  height: 135,
                  width: 210,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    height: 135,
                    width: 210,
                    color: _isDark
                        ? const Color(0xFF1F2235)
                        : const Color(0xFF1E1B4B),
                    child: Icon(
                      Icons.directions_car,
                      size: 50,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.directions_car,
                          color: Colors.white, size: 10),
                      const SizedBox(width: 3),
                      Text(type,
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle)),
                      const SizedBox(width: 3),
                      Text('DISPONIBLE',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFBBF24), size: 14),
                  const SizedBox(width: 3),
                  Text('$rating',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: _textPrimary)),
                  const SizedBox(width: 2),
                  Text('($reviews)',
                      style: GoogleFonts.inter(color: _textSub, fontSize: 11)),
                ]),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: '\$ ${_formatPrice(price)}',
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF4F46E5),
                              fontWeight: FontWeight.w700,
                              fontSize: 17)),
                      TextSpan(
                          text: '/hora',
                          style:
                              GoogleFonts.inter(color: _textSub, fontSize: 11)),
                    ])),
                    GestureDetector(
                      onTap: () {
                        final specs =
                            '$year • $transmission • $seats puestos • $location';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ReservaDetallePage(
                                    vehicleId: vehicleId,
                                    vehicleName: title,
                                    vehicleSpecs: specs,
                                    vehicleDescription: description,
                                    fuelType: fuelType,
                                    hasAC: hasAC,
                                    vehicleRating: rating,
                                    vehicleReviews: reviews,
                                    vehiclePrice: price,
                                    vehicleImage: image,
                                    precioHora: price,
                                    precioDia: precioDia,
                                    precioSemana: precioSemana,
                                  )),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('RENTAR',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildVehicleListItem(Map<String, dynamic> v, bool isSmallPhone) {
    final vehicleId = v['id'] as int;
    final name = _vehicleDisplayName(v);
    final specs =
        '${v['anio']} • ${v['transmision']} • ${v['puertos']} puestos • ${v['ubicacion']}';
    final ratingData =
        _vehicleRatings[vehicleId] ?? {'rating': 5.0, 'count': 0};
    final rating = ratingData['rating'] as double;
    final reviews = ratingData['count'] as int;
    final price = v['precio_hora'] as int;
    final precioDia = v['precio_dia'] as int;
    final precioSemana = v['precio_semana'] as int;
    final image = _resolveVehicleImage(v);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: _isDark ? Border.all(color: _borderColor) : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
          child: FlexiVehicleImage(
            imagePath: image,
            width: isSmallPhone ? 100 : 120,
            height: isSmallPhone ? 100 : 120,
            fit: BoxFit.cover,
            placeholder: Container(
              width: isSmallPhone ? 100 : 120,
              height: isSmallPhone ? 100 : 120,
              color:
                  _isDark ? const Color(0xFF1F2235) : const Color(0xFF1E1B4B),
              child: Icon(
                Icons.directions_car,
                size: 36,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(isSmallPhone ? 12 : 14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(name,
                        style: GoogleFonts.poppins(
                            fontSize: isSmallPhone ? 13 : 15,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary))),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _isDark
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('LIBRE',
                      style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF10B981))),
                ),
              ]),
              const SizedBox(height: 4),
              Text(specs,
                  style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 11 : 12, color: _textSub)),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFBBF24), size: 14),
                const SizedBox(width: 3),
                Text('$rating',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: _textPrimary)),
                const SizedBox(width: 2),
                Text('($reviews reseñas)',
                    style: GoogleFonts.inter(
                        color: _textSub, fontSize: isSmallPhone ? 10 : 11)),
              ]),
              SizedBox(height: isSmallPhone ? 8 : 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: '\$ ${_formatPrice(price)}',
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF4F46E5),
                            fontWeight: FontWeight.w700,
                            fontSize: isSmallPhone ? 15 : 17)),
                    TextSpan(
                        text: '/h',
                        style:
                            GoogleFonts.inter(color: _textSub, fontSize: 11)),
                  ])),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ReservaDetallePage(
                                vehicleId: vehicleId,
                                vehicleName: name,
                                vehicleSpecs: specs,
                                vehicleDescription: 'Descripción del vehículo',
                                fuelType: 'Gasolina',
                                hasAC: true,
                                vehicleRating: rating,
                                vehicleReviews: reviews,
                                vehiclePrice: price,
                                vehicleImage: image,
                                precioHora: price,
                                precioDia: precioDia,
                                precioSemana: precioSemana,
                              )),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: isSmallPhone ? 12 : 14,
                          vertical: isSmallPhone ? 7 : 9),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('Ver',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: isSmallPhone ? 12 : 13,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white, size: 12),
                      ]),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildAdvancedDateCard({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          gradient: highlighted
              ? const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                )
              : null,
          color: highlighted ? null : _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: highlighted ? null : Border.all(color: _borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: highlighted ? Colors.white70 : _textSub,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: highlighted ? Colors.white : _textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── BÚSQUEDA AVANZADA (fechas, ciudad y categoría) ──────────────
  void _showAdvancedSearchSheet() {
    var tempCity = _selectedCity;
    var tempCategory = _selectedCategory;
    var tempStart = _fechaDesde;
    var tempEnd = _fechaHasta;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            Future<void> pickStartDate() async {
              final nowCo = ColombiaTime.now();
              final firstAllowed = DateTime(nowCo.year, nowCo.month, nowCo.day);
              final picked = await showDatePicker(
                context: sheetContext,
                initialDate: tempStart,
                firstDate: firstAllowed,
                lastDate: DateTime(2027, 12, 31),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme:
                        const ColorScheme.light(primary: Color(0xFF4F46E5)),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                setModalState(() {
                  tempStart = picked;
                  if (tempEnd.isBefore(tempStart)) {
                    tempEnd = tempStart.add(const Duration(days: 1));
                  }
                });
              }
            }

            Future<void> pickEndDate() async {
              final picked = await showDatePicker(
                context: sheetContext,
                initialDate: tempEnd,
                firstDate: tempStart,
                lastDate: DateTime(2027, 12, 31),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme:
                        const ColorScheme.light(primary: Color(0xFF4F46E5)),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                setModalState(() => tempEnd = picked);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: _borderColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Text(
                      'Búsqueda avanzada',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ciudad',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _textSub,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _allCitiesOption,
                        ..._cityCoordinates.keys,
                      ]
                          .map(
                            (city) => ChoiceChip(
                              label: Text(city),
                              selected: tempCity == city,
                              onSelected: (_) {
                                setModalState(() => tempCity = city);
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Fechas',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _textSub,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAdvancedDateCard(
                            label: 'Desde',
                            value: _formatFecha(tempStart),
                            onTap: pickStartDate,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildAdvancedDateCard(
                            label: 'Hasta',
                            value: _formatFecha(tempEnd),
                            onTap: pickEndDate,
                            highlighted: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Categoría',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _textSub,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Todos',
                        'Sedán',
                        'SUV',
                        'Compacto',
                        'Premium',
                        'Pickup',
                      ]
                          .map(
                            (category) => ChoiceChip(
                              label: Text(category),
                              selected: tempCategory == category,
                              onSelected: (_) {
                                setModalState(() => tempCategory = category);
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCity = tempCity;
                            _selectedCategory = tempCategory;
                            _fechaDesde = tempStart;
                            _fechaHasta = tempEnd;
                            _rentalStartDate = tempStart;
                            _rentalEndDate = tempEnd;
                            _datesConfirmed = true;
                            _categoryConfirmed = true;
                          });
                          Navigator.pop(sheetContext);
                          _executeSearch();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          backgroundColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          'Aplicar búsqueda',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCitySelector() {
    final sheetBg = _isDark ? const Color(0xFF161827) : Colors.white;
    final inputBg = _isDark ? const Color(0xFF1F2235) : Colors.grey.shade100;

    if (_isLoadingCities) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: 200,
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Cargando ciudades...',
                    style: GoogleFonts.inter(color: _textSub)),
              ],
            ),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(builder: (context, setModalState) {
          final cityOptions = <String>[_allCitiesOption, ..._cities];
          final filtered = cityOptions
              .where((c) => c.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Column(children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      _isDark ? const Color(0xFF2E3355) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Selecciona tu ciudad',
                              style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary)),
                          const SizedBox(height: 2),
                          Text(
                              '${_cities.length} ciudades disponibles en Colombia',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: _textSub)),
                        ])),
                    IconButton(
                      icon:
                          Icon(Icons.close_rounded, color: _textSub, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                      color: inputBg, borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    onChanged: (v) => setModalState(() => searchQuery = v),
                    style: GoogleFonts.inter(color: _textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Buscar ciudad...',
                      hintStyle:
                          GoogleFonts.inter(color: _textSub, fontSize: 14),
                      prefixIcon:
                          Icon(Icons.search_rounded, color: _textSub, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final cityName = filtered[index];
                    final isSel = cityName == _selectedCity;
                    final vehicleCount = _contarVehiculosPorCiudad(cityName);
                    final cityIcon =
                        _cityIcons[cityName] ?? Icons.location_city;
                    return InkWell(
                      onTap: () {
                        _handleCitySelected(cityName);

                        /// Crea una instancia y prepara el estado inicial de `Navigator`.
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSel
                              ? (_isDark
                                  ? const Color(0xFF4F46E5)
                                      .withValues(alpha: 0.15)
                                  : const Color(0xFFEEF2FF))
                              : (_isDark
                                  ? const Color(0xFF1F2235)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                isSel ? const Color(0xFF4F46E5) : _borderColor,
                            width: isSel ? 2 : 1,
                          ),
                        ),
                        child: Row(children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSel
                                  ? (_isDark
                                      ? const Color(0xFF4F46E5)
                                          .withValues(alpha: 0.2)
                                      : const Color(0xFFDDE4FF))
                                  : (_isDark
                                      ? const Color(0xFF272B40)
                                      : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                                child: Icon(cityIcon,
                                    color: isSel
                                        ? const Color(0xFF4F46E5)
                                        : _textSub,
                                    size: 22)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(cityName,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: isSel
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSel
                                          ? const Color(0xFF4F46E5)
                                          : _textPrimary,
                                    )),
                                Text('$vehicleCount vehículos disponibles',
                                    style: GoogleFonts.inter(
                                        fontSize: 12, color: _textSub)),
                              ])),
                          if (isSel)
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF4F46E5), size: 22),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ]),
          );
        });
      },
    );
  }

  /// Gestiona format precio dentro de esta parte del flujo.
  String _formatPrice(int price) => price
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
}

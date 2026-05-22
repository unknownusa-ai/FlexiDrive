// Importamos Flutter - lo básico para la UI
import 'dart:async';

import 'package:flutter/material.dart';
// Fuentes bonitas de Google
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _allVehiclesSectionKey = GlobalKey();

  // Caché de calificaciones: vehicleId -> {rating, count}
  // Guardamos esto para no calcular todo el tiempo
  final Map<int, Map<String, dynamic>> _vehicleRatings = {};

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
  String get _citySectionLabel =>
      _isAllCitiesSelected ? 'todas las ciudades' : _selectedCity;

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
    _scrollController.dispose();
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
    var filtrados = _vehiculos.where((v) {
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

    // Filtro por categoría
    if (_selectedCategory != 'Todos') {
      filtrados =
          filtrados.where((v) => v['categoria'] == _selectedCategory).toList();
    }

    setState(() {
      _vehiculosFiltrados = filtrados;
    });
  }

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildPromoBanner(),
              const SizedBox(height: 20),
              _buildDateSelector(),
              const SizedBox(height: 20),
              _buildCategories(),
              const SizedBox(height: 20),
              if (_selectedCategory == 'Todos') ...[
                _buildDestacadosSection(),
                const SizedBox(height: 24),
                _buildAllVehiclesSection(),
                const SizedBox(height: 24),
              ] else if (_selectedCategory == 'Sedán') ...[
                _buildSedanSection(),
                const SizedBox(height: 24),
              ] else if (_selectedCategory == 'SUV') ...[
                _buildSUVSection(),
                const SizedBox(height: 24),
              ] else if (_selectedCategory == 'Compacto') ...[
                _buildCompactoSection(),
                const SizedBox(height: 24),
              ] else if (_selectedCategory == 'Premium') ...[
                _buildPremiumSection(),
                const SizedBox(height: 24),
              ] else if (_selectedCategory == 'Pickup') ...[
                _buildPickupSection(),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 60,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => MainPage.of(context).setIndex(3),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                      width: 2),
                                ),
                                child: const Icon(Icons.person,
                                    color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Buenas tardes 👋',
                                      style: GoogleFonts.inter(
                                          color: Colors.white
                                              .withValues(alpha: 0.75),
                                          fontSize: 12)),
                                  Text(_currentUserName,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => MainPage.of(context).setIndex(2),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.notifications_none_rounded,
                                    color: Colors.white, size: 22),
                                if (_hasUnreadNotifications)
                                  Positioned(
                                    top: 9,
                                    right: 9,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFEF4444),
                                          shape: BoxShape.circle),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Text('¿A dónde vas hoy?',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8)),
                          child:
                              const Text('🏞️', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Encuentra el vehículo perfecto para ti',
                        style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13)),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
              _buildSearchBar(),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildSearchBar() {
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

  // ─── PROMO BANNER ────────────────────────────────────────────────
  Widget _buildPromoBanner() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? colorScheme.outline : const Color(0xFFD1FAE5),
              width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981)
                  .withValues(alpha: isDark ? 0.15 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.trending_down_rounded,
                  color: const Color(0xFF10B981), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🌿 Ahorra hasta un 60%',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'vs. taxi tradicional en Bogotá',
                    style: GoogleFonts.inter(
                      color: theme.hintColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  'Ver más',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF10B981), size: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── DATE SELECTOR ───────────────────────────────────────────────
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

  // ─── ALL VEHICLES ────────────────────────────────────────────────
  Widget _buildAllVehiclesSection() {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);

    return Container(
      key: _allVehiclesSectionKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallPhone ? 16 : 20),
            child: Row(children: [
              const Text('🚗', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('Vehículos en $_citySectionLabel',
                      style: GoogleFonts.poppins(
                          fontSize: isSmallPhone ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      _isDark ? const Color(0xFF1F2235) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${_vehiculosFiltrados.length} disponibles',
                    style: GoogleFonts.inter(
                        color: _textSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          if (_isLoading)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ))
          else if (_vehiculosFiltrados.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: _textSub),
                    const SizedBox(height: 16),
                    Text(
                      'No se encontraron vehículos',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Intenta con otra búsqueda o ciudad',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _textSub,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallPhone ? 16 : 20),
              child: Column(
                  children: _vehiculosFiltrados
                      .map((v) => _buildVehicleListItem(v, isSmallPhone))
                      .toList()),
            ),
          const SizedBox(height: 20),
          _buildCompareSection(isSmallPhone),
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

  // ─── COMPARE SECTION ─────────────────────────────────────────────
  Widget _buildCompareSection(bool isSmallPhone) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallPhone ? 16 : 20),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: _isDark
              ? Border.all(color: _borderColor)
              : Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
        child: Column(children: [
          Row(children: [
            const Icon(Icons.bolt_rounded, color: Color(0xFF4F46E5), size: 22),
            const SizedBox(width: 8),
            Text('Compara y ahorra 💰',
                style: GoogleFonts.poppins(
                    fontSize: isSmallPhone ? 15 : 16,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary)),
          ]),
          SizedBox(height: isSmallPhone ? 16 : 20),
          Row(children: [
            Expanded(
                child: Column(children: [
              const Text('🚕', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text('Taxi (8h)',
                  style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 11 : 12, color: _textSub)),
              const SizedBox(height: 4),
              Text('\$ 180.000',
                  style: GoogleFonts.poppins(
                      fontSize: isSmallPhone ? 18 : 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444))),
            ])),
            Container(width: 1, height: 70, color: _dividerColor),
            Expanded(
                child: Column(children: [
              const Text('🚗', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text('FlexiDrive (8h)',
                  style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 11 : 12, color: _textSub)),
              const SizedBox(height: 4),
              Text('\$ 72.000',
                  style: GoogleFonts.poppins(
                      fontSize: isSmallPhone ? 18 : 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF10B981))),
            ])),
          ]),
          SizedBox(height: isSmallPhone ? 12 : 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isSmallPhone ? 10 : 12),
            decoration: BoxDecoration(
              color: _isDark
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: _isDark
                  ? Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2))
                  : null,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🎉', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('Ahorro estimado: \$ 108.000 (60%)',
                  style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 12 : 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981))),
            ]),
          ),
        ]),
      ),
    );
  }

  // ─── CATEGORY SECTIONS ───────────────────────────────────────────
  Widget _buildSedanSection() {
    final sedanes =
        _vehiculosFiltrados.where((v) => v['categoria'] == 'Sedán').toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildCategoryHeader(
          '🚗', 'Sedán en $_citySectionLabel', '${sedanes.length} disponibles'),
      const SizedBox(height: 16),
      if (_isLoading)
        const Center(child: CircularProgressIndicator())
      else if (sedanes.isEmpty)
        _buildEmptyCategoryMessage('No hay sedanes disponibles en esta ciudad')
      else
        ...sedanes.map((v) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: _buildHorizontalCardFromJson(v),
            )),
      const SizedBox(height: 24),
      _buildCompareSection(true),
    ]);
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildSUVSection() {
    final suvs =
        _vehiculosFiltrados.where((v) => v['categoria'] == 'SUV').toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildCategoryHeader(
          '🚙', 'SUV en $_citySectionLabel', '${suvs.length} disponibles'),
      const SizedBox(height: 16),
      if (_isLoading)
        const Center(child: CircularProgressIndicator())
      else if (suvs.isEmpty)
        _buildEmptyCategoryMessage('No hay SUVs disponibles en esta ciudad')
      else
        ...suvs.map((v) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: _buildHorizontalCardFromJson(v),
            )),
      const SizedBox(height: 24),
      _buildCompareSection(true),
    ]);
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildCompactoSection() {
    final compactos =
        _vehiculosFiltrados.where((v) => v['categoria'] == 'Compacto').toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildCategoryHeader('🚗', 'Compacto en $_citySectionLabel',
          '${compactos.length} disponibles'),
      const SizedBox(height: 16),
      if (_isLoading)
        const Center(child: CircularProgressIndicator())
      else if (compactos.isEmpty)
        _buildEmptyCategoryMessage(
            'No hay compactos disponibles en esta ciudad')
      else
        ...compactos.map((v) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: _buildHorizontalCardFromJson(v),
            )),
      const SizedBox(height: 24),
      _buildCompareSection(true),
    ]);
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildPremiumSection() {
    final premium =
        _vehiculosFiltrados.where((v) => v['categoria'] == 'Premium').toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildCategoryHeader('✨', 'Premium en $_citySectionLabel',
          '${premium.length} disponibles'),
      const SizedBox(height: 16),
      if (_isLoading)
        const Center(child: CircularProgressIndicator())
      else if (premium.isEmpty)
        _buildEmptyCategoryMessage(
            'No hay vehículos premium disponibles en esta ciudad')
      else
        ...premium.map((v) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: _buildHorizontalCardFromJson(v),
            )),
      const SizedBox(height: 24),
      _buildCompareSection(true),
    ]);
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildPickupSection() {
    final pickups =
        _vehiculosFiltrados.where((v) => v['categoria'] == 'Pickup').toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildCategoryHeader('🛻', 'Pickup en $_citySectionLabel',
          '${pickups.length} disponibles'),
      const SizedBox(height: 16),
      if (_isLoading)
        const Center(child: CircularProgressIndicator())
      else if (pickups.isEmpty)
        _buildEmptyCategoryMessage('No hay pickups disponibles en esta ciudad')
      else
        ...pickups.map((v) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: _buildHorizontalCardFromJson(v),
            )),
      const SizedBox(height: 24),
      _buildCompareSection(true),
    ]);
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildEmptyCategoryMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: _textSub,
          ),
        ),
      ),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildCategoryHeader(String emoji, String title, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF1F2235) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(count,
              style: GoogleFonts.inter(
                  color: _textSub, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildHorizontalCardFromJson(Map<String, dynamic> v) {
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
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: _isDark ? Border.all(color: _borderColor) : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
          child: FlexiVehicleImage(
            imagePath: image,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            placeholder: Container(
              width: 120,
              height: 120,
              color:
                  _isDark ? const Color(0xFF1F2235) : const Color(0xFF1E1B4B),
              child: Icon(
                Icons.directions_car,
                size: 50,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary)),
              const SizedBox(height: 4),
              Text(specs,
                  style: GoogleFonts.inter(fontSize: 11, color: _textSub)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFBBF24), size: 15),
                const SizedBox(width: 4),
                Text('$rating',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _textPrimary)),
                const SizedBox(width: 2),
                Text('($reviews reseñas)',
                    style: GoogleFonts.inter(color: _textSub, fontSize: 11)),
              ]),
              const SizedBox(height: 12),
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
                        text: '/h',
                        style:
                            GoogleFonts.inter(color: _textSub, fontSize: 12)),
                  ])),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReservaDetallePage(
                                  vehicleId: vehicleId,
                                  vehicleName: name,
                                  vehicleSpecs: specs,
                                  vehicleDescription:
                                      'Descripción del vehículo',
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
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('Ver',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 14),
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

  // ─── ciudad SELECTOR ───────────────────────────────────────────────
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
                        setState(() => _selectedCity = cityName);
                        _filtrarVehiculos();

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

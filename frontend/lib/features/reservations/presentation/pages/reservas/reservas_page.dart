// Flutter framework
import 'package:flutter/material.dart';
// Fuentes bonitas de Google
import 'package:google_fonts/google_fonts.dart';

// Sesion del usuario actual
import 'package:flexidrive/core/session/local_session_store.dart';
// Base de datos de publicaciones
import 'package:flexidrive/features/publications/application/use_cases/publication_access_use_case.dart';
// Base de datos de reservas
import 'package:flexidrive/features/reservations/application/use_cases/reservation_access_use_case.dart';
import 'package:flexidrive/features/reservations/domain/entities/reservation_models.dart';
// Base de datos de reseñas
import 'package:flexidrive/features/reviews/application/use_cases/review_access_use_case.dart';
// Servicio de vehiculos
import 'package:flexidrive/features/vehicles/application/use_cases/vehicle_inventory_use_case.dart';
import 'package:flexidrive/injection_container.dart';
import 'package:flexidrive/core/widgets/flexi_vehicle_image.dart';
import 'package:flexidrive/core/utils/vehicle_image_resolver.dart';

// Pagina de detalle de reserva
import 'reserva_detalle_completa_page.dart';
// Utilidades responsive
import 'package:flexidrive/core/utils/responsive_utils.dart';

// Página de reservas del usuario
// Muestra todas las reservas activas y pasadas
class ReservasPage extends StatefulWidget {
  /// Crea una instancia y prepara el estado inicial de `ReservasPage`.
  const ReservasPage({super.key});

  /// Gestiona crear estado dentro de esta parte del flujo.
  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

// Estado de la pagina de reservas
class _ReservasPageState extends State<ReservasPage>
    with WidgetsBindingObserver {
  // Filtro seleccionado: Activas, Pendientes, Finalizadas, Historial
  String _selectedFilter = 'Activas';
  // Contador de reservas finalizadas
  int _finalizadasCount = 0;
  // Contador de reservas canceladas
  int _canceladasCount = 0;
  // Esta cargando el historial?
  bool _isLoadingHistory = true;

  // Base de datos de reservas
  final ReservationAccessUseCase _reservationDb =
      InjectionContainer.instance.reservationAccessUseCase;
  // Base de datos de publicaciones
  final PublicationAccessUseCase _publicationDb =
      InjectionContainer.instance.publicationAccessUseCase;
  // Servicio de vehiculos
  final VehicleInventoryUseCase _vehiculoService =
      InjectionContainer.instance.vehicleInventoryUseCase;
  // Base de datos de reseñas
  final ReviewAccessUseCase _reviewDb =
      InjectionContainer.instance.reviewAccessUseCase;
  // Sesion del usuario
  final LocalSessionStore _sessionStore = LocalSessionStore.instance;

  // Lista de reservas activas
  List<_ReservaCardData> _activeReservations = [];
  // Lista de reservas pendientes
  List<_ReservaCardData> _pendingReservations = [];
  // Lista de historial de reservas
  List<_ReservaCardData> _historyReservations = [];
  // Lista de reservas finalizadas
  List<_ReservaCardData> _completedReservations = [];

  /// Inicializa el proceso de inicialización del estado antes de su uso.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadHistoryReservations(); // Carga historial de reservas
  }

  /// Gestiona dispose dentro de esta parte del flujo.
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Gestiona did change app lifecycle estado dentro de esta parte del flujo.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recargar reservas cuando la app vuelve a primer plano
      _refreshReservations();
    }
  }

  /// Gestiona did change dependencies dentro de esta parte del flujo.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar reservas cuando se regresa a esta página
    _refreshReservations();
  }

  // Refresca todas las reservas
  Future<void> _refreshReservations() async {
    setState(() => _isLoadingHistory = true);
    // Small delay a ensure new reserva is properly saved
    await Future.delayed(const Duration(milliseconds: 100));
    await _loadHistoryReservations();
  }

  // Carga el historial de reservas del usuario
  Future<void> _loadHistoryReservations() async {
    // Espera que todo cargue en paralelo
    await Future.wait([
      _sessionStore.init(),
      _reservationDb.loadIfNeeded(),
      _publicationDb.loadIfNeeded(),
      _vehiculoService.init(),
      _reviewDb.loadIfNeeded(),
    ]);

    final currentUserId = _sessionStore.userId;
    final userReservations = currentUserId == null
        ? <ReservationModel>[]
        : _reservationDb.reservations
            .where((reservation) => reservation.userId == currentUserId)
            .toList();

    // Separar reservas por estado
    final now = DateTime.now();
    final pendingReservations = userReservations
        .where((reservation) => reservation.statusId == 1)
        .toList()
      ..sort((a, b) => b.reservationDate
          .compareTo(a.reservationDate)); // statusId = 1 (Pendiente)

    final activeReservations = userReservations
        .where(
          (reservation) =>
              reservation.statusId == 4 ||
              (reservation.statusId == 2 && reservation.endDate.isAfter(now)),
        )
        .toList()
      ..sort((a, b) => b.reservationDate
          .compareTo(a.reservationDate)); // statusId = 4 (Activa)

    final publicationsById = {
      for (final publication in _publicationDb.publications)
        publication.id: publication,
    };
    final vehiclesById = {
      for (final vehicle in _vehiculoService.getVehiculos())
        vehicle['id']: vehicle,
    };

    final opinionsById = {
      for (final opinion in _reviewDb.opinions) opinion.id: opinion.rating,
    };

    final pricesByPublication = <int, Map<int, int>>{};
    for (final price in _publicationDb.publicationPrices) {
      pricesByPublication.putIfAbsent(
              price.publicationId, () => {})[price.periodTypeId] =
          price.price.round();
    }

    final mainImagesByPublication = <int, String>{};
    for (final image in _publicationDb.publicationImages) {
      final current = mainImagesByPublication[image.publicationId];
      if (current == null || image.isMain || image.order == 1) {
        mainImagesByPublication[image.publicationId] = image.imageUrl;
      }
    }

    // Procesar reservas pendientes
    final pendingReservationData = pendingReservations.map((reservation) {
      final publication = publicationsById[reservation.publicationId];
      final vehicle =
          publication == null ? null : vehiclesById[publication.vehicleId];
      final pubPrices =
          pricesByPublication[reservation.publicationId] ?? const <int, int>{};
      final reviewsForPublication = _reviewDb.reviews
          .where((review) => review.publicationId == reservation.publicationId)
          .toList();
      final rating = reviewsForPublication.isEmpty
          ? 4.9
          : reviewsForPublication
                  .map((review) => opinionsById[review.opinionId] ?? 0)
                  .fold<int>(0, (sum, current) => sum + current) /
              reviewsForPublication.length;

      final status = _statusLabel(reservation.statusId);
      return _ReservaCardData(
        vehicleName: vehicle == null
            ? 'Reserva ${reservation.code}'
            : _vehicleNameFromMap(vehicle),
        code: reservation.code,
        price: '\$ ${_formatAmount(reservation.totalValue.round())}',
        startDate: _formatDate(reservation.startDate),
        endDate: _formatDate(reservation.endDate),
        location:
            '${reservation.pickupLocation} - ${reservation.returnLocation}',
        progress: 0.2, // Progress for pending reservations
        status: status,
        imageUrl: _resolveVehicleImage(
          vehicle,
          publicationImage: mainImagesByPublication[reservation.publicationId],
        ),
        showEnCurso: false,
        vehicleSpecs: vehicle == null
            ? '2024 - Negro Jet'
            : _vehicleSpecsFromMap(vehicle),
        vehicleRating: rating,
        vehicleReviews: reviewsForPublication.length,
        vehiclePrice: pubPrices[reservation.periodTypeId] ??
            reservation.totalValue.round(),
        precioDia: pubPrices[2],
        precioSemana: pubPrices[3],
        statusColor: _statusColor(status),
        secondaryActionLabel: 'Cancelar',
        secondaryActionIcon: Icons.close,
        secondaryButtonColor: const Color(0xFFFEE2E2),
        secondaryTextColor: const Color(0xFFDC2626),
      );
    }).toList();

    // Procesar reservas activas
    final activeReservationData = activeReservations.map((reservation) {
      final publication = publicationsById[reservation.publicationId];
      final vehicle =
          publication == null ? null : vehiclesById[publication.vehicleId];
      final pubPrices =
          pricesByPublication[reservation.publicationId] ?? const <int, int>{};
      final reviewsForPublication = _reviewDb.reviews
          .where((review) => review.publicationId == reservation.publicationId)
          .toList();
      final rating = reviewsForPublication.isEmpty
          ? 4.9
          : reviewsForPublication
                  .map((review) => opinionsById[review.opinionId] ?? 0)
                  .fold<int>(0, (sum, current) => sum + current) /
              reviewsForPublication.length;

      final status = _statusLabel(reservation.statusId);
      return _ReservaCardData(
        vehicleName: vehicle == null
            ? 'Reserva ${reservation.code}'
            : _vehicleNameFromMap(vehicle),
        code: reservation.code,
        price: '\$ ${_formatAmount(reservation.totalValue.round())}',
        startDate: _formatDate(reservation.startDate),
        endDate: _formatDate(reservation.endDate),
        location:
            '${reservation.pickupLocation} - ${reservation.returnLocation}',
        progress: status == 'Activa'
            ? 0.4
            : status == 'Cancelada'
                ? 0.0
                : 1.0,
        status: status,
        imageUrl: _resolveVehicleImage(
          vehicle,
          publicationImage: mainImagesByPublication[reservation.publicationId],
        ),
        showEnCurso: status == 'Activa',
        vehicleSpecs: vehicle == null
            ? '2024 - Negro Jet'
            : _vehicleSpecsFromMap(vehicle),
        vehicleRating: rating,
        vehicleReviews: reviewsForPublication.length,
        vehiclePrice: pubPrices[reservation.periodTypeId] ??
            reservation.totalValue.round(),
        precioDia: pubPrices[2],
        precioSemana: pubPrices[3],
        statusColor: _statusColor(status),
        secondaryActionLabel: status == 'Activa' ? 'Cancelar' : 'Calificar',
        secondaryActionIcon:
            status == 'Activa' ? Icons.close : Icons.star_rounded,
        secondaryButtonColor: status == 'Activa'
            ? const Color(0xFFFEE2E2)
            : const Color(0xFFFCD34D),
        secondaryTextColor: status == 'Activa'
            ? const Color(0xFFDC2626)
            : const Color(0xFF111827),
      );
    }).toList();

    final reservationsForHistory = userReservations
        .where((reservation) => reservation.statusId != 1)
        .toList()
      ..sort((a, b) => b.reservationDate.compareTo(a.reservationDate));

    final history = reservationsForHistory.map((reservation) {
      final publication = publicationsById[reservation.publicationId];
      final vehicle =
          publication == null ? null : vehiclesById[publication.vehicleId];
      final pubPrices =
          pricesByPublication[reservation.publicationId] ?? const <int, int>{};
      final reviewsForPublication = _reviewDb.reviews
          .where((review) => review.publicationId == reservation.publicationId)
          .toList();
      final rating = reviewsForPublication.isEmpty
          ? 4.9
          : reviewsForPublication
                  .map((review) => opinionsById[review.opinionId] ?? 0)
                  .fold<int>(0, (sum, current) => sum + current) /
              reviewsForPublication.length;

      final status = _statusLabel(reservation.statusId);
      return _ReservaCardData(
        vehicleName: vehicle == null
            ? 'Reserva ${reservation.code}'
            : _vehicleNameFromMap(vehicle),
        code: reservation.code,
        price: '\$ ${_formatAmount(reservation.totalValue.round())}',
        startDate: _formatDate(reservation.startDate),
        endDate: _formatDate(reservation.endDate),
        location:
            '${reservation.pickupLocation} - ${reservation.returnLocation}',
        progress: status == 'Activa'
            ? 0.4
            : status == 'Cancelada'
                ? 0.0
                : 1.0,
        status: status,
        imageUrl: _resolveVehicleImage(
          vehicle,
          publicationImage: mainImagesByPublication[reservation.publicationId],
        ),
        showEnCurso: status == 'Activa',
        vehicleSpecs: vehicle == null
            ? '2024 - Negro Jet'
            : _vehicleSpecsFromMap(vehicle),
        vehicleRating: rating,
        vehicleReviews: reviewsForPublication.length,
        vehiclePrice: pubPrices[reservation.periodTypeId] ??
            reservation.totalValue.round(),
        precioDia: pubPrices[2],
        precioSemana: pubPrices[3],
        statusColor: _statusColor(status),
        secondaryActionLabel: status == 'Activa' ? 'Cancelar' : 'Calificar',
        secondaryActionIcon:
            status == 'Activa' ? Icons.close : Icons.star_rounded,
        secondaryButtonColor: status == 'Activa'
            ? const Color(0xFFFEE2E2)
            : const Color(0xFFFCD34D),
        secondaryTextColor: status == 'Activa'
            ? const Color(0xFFDC2626)
            : const Color(0xFF111827),
      );
    }).toList();

    final finalizadas =
        history.where((item) => item.status == 'Finalizada').length;
    final canceladas =
        history.where((item) => item.status == 'Cancelada').length;

    if (!mounted) return;

    setState(() {
      _activeReservations = activeReservationData;
      _pendingReservations = pendingReservationData;
      _historyReservations = history;
      _completedReservations =
          history.where((item) => item.status == 'Finalizada').toList();
      _finalizadasCount = finalizadas;
      _canceladasCount = canceladas;
      _isLoadingHistory = false;
    });
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activasCount = _activeReservations.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ConstrainedContainer(
        maxWidth: 800,
        child: Column(children: [
          Stack(clipBehavior: Clip.none, children: [
            _buildHeader(activasCount),
            Positioned(
                left: 20,
                right: 20,
                bottom: -45,
                child: _buildStatisticsCards(activasCount)),
          ]),
          const SizedBox(height: 58),
          _buildFilterButtons(),
          const SizedBox(height: 20),
          Expanded(child: _buildReservationsList()),
        ]),
      ),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildHeader(int activasCount) {
    final label = activasCount == 1
        ? '1 reserva activa'
        : '$activasCount reservas activas';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
        ),
      ),
      child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 52),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Mis Reservas',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text(label,
                  style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ]),
          )),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildStatisticsCards(int activasCount) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    return SizedBox(
        height: isSmallPhone ? 78 : 86,
        child: Row(children: [
          Expanded(
              child: _buildStatCard(
                  count: activasCount,
                  label: 'Activas',
                  color: const Color(0xFFD1FAE5),
                  textColor: const Color(0xFF10B981))),
          const SizedBox(width: 8),
          Expanded(
              child: _buildStatCard(
                  count: _finalizadasCount,
                  label: 'Finalizadas',
                  color: const Color(0xFFDBEAFE),
                  textColor: const Color(0xFF3B82F6))),
          const SizedBox(width: 8),
          Expanded(
              child: _buildStatCard(
                  count: _canceladasCount,
                  label: 'Canceladas',
                  color: const Color(0xFFFEE2E2),
                  textColor: const Color(0xFFEF4444))),
        ]));
  }

  Widget _buildStatCard(
      {required int count,
      required String label,
      required Color color,
      required Color textColor}) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmallPhone ? 4 : 5,
        horizontal: isSmallPhone ? 8 : 10,
      ),
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('$count',
            style: GoogleFonts.poppins(
                color: textColor,
                fontSize: isSmallPhone ? 24 : 27,
                fontWeight: FontWeight.bold,
                height: 1.0)),
        const SizedBox(height: 1),
        Flexible(
            child: Text(label,
                style: GoogleFonts.poppins(
                    color: textColor.withValues(alpha: 0.85),
                    fontSize: isSmallPhone ? 10 : 11,
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildFilterButtons() {
    final theme = Theme.of(context);
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final filters = <String>[
      'Activas',
      'Pendientes',
      'Finalizadas',
      'Historial',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallPhone ? 10 : 12,
          vertical: isSmallPhone ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedFilter,
            menuMaxHeight: 290,
            dropdownColor: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            icon: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            style: GoogleFonts.poppins(
              color: theme.colorScheme.onSurface,
              fontSize: isSmallPhone ? 14 : 15,
              fontWeight: FontWeight.w600,
            ),
            selectedItemBuilder: (context) {
              return filters.map((filter) {
                final count = _filterCount(filter);
                return Row(
                  children: [
                    Container(
                      width: isSmallPhone ? 24 : 26,
                      height: isSmallPhone ? 24 : 26,
                      decoration: BoxDecoration(
                        color: _filterIconColor(filter).withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _filterIcon(filter),
                        size: isSmallPhone ? 15 : 16,
                        color: _filterIconColor(filter),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filter,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallPhone ? 11 : 12,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList();
            },
            items: filters.map((filter) {
              final isSelected = _selectedFilter == filter;
              final count = _filterCount(filter);
              return DropdownMenuItem<String>(
                value: filter,
                child: Row(
                  children: [
                    Container(
                      width: isSmallPhone ? 24 : 26,
                      height: isSmallPhone ? 24 : 26,
                      decoration: BoxDecoration(
                        color: _filterIconColor(filter).withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _filterIcon(filter),
                        size: isSmallPhone ? 15 : 16,
                        color: _filterIconColor(filter),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        filter,
                        style: GoogleFonts.poppins(
                          color: isSelected
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.85),
                          fontSize: isSmallPhone ? 13 : 14,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallPhone ? 11 : 12,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: isSmallPhone ? 18 : 19,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.25),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedFilter = value);
            },
          ),
        ),
      ),
    );
  }

  /// Gestiona filter icon dentro de esta parte del flujo.
  IconData _filterIcon(String filter) {
    switch (filter) {
      case 'Activas':
        return Icons.play_circle_rounded;
      case 'Pendientes':
        return Icons.schedule_rounded;
      case 'Finalizadas':
        return Icons.verified_rounded;
      case 'Historial':
        return Icons.history_rounded;
      default:
        return Icons.tune_rounded;
    }
  }

  /// Gestiona filter icon color dentro de esta parte del flujo.
  Color _filterIconColor(String filter) {
    switch (filter) {
      case 'Activas':
        return const Color(0xFF10B981);
      case 'Pendientes':
        return const Color(0xFFF59E0B);
      case 'Finalizadas':
        return const Color(0xFF3B82F6);
      case 'Historial':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF64748B);
    }
  }

  /// Gestiona filter count dentro de esta parte del flujo.
  int _filterCount(String filter) {
    switch (filter) {
      case 'Activas':
        return _activeReservations.length;
      case 'Pendientes':
        return _pendingReservations.length;
      case 'Finalizadas':
        return _completedReservations.length;
      case 'Historial':
        return _historyReservations.length;
      default:
        return 0;
    }
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildReservationsList() {
    if (_selectedFilter == 'Activas') {
      if (_activeReservations.isEmpty) {
        return _buildEmptyActiveReservations();
      }

      return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: _activeReservations
              .map((reserva) => _buildReservationCard(
                    data: reserva,
                    onSecondaryAction: () =>
                        _showCancelReservationSheetForCardData(
                      reserva: reserva,
                    ),
                    onViewDetails: () => _openReservationDetails(
                      vehicleName: reserva.vehicleName,
                      vehicleSpecs: reserva.vehicleSpecs ?? '2024 - Negro Jet',
                      vehicleRating: reserva.vehicleRating ?? 4.9,
                      vehicleReviews: reserva.vehicleReviews ?? 128,
                      vehiclePrice: reserva.vehiclePrice ?? 440000,
                      vehicleImage: reserva.imageUrl,
                      precioDia: reserva.precioDia ?? 440000,
                      precioSemana: reserva.precioSemana ?? 2640000,
                      reservaCode: reserva.code,
                    ),
                  ))
              .toList());
    } else if (_selectedFilter == 'Pendientes') {
      if (_pendingReservations.isEmpty) {
        return _buildEmptyPendingReservations();
      }

      return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: _pendingReservations
              .map((reserva) => _buildReservationCard(
                    data: reserva,
                    onSecondaryAction: () =>
                        _showCancelReservationSheetForCardData(
                      reserva: reserva,
                    ),
                    onViewDetails: () => _openReservationDetails(
                      vehicleName: reserva.vehicleName,
                      vehicleSpecs: reserva.vehicleSpecs ?? '2024 - Negro Jet',
                      vehicleRating: reserva.vehicleRating ?? 4.9,
                      vehicleReviews: reserva.vehicleReviews ?? 128,
                      vehiclePrice: reserva.vehiclePrice ?? 440000,
                      vehicleImage: reserva.imageUrl,
                      precioDia: reserva.precioDia ?? 440000,
                      precioSemana: reserva.precioSemana ?? 2640000,
                      reservaCode: reserva.code,
                    ),
                  ))
              .toList());
    } else if (_selectedFilter == 'Finalizadas') {
      if (_isLoadingHistory) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_completedReservations.isEmpty) {
        return _buildEmptyCompletedReservations();
      }

      return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: _completedReservations
              .map((reserva) => _buildReservationCard(
                    data: reserva,
                    onSecondaryAction: () {},
                    onViewDetails: () => _openReservationDetails(
                      vehicleName: reserva.vehicleName,
                      vehicleSpecs: reserva.vehicleSpecs ?? '2024 - Negro Jet',
                      vehicleRating: reserva.vehicleRating ?? 4.9,
                      vehicleReviews: reserva.vehicleReviews ?? 128,
                      vehiclePrice: reserva.vehiclePrice ?? 380000,
                      vehicleImage: reserva.imageUrl,
                      precioDia: reserva.precioDia,
                      precioSemana: reserva.precioSemana,
                    ),
                  ))
              .toList());
    } else {
      if (_isLoadingHistory) {
        return const Center(child: CircularProgressIndicator());
      }

      final reservations = _historyReservations;

      return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: reservations
              .map((reserva) => _buildReservationCard(
                    data: reserva,
                    onSecondaryAction: () {},
                    onViewDetails: () => _openReservationDetails(
                      vehicleName: reserva.vehicleName,
                      vehicleSpecs: reserva.vehicleSpecs ?? '2024 - Negro Jet',
                      vehicleRating: reserva.vehicleRating ?? 4.9,
                      vehicleReviews: reserva.vehicleReviews ?? 128,
                      vehiclePrice: reserva.vehiclePrice ?? 380000,
                      vehicleImage: reserva.imageUrl,
                      precioDia: reserva.precioDia,
                      precioSemana: reserva.precioSemana,
                    ),
                  ))
              .toList());
    }
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildEmptyActiveReservations() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 56,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 10),
            Text(
              'No tienes reservas activas',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildEmptyPendingReservations() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hourglass_empty_outlined,
              size: 56,
              color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 10),
            Text(
              'No tienes reservas pendientes',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las reservas pendientes aparecerán aquí',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildEmptyCompletedReservations() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 56,
              color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 10),
            Text(
              'No tienes reservas finalizadas',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las reservas que terminen aparecerán aquí',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCancelReservationSheetForCardData({
    required _ReservaCardData reserva,
  }) async {
    final theme = Theme.of(context);
    final shouldCancel = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFBCFE8)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: const Color(0xFFE5E7EB),
                          child: reserva.imageUrl.isEmpty
                              ? _buildSmallPlaceholder()
                              : FlexiVehicleImage(
                                  imagePath: reserva.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: _buildSmallPlaceholder(),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reserva.vehicleName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${reserva.startDate} - ${reserva.price}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '¿Estás seguro de que deseas cancelar esta reserva?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Esta acción no se puede deshacer',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Mantener',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(sheetContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Si, cancelar',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldCancel == true) {
      final reservationIndex =
          _reservationDb.reservations.indexWhere((r) => r.code == reserva.code);
      if (reservationIndex != -1) {
        _reservationDb.reservations.removeAt(reservationIndex);
      }

      // recargar all reservas a actualizar listas
      await _refreshReservations();
    }
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildSmallPlaceholder() => const Center(
        child: Icon(
          Icons.directions_car,
          size: 22,
          color: Color(0xFF9CA3AF),
        ),
      );

  String _resolveVehicleImage(
    Map<String, dynamic>? vehicle, {
    String? publicationImage,
  }) {
    return VehicleImageResolver.resolveFromVehicle(
      vehicle,
      preferredImage: publicationImage,
      fallback: 'assets/imagenes_carros/cx5.jpg',
    );
  }

  Widget _buildReservationCard({
    required _ReservaCardData data,
    required VoidCallback onSecondaryAction,
    required VoidCallback onViewDetails,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                    theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    theme.colorScheme.onSurface.withValues(alpha: 0.05)
                  ])),
              child: data.imageUrl.isEmpty
                  ? _buildPlaceholder()
                  : FlexiVehicleImage(
                      imagePath: data.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: _buildPlaceholder(),
                    ),
            ),
          ),
          if (data.showEnCurso)
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(6)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFF10B981), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('EN CURSO',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                ]),
              ),
            ),
        ]),
        Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Text(data.vehicleName,
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface))),
                    const SizedBox(width: 8),
                    Text(data.price,
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary)),
                  ]),
              const SizedBox(height: 4),
              Text(data.code,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 6),
                Text('${data.startDate} -> ${data.endDate}',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.location_on_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(data.location,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Ver Detalles',
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 18),
                      ]),
                )),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: onSecondaryAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: data.secondaryButtonColor,
                    foregroundColor: data.secondaryTextColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(data.secondaryActionIcon, size: 20),
                    const SizedBox(width: 6),
                    Text(data.secondaryActionLabel,
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ]),
            ])),
      ]),
    );
  }

  void _openReservationDetails({
    required String vehicleName,
    required String vehicleSpecs,
    required double vehicleRating,
    required int vehicleReviews,
    required int vehiclePrice,
    required String vehicleImage,
    int? precioDia,
    int? precioSemana,
    String? reservaCode,
  }) {
    final reservas = _reservationDb.reservations;
    final reserva = reservas.firstWhere(
      (r) => r.code == reservaCode,
      orElse: () => reservas.first, // Fallback
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReservaDetalleCompletaPage(
          reservaCode: reserva.code,
          reservaId: reserva.id,
        ),
      ),
    );
  }

  /// Gestiona estado label dentro de esta parte del flujo.
  String _statusLabel(int statusId) {
    switch (statusId) {
      case 1:
        return 'Pendiente';
      case 2:
        return 'Finalizada';
      case 3:
        return 'Cancelada';
      case 4:
        return 'Activa';
      default:
        return 'Pendiente';
    }
  }

  /// Gestiona estado color dentro de esta parte del flujo.
  Color _statusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return const Color(0xFFF59E0B);
      case 'Finalizada':
        return const Color(0xFF3B82F6);
      case 'Cancelada':
        return const Color(0xFFEF4444);
      case 'Activa':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  /// Gestiona normalize vehicle text dentro de esta parte del flujo.
  String _normalizeVehicleText(dynamic value) {
    if (value == null) return '';
    final normalized = '$value'.replaceAll(RegExp(r'\s+'), ' ').trim();
    final lowered = normalized.toLowerCase();
    if (lowered == 'null' || lowered == 'undefined' || lowered == 'nan') {
      return '';
    }
    return normalized;
  }

  /// Gestiona vehicle name desde map dentro de esta parte del flujo.
  String _vehicleNameFromMap(Map<String, dynamic> vehicle) {
    final marca = _normalizeVehicleText(vehicle['marca']);
    final linea = _normalizeVehicleText(vehicle['linea']);
    final modelo = _normalizeVehicleText(vehicle['modelo']);
    final anio = _normalizeVehicleText(vehicle['anio']);

    final rawModel = linea.isNotEmpty ? linea : modelo;
    var cleanedModel = rawModel;
    if (marca.isNotEmpty &&
        cleanedModel.toLowerCase().startsWith(marca.toLowerCase())) {
      cleanedModel = cleanedModel.substring(marca.length).trimLeft();
    }

    var name = [
      if (marca.isNotEmpty) marca,
      if (cleanedModel.isNotEmpty) cleanedModel
    ].join(' ').trim();
    if (name.isEmpty) name = rawModel.isEmpty ? 'Vehiculo' : rawModel;

    final hasYear = RegExp(r'^\d{4}$').hasMatch(anio);
    if (hasYear && !name.contains(anio)) {
      return '$name $anio';
    }
    return name;
  }

  /// Gestiona vehicle specs desde map dentro de esta parte del flujo.
  String _vehicleSpecsFromMap(Map<String, dynamic> vehicle) {
    final anio = _normalizeVehicleText(vehicle['anio']);
    final color = _normalizeVehicleText(vehicle['color']);

    if (anio.isNotEmpty && color.isNotEmpty) return '$anio - $color';
    if (anio.isNotEmpty) return anio;
    if (color.isNotEmpty) return color;
    return 'N/A';
  }

  /// Gestiona format amount dentro de esta parte del flujo.
  String _formatAmount(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  /// Gestiona format date dentro de esta parte del flujo.
  String _formatDate(DateTime date) {
    const months = [
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
      'Dic',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildPlaceholder() => Container(
        color: const Color(0xFFE5E7EB),
        child: const Center(
            child:
                Icon(Icons.directions_car, size: 64, color: Color(0xFF9CA3AF))),
      );
}

/// Define la responsabilidad de `_ReservaCardData` dentro de este módulo.
class _ReservaCardData {
  const _ReservaCardData({
    required this.vehicleName,
    required this.code,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.progress,
    required this.status,
    required this.imageUrl,
    required this.showEnCurso,
    required this.vehicleSpecs,
    required this.vehicleRating,
    required this.vehicleReviews,
    required this.vehiclePrice,
    required this.precioDia,
    required this.precioSemana,
    required this.statusColor,
    required this.secondaryActionLabel,
    required this.secondaryActionIcon,
    required this.secondaryButtonColor,
    required this.secondaryTextColor,
  });

  final String vehicleName;
  final String code;
  final String price;
  final String startDate;
  final String endDate;
  final String location;
  final double progress;
  final String status;
  final String imageUrl;
  final bool showEnCurso;
  final String? vehicleSpecs;
  final double? vehicleRating;
  final int? vehicleReviews;
  final int? vehiclePrice;
  final int? precioDia;
  final int? precioSemana;
  final Color statusColor;
  final String secondaryActionLabel;
  final IconData secondaryActionIcon;
  final Color secondaryButtonColor;
  final Color secondaryTextColor;
}

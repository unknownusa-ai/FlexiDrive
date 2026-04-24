// Flutter framework
import 'package:flutter/material.dart';
// Fuentes bonitas de Google
import 'package:google_fonts/google_fonts.dart';

// Sesion del usuario actual
import 'package:flexidrive/core/session/local_session_store.dart';
// Base de datos de publicaciones
import 'package:flexidrive/services/publications/local_publication_db.dart';
// Base de datos de reservas
import 'package:flexidrive/services/reservations/local_reservation_db.dart';
// Base de datos de reseñas
import 'package:flexidrive/services/reviews/local_review_db.dart';
// Servicio de vehiculos
import 'package:flexidrive/services/vehiculo_service.dart';

// Pagina de detalle de reserva
import 'reserva_detalle_completa_page.dart';
// Utilidades responsive
import '../../../core/utils/responsive_utils.dart';

// Página de reservas del usuario
// Muestra todas las reservas activas y pasadas
class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});
  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

// Estado de la pagina de reservas
class _ReservasPageState extends State<ReservasPage> with WidgetsBindingObserver {
  // Filtro seleccionado: Activas, Pendientes, Historial
  String _selectedFilter = 'Activas';
  // Contador de reservas finalizadas
  int _finalizadasCount = 0;
  // Contador de reservas canceladas
  int _canceladasCount = 0;
  // Esta cargando el historial?
  bool _isLoadingHistory = true;

  // Base de datos de reservas
  final LocalReservationDb _reservationDb = LocalReservationDb.instance;
  // Base de datos de publicaciones
  final LocalPublicationDb _publicationDb = LocalPublicationDb.instance;
  // Servicio de vehiculos
  final VehiculoService _vehiculoService = VehiculoService();
  // Base de datos de reseñas
  final LocalReviewDb _reviewDb = LocalReviewDb.instance;
  // Sesion del usuario
  final LocalSessionStore _sessionStore = LocalSessionStore.instance;

  // Lista de reservas activas
  List<_ReservaCardData> _activeReservations = [];
  // Lista de reservas pendientes
  List<_ReservaCardData> _pendingReservations = [];
  // Lista de historial de reservas
  List<_ReservaCardData> _historyReservations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadHistoryReservations(); // Carga historial de reservas
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recargar reservas cuando la app vuelve a primer plano
      _refreshReservations();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar reservas cuando se regresa a esta página
    _refreshReservations();
  }

  // Refresca todas las reservas
  Future<void> _refreshReservations() async {
    setState(() => _isLoadingHistory = true);
    // Small delay to ensure new reservation is properly saved
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
        ? _reservationDb.reservations.take(6).toList()
        : _reservationDb.reservations
            .where((reservation) => reservation.userId == currentUserId)
            .toList();


    // Separar reservas por estado
    final pendingReservations = userReservations
        .where((reservation) => reservation.statusId == 1)
        .toList()
      ..sort((a, b) => b.reservationDate.compareTo(a.reservationDate)); // statusId = 1 (Pendiente)

    final activeReservations = userReservations
        .where((reservation) => reservation.statusId == 4)
        .toList()
      ..sort((a, b) => b.reservationDate.compareTo(a.reservationDate)); // statusId = 4 (Activa)

    final finalizedReservations = userReservations
        .where((reservation) => reservation.statusId == 2)
        .toList()
      ..sort((a, b) => b.reservationDate.compareTo(a.reservationDate)); // statusId = 2 (Finalizada)


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
            : '${vehicle['linea'] ?? 'Vehículo'} ${vehicle['modelo'] ?? ''}',
        code: reservation.code,
        price: '\$ ${_formatAmount(reservation.totalValue.round())}',
        startDate: _formatDate(reservation.startDate),
        endDate: _formatDate(reservation.endDate),
        location:
            '${reservation.pickupLocation} · ${reservation.returnLocation}',
        progress: 0.2, // Progress for pending reservations
        status: status,
        imageUrl: mainImagesByPublication[reservation.publicationId] ??
            'assets/imagenes_carros/cx5.jpg',
        showEnCurso: false,
        vehicleSpecs: vehicle == null
            ? '2024 • Negro Jet'
            : '${vehicle['modelo'] ?? ''} • ${vehicle['color'] ?? 'N/A'}',
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
            : '${vehicle['linea'] ?? 'Vehículo'} ${vehicle['modelo'] ?? ''}',
        code: reservation.code,
        price: '\$ ${_formatAmount(reservation.totalValue.round())}',
        startDate: _formatDate(reservation.startDate),
        endDate: _formatDate(reservation.endDate),
        location:
            '${reservation.pickupLocation} · ${reservation.returnLocation}',
        progress: status == 'Activa'
            ? 0.4
            : status == 'Cancelada'
                ? 0.0
                : 1.0,
        status: status,
        imageUrl: mainImagesByPublication[reservation.publicationId] ??
            'assets/imagenes_carros/cx5.jpg',
        showEnCurso: status == 'Activa',
        vehicleSpecs: vehicle == null
            ? '2024 • Negro Jet'
            : '${vehicle['modelo'] ?? ''} • ${vehicle['color'] ?? 'N/A'}',
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

    final reservations = finalizedReservations; // Para el historial

    final history = reservations.map((reservation) {
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
            : '${vehicle['linea'] ?? 'Vehículo'} ${vehicle['modelo'] ?? ''}',
        code: reservation.code,
        price: '\$ ${_formatAmount(reservation.totalValue.round())}',
        startDate: _formatDate(reservation.startDate),
        endDate: _formatDate(reservation.endDate),
        location:
            '${reservation.pickupLocation} · ${reservation.returnLocation}',
        progress: status == 'Activa'
            ? 0.4
            : status == 'Cancelada'
                ? 0.0
                : 1.0,
        status: status,
        imageUrl: vehicle == null || vehicle['imagen'] == null
            ? 'assets/imagenes_carros/cx5.jpg'
            : vehicle['imagen'] as String,
        showEnCurso: status == 'Activa',
        vehicleSpecs: vehicle == null
            ? '2024 • Negro Jet'
            : '${vehicle['modelo'] ?? ''} • ${vehicle['color'] ?? 'N/A'}',
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
      _historyReservations =
          history.isNotEmpty ? history : _fallbackHistoryReservations();
      _finalizadasCount = finalizadas;
      _canceladasCount = canceladas;
      _isLoadingHistory = false;
    });

  }

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

  Widget _buildStatisticsCards(int activasCount) {
    return SizedBox(
        height: 86,
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                fontSize: 27,
                fontWeight: FontWeight.bold,
                height: 1.0)),
        const SizedBox(height: 1),
        Flexible(
            child: Text(label,
                style: GoogleFonts.poppins(
                    color: textColor.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Widget _buildFilterButtons() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Expanded(
              child: _buildFilterButton(
            label: 'Activas',
            leadingWidget: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Color(0xFF10B981), shape: BoxShape.circle)),
            isSelected: _selectedFilter == 'Activas',
            onTap: () => setState(() => _selectedFilter = 'Activas'),
          )),
          Expanded(
              child: _buildFilterButton(
            label: 'Pendientes',
            leadingWidget: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B), shape: BoxShape.circle)),
            isSelected: _selectedFilter == 'Pendientes',
            onTap: () => setState(() => _selectedFilter = 'Pendientes'),
          )),
          Expanded(
              child: _buildFilterButton(
            label: 'Historial',
            leadingWidget: Icon(Icons.description_outlined,
                color: _selectedFilter == 'Historial'
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                size: 18),
            isSelected: _selectedFilter == 'Historial',
            onTap: () => setState(() => _selectedFilter = 'Historial'),
          )),
        ]),
      ),
    );
  }

  Widget _buildFilterButton(
      {required String label,
      required Widget leadingWidget,
      required bool isSelected,
      required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? theme.cardTheme.color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          leadingWidget,
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.poppins(
                  color: isSelected
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

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
                      vehicleSpecs: reserva.vehicleSpecs ?? '2024 • Negro Jet',
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
                      vehicleSpecs: reserva.vehicleSpecs ?? '2024 • Negro Jet',
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
    } else {
      if (_isLoadingHistory) {
        return const Center(child: CircularProgressIndicator());
      }

      final reservations = _historyReservations.isNotEmpty
          ? _historyReservations
          : _fallbackHistoryReservations();

      return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: reservations
              .map((reserva) => _buildReservationCard(
                    data: reserva,
                    onSecondaryAction: () {},
                    onViewDetails: () => _openReservationDetails(
                      vehicleName: reserva.vehicleName,
                      vehicleSpecs: reserva.vehicleSpecs ?? '2024 • Negro Jet',
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
                              : Image.asset(
                                  reserva.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildSmallPlaceholder(),
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
                              '${reserva.startDate} · ${reserva.price}',
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
      // Remove from database permanently
      final reservationIndex =
          _reservationDb.reservations.indexWhere((r) => r.code == reserva.code);
      if (reservationIndex != -1) {
        _reservationDb.reservations.removeAt(reservationIndex);
      }

      // Refresh all reservations to update lists
      await _refreshReservations();
    }
  }

  Widget _buildSmallPlaceholder() => const Center(
        child: Icon(
          Icons.directions_car,
          size: 22,
          color: Color(0xFF9CA3AF),
        ),
      );

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
                  : Image.asset(
                      data.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
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
                Text('${data.startDate} → ${data.endDate}',
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
    // Find the reservation by code to get the ID
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

  List<_ReservaCardData> _fallbackHistoryReservations() => [
        const _ReservaCardData(
          vehicleName: 'Tesla Model 3 2024',
          code: 'FXD-2024-0087',
          price: '\$ 380,000',
          startDate: '18 Feb 2026',
          endDate: '20 Feb 2026',
          location: 'Cra 7, Bogotá',
          progress: 1.0,
          status: 'Finalizada',
          imageUrl: 'assets/imagenes_carros/cx5.jpg',
          showEnCurso: false,
          vehicleSpecs: '2024 • Negro Jet',
          vehicleRating: 4.9,
          vehicleReviews: 128,
          vehiclePrice: 380000,
          precioDia: 380000,
          precioSemana: 2280000,
          statusColor: Color(0xFF3B82F6),
          secondaryActionLabel: 'Calificar',
          secondaryActionIcon: Icons.star_rounded,
          secondaryButtonColor: Color(0xFFFCD34D),
          secondaryTextColor: Color(0xFF111827),
        ),
        const _ReservaCardData(
          vehicleName: 'Mercedes GLC 2024',
          code: 'FXD-2024-0086',
          price: '\$ 520,000',
          startDate: '10 Feb 2026',
          endDate: '12 Feb 2026',
          location: 'Av. Paseo Consistorial, Bogotá',
          progress: 0.0,
          status: 'Cancelada',
          imageUrl: 'assets/imagenes_carros/cx5.jpg',
          showEnCurso: false,
          vehicleSpecs: '2024 • Negro Jet',
          vehicleRating: 4.9,
          vehicleReviews: 128,
          vehiclePrice: 520000,
          precioDia: 520000,
          precioSemana: 3120000,
          statusColor: Color(0xFFEF4444),
          secondaryActionLabel: 'Calificar',
          secondaryActionIcon: Icons.star_rounded,
          secondaryButtonColor: Color(0xFFFCD34D),
          secondaryTextColor: Color(0xFF111827),
        ),
      ];

  Widget _buildPlaceholder() => Container(
        color: const Color(0xFFE5E7EB),
        child: const Center(
            child:
                Icon(Icons.directions_car, size: 64, color: Color(0xFF9CA3AF))),
      );
}

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

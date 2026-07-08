import 'package:flexidrive/core/utils/responsive_utils.dart';
import 'package:flexidrive/core/utils/vehicle_image_resolver.dart';
import 'package:flexidrive/core/widgets/flexi_vehicle_image.dart';
import 'package:flexidrive/features/accounts/application/use_cases/account_access_use_case.dart';
import 'package:flexidrive/features/publications/application/use_cases/publication_access_use_case.dart';
import 'package:flexidrive/features/publications/domain/entities/publication_models.dart';
import 'package:flexidrive/features/reservations/application/use_cases/reservation_access_use_case.dart';
import 'package:flexidrive/features/reviews/application/use_cases/review_access_use_case.dart';
import 'package:flexidrive/features/vehicles/application/use_cases/vehicle_inventory_use_case.dart';
import 'package:flexidrive/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'publicar_vehiculo_page.dart';

class PrincipalArrendatarioPage extends StatefulWidget {
  const PrincipalArrendatarioPage({
    super.key,
    this.refreshToken = 0,
    this.onOpenRequests,
  });

  final int refreshToken;
  final VoidCallback? onOpenRequests;

  @override
  State<PrincipalArrendatarioPage> createState() =>
      _PrincipalArrendatarioPageState();
}

class _PrincipalArrendatarioPageState extends State<PrincipalArrendatarioPage> {
  static const Color _brandPrimary = Color(0xFF4F46E5);
  static const Color _brandSecondary = Color(0xFF7C3AED);
  static const Color _brandPrimaryDark = Color(0xFF4338CA);
  static const Color _brandSurface = Color(0xFFEEF2FF);
  static const Color _brandSurfaceSoft = Color(0xFFF5F3FF);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _dangerColor = Color(0xFFEF4444);
  final AccountAccessUseCase _accountRepository =
      InjectionContainer.instance.accountAccessUseCase;
  final PublicationAccessUseCase _publicationDb =
      InjectionContainer.instance.publicationAccessUseCase;
  final ReservationAccessUseCase _reservationDb =
      InjectionContainer.instance.reservationAccessUseCase;
  final ReviewAccessUseCase _reviewDb =
      InjectionContainer.instance.reviewAccessUseCase;
  final VehicleInventoryUseCase _vehicleDb =
      InjectionContainer.instance.vehicleInventoryUseCase;

  List<Map<String, dynamic>> _misVehiculos = <Map<String, dynamic>>[];
  String _firstName = 'Invitado';
  int _pendingRequests = 0;
  bool _isLoading = true;
  String _inventoryFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargarVehiculos();
  }

  @override
  void didUpdateWidget(covariant PrincipalArrendatarioPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _cargarVehiculos();
    }
  }

  Future<void> _cargarVehiculos() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await Future.wait([
        _vehicleDb.init(),
        _publicationDb.reload(),
        _reservationDb.loadIfNeeded(),
        _reviewDb.loadIfNeeded(),
      ]);

      final currentUser = await _accountRepository.getCurrentUser();
      if (currentUser == null) {
        if (!mounted) return;
        setState(() {
          _misVehiculos = <Map<String, dynamic>>[];
          _pendingRequests = 0;
          _isLoading = false;
        });
        return;
      }

      final vehiclesById = <int, Map<String, dynamic>>{
        for (final vehicle in _vehicleDb.getVehiculos())
          _asInt(vehicle['vehiculo_id'] ?? vehicle['id']): vehicle,
      };

      final opinionsById = {
        for (final opinion in _reviewDb.opinions) opinion.id: opinion,
      };

      final dailyPricesByPublicationId = <int, PublicationPriceModel>{
        for (final price in _publicationDb.publicationPrices
            .where((item) => item.periodTypeId == 1))
          price.publicationId: price,
      };

      final ownerPublications = _publicationDb.publications
          .where((publication) => publication.userId == currentUser.id)
          .toList();
      final ownerPublicationIds =
          ownerPublications.map((publication) => publication.id).toSet();

      final reservationsForOwner = _reservationDb.reservations
          .where((reservation) =>
              ownerPublicationIds.contains(reservation.publicationId))
          .toList();
      final now = DateTime.now();

      final pendingRequests = reservationsForOwner
          .where((reservation) => reservation.statusId == 1)
          .length;

      final ownerVehicles = <Map<String, dynamic>>[];

      for (final publication in ownerPublications) {
        final vehicle = vehiclesById[publication.vehicleId];
        if (vehicle == null) continue;

        final reservations = reservationsForOwner
            .where((reservation) => reservation.publicationId == publication.id)
            .toList();
        final activeReservations = reservations
            .where((reservation) =>
                reservation.statusId == 4 ||
                (reservation.statusId == 2 && reservation.endDate.isAfter(now)))
            .toList();
        final activeReservation =
            activeReservations.isEmpty ? null : activeReservations.first;
        final completedTrips = reservations
            .where((reservation) =>
                reservation.statusId == 3 ||
                (reservation.statusId == 2 &&
                    !reservation.endDate.isAfter(now)))
            .length;
        final earnings = reservations
            .where((reservation) =>
                reservation.statusId == 2 ||
                reservation.statusId == 3 ||
                reservation.statusId == 4)
            .fold<double>(
                0, (sum, reservation) => sum + reservation.totalValue);

        final publicationReviews = _reviewDb.reviews
            .where((review) => review.publicationId == publication.id)
            .toList();
        final ratings = publicationReviews
            .map((review) => opinionsById[review.opinionId]?.rating)
            .whereType<int>()
            .toList();
        final averageRating = ratings.isEmpty
            ? 5.0
            : ratings.reduce((a, b) => a + b) / ratings.length;

        final priceRecord = dailyPricesByPublicationId[publication.id];
        final publicationPrice =
            priceRecord?.price.round() ?? _asInt(vehicle['precio_dia']);

        ownerVehicles.add({
          ...vehicle,
          'publicacion_id': publication.id,
          'publicacion_activa': publication.active,
          'precio_publicacion_id': priceRecord?.id,
          'precio_dia': publicationPrice,
          'calificacion': averageRating,
          'viajes': completedTrips,
          'ganado': earnings.round(),
          'estado': !publication.active
              ? 'INACTIVO'
              : activeReservation == null
                  ? 'DISPONIBLE'
                  : 'RENTADO',
          'rentado_a': activeReservation == null
              ? null
              : 'Usuario #${activeReservation.userId}',
          'fecha_fin_renta': activeReservation == null
              ? null
              : _formatDate(activeReservation.endDate),
        });
      }

      ownerVehicles.sort((a, b) {
        final stateA = '${a['estado']}';
        final stateB = '${b['estado']}';
        final priorityA = _statusPriority(stateA);
        final priorityB = _statusPriority(stateB);
        if (priorityA != priorityB) return priorityA.compareTo(priorityB);
        return ('${a['modelo'] ?? ''}').compareTo('${b['modelo'] ?? ''}');
      });

      if (!mounted) return;
      setState(() {
        _firstName = _extractFirstName(currentUser.fullName);
        _pendingRequests = pendingRequests;
        _misVehiculos = ownerVehicles;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _misVehiculos = <Map<String, dynamic>>[];
        _pendingRequests = 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _cargarVehiculos,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(context, isSmallPhone),
                    Padding(
                      padding: EdgeInsets.all(isSmallPhone ? 14 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildManagementBar(context, isSmallPhone),
                          SizedBox(height: isSmallPhone ? 16 : 18),
                          _buildInventoryFilters(context, isSmallPhone),
                          SizedBox(height: isSmallPhone ? 14 : 16),
                          Text(
                            'Tu inventario',
                            style: GoogleFonts.inter(
                              fontSize: isSmallPhone ? 18 : 20,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Edita, pausa o elimina tus publicaciones desde aqui.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              height: 1.4,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          SizedBox(height: isSmallPhone ? 12 : 14),
                          if (_isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (_filteredVehiculos.isEmpty)
                            _buildEmptyInventoryState(context, isSmallPhone)
                          else
                            ..._filteredVehiculos.map(
                              (vehiculo) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: isSmallPhone ? 12 : 14,
                                ),
                                child: _buildVehicleCard(
                                  context: context,
                                  isSmallPhone: isSmallPhone,
                                  vehiculo: vehiculo,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          _buildTipsCard(context, isSmallPhone),
                        ],
                      ),
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

  Widget _buildHeader(BuildContext context, bool isSmallPhone) {
    final topPadding = MediaQuery.of(context).padding.top;
    final activeCount = _misVehiculos
        .where((vehicle) => vehicle['estado'] == 'DISPONIBLE')
        .length;
    final rentedCount =
        _misVehiculos.where((vehicle) => vehicle['estado'] == 'RENTADO').length;
    final earned = _calcularGanancias();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isSmallPhone ? 16 : 20,
        topPadding + (isSmallPhone ? 12 : 16),
        isSmallPhone ? 16 : 20,
        isSmallPhone ? 22 : 26,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_brandPrimaryDark, _brandPrimary, _brandSecondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: Text(
              'Panel de arrendador',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: isSmallPhone
                    ? MediaQuery.of(context).size.width - 44
                    : MediaQuery.of(context).size.width - 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mis Vehiculos',
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 30 : 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_firstName, aqui gestionas disponibilidad, precios y estado de cada publicacion.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.45,
                        color: Colors.white.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildHeaderPublishButton(),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.16),
                  Colors.white.withValues(alpha: 0.07),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen rapido',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildHeaderStat(
                      icon: Icons.directions_car_outlined,
                      value: '${_misVehiculos.length}',
                      label: 'Publicados',
                    ),
                    _buildDividerStat(),
                    _buildHeaderStat(
                      icon: Icons.toggle_on_outlined,
                      value: '$activeCount',
                      label: 'Disponibles',
                    ),
                    _buildDividerStat(),
                    _buildHeaderStat(
                      icon: Icons.local_shipping_outlined,
                      value: '$rentedCount',
                      label: 'Rentados',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildHeaderPill(
                      icon: Icons.payments_outlined,
                      text: 'Ganado \$${_formatNumber(earned)}',
                    ),
                    _buildHeaderPill(
                      icon: Icons.notifications_active_outlined,
                      text: _pendingRequests > 0
                          ? '$_pendingRequests solicitudes'
                          : 'Sin solicitudes pendientes',
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

  Widget _buildHeaderPublishButton() {
    return GestureDetector(
      onTap: _openPublishFlow,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(
              'Publicar',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDividerStat() {
    return Container(
      width: 1,
      height: 44,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildHeaderPill({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 7),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementBar(BuildContext context, bool isSmallPhone) {
    final theme = Theme.of(context);
    final hasPending = _pendingRequests > 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallPhone ? 16 : 18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: _brandPrimary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_brandSurface, _brandSurfaceSoft],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.dashboard_customize_outlined,
              color: _brandPrimary,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestion centralizada',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasPending
                      ? 'Tienes $_pendingRequests solicitudes por revisar junto a tus publicaciones.'
                      : 'Organiza tus vehiculos, manten precios claros y cambia su estado cuando lo necesites.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.45,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),
              ],
            ),
          ),
          if (hasPending) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: widget.onOpenRequests,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _brandSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Ver',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _brandPrimary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInventoryFilters(BuildContext context, bool isSmallPhone) {
    final filters = <String>['Todos', 'Activos', 'Rentados', 'Inactivos'];
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.45)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _inventoryFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _inventoryFilter = filter;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [_brandPrimary, _brandSecondary],
                          )
                        : null,
                    color: isSelected ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _brandPrimary.withValues(alpha: 0.18),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    filter,
                    style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 12 : 13,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface.withValues(alpha: 0.68),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyInventoryState(BuildContext context, bool isSmallPhone) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallPhone ? 18 : 22),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _brandSurfaceSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.garage_outlined,
              color: _brandPrimary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No hay vehículos en esta vista',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 15 : 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Prueba otro filtro o publica un nuevo vehículo para empezar a gestionarlo.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard({
    required BuildContext context,
    required bool isSmallPhone,
    required Map<String, dynamic> vehiculo,
  }) {
    final theme = Theme.of(context);
    final imagePath = VehicleImageResolver.resolveFromVehicle(
      vehiculo,
      preferredImage: vehiculo['imagen']?.toString(),
      fallback: 'assets/imagenes_carros/cx5.jpg',
    );
    final title = (vehiculo['modelo'] as String?)?.trim().isNotEmpty == true
        ? (vehiculo['modelo'] as String).trim()
        : (vehiculo['marca'] as String? ?? 'Vehículo');
    final subtitle =
        '${vehiculo['marca'] ?? ''} • ${vehiculo['categoria'] ?? 'Sedán'}';
    final rating = _formatRating(vehiculo['calificacion']);
    final tripCount = _asInt(vehiculo['viajes']);
    final earned = '\$${_formatNumber(_asInt(vehiculo['ganado']))}';
    final status = '${vehiculo['estado'] ?? 'DISPONIBLE'}';
    final dailyPrice = _asInt(vehiculo['precio_dia']);
    final rentInfo = status == 'RENTADO'
        ? 'Rentado a ${vehiculo['rentado_a']} hasta el ${vehiculo['fecha_fin_renta']}'
        : status == 'INACTIVO'
            ? 'No aparece en el catálogo hasta que lo reactives.'
            : 'Disponible para nuevas solicitudes.';

    final badgeColors = _statusColors(status);

    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 12 : 14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: FlexiVehicleImage(
                  imagePath: imagePath,
                  width: isSmallPhone ? 92 : 102,
                  height: isSmallPhone ? 76 : 84,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: isSmallPhone ? 15 : 16,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _buildStatusBadge(status, badgeColors),
                        const SizedBox(width: 4),
                        _buildVehicleMenuButton(vehiculo),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.58),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: _warningColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$rating • $tripCount ${tripCount == 1 ? 'viaje' : 'viajes'}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.52),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildVehicleMetric(
                            title: 'Precio/día',
                            value: '\$${_formatNumber(dailyPrice)}',
                            color: _brandPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildVehicleMetric(
                            title: 'Ganado',
                            value: earned,
                            color: _successColor,
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: badgeColors.$2.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              rentInfo,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  label: 'Editar',
                  icon: Icons.edit_outlined,
                  onTap: () => _showEditVehicleSheet(vehiculo),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionButton(
                  label: status == 'INACTIVO' ? 'Activar' : 'Inactivar',
                  icon: status == 'INACTIVO'
                      ? Icons.play_circle_outline
                      : Icons.pause_circle_outline,
                  onTap: () => _toggleVehicleActive(vehiculo),
                  foreground:
                      status == 'INACTIVO' ? _successColor : _brandPrimary,
                  background: status == 'INACTIVO'
                      ? const Color(0xFFDCFCE7)
                      : _brandSurface,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionButton(
                  label: 'Eliminar',
                  icon: Icons.delete_outline,
                  onTap: () => _confirmDeleteVehicle(vehiculo),
                  foreground: _dangerColor,
                  background: const Color(0xFFFEF2F2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleMetric({
    required String title,
    required String value,
    required Color color,
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, (Color, Color) colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.$2.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: colors.$1,
        ),
      ),
    );
  }

  Widget _buildVehicleMenuButton(Map<String, dynamic> vehiculo) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz_rounded,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _showEditVehicleSheet(vehiculo);
            break;
          case 'toggle':
            _toggleVehicleActive(vehiculo);
            break;
          case 'delete':
            _confirmDeleteVehicle(vehiculo);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Editar')),
        PopupMenuItem(
          value: 'toggle',
          child: Text(
            vehiculo['estado'] == 'INACTIVO'
                ? 'Activar vehículo'
                : 'Inactivar vehículo',
          ),
        ),
        const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color foreground = const Color(0xFF1F2937),
    Color background = const Color(0xFFF8FAFC),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: foreground, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard(BuildContext context, bool isSmallPhone) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallPhone ? 14 : 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mantén tus publicaciones activas',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 15 : 16,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          _tipItem('Edita precios según la demanda y la ciudad.'),
          const SizedBox(height: 6),
          _tipItem('Inactiva vehículos cuando entren a mantenimiento.'),
          const SizedBox(height: 6),
          _tipItem('Revisa alertas y solicitudes para no perder reservas.'),
        ],
      ),
    );
  }

  Widget _tipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 3),
          child: Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.62),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openPublishFlow() async {
    final didPublish = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const PublicarVehiculoPage()),
    );
    if (didPublish == true) {
      _cargarVehiculos();
    }
  }

  Future<void> _toggleVehicleActive(Map<String, dynamic> vehiculo) async {
    final publicationId = _asInt(vehiculo['publicacion_id']);
    PublicationModel? publication;
    for (final item in _publicationDb.publications) {
      if (item.id == publicationId) {
        publication = item;
        break;
      }
    }
    if (publication == null) return;

    final updatedPublication = PublicationModel(
      id: publication.id,
      userId: publication.userId,
      vehicleId: publication.vehicleId,
      publishDate: publication.publishDate,
      active: !publication.active,
    );

    await _publicationDb.updatePublication(updatedPublication);
    await _cargarVehiculos();
  }

  Future<void> _confirmDeleteVehicle(Map<String, dynamic> vehiculo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar vehículo'),
        content: Text(
          'Se eliminará la publicación de ${vehiculo['modelo'] ?? 'este vehículo'} del modo arrendatario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final publicationId = _asInt(vehiculo['publicacion_id']);
    final vehicleId = _asInt(vehiculo['vehiculo_id'] ?? vehiculo['id']);
    await _publicationDb.deletePublication(publicationId);
    _vehicleDb.deleteVehiculo(vehicleId);
    await _cargarVehiculos();
  }

  Future<void> _showEditVehicleSheet(Map<String, dynamic> vehiculo) async {
    final nameController = TextEditingController(
      text: '${vehiculo['modelo'] ?? ''}',
    );
    final priceController = TextEditingController(
      text: '${_asInt(vehiculo['precio_dia'])}',
    );
    final cityController = TextEditingController(
      text: '${vehiculo['ubicacion'] ?? ''}',
    );

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar vehículo',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _buildEditField('Nombre', nameController),
                const SizedBox(height: 12),
                _buildEditField('Precio por día', priceController),
                const SizedBox(height: 12),
                _buildEditField('Ciudad', cityController),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Guardar cambios'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (saved == true) {
      final vehicleId = _asInt(vehiculo['vehiculo_id'] ?? vehiculo['id']);
      final publicationId = _asInt(vehiculo['publicacion_id']);
      final publicationPriceId = _asInt(vehiculo['precio_publicacion_id']);
      PublicationModel? publication;
      for (final item in _publicationDb.publications) {
        if (item.id == publicationId) {
          publication = item;
          break;
        }
      }
      PublicationPriceModel? publicationPrice;
      for (final item in _publicationDb.publicationPrices) {
        if (item.id == publicationPriceId) {
          publicationPrice = item;
          break;
        }
      }

      _vehicleDb.updateVehiculo(vehicleId, {
        'modelo': nameController.text.trim(),
        'ubicacion': cityController.text.trim(),
        'precio_dia': int.tryParse(priceController.text.trim()) ??
            _asInt(vehiculo['precio_dia']),
      });

      if (publicationPrice != null) {
        await _publicationDb.updatePublicationPrice(
          PublicationPriceModel(
            id: publicationPrice.id,
            publicationId: publicationPrice.publicationId,
            periodTypeId: publicationPrice.periodTypeId,
            price: (int.tryParse(priceController.text.trim()) ??
                    _asInt(vehiculo['precio_dia']))
                .toDouble(),
          ),
        );
      }

      if (publication != null) {
        await _publicationDb.updatePublication(publication);
      }

      await _cargarVehiculos();
    }

    nameController.dispose();
    priceController.dispose();
    cityController.dispose();
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardTheme.color,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  (Color, Color) _statusColors(String status) {
    switch (status) {
      case 'RENTADO':
        return (const Color(0xFF2563EB), const Color(0xFFDBEAFE));
      case 'INACTIVO':
        return (const Color(0xFF64748B), const Color(0xFFE2E8F0));
      default:
        return (const Color(0xFFF59E0B), const Color(0xFFFEF3C7));
    }
  }

  int _statusPriority(String status) {
    switch (status) {
      case 'RENTADO':
        return 0;
      case 'DISPONIBLE':
        return 1;
      case 'INACTIVO':
        return 2;
      default:
        return 3;
    }
  }

  int _calcularGanancias() {
    return _misVehiculos.fold<int>(
      0,
      (sum, vehicle) => sum + _asInt(vehicle['ganado']),
    );
  }

  List<Map<String, dynamic>> get _filteredVehiculos {
    switch (_inventoryFilter) {
      case 'Activos':
        return _misVehiculos
            .where((vehicle) => vehicle['estado'] == 'DISPONIBLE')
            .toList();
      case 'Rentados':
        return _misVehiculos
            .where((vehicle) => vehicle['estado'] == 'RENTADO')
            .toList();
      case 'Inactivos':
        return _misVehiculos
            .where((vehicle) => vehicle['estado'] == 'INACTIVO')
            .toList();
      default:
        return _misVehiculos;
    }
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse('$value') ?? 0;
  }

  String _formatRating(dynamic value) {
    final parsed = value is num ? value.toDouble() : double.tryParse('$value');
    return (parsed ?? 5.0).toStringAsFixed(1);
  }

  String _extractFirstName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return 'Invitado';
    return trimmed.split(' ').first;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (match) => '${match[1]}.',
        );
  }
}

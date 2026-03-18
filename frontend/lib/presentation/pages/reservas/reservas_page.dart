import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'reserva_detalle_page.dart';
import 'reservas_store.dart';
import '../../../core/utils/responsive_utils.dart';

class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});
  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  String _selectedFilter = 'Activas';
  final int _finalizadasCount = 2;
  int _canceladasCount = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTextStyle.merge(
      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      child: ValueListenableBuilder<List<ReservaActiva>>(
        valueListenable: ReservasStore.activasNotifier,
        builder: (context, activas, _) {
          final activasCount = activas.length;

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
                Expanded(child: _buildReservationsList(activas)),
              ]),
            ),
          );
        },
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

  Widget _buildReservationsList(List<ReservaActiva> activas) {
    if (_selectedFilter == 'Activas') {
      if (activas.isEmpty) {
        return _buildEmptyActiveReservations();
      }

      return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: activas
              .map((reserva) => _buildReservationCard(
                    vehicleName: reserva.vehicleName,
                    code: reserva.code,
                    price: reserva.price,
                    startDate: reserva.startDate,
                    endDate: reserva.endDate,
                    location: reserva.location,
                    progress: reserva.progress,
                    status: reserva.status,
                    statusColor: const Color(0xFF06B6D4),
                    imageUrl: reserva.imageUrl,
                    showEnCurso: true,
                    onSecondaryAction: () => _showCancelReservationSheet(
                      reserva: reserva,
                    ),
                    secondaryActionLabel: 'Cancelar',
                    secondaryActionIcon: Icons.close,
                    secondaryButtonColor: const Color(0xFFFEE2E2),
                    secondaryTextColor: const Color(0xFFDC2626),
                  ))
              .toList());
    } else {
      return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            _buildReservationCard(
              vehicleName: 'Tesla Model 3 2024',
              code: 'FXD-2024-0087',
              price: '\$ 380,000',
              startDate: '18 Feb 2026',
              endDate: '20 Feb 2026',
              location: 'Cra 7, Bogotá',
              progress: 1.0,
              status: 'Finalizada',
              statusColor: const Color(0xFF3B82F6),
              imageUrl:
                  'https://images.unsplash.com/photo-1560958089-b8a63c50ce20?w=800&q=80',
              secondaryActionLabel: 'Calificar',
              secondaryActionIcon: Icons.star_rounded,
              secondaryButtonColor: const Color(0xFFFCD34D),
              secondaryTextColor: const Color(0xFF111827),
              onSecondaryAction: () {},
            ),
            const SizedBox(height: 16),
            _buildReservationCard(
              vehicleName: 'Mercedes GLC 2024',
              code: 'FXD-2024-0086',
              price: '\$ 520,000',
              startDate: '10 Feb 2026',
              endDate: '12 Feb 2026',
              location: 'Av. Paseo Consistorial, Bogotá',
              progress: 0.0,
              status: 'Cancelada',
              statusColor: const Color(0xFFEF4444),
              imageUrl: '',
              secondaryActionLabel: 'Calificar',
              secondaryActionIcon: Icons.star_rounded,
              secondaryButtonColor: const Color(0xFFFCD34D),
              secondaryTextColor: const Color(0xFF111827),
              onSecondaryAction: () {},
            ),
          ]);
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

  Future<void> _showCancelReservationSheet({
    required ReservaActiva reserva,
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
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFEF4444),
                    size: 42,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '¿Cancelar reserva?',
                  style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Se cancelará la reserva de ${reserva.vehicleName}.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.52),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
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
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Text(
                    '⚠ Reembolso sujeto a politica de cancelacion. Puede aplicar cargo del 10%.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(sheetContext, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.onSurface
                              .withValues(alpha: 0.08),
                          foregroundColor: theme.colorScheme.onSurface,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
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
      setState(() {
        _canceladasCount += 1;
      });
      ReservasStore.removeActivaByCode(reserva.code);
    }
  }

  Widget _buildSmallPlaceholder() => const Center(
        child: Icon(
          Icons.directions_car,
          size: 22,
          color: Color(0xFF9CA3AF),
        ),
      );

  Widget _buildReservationCard(
      {required String vehicleName,
      required String code,
      required String price,
      required String startDate,
      required String endDate,
      required String location,
      required double progress,
      required String status,
      required Color statusColor,
      required String imageUrl,
      bool showEnCurso = false,
      required String secondaryActionLabel,
      required IconData secondaryActionIcon,
      required Color secondaryButtonColor,
      required Color secondaryTextColor,
      required VoidCallback onSecondaryAction}) {
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
              child: imageUrl.isEmpty
                  ? _buildPlaceholder()
                  : Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    ),
            ),
          ),
          if (showEnCurso)
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
                        child: Text(vehicleName,
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface))),
                    const SizedBox(width: 8),
                    Text(price,
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary)),
                  ]),
              const SizedBox(height: 4),
              Text(code,
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
                Text('$startDate → $endDate',
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
                    child: Text(location,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ReservaDetallePage()),
                    );
                  },
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
                    backgroundColor: secondaryButtonColor,
                    foregroundColor: secondaryTextColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(secondaryActionIcon, size: 20),
                    const SizedBox(width: 6),
                    Text(secondaryActionLabel,
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ]),
            ])),
      ]),
    );
  }

  Widget _buildPlaceholder() => Container(
        color: const Color(0xFFE5E7EB),
        child: const Center(
            child:
                Icon(Icons.directions_car, size: 64, color: Color(0xFF9CA3AF))),
      );
}

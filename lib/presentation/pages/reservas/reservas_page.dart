import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_utils.dart';

class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});
  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  String _selectedFilter = 'Activas';
  final int _activasCount = 1;
  final int _finalizadasCount = 2;
  final int _canceladasCount = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTextStyle.merge(
      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: ConstrainedContainer(
          maxWidth: 800,
          child: Column(children: [
            Stack(clipBehavior: Clip.none, children: [
              _buildHeader(),
              Positioned(left: 20, right: 20, bottom: -45, child: _buildStatisticsCards()),
            ]),
            const SizedBox(height: 58),
            _buildFilterButtons(),
            const SizedBox(height: 20),
            Expanded(child: _buildReservationsList()),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
        ),
      ),
      child: SafeArea(bottom: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 52),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Mis Reservas', style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text('$_activasCount reserva activa', style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.85), fontSize: 14, fontWeight: FontWeight.bold)),
        ]),
      )),
    );
  }

  Widget _buildStatisticsCards() {
    return SizedBox(height: 86, child: Row(children: [
      Expanded(child: _buildStatCard(count: _activasCount, label: 'Activas',
          color: const Color(0xFFD1FAE5), textColor: const Color(0xFF10B981))),
      const SizedBox(width: 8),
      Expanded(child: _buildStatCard(count: _finalizadasCount, label: 'Finalizadas',
          color: const Color(0xFFDBEAFE), textColor: const Color(0xFF3B82F6))),
      const SizedBox(width: 8),
      Expanded(child: _buildStatCard(count: _canceladasCount, label: 'Canceladas',
          color: const Color(0xFFFEE2E2), textColor: const Color(0xFFEF4444))),
    ]));
  }

  Widget _buildStatCard({required int count, required String label, required Color color, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('$count', style: GoogleFonts.poppins(
            color: textColor, fontSize: 27, fontWeight: FontWeight.bold, height: 1.0)),
        const SizedBox(height: 1),
        Flexible(child: Text(label, style: GoogleFonts.poppins(
            color: textColor.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.bold),
            maxLines: 1, overflow: TextOverflow.ellipsis)),
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
          color: theme.colorScheme.onSurface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)
        ),
        child: Row(children: [
          Expanded(child: _buildFilterButton(
            label: 'Activas',
            leadingWidget: Container(width: 8, height: 8,
                decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
            isSelected: _selectedFilter == 'Activas',
            onTap: () => setState(() => _selectedFilter = 'Activas'),
          )),
          Expanded(child: _buildFilterButton(
            label: 'Historial',
            leadingWidget: Icon(Icons.description_outlined,
                color: _selectedFilter == 'Historial' ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.5), size: 18),
            isSelected: _selectedFilter == 'Historial',
            onTap: () => setState(() => _selectedFilter = 'Historial'),
          )),
        ]),
      ),
    );
  }

  Widget _buildFilterButton({required String label, required Widget leadingWidget,
      required bool isSelected, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180), curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? theme.cardTheme.color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))]
              : [],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          leadingWidget,
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.poppins(
              color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildReservationsList() {
    if (_selectedFilter == 'Activas') {
      return ListView(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), children: [
        _buildReservationCard(
          vehicleName: 'Mazda CX-5 2024', code: 'FXD-2024-0089', price: '\$ 440,000',
          startDate: '22 Feb 2026', endDate: '24 Feb 2026', location: 'Av. El Dorado, Bogotá',
          progress: 0.4, status: 'Activa', statusColor: const Color(0xFF06B6D4),
          imageUrl: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800&q=80',
          showEnCurso: true,
        ),
      ]);
    } else {
      return ListView(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), children: [
        _buildReservationCard(
          vehicleName: 'Tesla Model 3 2024', code: 'FXD-2024-0087', price: '\$ 380,000',
          startDate: '18 Feb 2026', endDate: '20 Feb 2026', location: 'Cra 7, Bogotá',
          progress: 1.0, status: 'Finalizada', statusColor: const Color(0xFF3B82F6),
          imageUrl: 'https://images.unsplash.com/photo-1560958089-b8a63c50ce20?w=800&q=80',
        ),
        const SizedBox(height: 16),
        _buildReservationCard(
          vehicleName: 'Mercedes GLC 2024', code: 'FXD-2024-0086', price: '\$ 520,000',
          startDate: '10 Feb 2026', endDate: '12 Feb 2026', location: 'Av. Paseo Consistorial, Bogotá',
          progress: 0.0, status: 'Cancelada', statusColor: const Color(0xFFEF4444),
          imageUrl: '',
        ),
      ]);
    }
  }

  Widget _buildReservationCard({required String vehicleName, required String code, required String price,
      required String startDate, required String endDate, required String location,
      required double progress, required String status, required Color statusColor,
      required String imageUrl, bool showEnCurso = false}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 2))]
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: Container(
              height: 140, width: double.infinity,
              decoration: BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [theme.colorScheme.onSurface.withOpacity(0.1), theme.colorScheme.onSurface.withOpacity(0.05)])),
              child: imageUrl.isEmpty
                  ? _buildPlaceholder()
                  : Image.network(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      loadingBuilder: (_, child, p) => p == null ? child : _buildPlaceholder()),
            ),
          ),
          if (showEnCurso) Positioned(bottom: 12, left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(6)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 8, height: 8,
                    decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('EN CURSO', style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ]),
            ),
          ),
        ]),
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(vehicleName, style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface))),
            const SizedBox(width: 8),
            Text(price, style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          ]),
          const SizedBox(height: 4),
          Text(code, style: GoogleFonts.poppins(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.calendar_today_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(width: 6),
            Text('$startDate → $endDate', style: GoogleFonts.poppins(
                fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(width: 6),
            Expanded(child: Text(location, style: GoogleFonts.poppins(
                fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.bold),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Ver Detalles', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 18),
              ]),
            )),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFCD34D),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0,
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.star_rounded, size: 20),
                const SizedBox(width: 6),
                Text('Calificar', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
              ]),
            ),
          ]),
        ])),
      ]),
    );
  }

  Widget _buildPlaceholder() => Container(
    color: const Color(0xFFE5E7EB),
    child: const Center(child: Icon(Icons.directions_car, size: 64, color: Color(0xFF9CA3AF))),
  );
}
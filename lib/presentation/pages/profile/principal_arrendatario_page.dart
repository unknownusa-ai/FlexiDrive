import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_utils.dart';
import 'publicar_vehiculo_page.dart';
import 'solicitudes_page.dart';

class PrincipalArrendatarioPage extends StatelessWidget {
  const PrincipalArrendatarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context, isSmallPhone),
                  Padding(
                    padding: EdgeInsets.all(isSmallPhone ? 14 : 16),
                    child: Column(
                      children: [
                        _buildPendingRequestCard(isSmallPhone),
                        SizedBox(height: isSmallPhone ? 18 : 20),
                        _buildPublishedHeader(isSmallPhone),
                        SizedBox(height: isSmallPhone ? 12 : 14),
                        _buildVehicleCard(
                          isSmallPhone: isSmallPhone,
                          imagePath: 'assets/imagenes_carros/tesla.jpg',
                          title: 'Mazda 3 Grand Touring',
                          subtitle: 'Mazda • Sedán',
                          rating: '4.8',
                          trips: '18 viajes',
                          pricePerDay: '\$180.000/día',
                          earned: '\$3.240.000',
                          status: 'RENTADO',
                          statusColor: const Color(0xFFF59E0B),
                          rentInfo:
                              'Rentado a Carlos Mendoza hasta el 2026-03-15',
                        ),
                        SizedBox(height: isSmallPhone ? 12 : 14),
                        _buildVehicleCard(
                          isSmallPhone: isSmallPhone,
                          imagePath: 'assets/imagenes_carros/cx5.jpg',
                          title: 'Chevrolet Onix Turbo',
                          subtitle: 'Chevrolet • Compacto',
                          rating: '4.9',
                          trips: '13 viajes',
                          pricePerDay: '\$120.000/día',
                          earned: '\$1.560.000',
                          status: 'DISPONIBLE',
                          statusColor: const Color(0xFF10B981),
                          rentInfo: null,
                        ),
                        SizedBox(height: isSmallPhone ? 16 : 18),
                        _buildTipsCard(isSmallPhone),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, isSmallPhone),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallPhone) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isSmallPhone ? 16 : 20,
        topPadding + (isSmallPhone ? 12 : 16),
        isSmallPhone ? 16 : 20,
        isSmallPhone ? 20 : 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFF7A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modo Arrendatario 🏠',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mis Vehículos',
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 36 : 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PublicarVehiculoPage(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Publicar',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.attach_money,
                value: '\$1.440.000',
                label: 'Saldo',
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                icon: Icons.directions_car,
                value: '2',
                label: 'Vehículos',
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                icon: Icons.people_outline,
                value: '1',
                label: 'Activas',
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                icon: Icons.trending_up,
                value: '\$4.800.000',
                label: 'Ganancias',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        height: 110,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestCard(bool isSmallPhone) {
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 14 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.access_time, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1 solicitud pendiente',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Revisa y acepta solicitudes de renta',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF991B1B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFEF4444), size: 28),
        ],
      ),
    );
  }

  Widget _buildPublishedHeader(bool isSmallPhone) {
    return Row(
      children: [
        Text(
          '🚗',
          style: TextStyle(fontSize: isSmallPhone ? 18 : 20),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Mis Vehículos Publicados',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 20 : 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        Text(
          '+ Agregar',
          style: GoogleFonts.inter(
            fontSize: isSmallPhone ? 14 : 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard({
    required bool isSmallPhone,
    required String imagePath,
    required String title,
    required String subtitle,
    required String rating,
    required String trips,
    required String pricePerDay,
    required String earned,
    required String status,
    required Color statusColor,
    required String? rentInfo,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  imagePath,
                  width: isSmallPhone ? 116 : 128,
                  height: isSmallPhone ? 102 : 110,
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
                              fontSize: isSmallPhone ? 18 : 19,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: GoogleFonts.inter(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFF59E0B),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$rating • $trips',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFFF59E0B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            pricePerDay,
                            style: GoogleFonts.inter(
                              fontSize: isSmallPhone ? 20 : 21,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF59E0B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Ganado',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              earned,
                              style: GoogleFonts.inter(
                                fontSize: isSmallPhone ? 19 : 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (rentInfo != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: _buildRentInfoText(rentInfo),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRentInfoText(String rentInfo) {
    // Extraer el nombre del texto "Rentado a [Nombre] hasta el [fecha]"
    final regExp = RegExp(r'Rentado a (.+?) hasta el');
    final match = regExp.firstMatch(rentInfo);

    if (match != null && match.groupCount >= 1) {
      final name = match.group(1)!;
      final nameStart = rentInfo.indexOf(name);
      final nameEnd = nameStart + name.length;
      final beforeName = rentInfo.substring(0, nameStart);
      final afterName = rentInfo.substring(nameEnd);

      return Text.rich(
        TextSpan(
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF94A3B8),
            height: 1.5,
          ),
          children: [
            TextSpan(text: beforeName),
            TextSpan(
              text: name,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            TextSpan(text: afterName),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text(
      rentInfo,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: const Color(0xFF94A3B8),
        height: 1.5,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTipsCard(bool isSmallPhone) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallPhone ? 16 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 Maximiza tus ganancias',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 20 : 21,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          _tipItem('📸 Agrega fotos de alta calidad de tu vehículo'),
          const SizedBox(height: 6),
          _tipItem('💰 Ajusta precios competitivos según la demanda'),
          const SizedBox(height: 6),
          _tipItem('⭐ Mantén tu vehículo limpio para buenas reseñas'),
        ],
      ),
    );
  }

  Widget _tipItem(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        color: const Color(0xFF94A3B8),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isSmallPhone) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isSmallPhone ? 10 : 14,
            8,
            isSmallPhone ? 10 : 14,
            8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                icon: Icons.home_outlined,
                label: 'Inicio',
                active: true,
              ),
              _navItem(
                icon: Icons.description_outlined,
                label: 'Solicitudes',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SolicitudesPage(),
                    ),
                  );
                },
              ),
              Container(
                width: 74,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 36),
              ),
              _navItem(
                icon: Icons.notifications_none,
                label: 'Alertas',
                dot: true,
              ),
              _navItem(
                icon: Icons.person_outline,
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    bool active = false,
    bool dot = false,
    VoidCallback? onTap,
  }) {
    final activeColor = const Color(0xFFF59E0B);
    final inactiveColor = const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 66,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: active ? const Color(0xFFFFF7ED) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: active ? activeColor : inactiveColor,
                    size: 27,
                  ),
                  if (dot)
                    const Positioned(
                      right: -2,
                      top: -1,
                      child: CircleAvatar(
                        radius: 3,
                        backgroundColor: Color(0xFFEF4444),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: active ? activeColor : inactiveColor,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

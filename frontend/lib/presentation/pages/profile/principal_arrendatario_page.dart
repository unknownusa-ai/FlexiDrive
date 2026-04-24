import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../services/vehiculo_service.dart';
import 'publicar_vehiculo_page.dart';

// Página principal del arrendador
// Dashboard que muestra los vehículos del arrendador y estadísticas
class PrincipalArrendatarioPage extends StatefulWidget {
  const PrincipalArrendatarioPage({super.key});

  @override
  State<PrincipalArrendatarioPage> createState() =>
      _PrincipalArrendatarioPageState();
}

// Estado de la página principal del arrendador
// Maneja la carga de vehículos y métricas
class _PrincipalArrendatarioPageState extends State<PrincipalArrendatarioPage> {
  // Servicio para manejar vehículos
  final VehiculoService _service = VehiculoService();
  // Lista de vehículos del arrendador
  List<Map<String, dynamic>> _misVehiculos = [];
  // Indica si se están cargando los vehículos
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarVehiculos();
  }

  Future<void> _cargarVehiculos() async {
    await _service.init();
    setState(() {
      _misVehiculos = _service.getVehiculosByPropietario(1);
      _isLoading = false;
    });
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context, isSmallPhone),
                  Padding(
                    padding: EdgeInsets.all(isSmallPhone ? 14 : 16),
                    child: Column(
                      children: [
                        _buildPendingRequestCard(context, isSmallPhone),
                        SizedBox(height: isSmallPhone ? 12 : 14),
                        _buildPublishedHeader(context, isSmallPhone),
                        SizedBox(height: isSmallPhone ? 8 : 10),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          ..._misVehiculos.map((v) {
                            final isRentado = v['estado'] == 'RENTADO';
                            final rentInfo = isRentado
                                ? 'Rentado a ${v['rentado_a']} hasta el ${v['fecha_fin_renta']}'
                                : null;
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: isSmallPhone ? 12 : 14),
                              child: _buildVehicleCardFromJson(
                                context: context,
                                isSmallPhone: isSmallPhone,
                                vehiculo: v,
                                rentInfo: rentInfo,
                              ),
                            );
                          }),
                        SizedBox(height: isSmallPhone ? 16 : 18),
                        _buildTipsCard(context, isSmallPhone),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
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
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mis Vehículos',
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1,
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
                      const Icon(Icons.add, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Publicar',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.attach_money,
                value:
                    _isLoading ? '\$0' : '\$${_formatNumber(_calcularSaldo())}',
                label: 'Saldo',
              ),
              const SizedBox(width: 6),
              _buildStatCard(
                icon: Icons.directions_car,
                value: _isLoading ? '0' : '${_misVehiculos.length}',
                label: 'Vehículos',
              ),
              const SizedBox(width: 6),
              _buildStatCard(
                icon: Icons.people_outline,
                value: _isLoading ? '0' : '${_calcularRentasActivas()}',
                label: 'Activas',
              ),
              const SizedBox(width: 6),
              _buildStatCard(
                icon: Icons.trending_up,
                value: _isLoading
                    ? '\$0'
                    : '\$${_formatNumber(_calcularGanancias())}',
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
        height: 70,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 9,
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

  Widget _buildPendingRequestCard(BuildContext context, bool isSmallPhone) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 12 : 14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.access_time, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1 solicitud pendiente',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Revisa y acepta solicitudes de renta',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: const Color(0xFFEF4444), size: 24),
        ],
      ),
    );
  }

  Widget _buildPublishedHeader(BuildContext context, bool isSmallPhone) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          '🚗',
          style: TextStyle(fontSize: isSmallPhone ? 14 : 16),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            'Mis Vehículos Publicados',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 16 : 17,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          '+ Agregar',
          style: GoogleFonts.inter(
            fontSize: isSmallPhone ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFBBF24),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCardFromJson({
    required BuildContext context,
    required bool isSmallPhone,
    required Map<String, dynamic> vehiculo,
    required String? rentInfo,
  }) {
    final imagePath = vehiculo['imagen'] as String?;
    final title =
        '${vehiculo['marca'] ?? 'Vehículo'} ${vehiculo['modelo'] ?? ''}';
    final subtitle =
        '${vehiculo['marca'] ?? ''} • ${vehiculo['categoria'] ?? 'Sedán'}';
    final rating = (vehiculo['calificacion'] ?? 4.5).toString();
    final trips = '${vehiculo['viajes'] ?? 0} viajes';
    final pricePerDay = '\$${_formatNumber(vehiculo['precio_dia'] ?? 0)}/día';
    final earned = '\$${_formatNumber(vehiculo['ganado'] ?? 0)}';
    final status = vehiculo['estado'] as String? ?? 'DISPONIBLE';
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 10 : 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imagePath != null
                    ? Image.asset(
                        imagePath,
                        width: isSmallPhone ? 90 : 100,
                        height: isSmallPhone ? 70 : 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: isSmallPhone ? 90 : 100,
                        height: isSmallPhone ? 70 : 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.grey,
                          size: 32,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
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
                              fontSize: isSmallPhone ? 14 : 15,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFF59E0B),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFF59E0B),
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$rating • $trips',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                fontSize: isSmallPhone ? 16 : 17,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFF59E0B),
                              ),
                              children: [
                                TextSpan(
                                    text: pricePerDay.replaceAll('/día', '')),
                                TextSpan(
                                  text: '/día',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Ganado',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            Text(
                              earned,
                              style: GoogleFonts.inter(
                                fontSize: isSmallPhone ? 14 : 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
                              ),
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
            const SizedBox(height: 8),
            Divider(
                height: 1, color: theme.dividerColor.withValues(alpha: 0.5)),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: _buildRentInfoText(context, rentInfo),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRentInfoText(BuildContext context, String rentInfo) {
    final theme = Theme.of(context);
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            height: 1.5,
          ),
          children: [
            TextSpan(text: beforeName),
            TextSpan(
              text: name,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
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
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        height: 1.5,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTipsCard(BuildContext context, bool isSmallPhone) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallPhone ? 12 : 14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 Maximiza tus ganancias',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 14 : 15,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          _tipItem(context, '📸 Agrega fotos de alta calidad de tu vehículo'),
          const SizedBox(height: 4),
          _tipItem(context, '💰 Ajusta precios competitivos según la demanda'),
          const SizedBox(height: 4),
          _tipItem(context, '⭐ Mantén tu vehículo limpio para buenas reseñas'),
        ],
      ),
    );
  }

  Widget _tipItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  int _calcularSaldo() {
    // Saldo disponible = ganancias totales - un estimado de retención
    final ganancias = _calcularGanancias();
    return (ganancias * 0.3).round();
  }

  int _calcularRentasActivas() {
    return _misVehiculos.where((v) => v['estado'] == 'RENTADO').length;
  }

  int _calcularGanancias() {
    return _misVehiculos.fold(0, (sum, v) => sum + (v['ganado'] as int? ?? 0));
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (match) => '${match[1]}.',
        );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_utils.dart';

class SolicitudesPage extends StatefulWidget {
  final int initialTab;
  const SolicitudesPage({super.key, this.initialTab = 0});

  @override
  State<SolicitudesPage> createState() => SolicitudesPageState();
}

class SolicitudesPageState extends State<SolicitudesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(SolicitudesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _tabController.animateTo(widget.initialTab);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void setTab(int index) {
    if (index >= 0 && index < 3) {
      _tabController.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            _buildHeader(isSmallPhone),
            _buildTitleSection(isSmallPhone),
            _buildTabBar(isSmallPhone),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPendientesList(isSmallPhone),
                  _buildActivasList(isSmallPhone),
                  _buildCompletadasList(isSmallPhone),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallPhone) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isSmallPhone ? 16 : 20,
        MediaQuery.of(context).padding.top + (isSmallPhone ? 12 : 16),
        isSmallPhone ? 16 : 20,
        isSmallPhone ? 14 : 16,
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
          Text(
            'Solicitudes',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmallPhone ? 4 : 6),
          Text(
            'Gestiona las rentas de tus vehículos',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 13 : 15,
              color: Colors.white.withValues(alpha: 0.95),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(bool isSmallPhone) {
    final theme = Theme.of(context);
    return Container(
      color: theme.cardTheme.color,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isSmallPhone ? 16 : 20,
        isSmallPhone ? 16 : 20,
        isSmallPhone ? 16 : 20,
        isSmallPhone ? 12 : 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solicitudes de Renta',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmallPhone ? 4 : 6),
          Text(
            'Gestiona las solicitudes de tus vehículos',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 13 : 15,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isSmallPhone) {
    final theme = Theme.of(context);
    return Container(
      color: theme.cardTheme.color,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 12 : 16,
        vertical: isSmallPhone ? 10 : 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCustomTab(
              label: 'Pendientes',
              count: '1',
              isActive: _tabController.index == 0,
              onTap: () => _tabController.animateTo(0),
              isSmallPhone: isSmallPhone,
            ),
          ),
          SizedBox(width: isSmallPhone ? 8 : 10),
          Expanded(
            child: _buildCustomTab(
              label: 'Activas',
              count: '1',
              isActive: _tabController.index == 1,
              onTap: () => _tabController.animateTo(1),
              isSmallPhone: isSmallPhone,
            ),
          ),
          SizedBox(width: isSmallPhone ? 8 : 10),
          Expanded(
            child: _buildCustomTab(
              label: 'Completadas',
              count: '2',
              isActive: _tabController.index == 2,
              onTap: () => _tabController.animateTo(2),
              isSmallPhone: isSmallPhone,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTab({
    required String label,
    required String count,
    required bool isActive,
    required VoidCallback onTap,
    required bool isSmallPhone,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallPhone ? 8 : 12,
          vertical: isSmallPhone ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: isActive 
              ? (isDarkMode ? const Color(0xFF3B2510) : const Color(0xFFFFFBEB))
              : (isDarkMode ? const Color(0xFF334155) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF10B981) : (isDarkMode ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
            width: isActive ? 2 : 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 11 : 14,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? const Color(0xFF10B981)
                    : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              count,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? const Color(0xFF10B981)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendientesList(bool isSmallPhone) {
    return ListView(
      padding: EdgeInsets.all(isSmallPhone ? 14 : 16),
      children: [
        _buildRequestCard(
          isSmallPhone: isSmallPhone,
          userName: 'María López',
          userImage: 'https://i.pravatar.cc/150?img=5',
          userRating: '4.9',
          userType: 'Arrendatario',
          vehicleName: 'Chevrolet Onix Turbo',
          vehicleImage: 'assets/imagenes_carros/cx5.jpg',
          startDate: '2026-03-12',
          endDate: '2026-03-14',
          location: 'Cl 72 #10-34, Bogotá',
          totalPrice: '\$240.000',
          status: 'pending',
        ),
      ],
    );
  }

  Widget _buildActivasList(bool isSmallPhone) {
    return ListView(
      padding: EdgeInsets.all(isSmallPhone ? 14 : 16),
      children: [
        _buildRequestCard(
          isSmallPhone: isSmallPhone,
          userName: 'Carlos Mendoza',
          userImage: 'https://i.pravatar.cc/150?img=12',
          userRating: '4.8',
          userType: 'Arrendatario',
          vehicleName: 'Mazda 3 Grand Touring',
          vehicleImage: 'assets/imagenes_carros/tesla.jpg',
          startDate: '2026-03-08',
          endDate: '2026-03-15',
          location: 'Cra 15 #85-20, Bogotá',
          totalPrice: '\$1.260.000',
          status: 'active',
        ),
      ],
    );
  }

  Widget _buildCompletadasList(bool isSmallPhone) {
    return ListView(
      padding: EdgeInsets.all(isSmallPhone ? 14 : 16),
      children: [
        _buildRequestCard(
          isSmallPhone: isSmallPhone,
          userName: 'Andrea López',
          userImage: 'https://i.pravatar.cc/150?img=9',
          userRating: '4.8',
          userType: 'Arrendatario',
          vehicleName: 'Chevrolet Onix Turbo',
          vehicleImage: 'assets/imagenes_carros/cx5.jpg',
          startDate: '2026-02-12',
          endDate: '2026-02-14',
          location: 'Cra 7 #32-16, Bogotá',
          totalPrice: '\$240.000',
          status: 'completed',
        ),
        SizedBox(height: isSmallPhone ? 12 : 14),
        _buildRequestCard(
          isSmallPhone: isSmallPhone,
          userName: 'Roberto Silva',
          userImage: 'https://i.pravatar.cc/150?img=13',
          userRating: '4.6',
          userType: 'Arrendatario',
          vehicleName: 'Mazda 3 Grand Touring',
          vehicleImage: 'assets/imagenes_carros/tesla.jpg',
          startDate: '2026-02-05',
          endDate: '2026-02-08',
          location: 'Cl 100 #18-90, Bogotá',
          totalPrice: '\$540.000',
          status: 'completed',
        ),
      ],
    );
  }

  Widget _buildRequestCard({
    required bool isSmallPhone,
    required String userName,
    required String userImage,
    required String userRating,
    required String userType,
    required String vehicleName,
    required String vehicleImage,
    required String startDate,
    required String endDate,
    required String location,
    required String totalPrice,
    required String status,
  }) {
    Color statusColor;
    Color statusBgColor;
    String statusText;

    switch (status) {
      case 'pending':
        statusColor = const Color(0xFFEF4444);
        statusBgColor = const Color(0xFFFFF7ED);
        statusText = 'PENDIENTE';
        break;
      case 'active':
        statusColor = const Color(0xFF3B82F6);
        statusBgColor = const Color(0xFFEFF6FF);
        statusText = 'ACTIVA';
        break;
      case 'completed':
        statusColor = const Color(0xFF10B981);
        statusBgColor = const Color(0xFFECFDF5);
        statusText = 'COMPLETADA';
        break;
      default:
        statusColor = const Color(0xFF94A3B8);
        statusBgColor = const Color(0xFFF1F5F9);
        statusText = 'DESCONOCIDO';
    }

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 16 : 18),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con usuario y badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 17 : 19,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          userRating,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '• $userType',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF94A3B8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallPhone ? 10 : 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 11 : 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Vehículo con imagen
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  vehicleImage,
                  width: isSmallPhone ? 90 : 100,
                  height: isSmallPhone ? 72 : 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicleName,
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 15 : 17,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$startDate - $endDate',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Detalles con iconos
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Fechas',
            value: '$startDate → $endDate',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: 'Ubicación',
            value: location,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.attach_money,
            label: 'Monto total',
            value: totalPrice,
            valueColor: const Color(0xFF10B981),
            valueBold: true,
          ),

          // Botones solo para pendientes
          if (status == 'pending') ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(),
                    icon: const Icon(Icons.cancel_outlined, size: 20),
                    label: Text(
                      'Rechazar',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAcceptDialog(),
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: Text(
                      'Aprobar',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool valueBold = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF94A3B8),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
                  color: valueColor ?? theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAcceptDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '¿Aprobar solicitud?',
                style: GoogleFonts.inter(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'El usuario será notificado y podrá proceder con el pago. Asegúrate de que tu vehículo estará disponible en las fechas solicitadas.',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackBar('Solicitud aprobada correctamente');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Confirmar',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog() {
    String? selectedReason;
    final reasons = [
      'Fechas no disponibles',
      'Mantenimiento programado',
      'Vehículo ya rentado',
      'Perfil del usuario no verificado',
      'Otro motivo',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.cancel,
                  color: Color(0xFFEF4444),
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¿Rechazar solicitud?',
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona el motivo del rechazo:',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ...reasons.map((reason) => RadioListTile<String>(
                    title: Text(
                      reason,
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                    value: reason,
                    groupValue: selectedReason,
                    activeColor: const Color(0xFFEF4444),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() => selectedReason = value);
                    },
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: selectedReason != null
                  ? () {
                      Navigator.pop(context);
                      _showSuccessSnackBar('Solicitud rechazada');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Rechazar',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

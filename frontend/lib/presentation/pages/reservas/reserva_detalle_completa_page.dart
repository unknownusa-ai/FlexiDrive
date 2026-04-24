import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/responsive_utils.dart';
import '../../../services/reservations/local_reservation_db.dart';
import '../../../services/publications/local_publication_db.dart';
import '../../../services/vehiculo_service.dart';

// Página de detalle completo de reserva
// Muestra toda la información detallada de una reserva específica
class ReservaDetalleCompletaPage extends StatefulWidget {
  // Constructor con código e ID de la reserva
  const ReservaDetalleCompletaPage({
    super.key,
    required this.reservaCode, // Código de la reserva
    required this.reservaId, // ID de la reserva
  });

  // Código único de la reserva
  final String reservaCode;
  // ID de la reserva en la base de datos
  final int reservaId;

  @override
  State<ReservaDetalleCompletaPage> createState() =>
      _ReservaDetalleCompletaPageState();
}

class _ReservaDetalleCompletaPageState
    extends State<ReservaDetalleCompletaPage> {
  final LocalReservationDb _reservationDb = LocalReservationDb.instance;
  final LocalPublicationDb _publicationDb = LocalPublicationDb.instance;
  final VehiculoService _vehiculoService = VehiculoService();

  Map<String, dynamic>? _reserva;
  Map<String, dynamic>? _vehiculo;
  bool _isLoading = true;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _textPrimary =>
      _isDark ? const Color(0xFFF1F3FF) : const Color(0xFF0F172A);
  Color get _textSecondary =>
      _isDark ? const Color(0xFF8B93B8) : const Color(0xFF94A3B8);
  Color get _borderColor =>
      _isDark ? const Color(0xFF2E3355) : const Color(0xFFE2E8F0);
  Color get _cardBgColor => _isDark ? const Color(0xFF1A1F35) : Colors.white;

  @override
  void initState() {
    super.initState();
    _loadReservaDetails();
  }

  Future<void> _loadReservaDetails() async {
    await Future.wait([
      _reservationDb.loadIfNeeded(),
      _publicationDb.loadIfNeeded(),
      _vehiculoService.init(),
    ]);

    // Find the reservation
    final reservas = _reservationDb.reservations;
    final reserva = reservas.firstWhere(
      (r) => r.id == widget.reservaId,
      orElse: () => reservas.firstWhere(
        (r) => r.code == widget.reservaCode,
        orElse: () => throw Exception('Reserva no encontrada'),
      ),
    );

    // Get publication and vehicle details
    final publicacion = _publicationDb.publications
        .firstWhere((p) => p.id == reserva.publicationId);
    final vehiculos = _vehiculoService.getVehiculos();
    final vehiculo = vehiculos.firstWhere(
      (v) => v['id'] == publicacion.vehicleId,
      orElse: () => vehiculos.first,
    );

    setState(() {
      _reserva = {
        'id': reserva.id,
        'code': reserva.code,
        'statusId': reserva.statusId,
        'startDate': reserva.startDate,
        'endDate': reserva.endDate,
        'totalValue': reserva.totalValue,
        'pickupLocation': reserva.pickupLocation,
        'returnLocation': reserva.returnLocation,
        'periodCount': reserva.periodCount,
        'publicationId': reserva.publicationId,
      };
      _vehiculo = vehiculo;
      _isLoading = false;
    });
  }

  String _formatDate(DateTime date) {
    final months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatAmount(int amount) {
    // Formato simple: separar miles con puntos
    return amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  
  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isSmallPhone),
          SliverPadding(
            padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildVehicleInfo(isSmallPhone),
                const SizedBox(height: 20),
                _buildReservationInfo(isSmallPhone),
                const SizedBox(height: 20),
                _buildPricingInfo(isSmallPhone),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isSmallPhone) {
    return SliverAppBar(
      expandedHeight: isSmallPhone ? 200 : 250,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (_vehiculo!['imagen'] != null && _vehiculo!['imagen'].isNotEmpty)
              Image.asset(
                _vehiculo!['imagen'],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
              )
            else
              _buildPlaceholderImage(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: const Center(
        child: Icon(
          Icons.directions_car,
          size: 80,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildVehicleInfo(bool isSmallPhone) {
    return _buildInfoCard(
      title: 'Información del Vehículo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_vehiculo!['linea'] ?? 'Vehículo'} ${_vehiculo!['modelo'] ?? ''}',
            style: GoogleFonts.poppins(
              fontSize: isSmallPhone ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Color',
            _vehiculo!['color']?.toString() ?? 'No especificado',
            Icons.palette_outlined,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Transmisión',
            _vehiculo!['transmision']?.toString() ?? 'No especificado',
            Icons.settings_outlined,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Combustible',
            _vehiculo!['combustible']?.toString() ?? 'No especificado',
            Icons.local_gas_station_outlined,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Asientos',
            _vehiculo!['asientos']?.toString() ?? 'No especificado',
            Icons.airline_seat_recline_normal_outlined,
          ),
          if (_vehiculo!['aire_acondicionado'] == true) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              'Aire Acondicionado',
              'Sí',
              Icons.ac_unit_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReservationInfo(bool isSmallPhone) {
    return _buildInfoCard(
      title: 'Información de la Reserva',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Código: ',
                style: GoogleFonts.poppins(
                  fontSize: isSmallPhone ? 16 : 18,
                  color: _textSecondary,
                ),
              ),
              Text(
                _reserva!['code'],
                style: GoogleFonts.poppins(
                  fontSize: isSmallPhone ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Fecha de inicio',
            _formatDate(_reserva!['startDate']),
            Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Fecha de fin',
            _formatDate(_reserva!['endDate']),
            Icons.event_available_outlined,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Lugar de recogida',
            _reserva!['pickupLocation'],
            Icons.location_on_outlined,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Lugar de devolución',
            _reserva!['returnLocation'],
            Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingInfo(bool isSmallPhone) {
    // Calculate actual values based on reservation data
    final totalValue = (_reserva!['totalValue'] as num).toDouble();
    final periodCount = _reserva!['periodCount'] as int;

    // Try to get publication prices
    final publicationId = _reserva!['publicationId'] as int?;
    double vehicleRental;
    double insurance;

    if (publicationId != null) {
      final publicationPrices = _publicationDb.publicationPrices
          .where((p) => p.publicationId == publicationId)
          .toList();
      
      if (publicationPrices.isNotEmpty) {
        // Find daily rate (periodTypeId 2 = daily)
        final dailyPrice = publicationPrices
            .firstWhere((p) => p.periodTypeId == 2, 
                orElse: () => publicationPrices.first);
        final dailyRate = dailyPrice.price;
        
        // Calculate vehicle rental (daily rate * days)
        vehicleRental = dailyRate * periodCount;
        
        // Ensure vehicle rental doesn't exceed total
        if (vehicleRental > totalValue) {
          vehicleRental = totalValue * 0.85; // 85% for vehicle
        }
        
        // Calculate insurance and service fee (remaining amount)
        insurance = totalValue - vehicleRental;
      } else {
        // No prices found, use default split: 85% vehicle, 15% insurance
        vehicleRental = totalValue * 0.85;
        insurance = totalValue * 0.15;
      }
    } else {
      // No publication info, use default split
      vehicleRental = totalValue * 0.85;
      insurance = totalValue * 0.15;
    }

    return _buildInfoCard(
      title: 'Desglose de Precios',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPricingRow(
            'Alquiler del vehículo',
            '\$ ${_formatAmount(vehicleRental.round())}',
            isSmallPhone,
          ),
          const SizedBox(height: 8),
          _buildPricingRow(
            'Seguro',
            '\$ ${_formatAmount(insurance.round())}',
            isSmallPhone,
          ),
          Divider(height: 20, color: _borderColor),
          _buildPricingRow(
            'Total',
            '\$ ${_formatAmount(totalValue.round())}',
            isSmallPhone,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF6366F1),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingRow(String label, String value, bool isSmallPhone,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isSmallPhone ? 14 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: _textPrimary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isSmallPhone ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFF10B981) : _textPrimary,
          ),
        ),
      ],
    );
  }
}

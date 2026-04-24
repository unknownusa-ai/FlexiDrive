import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/responsive_utils.dart';
import '../../../core/session/local_session_store.dart';
import '../../../services/payments/local_payment_db.dart';
import '../../../services/catalogs/local_catalog_db.dart';
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
  final LocalSessionStore _sessionStore = LocalSessionStore.instance;
  final LocalPaymentDb _paymentDb = LocalPaymentDb.instance;
  final LocalCatalogDb _catalogDb = LocalCatalogDb.instance;
  final LocalReservationDb _reservationDb = LocalReservationDb.instance;
  final LocalPublicationDb _publicationDb = LocalPublicationDb.instance;
  final VehiculoService _vehiculoService = VehiculoService();

  Map<String, dynamic>? _reserva;
  Map<String, dynamic>? _vehiculo;
  Map<String, dynamic>? _paymentMethod;
  Map<String, dynamic>? _paymentDetails;
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
      _sessionStore.init(),
      _paymentDb.loadIfNeeded(),
      _catalogDb.loadIfNeeded(),
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

    // Get payment method details
    final paymentMethod =
        _paymentDb.getPaymentMethodById(reserva.paymentMethodId);
    Map<String, dynamic>? paymentDetails;

    if (paymentMethod != null) {
      if (paymentMethod.paymentMethodTypeId == 1) {
        // Tarjeta
        final card = _paymentDb.getCardByPaymentMethodId(paymentMethod.id);
        final cardBrand = _catalogDb.cardBrands.firstWhere(
            (brand) => brand.id == card?.cardBrandId,
            orElse: () => _catalogDb.cardBrands.first);

        paymentDetails = {
          'type': 'Tarjeta',
          'brand': cardBrand.name,
          'last4':
              card?.cardNumber.substring(card.cardNumber.length - 4) ?? '****',
          'expiryMonth': card?.expirationMonth,
          'expiryYear': card?.expirationYear,
        };
      } else if (paymentMethod.paymentMethodTypeId == 2) {
        // PSE
        final pse = _paymentDb.getPseByPaymentMethodId(paymentMethod.id);
        final bank = _catalogDb.banks.firstWhere(
            (bank) => bank.id == pse?.bankId,
            orElse: () => _catalogDb.banks.first);

        paymentDetails = {
          'type': 'PSE',
          'bank': bank.name,
          'personType': pse?.personTypeId == 1 ? 'Natural' : 'Jurídica',
        };
      } else {
        // Efectivo
        paymentDetails = {
          'type': 'Efectivo',
        };
      }
    }

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
        'paymentMethodId': reserva.paymentMethodId,
        'periodCount': reserva.periodCount,
      };
      _vehiculo = vehiculo;
      _paymentMethod = paymentMethod != null
          ? {
              'id': paymentMethod.id,
              'typeId': paymentMethod.paymentMethodTypeId,
              'isDefault': paymentMethod.isDefault,
            }
          : null;
      _paymentDetails = paymentDetails;
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
    final digits = amount.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString().split('').reversed.join('');
  }

  String _getStatusLabel(int statusId) {
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

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1:
        return const Color(0xFFF59E0B);
      case 2:
        return const Color(0xFF3B82F6);
      case 3:
        return const Color(0xFFEF4444);
      case 4:
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFFF59E0B);
    }
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
                _buildPaymentInfo(isSmallPhone),
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
            _vehiculo!['tipo_transmision']?.toString() ?? 'No especificado',
            Icons.settings_outlined,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Combustible',
            _vehiculo!['tipo_combustible']?.toString() ?? 'No especificado',
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
    final status = _getStatusLabel(_reserva!['statusId']);
    final statusColor = _getStatusColor(_reserva!['statusId']);

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
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallPhone ? 8 : 12,
                  vertical: isSmallPhone ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallPhone ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
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

  Widget _buildPaymentInfo(bool isSmallPhone) {
    if (_paymentDetails == null) {
      return _buildInfoCard(
        title: 'Información de Pago',
        child: Text(
          'Método de pago no disponible',
          style: GoogleFonts.poppins(
            fontSize: isSmallPhone ? 14 : 16,
            color: _textSecondary,
          ),
        ),
      );
    }

    return _buildInfoCard(
      title: 'Información de Pago',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _paymentDetails!['type'] == 'Tarjeta'
                    ? Icons.credit_card
                    : _paymentDetails!['type'] == 'PSE'
                        ? Icons.account_balance
                        : Icons.attach_money,
                color: const Color(0xFF6366F1),
                size: isSmallPhone ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                _paymentDetails!['type'],
                style: GoogleFonts.poppins(
                  fontSize: isSmallPhone ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_paymentDetails!['type'] == 'Tarjeta') ...[
            _buildInfoRow(
              'Banco',
              _paymentDetails!['brand'],
              Icons.credit_card,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Número',
              '•••• ${_paymentDetails!['last4']}',
              Icons.numbers,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Vencimiento',
              '${_paymentDetails!['expiryMonth']}/${_paymentDetails!['expiryYear']}',
              Icons.date_range,
            ),
          ] else if (_paymentDetails!['type'] == 'PSE') ...[
            _buildInfoRow(
              'Banco',
              _paymentDetails!['bank'],
              Icons.account_balance,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Tipo de persona',
              _paymentDetails!['personType'],
              Icons.person_outline,
            ),
          ] else ...[
            _buildInfoRow(
              'Método',
              'Pago en efectivo',
              Icons.attach_money,
            ),
          ],
          if (_paymentMethod?['isDefault'] == true) ...[
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallPhone ? 8 : 12,
                vertical: isSmallPhone ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: const Color(0xFF10B981),
                    size: isSmallPhone ? 16 : 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Método predeterminado',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallPhone ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingInfo(bool isSmallPhone) {
    // Calculate actual values based on reservation data
    final totalValue = _reserva!['totalValue'] as double;
    final periodCount = _reserva!['periodCount'] as int;

    // Get publication price to find the actual rate
    final publicationPrice = _publicationDb.publicationPrices.firstWhere(
        (p) => p.publicationId == _reserva!['publicationId'],
        orElse: () => _publicationDb.publicationPrices.first);
    final dailyRate = publicationPrice.price;

    // Calculate vehicle rental (based on actual rate)
    final vehicleRental = dailyRate * periodCount;

    // Calculate insurance (remaining amount)
    final insurance = totalValue - vehicleRental;

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

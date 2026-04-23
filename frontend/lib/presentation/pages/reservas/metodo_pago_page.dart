import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/session/local_session_store.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../services/notifications/local_notification_db.dart';
import 'reserva_confirmada_page.dart';
import 'reservas_store.dart';

class MetodoPagoPage extends StatefulWidget {
  const MetodoPagoPage({
    super.key,
    this.total = 54900,
    this.alquilerVehiculo = 38000,
    this.servicioSeguro = 16900,
    this.periodo = 'Semanas',
    this.cantidad = 1,
    this.precioUnitario = 38000,
    this.vehiculoBrand = 'Mazda CX-5 2024',
    this.vehiculoImage = '',
    this.lugarRecogida = 'Av. El Dorado, Bogotá',
  });

  final int total;
  final int alquilerVehiculo;
  final int servicioSeguro;
  final String periodo;
  final int cantidad;
  final int precioUnitario;
  final String vehiculoBrand;
  final String vehiculoImage;
  final String lugarRecogida;

  @override
  State<MetodoPagoPage> createState() => _MetodoPagoPageState();
}

class _MetodoPagoPageState extends State<MetodoPagoPage> {
  static const _reservaCategoryId = 1;

  String _metodoPago = 'Tarjeta';
  final _numeroTarjetaCtrl = TextEditingController();
  final _titularCtrl = TextEditingController();
  final _vencimientoCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final LocalSessionStore _sessionStore = LocalSessionStore.instance;
  final LocalNotificationDb _notificationDb = LocalNotificationDb.instance;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _textPrimary =>
      _isDark ? const Color(0xFFF1F3FF) : const Color(0xFF0F172A);
  Color get _textSecondary =>
      _isDark ? const Color(0xFF8B93B8) : const Color(0xFF94A3B8);
  Color get _borderColor =>
      _isDark ? const Color(0xFF2E3355) : const Color(0xFFE2E8F0);
  Color get _cardBgColor => _isDark ? const Color(0xFF1A1F35) : Colors.white;
  Color get _inputBgColor =>
      _isDark ? const Color(0xFF272B40) : const Color(0xFFF3F4F6);

  String get _totalFormateado {
    final asString = widget.total.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < asString.length; i++) {
      final reverseIndex = asString.length - i;
      buffer.write(asString[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  String _formatearNumero(int value) {
    final asString = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < asString.length; i++) {
      final reverseIndex = asString.length - i;
      buffer.write(asString[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  String _formatearFechaCorta(DateTime date) {
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

  DateTime _calcularFechaFin(DateTime inicio) {
    final periodo = widget.periodo.toLowerCase();

    if (periodo.contains('hora')) {
      return inicio.add(Duration(hours: widget.cantidad));
    }

    if (periodo.contains('semana')) {
      return inicio.add(Duration(days: widget.cantidad * 7));
    }

    return inicio.add(Duration(days: widget.cantidad));
  }

  String _generarCodigoReserva() {
    final now = DateTime.now();
    final suffix =
        (now.microsecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    return 'FXD-${now.year}-$suffix';
  }

  Future<void> _crearNotificacionReserva({
    required String codigoReserva,
    required DateTime fechaInicio,
  }) async {
    await _sessionStore.init();
    final currentUserId = _sessionStore.userId;
    if (currentUserId == null) return;

    await _notificationDb.addNotification(
      userId: currentUserId,
      categoryId: _reservaCategoryId,
      subject: 'Reserva confirmada',
      description:
          'Tu reserva $codigoReserva de ${widget.vehiculoBrand} fue confirmada para ${_formatearFechaCorta(fechaInicio)} en ${widget.lugarRecogida}.',
    );
  }

  @override
  void dispose() {
    _numeroTarjetaCtrl.dispose();
    _titularCtrl.dispose();
    _vencimientoCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final padding = isSmallPhone ? 12.0 : 20.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetodoSeleccion(isSmallPhone),
                    SizedBox(height: isSmallPhone ? 16 : 24),
                    if (_metodoPago == 'Tarjeta') ...[
                      _buildTarjetaCard(isSmallPhone),
                      SizedBox(height: isSmallPhone ? 16 : 20),
                      _buildCamposTarjeta(isSmallPhone),
                    ],
                    if (_metodoPago == 'PSE') ...[
                      _buildPSEContent(isSmallPhone),
                    ],
                    if (_metodoPago == 'Efectivo') ...[
                      _buildEfectivoContent(isSmallPhone),
                    ],
                    SizedBox(height: isSmallPhone ? 16 : 24),
                    _buildResumenCobro(isSmallPhone),
                    SizedBox(height: isSmallPhone ? 16 : 20),
                    _buildSeguridad(isSmallPhone),
                    SizedBox(height: isSmallPhone ? 16 : 24),
                  ],
                ),
              ),
            ),
          ),
          _buildBotonPagar(isSmallPhone),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Método de Pago',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepCircle(1, isCompleted: true, isActive: false),
                  _buildStepLine(true),
                  _buildStepCircle(2, isCompleted: false, isActive: true),
                  _buildStepLine(false),
                  _buildStepCircle(3, isCompleted: false, isActive: false),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCircle(int step,
      {required bool isCompleted, required bool isActive}) {
    Color backgroundColor;
    Widget child;

    if (isCompleted) {
      // Step completado (paso 1) - fondo blanco con checkmark verde
      backgroundColor = Colors.white;
      child = const Icon(Icons.check, color: Color(0xFF10B981), size: 22);
    } else if (isActive) {
      // Step activo (paso 2) - fondo morado/azul con número blanco
      backgroundColor = const Color(0xFF6366F1);
      child = Text(
        '$step',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 16,
        ),
      );
    } else {
      // Step futuro (paso 3) - fondo semi-transparente con número blanco
      backgroundColor = Colors.white.withValues(alpha: 0.3);
      child = Text(
        '$step',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 16,
        ),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(child: child),
    );
  }

  Widget _buildStepLine(bool completed) {
    return Container(
      width: 60,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: completed ? Colors.white : Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildMetodoSeleccion(bool isSmallPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECCIONA EL MÉTODO',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMetodoBoton('Tarjeta', Icons.credit_card, isSmallPhone),
            const SizedBox(width: 12),
            _buildMetodoBoton('PSE', Icons.apartment, isSmallPhone),
            const SizedBox(width: 12),
            _buildMetodoBoton('Efectivo', Icons.attach_money, isSmallPhone),
          ],
        ),
      ],
    );
  }

  Widget _buildMetodoBoton(String label, IconData icon, bool isSmallPhone) {
    final selected = _metodoPago == label;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _metodoPago = label),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isSmallPhone ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEEF2FF) : _cardBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF4F46E5) : _borderColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? const Color(0xFF4F46E5) : _textSecondary,
                size: isSmallPhone ? 24 : 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: isSmallPhone ? 12 : 13,
                  fontWeight: FontWeight.bold,
                  color: selected ? const Color(0xFF4F46E5) : _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTarjetaCard(bool isSmallPhone) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chip dorado
              Container(
                width: 40,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                'FLEXIDRIVE',
                style: GoogleFonts.poppins(
                  fontSize: isSmallPhone ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Números de tarjeta en formato **** **** **** ****
          Text(
            '• • • •    • • • •    • • • •    • • • •',
            style: GoogleFonts.poppins(
              fontSize: isSmallPhone ? 16 : 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          // MM/AA alineado a la derecha
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'MM/AA',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCamposTarjeta(bool isSmallPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NÚMERO DE TARJETA',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        _buildInputField('1234 5678 9012 3456', _numeroTarjetaCtrl),
        const SizedBox(height: 16),
        Text(
          'TITULAR',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        _buildInputField('NOMBRE COMO EN LA TARJETA', _titularCtrl),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VENCIMIENTO',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInputField('MM/AA', _vencimientoCtrl),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CVV',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInputField('•••', _cvvCtrl),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPSEContent(bool isSmallPhone) {
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Serás redirigido al portal PSE para completar el pago de forma segura. Tiempo: 2-5 min.',
            style: GoogleFonts.poppins(
              fontSize: isSmallPhone ? 12 : 13,
              color: _textSecondary,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmallPhone ? 16 : 20),
          Container(
            padding: EdgeInsets.all(isSmallPhone ? 12 : 14),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: isSmallPhone ? 36 : 40,
                  height: isSmallPhone ? 36 : 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.apartment,
                    color: Color(0xFF4F46E5),
                    size: 20,
                  ),
                ),
                SizedBox(width: isSmallPhone ? 12 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Banco: Bancolombia',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallPhone ? 13 : 14,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                      SizedBox(height: isSmallPhone ? 2 : 4),
                      Text(
                        'Débito bancario directo',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallPhone ? 11 : 12,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEfectivoContent(bool isSmallPhone) {
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isSmallPhone ? 36 : 40,
                height: isSmallPhone ? 36 : 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              SizedBox(width: isSmallPhone ? 12 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pago en efectivo',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallPhone ? 14 : 15,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    SizedBox(height: isSmallPhone ? 2 : 4),
                    Text(
                      'Paga al recoger tu vehículo',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallPhone ? 11 : 12,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallPhone ? 14 : 16),
          Container(
            padding: EdgeInsets.all(isSmallPhone ? 12 : 14),
            decoration: BoxDecoration(
              color:
                  _isDark ? const Color(0xFF0F3D2D) : const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF10B981),
                  size: 18,
                ),
                SizedBox(width: isSmallPhone ? 10 : 12),
                Expanded(
                  child: Text(
                    'Av. El Dorado — Bogotá. Lleva el código de reserva.',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallPhone ? 11 : 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(
        color: _textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: _textSecondary,
          fontSize: 14,
        ),
        filled: true,
        fillColor: _inputBgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildResumenCobro(bool isSmallPhone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del cobro',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildResumenLineaDetallada(),
          const SizedBox(height: 8),
          _buildResumenLinea('Servicio + Seguro', widget.servicioSeguro),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: _borderColor,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              Text(
                '\$ $_totalFormateado',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumenLineaDetallada() {
    String unidadLabel = widget.cantidad == 1
        ? widget.periodo.toLowerCase().replaceAll('s', '')
        : widget.periodo.toLowerCase();

    final precioFormateado = _formatearPrecio(widget.precioUnitario);
    final totalAlquilerFormateado = _formatearPrecio(widget.alquilerVehiculo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alquiler vehículo',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '\$ $totalAlquilerFormateado',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '\$ $precioFormateado x ${widget.cantidad} $unidadLabel',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: _textSecondary.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  String _formatearPrecio(int precio) {
    final asString = precio.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < asString.length; i++) {
      final reverseIndex = asString.length - i;
      buffer.write(asString[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  Widget _buildResumenLinea(String label, int monto) {
    final montoFormateado = _formatearPrecio(monto);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: _textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '\$ $montoFormateado',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSeguridad(bool isSmallPhone) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF0F3D2D) : const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pago 100% seguro • SSL 256-bit',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonPagar(bool isSmallPhone) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          isSmallPhone ? 12 : 20,
          isSmallPhone ? 10 : 14,
          isSmallPhone ? 12 : 20,
          isSmallPhone ? 10 : 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          top: BorderSide(color: _borderColor),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: isSmallPhone ? 48 : 56,
          child: ElevatedButton(
            onPressed: () async {
              final codigoReserva = _generarCodigoReserva();
              final fechaInicio = DateTime.now();
              final fechaFin = _calcularFechaFin(fechaInicio);

              ReservasStore.addActiva(
                ReservaActiva(
                  vehicleName: widget.vehiculoBrand,
                  code: codigoReserva,
                  price: '\$ ${_formatearNumero(widget.total)}',
                  startDate: _formatearFechaCorta(fechaInicio),
                  endDate: _formatearFechaCorta(fechaFin),
                  location: widget.lugarRecogida,
                  imageUrl: widget.vehiculoImage,
                ),
              );

              await _crearNotificacionReserva(
                codigoReserva: codigoReserva,
                fechaInicio: fechaInicio,
              );

              if (!mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ReservaConfirmadaPage(
                    vehiculoBrand: widget.vehiculoBrand,
                    vehiculoImage: widget.vehiculoImage,
                    periodo: widget.periodo,
                    cantidad: widget.cantidad,
                    lugarRecogida: widget.lugarRecogida,
                    totalPagado: widget.total,
                    codigoReserva: codigoReserva,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              shadowColor: const Color(0xFF4F46E5).withValues(alpha: 0.35),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Pagar \$ $_totalFormateado',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallPhone ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

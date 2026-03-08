import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/responsive_utils.dart';
import 'metodo_pago_page.dart';

class ResumenReservaPage extends StatefulWidget {
  const ResumenReservaPage({
    super.key,
    this.vehiculoBrand = 'Mazda CX-5 2024',
    this.vehiculoColor = 'Negro Jet',
    this.vehiculoImage = '',
    this.periodo = 'Semanas',
    this.cantidad = 1,
    this.precioUnitario = 1300000,
    this.fechaInicio = '22 Feb 2026, 8:00 AM',
    this.lugarRecogida = 'Av. El Dorado, Bogotá',
    this.conductor = 'Carlos Rodríguez',
    this.tarifaServicio = 1900,
    this.seguroBasico = 15000,
  });

  final String vehiculoBrand;
  final String vehiculoColor;
  final String vehiculoImage;
  final String periodo;
  final int cantidad;
  final int precioUnitario;
  final String fechaInicio;
  final String lugarRecogida;
  final String conductor;
  final int tarifaServicio;
  final int seguroBasico;

  @override
  State<ResumenReservaPage> createState() => _ResumenReservaPageState();
}

class _ResumenReservaPageState extends State<ResumenReservaPage> {
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _textPrimary =>
      _isDark ? const Color(0xFFF1F3FF) : const Color(0xFF0F172A);
  Color get _textSecondary =>
      _isDark ? const Color(0xFF8B93B8) : const Color(0xFF94A3B8);
  Color get _borderColor =>
      _isDark ? const Color(0xFF2E3355) : const Color(0xFFE2E8F0);
  Color get _cardBgColor => _isDark ? const Color(0xFF1A1F35) : Colors.white;
  Color get _successBgColor =>
      _isDark ? const Color(0xFF0F3D2D) : const Color(0xFFD1FAE5);
  Color get _successBorderColor =>
      _isDark ? const Color(0xFF10B981) : const Color(0xFF10B981);

  late int _totalPrice;
  late String _unidadLabel;

  @override
  void initState() {
    super.initState();
    _calcularTotal();
  }

  void _calcularTotal() {
    _totalPrice = (widget.precioUnitario * widget.cantidad) +
        widget.tarifaServicio +
        widget.seguroBasico;

    _unidadLabel = widget.cantidad == 1
        ? widget.periodo.toLowerCase().replaceAll('s', '')
        : widget.periodo.toLowerCase();
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

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final theme = Theme.of(context);
    final padding = isSmallPhone ? 12.0 : 20.0;

    return DefaultTextStyle.merge(
      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header con pasos
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF5B58FF),
                        Color(0xFF7C3AED),
                      ],
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    padding,
                    isSmallPhone ? 16 : 24,
                    padding,
                    isSmallPhone ? 20 : 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Resumen del Alquiler',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: isSmallPhone ? 20 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallPhone ? 24 : 32),
                      // Pasos
                      SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Paso 1
                            _buildPasoCirculo(1, true),
                            // Línea 1
                            Expanded(
                              child: SizedBox(
                                height: 2,
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                            // Paso 2
                            _buildPasoCirculo(2, true),
                            // Línea 2
                            Expanded(
                              child: SizedBox(
                                height: 2,
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                            // Paso 3
                            _buildPasoCirculo(3, false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Contenido principal
                Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarjeta del vehículo
                      _buildTarjetaVehiculo(isSmallPhone),
                      SizedBox(height: isSmallPhone ? 16 : 20),
                      // Detalles del Alquiler
                      _buildDetallesAlquiler(isSmallPhone),
                      SizedBox(height: isSmallPhone ? 16 : 20),
                      // Desglose de precios
                      _buildDesglosePrecios(isSmallPhone),
                      SizedBox(height: isSmallPhone ? 16 : 20),
                      // Mensaje de ahorro
                      _buildMensajeAhorro(isSmallPhone),
                      SizedBox(height: isSmallPhone ? 20 : 24),
                      // Botón Continuar
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MetodoPagoPage(
                                  total: _totalPrice,
                                  alquilerVehiculo:
                                      widget.precioUnitario * widget.cantidad,
                                  servicioSeguro: widget.tarifaServicio +
                                      widget.seguroBasico,
                                  periodo: widget.periodo,
                                  cantidad: widget.cantidad,
                                  precioUnitario: widget.precioUnitario,
                                  vehiculoBrand: widget.vehiculoBrand,
                                  vehiculoImage: widget.vehiculoImage,
                                  lugarRecogida: widget.lugarRecogida,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B58FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 8,
                            shadowColor:
                                const Color(0xFF5B58FF).withValues(alpha: 0.35),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continuar al Pago',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallPhone ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasoCirculo(int numero, bool activo) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: activo ? Colors.white : Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          numero.toString(),
          style: GoogleFonts.poppins(
            color: activo ? const Color(0xFF5B58FF) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTarjetaVehiculo(bool isSmallPhone) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/imagenes_carros/cx5.jpg',
              height: isSmallPhone ? 180 : 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: isSmallPhone ? 180 : 220,
                  color: Colors.grey[300],
                  child: const Icon(Icons.directions_car),
                );
              },
            ),
          ),
          // Gradiente oscuro
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
          // Contenido
          Positioned(
            bottom: isSmallPhone ? 12 : 16,
            left: isSmallPhone ? 12 : 16,
            right: isSmallPhone ? 12 : 16,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.vehiculoBrand,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isSmallPhone ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isSmallPhone ? 2 : 4),
                      Text(
                        widget.vehiculoColor,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: isSmallPhone ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '● DISPONIBLE',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isSmallPhone ? 11 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetallesAlquiler(bool isSmallPhone) {
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
            'Detalles del Alquiler',
            style: GoogleFonts.poppins(
              color: _textPrimary,
              fontSize: isSmallPhone ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmallPhone ? 12 : 16),
          _buildDetalleItem(
            Icons.schedule,
            const Color(0xFF5B58FF),
            'Período',
            '${widget.cantidad} $_unidadLabel',
            isSmallPhone,
          ),
          _buildDetalleItem(
            Icons.calendar_today,
            const Color(0xFF7C3AED),
            'Fecha Inicio',
            widget.fechaInicio,
            isSmallPhone,
          ),
          _buildDetalleItem(
            Icons.location_on,
            const Color(0xFF10B981),
            'Recogida',
            widget.lugarRecogida,
            isSmallPhone,
          ),
          _buildDetalleItem(
            Icons.person,
            const Color(0xFFFB923C),
            'Conductor',
            widget.conductor,
            isSmallPhone,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleItem(
    IconData icon,
    Color iconColor,
    String label,
    String value,
    bool isSmallPhone, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            SizedBox(width: isSmallPhone ? 10 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: _textSecondary,
                      fontSize: isSmallPhone ? 11 : 12,
                    ),
                  ),
                  SizedBox(height: isSmallPhone ? 2 : 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: _textPrimary,
                      fontSize: isSmallPhone ? 13 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) SizedBox(height: isSmallPhone ? 12 : 16),
      ],
    );
  }

  Widget _buildDesglosePrecios(bool isSmallPhone) {
    final precioVehiculo = widget.precioUnitario * widget.cantidad;

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
            'Desglose de precios',
            style: GoogleFonts.poppins(
              color: _textPrimary,
              fontSize: isSmallPhone ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmallPhone ? 12 : 16),
          _buildFilaPrice(
            '$widget.vehiculoBrand ($widget.cantidad $_unidadLabel)',
            _formatearPrecio(precioVehiculo),
            isSmallPhone,
            const Color(0xFF5B58FF).withValues(alpha: 0.15),
          ),
          SizedBox(height: isSmallPhone ? 8 : 10),
          _buildFilaPrice(
            'Tarifa de servicio (5%)',
            _formatearPrecio(widget.tarifaServicio),
            isSmallPhone,
            const Color(0xFFFB923C).withValues(alpha: 0.15),
          ),
          SizedBox(height: isSmallPhone ? 8 : 10),
          _buildFilaPrice(
            'Seguro básico incluido',
            _formatearPrecio(widget.seguroBasico),
            isSmallPhone,
            const Color(0xFF10B981).withValues(alpha: 0.15),
          ),
          SizedBox(height: isSmallPhone ? 12 : 16),
          Divider(
            color: _borderColor,
            height: 1,
          ),
          SizedBox(height: isSmallPhone ? 12 : 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total a pagar',
                style: GoogleFonts.poppins(
                  color: _textPrimary,
                  fontSize: isSmallPhone ? 15 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$ ${_formatearPrecio(_totalPrice)}',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF5B58FF),
                  fontSize: isSmallPhone ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilaPrice(
    String label,
    String price,
    bool isSmallPhone,
    Color bgColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 10 : 12,
        vertical: isSmallPhone ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: _textSecondary,
                fontSize: isSmallPhone ? 12 : 13,
              ),
            ),
          ),
          Text(
            '\$ $price',
            style: GoogleFonts.poppins(
              color: _textPrimary,
              fontSize: isSmallPhone ? 13 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMensajeAhorro(bool isSmallPhone) {
    final precioVehiculo = widget.precioUnitario * widget.cantidad;
    final transporteTradicional =
        precioVehiculo * 2; // Aproximadamente el doble
    final ahorro = transporteTradicional - _totalPrice;

    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
      decoration: BoxDecoration(
        color: _successBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _successBorderColor.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flash_on,
            color: const Color(0xFF10B981),
            size: isSmallPhone ? 24 : 28,
          ),
          SizedBox(width: isSmallPhone ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Excelente elección!',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF10B981),
                    fontSize: isSmallPhone ? 14 : 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isSmallPhone ? 2 : 4),
                Text(
                  'Ahorras aprox. \$ ${_formatearPrecio(ahorro)} vs. transporte tradicional',
                  style: GoogleFonts.poppins(
                    color: _isDark
                        ? const Color(0xFF10B981).withValues(alpha: 0.8)
                        : const Color(0xFF047857),
                    fontSize: isSmallPhone ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

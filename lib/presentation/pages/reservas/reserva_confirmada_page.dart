import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/responsive_utils.dart';
import '../main_page.dart';

class ReservaConfirmadaPage extends StatelessWidget {
  const ReservaConfirmadaPage({
    super.key,
    this.vehiculoBrand = 'Mazda CX-5 2024',
    this.vehiculoImage = '',
    this.periodo = 'Días',
    this.cantidad = 1,
    this.lugarRecogida = 'Av. El Dorado, Bogotá',
    this.totalPagado = 0,
    this.codigoReserva = 'FXD-2026-9038',
  });

  final String vehiculoBrand;
  final String vehiculoImage;
  final String periodo;
  final int cantidad;
  final String lugarRecogida;
  final int totalPagado;
  final String codigoReserva;

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

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

  String _unidadPeriodo() {
    final periodoLower = periodo.toLowerCase();
    if (cantidad == 1) {
      if (periodoLower.contains('hora')) return 'hora';
      if (periodoLower.contains('semana')) return 'semana';
      return 'día';
    }

    if (periodoLower.contains('hora')) return 'horas';
    if (periodoLower.contains('semana')) return 'semanas';
    return 'días';
  }

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final isDark = _isDark(context);
    final textPrimary =
        isDark ? const Color(0xFFF1F3FF) : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF8B93B8) : const Color(0xFF94A3B8);
    final cardBg = isDark ? const Color(0xFF1A1F35) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2E3355) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(isSmallPhone),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallPhone ? 12 : 20),
              child: Column(
                children: [
                  _buildSuccessBadge(isSmallPhone, textPrimary, textSecondary),
                  SizedBox(height: isSmallPhone ? 14 : 18),
                  _buildCodigoCard(isSmallPhone),
                  SizedBox(height: isSmallPhone ? 14 : 18),
                  _buildResumenCard(
                    context,
                    isSmallPhone,
                    cardBg,
                    borderColor,
                    textPrimary,
                    textSecondary,
                  ),
                  SizedBox(height: isSmallPhone ? 14 : 18),
                  _buildActionsRow(
                      context, isSmallPhone, borderColor, textPrimary),
                ],
              ),
            ),
          ),
          _buildBottomButtons(context, isSmallPhone, borderColor),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSmallPhone) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, isSmallPhone ? 14 : 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Reserva Confirmada!',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallPhone ? 28 : 32,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _stepCircle(check: true, number: '1'),
                  _stepLine(),
                  _stepCircle(check: true, number: '2'),
                  _stepLine(),
                  _stepCircle(check: false, number: '3', active: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepCircle(
      {required bool check, required String number, bool active = false}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: check
            ? const Color(0xFF10B981)
            : active
                ? const Color(0xFF6366F1)
                : Colors.white.withOpacity(0.25),
      ),
      child: Center(
        child: check
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : Text(
                number,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }

  Widget _stepLine() {
    return Container(
      width: 48,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: const Color(0xFF10B981),
    );
  }

  Widget _buildSuccessBadge(
    bool isSmallPhone,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      children: [
        Container(
          width: isSmallPhone ? 90 : 104,
          height: isSmallPhone ? 90 : 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF10B981).withOpacity(0.18),
          ),
          child: Center(
            child: Container(
              width: isSmallPhone ? 72 : 84,
              height: isSmallPhone ? 72 : 84,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF10B981),
              ),
              child:
                  const Icon(Icons.check, color: Color(0xFF052E2B), size: 44),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '¡Todo listo! 🎉',
          style: GoogleFonts.poppins(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: isSmallPhone ? 28 : 32,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tu vehículo está reservado',
          style: GoogleFonts.poppins(
            color: textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: isSmallPhone ? 20 : 22,
          ),
        ),
      ],
    );
  }

  Widget _buildCodigoCard(bool isSmallPhone) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          vertical: isSmallPhone ? 16 : 20, horizontal: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'CÓDIGO DE RESERVA',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: isSmallPhone ? 12 : 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            codigoReserva,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallPhone ? 24 : 30,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presenta este código al recoger tu vehículo',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.bold,
              fontSize: isSmallPhone ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenCard(
    BuildContext context,
    bool isSmallPhone,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final unidad = _unidadPeriodo();
    final image = vehiculoImage.isEmpty
        ? 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=1400&q=80'
        : vehiculoImage;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Stack(
              children: [
                SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: borderColor,
                      alignment: Alignment.center,
                      child: const Icon(Icons.directions_car, size: 36),
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  bottom: 10,
                  child: Text(
                    vehiculoBrand,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallPhone ? 16 : 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _resumenRow('📅 Período', '$cantidad $unidad', textPrimary,
                    textSecondary),
                Divider(color: borderColor, height: 18),
                _resumenRow(
                    '📍 Recogida', lugarRecogida, textPrimary, textSecondary),
                Divider(color: borderColor, height: 18),
                _resumenRow(
                  '💰 Total pagado',
                  '\$ ${_formatearPrecio(totalPagado)}',
                  const Color(0xFF2563EB),
                  textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumenRow(
    String label,
    String value,
    Color valueColor,
    Color labelColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: labelColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.poppins(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsRow(
    BuildContext context,
    bool isSmallPhone,
    Color borderColor,
    Color textPrimary,
  ) {
    Widget buildAction(String label, IconData icon, Color iconColor) {
      return Expanded(
        child: OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '$label próximamente',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: borderColor),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            padding: EdgeInsets.symmetric(vertical: isSmallPhone ? 12 : 14),
          ),
          icon: Icon(icon, size: 18, color: iconColor),
          label: Text(
            label,
            style: GoogleFonts.poppins(
              color: textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: isSmallPhone ? 14 : 15,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildAction(
            'Ver factura', Icons.download_outlined, const Color(0xFF2563EB)),
        const SizedBox(width: 12),
        buildAction('Compartir', Icons.share_outlined, const Color(0xFF7C3AED)),
      ],
    );
  }

  Widget _buildBottomButtons(
      BuildContext context, bool isSmallPhone, Color borderColor) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, isSmallPhone ? 10 : 14, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: isSmallPhone ? 48 : 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainPage(initialIndex: 1),
                    ),
                    (_) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.description_outlined, size: 20),
                label: Text(
                  'Ver en mis Reservas',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallPhone ? 16 : 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: isSmallPhone ? 46 : 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainPage(initialIndex: 0),
                    ),
                    (_) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.home_outlined, size: 20),
                label: Text(
                  'Volver al Inicio',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallPhone ? 16 : 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

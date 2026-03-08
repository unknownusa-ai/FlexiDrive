import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/responsive_utils.dart';
import '../main_page.dart';

class FacturaDigitalPage extends StatelessWidget {
  const FacturaDigitalPage({
    super.key,
    this.empresa = 'FlexiDrive',
    this.nit = '901.234.567-8',
    this.numeroFactura = 'FXD-INV-2026-25393',
    this.fecha = '22 Feb 2026',
    this.clienteNombre = 'Carlos Rodríguez',
    this.clienteEmail = 'carlos.rodriguez@email.com',
    this.descripcionServicio = 'Renta Vehículo',
    this.cantidad = 1,
    this.periodoUnidad = 'día',
    this.tarifaServicio = 0,
    this.seguroBasico = 0,
  });

  final String empresa;
  final String nit;
  final String numeroFactura;
  final String fecha;
  final String clienteNombre;
  final String clienteEmail;
  final String descripcionServicio;
  final int cantidad;
  final String periodoUnidad;
  final int tarifaServicio;
  final int seguroBasico;

  int get subtotal => tarifaServicio + seguroBasico;
  int get iva => 0;
  int get total => subtotal + iva;

  String _price(int value) {
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

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final isDark = _isDark(context);
    final borderColor =
        isDark ? const Color(0xFF2E3355) : const Color(0xFFD5DBE5);
    final cardColor =
        isDark ? const Color(0xFF1A1F35) : const Color(0xFFF8FAFC);
    final titleColor =
        isDark ? const Color(0xFFE4E8FF) : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFF9CA3C8) : const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context, isSmallPhone),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, isSmallPhone ? 14 : 18, 16, 22),
              child: Column(
                children: [
                  _buildInvoiceCard(
                    isSmallPhone,
                    cardColor,
                    borderColor,
                    titleColor,
                    muted,
                  ),
                  SizedBox(height: isSmallPhone ? 14 : 18),
                  _buildActionButtons(context, isSmallPhone, borderColor),
                ],
              ),
            ),
          ),
          _buildBottomButton(context, isSmallPhone),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallPhone) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, isSmallPhone ? 12 : 14, 16, 14),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Factura Digital',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallPhone ? 30 : 34,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(
    bool isSmallPhone,
    Color cardColor,
    Color borderColor,
    Color titleColor,
    Color muted,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                              ),
                            ),
                            child: const Center(
                              child: Text('🚗', style: TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                empresa,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF2563EB),
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallPhone ? 22 : 24,
                                ),
                              ),
                              Text(
                                'NIT: $nit',
                                style: GoogleFonts.poppins(
                                  color: muted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: const Color(0xFF22C55E).withOpacity(0.35)),
                      ),
                      child: Text(
                        '✅ PAGADO',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _blockInfo(
                        'N° FACTURA',
                        numeroFactura,
                        muted,
                        titleColor,
                        valueFontSize: isSmallPhone ? 16 : 17,
                        shrinkValueToFit: true,
                      ),
                    ),
                    Expanded(
                      child: _blockInfo(
                        'FECHA',
                        fecha,
                        muted,
                        titleColor,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: borderColor, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CLIENTE',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      color: muted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    clienteNombre,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      color: titleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    clienteEmail,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      color: muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: borderColor, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DESCRIPCIÓN DEL SERVICIO',
                  style: GoogleFonts.poppins(
                    color: muted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _priceRow(
                  '$descripcionServicio — $cantidad $periodoUnidad${cantidad > 1 ? 's' : ''}',
                  0,
                  titleColor,
                  borderColor,
                ),
                _priceRow('Tarifa de servicio (5%)', tarifaServicio, titleColor,
                    borderColor),
                _priceRow('Seguro básico de viaje', seguroBasico, titleColor,
                    borderColor,
                    showDivider: false),
                const SizedBox(height: 16),
                _totalsRow('Subtotal', subtotal, muted, titleColor),
                const SizedBox(height: 8),
                _totalsRow('IVA (19%)', iva, muted, titleColor),
                const SizedBox(height: 12),
                Divider(color: borderColor, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'TOTAL',
                        style: GoogleFonts.poppins(
                          color: titleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Text(
                      '\$ ${_price(total)}',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.13),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '✅   Pago procesado exitosamente',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF059669),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    'Código: ${numeroFactura.replaceAll('FXD-INV-', 'FXD-')} • FlexiDrive S.A.S. • Bogotá, Colombia 🇨🇴',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, bool isSmallPhone, Color borderColor) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: isSmallPhone ? 56 : 60,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Descarga de PDF próximamente',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.download_outlined),
              label: Text(
                'Descargar PDF',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallPhone ? 17 : 18,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: isSmallPhone ? 56 : 60,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Compartir factura próximamente',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.share_outlined, color: Color(0xFF7C3AED)),
              label: Text(
                'Compartir',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallPhone ? 17 : 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context, bool isSmallPhone) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, isSmallPhone ? 10 : 12, 16, 14),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: isSmallPhone ? 54 : 58,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const MainPage(initialIndex: 0)),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Volver al Inicio 🏠',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: isSmallPhone ? 17 : 19,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _blockInfo(
    String label,
    String value,
    Color labelColor,
    Color valueColor, {
    TextAlign textAlign = TextAlign.start,
    double valueFontSize = 20,
    bool shrinkValueToFit = false,
  }) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: GoogleFonts.poppins(
            color: labelColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        if (shrinkValueToFit)
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: textAlign == TextAlign.end
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                softWrap: false,
                textAlign: textAlign,
                style: GoogleFonts.poppins(
                  color: valueColor,
                  fontWeight: FontWeight.bold,
                  fontSize: valueFontSize,
                ),
              ),
            ),
          )
        else
          Text(
            value,
            textAlign: textAlign,
            style: GoogleFonts.poppins(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: valueFontSize,
            ),
          ),
      ],
    );
  }

  Widget _priceRow(String label, int value, Color textColor, Color borderColor,
      {bool showDivider = true}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$ ${_price(value)}',
              style: GoogleFonts.poppins(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 10),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _totalsRow(
      String label, int value, Color labelColor, Color valueColor) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: labelColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          '\$ ${_price(value)}',
          style: GoogleFonts.poppins(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

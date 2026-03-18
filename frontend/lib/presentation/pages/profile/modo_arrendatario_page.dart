import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_utils.dart';
import 'arrendatario_main_page.dart';

class ModoArrendatarioPage extends StatefulWidget {
  const ModoArrendatarioPage({super.key});

  @override
  State<ModoArrendatarioPage> createState() => _ModoArrendatarioPageState();
}

class _ModoArrendatarioPageState extends State<ModoArrendatarioPage> {
  int documentosCompletados = 0;
  final int totalDocumentos = 4;

  final List<DocumentoVerificacion> documentos = [
    DocumentoVerificacion(
      icono: Icons.person_outline,
      titulo: 'Cédula (Frontal)',
      descripcion: 'Foto del frente de tu cédula',
      completado: false,
    ),
    DocumentoVerificacion(
      icono: Icons.person_outline,
      titulo: 'Cédula (Reverso)',
      descripcion: 'Foto del reverso de tu cédula',
      completado: false,
    ),
    DocumentoVerificacion(
      icono: Icons.description_outlined,
      titulo: 'Tarjeta de Propiedad',
      descripcion: 'Documento del vehículo',
      completado: false,
    ),
    DocumentoVerificacion(
      icono: Icons.credit_card_outlined,
      titulo: 'Cuenta Bancaria',
      descripcion: 'Tarjeta débito o certificado bancario',
      completado: false,
    ),
  ];

  void _subirDocumento(int index) {
    if (!documentos[index].completado) {
      setState(() {
        documentos[index].completado = true;
        documentosCompletados++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final progress = documentosCompletados / totalDocumentos;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildOrangeHeader(isSmallPhone),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressSection(isSmallPhone, progress),
                    SizedBox(height: isSmallPhone ? 16 : 20),
                    _buildInfoCard(isSmallPhone),
                    SizedBox(height: isSmallPhone ? 20 : 24),
                    _buildDocumentsList(isSmallPhone),
                    SizedBox(height: isSmallPhone ? 24 : 32),
                    _buildActivateButton(isSmallPhone),
                    SizedBox(height: isSmallPhone ? 20 : 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrangeHeader(bool isSmallPhone) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 16 : 20,
        vertical: isSmallPhone ? 16 : 20,
      ),
      child: Row(
        children: [
          Container(
            width: isSmallPhone ? 36 : 40,
            height: isSmallPhone ? 36 : 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: isSmallPhone ? 20 : 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo Arrendatario',
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Completa tu verificación para activar',
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 12 : 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(bool isSmallPhone, double progress) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final progressBgColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso de verificación',
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              '$documentosCompletados/$totalDocumentos',
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: progressBgColor,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(bool isSmallPhone) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor =
        isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B);

    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isSmallPhone ? 40 : 44,
            height: isSmallPhone ? 40 : 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.info_outline,
              color: const Color(0xFFF59E0B),
              size: isSmallPhone ? 22 : 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Por qué necesitamos estos documentos?',
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    text:
                        'Para proteger a todos los usuarios de FlexiDrive, verificamos la identidad de cada arrendatario y que el vehículo esté debidamente registrado. Tus datos están seguros ',
                    style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 12 : 13,
                      color: subtextColor,
                      height: 1.5,
                    ),
                    children: const [
                      TextSpan(
                        text: '🔒',
                        style: TextStyle(fontSize: 12),
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

  Widget _buildDocumentsList(bool isSmallPhone) {
    return Column(
      children: List.generate(
        documentos.length,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: isSmallPhone ? 12 : 16),
          child: _buildDocumentoCard(
            isSmallPhone,
            documentos[index],
            index,
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentoCard(
    bool isSmallPhone,
    DocumentoVerificacion documento,
    int index,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final iconBgColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor =
        isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF64748B);
    final isCompleted = documento.completado;

    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? const Color(0xFF10B981) : borderColor,
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isSmallPhone ? 50 : 56,
            height: isSmallPhone ? 50 : 56,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : iconBgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFF10B981).withValues(alpha: 0.3)
                    : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : documento.icono,
              color: isCompleted
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
              size: isSmallPhone ? 24 : 28,
            ),
          ),
          SizedBox(width: isSmallPhone ? 14 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documento.titulo,
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 15 : 17,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  documento.descripcion,
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 12 : 13,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          isCompleted
              ? Container(
                  width: isSmallPhone ? 40 : 44,
                  height: isSmallPhone ? 40 : 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    size: isSmallPhone ? 22 : 24,
                    color: const Color(0xFF10B981),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _subirDocumento(index),
                    icon: Icon(
                      Icons.upload,
                      size: isSmallPhone ? 16 : 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Subir',
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 13 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallPhone ? 14 : 16,
                        vertical: isSmallPhone ? 10 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildActivateButton(bool isSmallPhone) {
    final isEnabled = documentosCompletados == totalDocumentos;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF10B981)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isEnabled ? null : const Color(0xFF64748B),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                _showSuccessDialog();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            vertical: isSmallPhone ? 16 : 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isEnabled ? Icons.check_circle : Icons.lock,
              color: Colors.white,
              size: isSmallPhone ? 20 : 22,
            ),
            const SizedBox(width: 10),
            Text(
              isEnabled
                  ? 'Activar Modo Arrendatario'
                  : 'Completa todos los documentos',
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 15 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor =
        isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF64748B);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Auto-cerrar y navegar después de 2.5 segundos
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (context.mounted) {
            Navigator.pop(context); // Cerrar diálogo
            // Navegar a ArrendatarioMainPage (con tabbar global)
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const ArrendatarioMainPage(),
              ),
              (route) => false,
            );
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(isSmallPhone ? 24 : 32),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Círculo verde con check
                Container(
                  width: isSmallPhone ? 80 : 100,
                  height: isSmallPhone ? 80 : 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: const Color(0xFFF59E0B),
                    size: isSmallPhone ? 50 : 60,
                  ),
                ),
                SizedBox(height: isSmallPhone ? 20 : 24),
                // Título con emoji
                Text(
                  '¡Felicitaciones! 🎉',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 22 : 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: isSmallPhone ? 12 : 16),
                // Mensaje
                Text(
                  'Tu cuenta de arrendatario ha sido activada exitosamente. Ya puedes comenzar a publicar tus vehículos y generar ingresos.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 13 : 15,
                    color: subtextColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DocumentoVerificacion {
  final IconData icono;
  final String titulo;
  final String descripcion;
  bool completado;

  DocumentoVerificacion({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    this.completado = false,
  });
}

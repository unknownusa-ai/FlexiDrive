import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/responsive_utils.dart';
import 'resumen_reserva_page.dart';

class ReservaDetallePage extends StatefulWidget {
  final String? vehicleName;
  final String? vehicleSpecs;
  final double? vehicleRating;
  final int? vehicleReviews;
  final int? vehiclePrice;
  final String? vehicleImage;

  const ReservaDetallePage({
    super.key,
    this.vehicleName,
    this.vehicleSpecs,
    this.vehicleRating,
    this.vehicleReviews,
    this.vehiclePrice,
    this.vehicleImage,
  });

  @override
  State<ReservaDetallePage> createState() => _ReservaDetallePageState();
}

class _ReservaDetallePageState extends State<ReservaDetallePage> {
  String _periodoSeleccionado = 'Días';
  int _cantidad = 1;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // Color properties for theme support
  Color get _textPrimary =>
      _isDark ? const Color(0xFFF1F3FF) : const Color(0xFF0F172A);
  Color get _textSecondary =>
      _isDark ? const Color(0xFF8B93B8) : const Color(0xFF94A3B8);
  Color get _borderColor =>
      _isDark ? const Color(0xFF2E3355) : const Color(0xFFE2E8F0);
  Color get _chipBgColor =>
      _isDark ? const Color(0xFF272B40) : const Color(0xFFF1F5F9);
  Color get _ratingBgColor =>
      _isDark ? const Color(0xFF272B40) : const Color(0xFFFFFBEB);
  Color get _ratingBorderColor =>
      _isDark ? const Color(0xFF3D4158) : const Color(0xFFFCD7A3);

  int get _precioUnitario {
    switch (_periodoSeleccionado) {
      case 'Horas':
        return 38000;
      case 'Semanas':
        return 1300000;
      case 'Días':
      default:
        return 220000;
    }
  }

  String get _unidadLabel {
    switch (_periodoSeleccionado) {
      case 'Horas':
        return _cantidad == 1 ? 'hora' : 'horas';
      case 'Semanas':
        return _cantidad == 1 ? 'semana' : 'semanas';
      case 'Días':
      default:
        return _cantidad == 1 ? 'día' : 'días';
    }
  }

  String get _totalFormateado {
    final total = _precioUnitario * _cantidad;
    final asString = total.toString();
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
    final theme = Theme.of(context);
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final padding = isSmallPhone ? 12.0 : 20.0;

    return DefaultTextStyle.merge(
      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: ConstrainedContainer(
          maxWidth: 800,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroSection(),
                      Padding(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTituloYRating(isSmallPhone),
                            SizedBox(height: isSmallPhone ? 12 : 18),
                            _buildCaracteristicas(isSmallPhone),
                            SizedBox(height: isSmallPhone ? 10 : 14),
                            _buildDescripcion(theme, isSmallPhone),
                            SizedBox(height: isSmallPhone ? 10 : 14),
                            _buildSeleccionPeriodo(theme, isSmallPhone),
                            SizedBox(height: isSmallPhone ? 10 : 14),
                            _buildOpiniones(theme, isSmallPhone),
                            SizedBox(height: isSmallPhone ? 16 : 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomTotal(theme, isSmallPhone),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final heroHeight = isSmallPhone ? 220.0 : 310.0;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              widget.vehicleImage ?? 'assets/imagenes_carros/cx5.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFE5E7EB),
                child: const Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 72,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: isSmallPhone ? 40 : 56,
            left: isSmallPhone ? 12 : 20,
            child: _buildCircleIconButton(Icons.arrow_back_ios_new, () {
              Navigator.pop(context);
            }, isSmallPhone),
          ),
          Positioned(
            top: isSmallPhone ? 40 : 56,
            right: isSmallPhone ? 56 : 84,
            child: _buildCircleIconButton(
                Icons.share_outlined, () {}, isSmallPhone),
          ),
          Positioned(
            top: isSmallPhone ? 40 : 56,
            right: isSmallPhone ? 12 : 20,
            child: _buildCircleIconButton(
                Icons.favorite_border, () {}, isSmallPhone),
          ),
          Positioned(
            left: isSmallPhone ? 12 : 20,
            bottom: 12,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isSmallPhone ? 10 : 14,
                  vertical: isSmallPhone ? 6 : 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🚙', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Text(
                    widget.vehicleSpecs?.split('•').first.trim() ?? 'SUV',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isSmallPhone ? 16 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: isSmallPhone ? 12 : 20,
            bottom: isSmallPhone ? 14 : 18,
            child: Row(
              children: [
                Container(
                  width: isSmallPhone ? 18 : 22,
                  height: isSmallPhone ? 6 : 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: isSmallPhone ? 6 : 8,
                  height: isSmallPhone ? 6 : 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1D5DB),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton(
      IconData icon, VoidCallback onTap, bool isSmallPhone) {
    final size = isSmallPhone ? 40.0 : 48.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: isSmallPhone ? 18 : 22),
      ),
    );
  }

  Widget _buildTituloYRating(bool isSmallPhone) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.vehicleName ?? 'Mazda CX-5 2024',
                style: GoogleFonts.poppins(
                  fontSize: isSmallPhone ? 28 : 40,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.vehicleSpecs ?? '2024 • Negro Jet',
                style: GoogleFonts.poppins(
                  fontSize: isSmallPhone ? 12 : 14,
                  color: _textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: isSmallPhone ? 8 : 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isSmallPhone ? 10 : 14,
                  vertical: isSmallPhone ? 6 : 8),
              decoration: BoxDecoration(
                color: _ratingBgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _ratingBorderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.vehicleRating ?? 4.9}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFF59E0B),
                      fontSize: isSmallPhone ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.vehicleReviews ?? 128} reseñas',
              style: GoogleFonts.poppins(
                fontSize: isSmallPhone ? 11 : 12,
                color: _textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCaracteristicas(bool isSmallPhone) {
    return Row(
      children: [
        _CaracteristicaItem(
            icon: Icons.people_outline,
            color: const Color(0xFF2563EB),
            label: '5 Puestos',
            isSmallPhone: isSmallPhone,
            isDark: _isDark),
        SizedBox(width: isSmallPhone ? 6 : 10),
        _CaracteristicaItem(
            icon: Icons.settings_outlined,
            color: const Color(0xFF8B5CF6),
            label: 'Automático',
            isSmallPhone: isSmallPhone,
            isDark: _isDark),
        SizedBox(width: isSmallPhone ? 6 : 10),
        _CaracteristicaItem(
            icon: Icons.air,
            color: const Color(0xFF10B981),
            label: 'A/C',
            isSmallPhone: isSmallPhone,
            isDark: _isDark),
        SizedBox(width: isSmallPhone ? 6 : 10),
        _CaracteristicaItem(
            icon: Icons.local_gas_station_outlined,
            color: const Color(0xFFF59E0B),
            label: 'Gasolina',
            isSmallPhone: isSmallPhone,
            isDark: _isDark),
      ],
    );
  }

  Widget _buildDescripcion(ThemeData theme, bool isSmallPhone) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Text(
        'El ${widget.vehicleName ?? 'vehículo'} combina elegancia y potencia. Perfecto para viajes urbanos y escapadas de fin de semana. Equipado con las últimas tecnologías de seguridad y confort.',
        style: GoogleFonts.poppins(
          fontSize: isSmallPhone ? 12 : 13,
          color: _textSecondary,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSeleccionPeriodo(ThemeData theme, bool isSmallPhone) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona el período',
            style: GoogleFonts.poppins(
              fontSize: isSmallPhone ? 14 : 17,
              color: _textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmallPhone ? 10 : 12),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: _chipBgColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                _periodChip('Horas', isSmallPhone),
                _periodChip('Días', isSmallPhone),
                _periodChip('Semanas', isSmallPhone),
              ],
            ),
          ),
          SizedBox(height: isSmallPhone ? 10 : 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_cantidad $_unidadLabel',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallPhone ? 11 : 12,
                        color: _textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        children: [
                          const TextSpan(
                            text: '\$ ',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: _totalFormateado,
                            style: TextStyle(
                              color: const Color(0xFF2563EB),
                              fontSize: isSmallPhone ? 16 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '/$_unidadLabel',
                            style: GoogleFonts.poppins(
                              color: _textSecondary,
                              fontSize: isSmallPhone ? 12 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _counterButton(Icons.remove, false, () {
                if (_cantidad > 1) {
                  setState(() => _cantidad--);
                }
              }, isSmallPhone),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: isSmallPhone ? 12 : 16),
                child: Text(
                  '$_cantidad',
                  style: GoogleFonts.poppins(
                    color: _textPrimary,
                    fontSize: isSmallPhone ? 24 : 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _counterButton(Icons.add, true, () {
                setState(() => _cantidad++);
              }, isSmallPhone),
            ],
          ),
        ],
      ),
    );
  }

  Widget _periodChip(String text, bool isSmallPhone) {
    final selected = _periodoSeleccionado == text;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _periodoSeleccionado = text),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: isSmallPhone ? 8 : 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                  )
                : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: selected ? Colors.white : _textSecondary,
                fontSize: isSmallPhone ? 13 : 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _counterButton(
      IconData icon, bool isPrimary, VoidCallback onTap, bool isSmallPhone) {
    final size = isSmallPhone ? 36.0 : 40.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF4F46E5) : _chipBgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isPrimary
              ? Colors.white
              : (_isDark ? const Color(0xFF8B93B8) : const Color(0xFF334155)),
          size: isSmallPhone ? 18 : 24,
        ),
      ),
    );
  }

  Widget _buildOpiniones(ThemeData theme, bool isSmallPhone) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Opiniones de usuarios',
                style: GoogleFonts.poppins(
                  color: _textPrimary,
                  fontSize: isSmallPhone ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallPhone ? 12 : 16,
                    vertical: isSmallPhone ? 8 : 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.rate_review_outlined,
                        color: Colors.white, size: isSmallPhone ? 14 : 16),
                    const SizedBox(width: 6),
                    Text(
                      'Opinar',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isSmallPhone ? 13 : 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallPhone ? 10 : 14),
          Text(
            'Sé el primero en opinar sobre este vehículo 💬',
            style: GoogleFonts.poppins(
              color: _textSecondary,
              fontSize: isSmallPhone ? 12 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTotal(ThemeData theme, bool isSmallPhone) {
    final isVertical = MediaQuery.of(context).size.width < 400;

    return Container(
      padding: EdgeInsets.fromLTRB(
          isSmallPhone ? 12 : 20,
          isSmallPhone ? 10 : 14,
          isSmallPhone ? 12 : 20,
          isSmallPhone ? 10 : 18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: isVertical
            ? Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total estimado',
                        style: GoogleFonts.poppins(
                          color: _textSecondary,
                          fontSize: isSmallPhone ? 12 : 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$ $_totalFormateado',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2563EB),
                          fontSize: isSmallPhone ? 18 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'por $_cantidad $_unidadLabel',
                        style: GoogleFonts.poppins(
                          color: _textSecondary,
                          fontSize: isSmallPhone ? 11 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResumenReservaPage(
                              vehiculoBrand: widget.vehicleName ?? 'Mazda CX-5 2024',
                              vehiculoColor: widget.vehicleSpecs?.split('•').elementAtOrNull(1)?.trim() ?? 'Negro Jet',
                              vehiculoImage: widget.vehicleImage ?? '',
                              periodo: _periodoSeleccionado,
                              cantidad: _cantidad,
                              precioUnitario: widget.vehiclePrice ?? 1300000,
                              fechaInicio: '22 Feb 2026, 8:00 AM',
                              lugarRecogida: 'Av. El Dorado, Bogotá',
                              conductor: 'Carlos Rodríguez',
                              tarifaServicio: 1900,
                              seguroBasico: 15000,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF10B981).withValues(alpha: 0.35),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Reservar Ahora',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallPhone ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.chevron_right, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total estimado',
                          style: GoogleFonts.poppins(
                            color: _textSecondary,
                            fontSize: isSmallPhone ? 12 : 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$ $_totalFormateado',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.35),
                            fontSize: isSmallPhone ? 18 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'por $_cantidad $_unidadLabel',
                          style: GoogleFonts.poppins(
                            color: _textSecondary,
                            fontSize: isSmallPhone ? 11 : 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResumenReservaPage(
                                vehiculoBrand: widget.vehicleName ?? 'Mazda CX-5 2024',
                                vehiculoColor: widget.vehicleSpecs?.split('•').elementAtOrNull(1)?.trim() ?? 'Negro Jet',
                                vehiculoImage: widget.vehicleImage ?? '',
                                periodo: _periodoSeleccionado,
                                cantidad: _cantidad,
                                precioUnitario: widget.vehiclePrice ?? 1300000,
                                fechaInicio: '22 Feb 2026, 8:00 AM',
                                lugarRecogida: 'Av. El Dorado, Bogotá',
                                conductor: 'Carlos Rodríguez',
                                tarifaServicio: 1900,
                                seguroBasico: 15000,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFF10B981).withValues(alpha: 0.13),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Reservar Ahora',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallPhone ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right, size: 22),
                            ],
                          ),
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

class _CaracteristicaItem extends StatelessWidget {
  const _CaracteristicaItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.isSmallPhone,
    required this.isDark,
  });

  final IconData icon;
  final Color color;
  final String label;
  final bool isSmallPhone;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmallPhone ? 10 : 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF272B40) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF2E3355) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: isSmallPhone ? 18 : 22, color: color),
            SizedBox(height: isSmallPhone ? 6 : 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color:
                    isDark ? const Color(0xFF8B93B8) : const Color(0xFF94A3B8),
                fontSize: isSmallPhone ? 11 : 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

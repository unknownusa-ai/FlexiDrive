import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_utils.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  // Empty list to show empty state as per prototype
  List<Map<String, dynamic>> _reviews = [];

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildGradientHeader(isSmallPhone),
          Expanded(
            child: _reviews.isEmpty
                ? _buildEmptyState(isSmallPhone)
                : _buildReviewsList(isSmallPhone),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientHeader(bool isSmallPhone) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6B35), // orange
                Color(0xFFFF3CAC), // pink
                Color(0xFF7C3AED), // purple
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isSmallPhone ? 16 : 20,
                isSmallPhone ? 8 : 12,
                isSmallPhone ? 16 : 20,
                isSmallPhone ? 16 : 20,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: isSmallPhone ? 36 : 40,
                      height: isSmallPhone ? 36 : 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: isSmallPhone ? 16 : 18,
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallPhone ? 12 : 16),
                  Text(
                    'Mis Reseñas',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isSmallPhone ? 20 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Decorative bubble top-right
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isSmallPhone) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmallPhone ? 32 : 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: isSmallPhone ? 80 : 90,
              height: isSmallPhone ? 80 : 90,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.add_comment_outlined,
                color: const Color(0xFFF59E0B),
                size: isSmallPhone ? 40 : 44,
              ),
            ),
            SizedBox(height: isSmallPhone ? 24 : 28),
            Text(
              'Aún no tienes reseñas',
              style: GoogleFonts.poppins(
                fontSize: isSmallPhone ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallPhone ? 10 : 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: isSmallPhone ? 13 : 14,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text: 'Cuando finalices un viaje, podrás\ncalificarlo desde la pantalla de ',
                  ),
                  TextSpan(
                    text: 'Mis\nReservas',
                    style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 13 : 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const TextSpan(text: ' usando el botón '),
                  TextSpan(
                    text: '⭐ Calificar',
                    style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 13 : 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            SizedBox(height: isSmallPhone ? 32 : 36),
            // CTA Button with orange gradient
            GestureDetector(
              onTap: () {
                // Navigate to reservations
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallPhone ? 32 : 40,
                  vertical: isSmallPhone ? 14 : 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFFF8C00),
                      Color(0xFFFF5722),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5722).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '⭐',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(width: isSmallPhone ? 8 : 10),
                    Text(
                      'Ir a Mis Reservas',
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 15 : 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList(bool isSmallPhone) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 16 : 20,
        vertical: isSmallPhone ? 16 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsSection(isSmallPhone),
          SizedBox(height: isSmallPhone ? 16 : 20),
          _buildReviewsSection(isSmallPhone),
          SizedBox(height: isSmallPhone ? 20 : 24),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isSmallPhone) {
    final theme = Theme.of(context);
    final avgRating = _reviews.isEmpty
        ? 0.0
        : _reviews.fold<double>(
                0.0, (sum, review) => sum + (review['rating'] as double)) /
            _reviews.length;

    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isSmallPhone ? 60 : 70,
            height: isSmallPhone ? 60 : 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF6B35), Color(0xFFFF3CAC)],
              ),
              borderRadius:
                  BorderRadius.circular(isSmallPhone ? 30 : 35),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isSmallPhone ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: isSmallPhone ? 12 : 14),
                    const SizedBox(width: 2),
                    Text(
                      '5.0',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: isSmallPhone ? 10 : 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: isSmallPhone ? 16 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Excelente conductor',
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tus reseñas ayudan a otros usuarios a tomar mejores decisiones',
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 12 : 13,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(bool isSmallPhone) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TUS RESEÑAS',
          style: GoogleFonts.inter(
            fontSize: isSmallPhone ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: isSmallPhone ? 10 : 12),
        ..._reviews
            .map((review) => _buildReviewCard(review, isSmallPhone))
            .toList(),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, bool isSmallPhone) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: isSmallPhone ? 40 : 48,
                height: isSmallPhone ? 40 : 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6B35), Color(0xFFFF3CAC)],
                  ),
                  borderRadius:
                      BorderRadius.circular(isSmallPhone ? 20 : 24),
                ),
                child: Center(
                  child: Text(
                    review['userAvatar'],
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isSmallPhone ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isSmallPhone ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review['userName'],
                          style: GoogleFonts.inter(
                            fontSize: isSmallPhone ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            return Icon(
                              index < review['rating']
                                  ? Icons.star
                                  : Icons.star_border,
                              color: const Color(0xFFFBBF24),
                              size: isSmallPhone ? 12 : 14,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${review['carModel']} • ${review['carPlate']}',
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 12 : 13,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review['date'],
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 11 : 12,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallPhone ? 12 : 16),
          Text(
            review['comment'],
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 13 : 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1A1A),
              height: 1.4,
            ),
          ),
          if (review['ownerResponse'] != null) ...[
            SizedBox(height: isSmallPhone ? 12 : 16),
            Container(
              padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE4C4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        color: const Color(0xFFFF6B35),
                        size: isSmallPhone ? 16 : 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Respuesta del propietario',
                        style: GoogleFonts.inter(
                          fontSize: isSmallPhone ? 12 : 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF6B35),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review['ownerResponse'],
                    style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 12 : 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade700,
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
}
// Flutter framework
import 'package:flutter/material.dart';
// Fuentes bonitas de Google
import 'package:google_fonts/google_fonts.dart';
// Utilidades para pantallas pequeñas/grandes
import 'package:flexidrive/core/utils/responsive_utils.dart';
// Base de datos de reseñas
import 'package:flexidrive/features/reviews/application/use_cases/review_access_use_case.dart';
// Repositorio de usuarios
import 'package:flexidrive/features/accounts/application/use_cases/account_access_use_case.dart';
// Base de datos local de cuentas
// Base de datos de vehiculos
import 'package:flexidrive/features/vehicles/application/use_cases/vehicle_catalog_use_case.dart';
// Base de datos de publicaciones
import 'package:flexidrive/features/publications/application/use_cases/publication_access_use_case.dart';
import 'package:flexidrive/injection_container.dart';

// Pagina "Mis Reseñas" - muestra reseñas escritas o recibidas
class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key, this.receivedMode = false});

  final bool receivedMode;

  /// Gestiona crear estado dentro de esta parte del flujo.
  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

// Estado de la pagina de reseñas
class _MyReviewsPageState extends State<MyReviewsPage> {
  final AccountAccessUseCase _accountRepository =
      InjectionContainer.instance.accountAccessUseCase;
  final ReviewAccessUseCase _reviewDb =
      InjectionContainer.instance.reviewAccessUseCase;
  final VehicleCatalogUseCase _vehicleDb =
      InjectionContainer.instance.vehicleCatalogUseCase;
  final PublicationAccessUseCase _publicationDb =
      InjectionContainer.instance.publicationAccessUseCase;
  // Lista de reseñas del usuario
  List<Map<String, dynamic>> _reviews = [];
  // Esta cargando las reseñas?
  bool _isLoading = true;

  // Funcion ayudante para buscar un elemento o retornar null
  // Como firstWhereOrNull pero implementado aqui
  T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  /// Inicializa el proceso de inicialización del estado antes de su uso.
  @override
  void initState() {
    super.initState();
    _loadReviews(); // Carga las reseñas del usuario
  }

  // Carga reseñas escritas por el usuario o recibidas en sus publicaciones.
  Future<void> _loadReviews() async {
    final users = await _accountRepository.getUsers();
    // Aseguramos que las bases de datos esten cargadas
    await _reviewDb.loadIfNeeded();
    await _vehicleDb.loadIfNeeded();
    await _publicationDb.loadIfNeeded();

    // Obtenemos el usuario actual
    final currentUser = await _accountRepository.getCurrentUser();
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final ownedPublicationIds = _publicationDb.publications
        .where((publication) => publication.userId == currentUser.id)
        .map((publication) => publication.id)
        .toSet();

    final userReviews = widget.receivedMode
        ? _reviewDb.reviews
            .where(
                (review) => ownedPublicationIds.contains(review.publicationId))
            .toList()
        : _reviewDb.reviews
            .where((review) => review.userId == currentUser.id)
            .toList();

    final reviewsData = <Map<String, dynamic>>[];

    for (final review in userReviews) {
      final opinion = _firstWhereOrNull(
        _reviewDb.opinions,
        (o) => o.id == review.opinionId,
      );

      if (opinion == null) continue;

      final publication = _firstWhereOrNull(
        _publicationDb.publications,
        (p) => p.id == review.publicationId,
      );

      if (publication == null) continue;

      final vehicle = _firstWhereOrNull(
        _vehicleDb.vehicles,
        (v) => v.id == publication.vehicleId,
      );

      if (vehicle == null) continue;

      final reviewer = _firstWhereOrNull(
        users,
        (u) => u.id == review.userId,
      );
      if (reviewer == null) continue;

      reviewsData.add({
        'userAvatar': reviewer.fullName.isNotEmpty ? reviewer.fullName[0] : 'U',
        'userName': reviewer.fullName,
        'rating': opinion.rating,
        'carModel': '${vehicle.line} ${vehicle.model}',
        'carPlate': 'Sin placa',
        'date':
            '${review.date.day.toString().padLeft(2, '0')}/${review.date.month.toString().padLeft(2, '0')}/${review.date.year}',
        'comment': opinion.description ?? 'Sin comentario',
        'ownerResponse': null,
      });
    }

    setState(() {
      _reviews = reviewsData;
      _isLoading = false;
    });
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reviews.isEmpty
                    ? _buildEmptyState(isSmallPhone)
                    : _buildReviewsList(isSmallPhone),
          ),
        ],
      ),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
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

  /// Construye y devuelve el widget correspondiente a esta sección.
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
                color: const Color(0xFFEF4444),
                size: isSmallPhone ? 40 : 44,
              ),
            ),
            SizedBox(height: isSmallPhone ? 24 : 28),
            Text(
              widget.receivedMode
                  ? 'Aún no has recibido reseñas'
                  : 'Aún no tienes reseñas',
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
                  if (widget.receivedMode) ...[
                    const TextSpan(
                      text:
                          'Cuando finalicen viajes en tus publicaciones,\nrecibirás reseñas aquí.',
                    ),
                  ] else ...[
                    const TextSpan(
                      text:
                          'Cuando finalices un viaje, podrás\ncalificarlo desde la pantalla de ',
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
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ],
              ),
            ),
            SizedBox(height: isSmallPhone ? 32 : 36),
            GestureDetector(
              onTap: () {
                // Navigate a reservas
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

  /// Construye y devuelve el widget correspondiente a esta sección.
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

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildStatsSection(bool isSmallPhone) {
    final theme = Theme.of(context);
    final avgRating = _reviews.isEmpty
        ? 0.0
        : _reviews.fold<double>(0.0,
                (sum, review) => sum + (review['rating'] as num).toDouble()) /
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
              borderRadius: BorderRadius.circular(isSmallPhone ? 30 : 35),
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
                    Icon(Icons.star,
                        color: Colors.white, size: isSmallPhone ? 12 : 14),
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

  /// Construye y devuelve el widget correspondiente a esta sección.
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
        ..._reviews.map((review) => _buildReviewCard(review, isSmallPhone)),
      ],
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
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
                  borderRadius: BorderRadius.circular(isSmallPhone ? 20 : 24),
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
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review['date'],
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 11 : 12,
                        fontWeight: FontWeight.w400,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
              color: Colors.white.withValues(alpha: 0.9),
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

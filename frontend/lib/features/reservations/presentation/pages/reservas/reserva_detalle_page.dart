// Flutter framework
import 'package:flutter/material.dart';
// Fuentes bonitas de Google
import 'package:google_fonts/google_fonts.dart';

// Utilidades y servicios
import 'package:flexidrive/core/utils/responsive_utils.dart';
import 'package:flexidrive/features/accounts/application/use_cases/account_access_use_case.dart';
import 'package:flexidrive/features/catalogs/application/use_cases/catalog_access_use_case.dart';
import 'package:flexidrive/features/notifications/application/use_cases/notification_access_use_case.dart';
import 'package:flexidrive/features/publications/application/use_cases/publication_access_use_case.dart';
import 'package:flexidrive/features/reviews/application/use_cases/review_access_use_case.dart';
import 'package:flexidrive/injection_container.dart';
import 'package:flexidrive/core/widgets/flexi_vehicle_image.dart';
import 'package:flexidrive/core/utils/vehicle_image_resolver.dart';
// Modelos de datos
import 'package:flexidrive/features/accounts/domain/entities/account_models.dart';
import 'package:flexidrive/features/publications/domain/entities/publication_models.dart';
import 'package:flexidrive/features/reviews/domain/entities/review_models.dart';
// Pagina de resumen de reserva
import 'resumen_reserva_page.dart';

// Pagina de detalle de vehiculo
// Muestra toda la info del carro antes de reservar
class ReservaDetallePage extends StatefulWidget {
  // Constructor con parámetros del vehículo
  const ReservaDetallePage({
    super.key,
    this.vehicleId = 0, // ID del vehículo
    this.vehicleName, // Nombre del vehículo
    this.vehicleSpecs, // Especificaciones
    this.vehicleDescription, // Descripción
    this.fuelType, // Tipo de combustible
    this.hasAC, // Tiene aire acondicionado?
    this.vehicleRating, // Calificacion promedio
    this.vehicleReviews, // Cantidad de reseñas
    this.vehiclePrice, // Precio base
    this.vehicleImage, // URL de la imagen
    this.precioHora, // Precio por hora
    this.precioDia, // Precio por dia
    this.precioSemana, // Precio por semana
  });

  // ID del vehículo
  final int vehicleId;
  // Nombre del vehículo
  final String? vehicleName;
  // Especificaciones del vehículo
  final String? vehicleSpecs;
  // Descripción del vehículo
  final String? vehicleDescription;
  // Tipo de combustible
  final String? fuelType;
  // Tiene aire acondicionado?
  final bool? hasAC;
  // Calificacion promedio
  final double? vehicleRating;
  // Cantidad de reseñas
  final int? vehicleReviews;
  // Precio base
  final int? vehiclePrice;
  // URL de la imagen
  final String? vehicleImage;
  // Precio por hora
  final int? precioHora;
  // Precio por dia
  final int? precioDia;
  // Precio por semana
  final int? precioSemana;

  /// Gestiona crear estado dentro de esta parte del flujo.
  @override
  State<ReservaDetallePage> createState() => _ReservaDetallePageState();
}

// Estado de la pagina de detalle
class _ReservaDetallePageState extends State<ReservaDetallePage> {
  // Periodo seleccionado para la reserva
  String _periodoSeleccionado = 'Días';
  int _cantidad = 1;

  // DBs existentes - una sola lista por tabla
  final PublicationAccessUseCase _publicationDb =
      InjectionContainer.instance.publicationAccessUseCase;
  final ReviewAccessUseCase _reviewDb =
      InjectionContainer.instance.reviewAccessUseCase;
  final AccountAccessUseCase _accountRepository =
      InjectionContainer.instance.accountAccessUseCase;
  final CatalogAccessUseCase _catalogDb =
      InjectionContainer.instance.catalogAccessUseCase;
  final NotificationAccessUseCase _notificationDb =
      InjectionContainer.instance.notificationAccessUseCase;

  // Estado de reseñas
  List<ReviewModel> _vehicleReviews = [];
  List<OpinionModel> _reviewOpinions = [];
  UserModel? _currentUser;
  int? _currentUserReviewId;
  bool _isLoadingReviews = true;
  int _totalOpinions = 0;
  double _averageRating = 0.0;
  int _publicationId = 1; // Default publication ID

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  /// Gestiona resolved vehicle imagen dentro de esta parte del flujo.
  String _resolvedVehicleImage() {
    return VehicleImageResolver.resolveFromVehicle(
      {
        'modelo': widget.vehicleName ?? '',
        'imagen': widget.vehicleImage ?? '',
      },
      preferredImage: widget.vehicleImage,
      fallback: 'assets/imagenes_carros/cx5.jpg',
    );
  }

  /// Inicializa el proceso de inicialización del estado antes de su uso.
  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  /// Carga los datos necesarios para cargar reseñas.
  Future<void> _loadReviews() async {
    await _publicationDb.loadIfNeeded();
    await _reviewDb.loadIfNeeded();
    _currentUser = await _accountRepository.getCurrentUser();

    // Buscar publicación del vehículo
    final publication = _publicationDb.publications.firstWhere(
      (p) => p.vehicleId == widget.vehicleId,
      orElse: () => PublicationModel(
        id: 0,
        userId: 0,
        vehicleId: 0,
        publishDate: DateTime.now(),
        active: false,
      ),
    );

    if (publication.id != 0) {
      _publicationId = publication.id;
    }

    if (publication.id != 0) {
      // Obtener reseñas de esta publicación
      _vehicleReviews = _reviewDb.reviews
          .where((r) => r.publicationId == publication.id)
          .toList();

      // Obtener opiniones de estas reseñas
      _reviewOpinions = [];
      double totalRating = 0;
      for (var review in _vehicleReviews) {
        final opinion = _reviewDb.opinions.firstWhere(
          (o) => o.id == review.opinionId,
          orElse: () => OpinionModel(id: 0, rating: 0),
        );
        if (opinion.id != 0) {
          _reviewOpinions.add(opinion);
          totalRating += opinion.rating;
        }
      }

      _totalOpinions = _reviewOpinions.length;
      _averageRating = _totalOpinions > 0 ? totalRating / _totalOpinions : 0;

      // Verificar si el usuario actual ya tiene una reseña
      if (_currentUser != null) {
        final userReview = _vehicleReviews.firstWhere(
          (r) => r.userId == _currentUser!.id,
          orElse: () => ReviewModel(
            id: 0,
            userId: 0,
            publicationId: 0,
            opinionId: 0,
            date: DateTime.now(),
          ),
        );
        _currentUserReviewId = userReview.id != 0 ? userReview.id : null;
      }
    }

    setState(() => _isLoadingReviews = false);
  }

  /// Agregar o actualizar reseña esta parte del flujo de trabajo.
  Future<void> _addOrUpdateReview(int rating, String description) async {
    if (_currentUser == null) {
      _showLoginDialog();
      return;
    }

    await _reviewDb.loadIfNeeded();

    // Buscar publicación
    final publication = _publicationDb.publications.firstWhere(
      (p) => p.vehicleId == widget.vehicleId,
      orElse: () => PublicationModel(
        id: 0,
        userId: 0,
        vehicleId: 0,
        publishDate: DateTime.now(),
        active: false,
      ),
    );

    if (publication.id == 0) return;
    final isNewReview = _currentUserReviewId == null;

    final savedReview = await _reviewDb.addOrUpdateReview(
      userId: _currentUser!.id,
      publicationId: publication.id,
      rating: rating,
      description: description,
      reviewId: _currentUserReviewId,
    );

    _currentUserReviewId = savedReview.id;
    if (isNewReview) {
      await _notifyOwnerAboutNewReview(
        ownerUserId: publication.userId,
        rating: rating,
      );
    }
    _loadReviews(); // Recargar
  }

  Future<void> _notifyOwnerAboutNewReview({
    required int ownerUserId,
    required int rating,
  }) async {
    if (_currentUser == null) return;
    if (ownerUserId == _currentUser!.id) return;

    await _catalogDb.loadIfNeeded();
    final categoryId = _resolveReviewCategoryId();
    final vehicleName = (widget.vehicleName ?? 'tu publicación').trim();
    final reviewerName = _currentUser!.fullName.trim().isEmpty
        ? 'Un usuario'
        : _currentUser!.fullName.trim();

    await _notificationDb.addNotification(
      userId: ownerUserId,
      categoryId: categoryId,
      subject: 'Nueva reseña en tu publicación',
      description:
          '$reviewerName dejó una reseña de $rating estrellas en $vehicleName.',
    );
  }

  /// Gestiona resolve reseña category id dentro de esta parte del flujo.
  int _resolveReviewCategoryId() {
    for (final category in _catalogDb.notificationCategories) {
      final name = category.name.toLowerCase();
      if (name.contains('rese') ||
          name.contains('resena') ||
          name.contains('calificacion')) {
        return category.id;
      }
    }
    return _catalogDb.notificationCategories.isEmpty
        ? 1
        : _catalogDb.notificationCategories.first.id;
  }

  /// Elimina los datos vinculados a eliminar reseña.
  Future<void> _deleteReview() async {
    if (_currentUserReviewId == null) return;

    await _reviewDb.loadIfNeeded();
    await _reviewDb.deleteReview(_currentUserReviewId!);
    _currentUserReviewId = null;

    _loadReviews(); // Recargar
  }

  /// Mostrar diálogo de inicio de sesión esta parte del flujo de trabajo.
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Iniciar sesión',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Debes iniciar sesión para opinar',
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () {
              /// Crea una instancia y prepara el estado inicial de `Navigator`.
              Navigator.pop(ctx);
              // Navegar a inicio de sesión
            },
            child: Text('Iniciar sesión',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
        return widget.precioHora ?? widget.vehiclePrice ?? 38000;
      case 'Semanas':
        return widget.precioSemana ?? 1300000;
      case 'Días':
      default:
        return widget.precioDia ?? 220000;
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

  /// Construye y devuelve el widget correspondiente a esta sección.
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

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildHeroSection() {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final heroHeight = isSmallPhone ? 220.0 : 310.0;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: FlexiVehicleImage(
              imagePath: _resolvedVehicleImage(),
              fit: BoxFit.cover,
              placeholder: Container(
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
              /// Crea una instancia y prepara el estado inicial de `Navigator`.
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

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildTituloYRating(bool isSmallPhone) {
    // Usar el rating real calculado de las reseñas
    final displayRating = _isLoadingReviews
        ? (widget.vehicleRating ?? 4.9)
        : (_averageRating > 0 ? _averageRating : (widget.vehicleRating ?? 4.9));
    final displayReviews =
        _isLoadingReviews ? (widget.vehicleReviews ?? 0) : _totalOpinions;

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
        GestureDetector(
          onTap: () {
            // Scroll hacia las opiniones
            // Aquí podrías implementar un scroll controller
          },
          child: Column(
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
                    const Icon(Icons.star, color: Color(0xFFEF4444), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      displayRating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFEF4444),
                        fontSize: isSmallPhone ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$displayReviews reseñas',
                style: GoogleFonts.poppins(
                  fontSize: isSmallPhone ? 11 : 12,
                  color: _textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildCaracteristicas(bool isSmallPhone) {
    // Extraer datos de vehicleSpecs (formato: "2023 • Automática • 5 puestos • Bogotá")
    final specs = widget.vehicleSpecs ?? '';
    final parts = specs.split('•').map((p) => p.trim()).toList();
    final seats = parts.length > 2 ? parts[2].split(' ').first : '5';
    final transmission = parts.length > 1 ? parts[1] : 'Automático';
    final fuelType = widget.fuelType ?? 'Gasolina';
    final hasAC = widget.hasAC ?? true;

    return Row(
      children: [
        _CaracteristicaItem(
            icon: Icons.people_outline,
            color: const Color(0xFF2563EB),
            label: '$seats Puestos',
            isSmallPhone: isSmallPhone,
            isDark: _isDark),
        SizedBox(width: isSmallPhone ? 6 : 10),
        _CaracteristicaItem(
            icon: Icons.settings_outlined,
            color: const Color(0xFF8B5CF6),
            label: transmission,
            isSmallPhone: isSmallPhone,
            isDark: _isDark),
        SizedBox(width: isSmallPhone ? 6 : 10),
        if (hasAC)
          _CaracteristicaItem(
              icon: Icons.air,
              color: const Color(0xFF10B981),
              label: 'A/C',
              isSmallPhone: isSmallPhone,
              isDark: _isDark),
        if (hasAC) SizedBox(width: isSmallPhone ? 6 : 10),
        _CaracteristicaItem(
            icon: Icons.local_gas_station_outlined,
            color: const Color(0xFFEF4444),
            label: fuelType,
            isSmallPhone: isSmallPhone,
            isDark: _isDark),
      ],
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildDescripcion(ThemeData theme, bool isSmallPhone) {
    final description = widget.vehicleDescription ??
        'El ${widget.vehicleName ?? 'vehículo'} combina elegancia y potencia. Perfecto para viajes urbanos y escapadas de fin de semana. Equipado con las últimas tecnologías de seguridad y confort.';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Text(
        description,
        style: GoogleFonts.poppins(
          fontSize: isSmallPhone ? 12 : 13,
          color: _textSecondary,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
      ),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
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

  /// Gestiona period chip dentro de esta parte del flujo.
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

  /// Construye y devuelve el widget correspondiente a esta sección.
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con rating promedio y botón opinar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Opiniones de usuarios',
                    style: GoogleFonts.poppins(
                      color: _textPrimary,
                      fontSize: isSmallPhone ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star,
                          color: const Color(0xFFF59E0B),
                          size: isSmallPhone ? 14 : 16),
                      const SizedBox(width: 4),
                      Text(
                        _isLoadingReviews
                            ? '...'
                            : '${_averageRating.toStringAsFixed(1)} ($_totalOpinions reseñas)',
                        style: GoogleFonts.poppins(
                          color: _textSecondary,
                          fontSize: isSmallPhone ? 12 : 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showReviewDialog(isSmallPhone),
                child: Container(
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
                        _currentUserReviewId != null ? 'Editar' : 'Opinar',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isSmallPhone ? 13 : 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallPhone ? 12 : 16),

          // Lista de opiniones
          if (_isLoadingReviews)
            const Center(child: CircularProgressIndicator())
          else if (_reviewOpinions.isEmpty)
            Center(
              child: Text(
                'Sé el primero en opinar sobre este vehículo 💬',
                style: GoogleFonts.poppins(
                  color: _textSecondary,
                  fontSize: isSmallPhone ? 12 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Column(
              children: _reviewOpinions.asMap().entries.map((entry) {
                final index = entry.key;
                final opinion = entry.value;
                final review = _vehicleReviews[index];
                final isCurrentUserReview =
                    _currentUser != null && review.userId == _currentUser!.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(isSmallPhone ? 10 : 12),
                  decoration: BoxDecoration(
                    color: isCurrentUserReview
                        ? (_isDark
                            ? const Color(0xFF4F46E5).withValues(alpha: 0.1)
                            : const Color(0xFFEEF2FF))
                        : (_isDark
                            ? const Color(0xFF1F2235)
                            : Colors.grey.shade50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrentUserReview
                          ? const Color(0xFF4F46E5)
                          : (_isDark
                              ? const Color(0xFF2E3355)
                              : Colors.grey.shade200),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Estrellas
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < opinion.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: const Color(0xFFF59E0B),
                                size: isSmallPhone ? 14 : 16,
                              );
                            }),
                          ),
                          const Spacer(),
                          // Acciones para el usuario actual
                          if (isCurrentUserReview) ...[
                            IconButton(
                              onPressed: () => _showReviewDialog(isSmallPhone,
                                  existingOpinion: opinion),
                              icon: Icon(Icons.edit,
                                  size: isSmallPhone ? 16 : 18,
                                  color: const Color(0xFF4F46E5)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () =>
                                  _confirmDeleteReview(isSmallPhone),
                              icon: Icon(Icons.delete,
                                  size: isSmallPhone ? 16 : 18,
                                  color: const Color(0xFFEF4444)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (opinion.description != null &&
                          opinion.description!.isNotEmpty)
                        Text(
                          opinion.description!,
                          style: GoogleFonts.inter(
                            color: _textPrimary,
                            fontSize: isSmallPhone ? 12 : 13,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        'Usuario #${review.userId} • ${_formatDate(review.date)}',
                        style: GoogleFonts.inter(
                          color: _textSecondary,
                          fontSize: isSmallPhone ? 10 : 11,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ayudante methods para evitar errores en el resumen
  String _extractColorFromSpecs() {
    try {
      final specs = widget.vehicleSpecs ?? '';
      final parts = specs.split('•').map((p) => p.trim()).toList();
      // El formato es: "2024 • Negro Jet • Automática • 5 puestos • Bogotá"
      // El color está en el segundo elemento (índice 1)
      if (parts.length > 1) {
        final colorPart = parts[1];
        // Si contiene "Negro Jet", extraer solo "Negro Jet"
        return colorPart.contains(' ') ? colorPart.split(' ').first : colorPart;
      }
      return 'Negro';
    } catch (e) {
      return 'Negro';
    }
  }

  /// Obtiene la información asociada a obtener precio unitario.
  int _getPrecioUnitario() {
    try {
      // Calcular precio según el período seleccionado
      if (_periodoSeleccionado == 'Horas') {
        return widget.precioHora ?? 15000;
      } else if (_periodoSeleccionado == 'Días') {
        return widget.precioDia ?? 120000;
      } else if (_periodoSeleccionado == 'Semanas') {
        return widget.precioSemana ?? 750000;
      }
      return widget.vehiclePrice ?? 120000;
    } catch (e) {
      return 120000;
    }
  }

  /// Gestiona format fecha inicio dentro de esta parte del flujo.
  String _formatFechaInicio() {
    try {
      final now = DateTime.now();
      final meses = [
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
      return '${now.day} ${meses[now.month - 1]} ${now.year}, 8:00 AM';
    } catch (e) {
      return '22 Feb 2026, 8:00 AM';
    }
  }

  /// Gestiona format date dentro de esta parte del flujo.
  String _formatDate(DateTime date) {
    final meses = [
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
    return '${date.day} ${meses[date.month - 1]} ${date.year}';
  }

  /// Gestiona confirm eliminar reseña dentro de esta parte del flujo.
  void _confirmDeleteReview(bool isSmallPhone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar opinión',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro de que quieres eliminar tu opinión?',
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () {
              /// Crea una instancia y prepara el estado inicial de `Navigator`.
              Navigator.pop(ctx);
              _deleteReview();
            },
            child: Text('Eliminar',
                style: GoogleFonts.inter(
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Mostrar diálogo de reseña esta parte del flujo de trabajo.
  void _showReviewDialog(bool isSmallPhone, {OpinionModel? existingOpinion}) {
    int selectedRating = existingOpinion?.rating ?? 5;
    final descriptionController =
        TextEditingController(text: existingOpinion?.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            existingOpinion != null ? 'Editar opinión' : 'Nueva opinión',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calificación',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () =>
                          setDialogState(() => selectedRating = index + 1),
                      child: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: const Color(0xFFF59E0B),
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text('Descripción (opcional)',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Comparte tu experiencia con este vehículo...',
                    hintStyle: GoogleFonts.inter(fontSize: 13),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: GoogleFonts.inter()),
            ),
            TextButton(
              onPressed: () {
                /// Crea una instancia y prepara el estado inicial de `Navigator`.
                Navigator.pop(ctx);
                _confirmPublishReview(
                  rating: selectedRating,
                  description: descriptionController.text.trim(),
                  isUpdate: existingOpinion != null,
                );
              },
              child: Text(
                existingOpinion != null ? 'Actualizar' : 'Publicar',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPublishReview({
    required int rating,
    required String description,
    required bool isUpdate,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isUpdate ? 'Confirmar actualización' : 'Confirmar publicación',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isUpdate
              ? '¿Quieres actualizar tu reseña de este vehículo?'
              : '¿Quieres publicar esta reseña en la publicación?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () {
              /// Crea una instancia y prepara el estado inicial de `Navigator`.
              Navigator.pop(ctx);
              _addOrUpdateReview(rating, description);
            },
            child: Text(
              isUpdate ? 'Actualizar' : 'Publicar',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
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
                              vehiculoBrand:
                                  widget.vehicleName ?? 'Mazda CX-5 2024',
                              vehiculoColor: _extractColorFromSpecs(),
                              vehiculoImage: widget.vehicleImage ?? '',
                              periodo: _periodoSeleccionado,
                              cantidad: _cantidad,
                              precioUnitario: _getPrecioUnitario(),
                              fechaInicio: _formatFechaInicio(),
                              lugarRecogida: 'Av. El Dorado, Bogotá',
                              conductor: 'Carlos Rodríguez',
                              tarifaServicio: 1900,
                              seguroBasico: 15000,
                              publicationId: _publicationId,
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
                        shadowColor:
                            const Color(0xFF10B981).withValues(alpha: 0.35),
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
                            color:
                                const Color(0xFF22C55E).withValues(alpha: 0.35),
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
                                vehiculoBrand:
                                    widget.vehicleName ?? 'Mazda CX-5 2024',
                                vehiculoColor: _extractColorFromSpecs(),
                                vehiculoImage: widget.vehicleImage ?? '',
                                periodo: _periodoSeleccionado,
                                cantidad: _cantidad,
                                precioUnitario: _getPrecioUnitario(),
                                fechaInicio: _formatFechaInicio(),
                                lugarRecogida: 'Av. El Dorado, Bogotá',
                                conductor: 'Carlos Rodríguez',
                                tarifaServicio: 1900,
                                seguroBasico: 15000,
                                publicationId: _publicationId,
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
                          shadowColor:
                              const Color(0xFF10B981).withValues(alpha: 0.13),
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

/// Define la responsabilidad de `_CaracteristicaItem` dentro de este módulo.
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

  /// Construye y devuelve el widget correspondiente a esta sección.
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

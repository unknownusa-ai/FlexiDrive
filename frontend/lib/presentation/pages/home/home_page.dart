import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flexidrive/presentation/pages/main_page.dart';
import 'package:flexidrive/services/accounts/local_account_repository.dart';
import '../../../core/utils/responsive_utils.dart';
import '../reservas/reserva_detalle_page.dart';
import '../../../services/vehiculo_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocalAccountRepository _accountRepository = LocalAccountRepository();

  String _selectedCategory = 'Todos';
  String _selectedDate = 'Hoy';
  String _selectedCity = 'Bogotá';
  String _currentUserName = 'Invitado';

  // Servicio para cargar datos desde JSON
  final VehiculoService _vehiculoService = VehiculoService();
  List<Map<String, dynamic>> _vehiculos = [];
  bool _isLoading = true;

  static const _cityData = [
    {'name': 'Bogotá', 'emoji': '🏙️', 'vehicles': 48},
    {'name': 'Medellín', 'emoji': '🌸', 'vehicles': 36},
    {'name': 'Cali', 'emoji': '🎵', 'vehicles': 29},
    {'name': 'Barranquilla', 'emoji': '🌊', 'vehicles': 22},
    {'name': 'Cartagena', 'emoji': '🏖️', 'vehicles': 18},
    {'name': 'Bucaramanga', 'emoji': '🏔️', 'vehicles': 15},
    {'name': 'Pereira', 'emoji': '☕', 'vehicles': 12},
    {'name': 'Cúcuta', 'emoji': '🌄', 'vehicles': 12},
    {'name': 'Santa Marta', 'emoji': '🏝️', 'vehicles': 10},
    {'name': 'Ibagué', 'emoji': '🎶', 'vehicles': 9},
    {'name': 'Manizales', 'emoji': '🌋', 'vehicles': 8},
    {'name': 'Villavicencio', 'emoji': '🦋', 'vehicles': 7},
    {'name': 'Armenia', 'emoji': '🌺', 'vehicles': 7},
    {'name': 'Neiva', 'emoji': '🌞', 'vehicles': 6},
    {'name': 'Popayán', 'emoji': '⛪', 'vehicles': 6},
    {'name': 'Montería', 'emoji': '🐄', 'vehicles': 5},
    {'name': 'Valledupar', 'emoji': '🎸', 'vehicles': 5},
    {'name': 'Pasto', 'emoji': '🎭', 'vehicles': 5},
    {'name': 'Sincelejo', 'emoji': '🌿', 'vehicles': 4},
    {'name': 'Tunja', 'emoji': '🏛️', 'vehicles': 4},
  ];

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // Dark-mode aware palette helpers
  Color get _cardBg => _isDark ? const Color(0xFF161827) : Colors.white;
  Color get _borderColor =>
      _isDark ? const Color(0xFF2E3355) : Colors.grey.shade200;
  Color get _dividerColor =>
      _isDark ? const Color(0xFF252942) : Colors.grey.shade100;
  Color get _textPrimary =>
      _isDark ? const Color(0xFFF1F3FF) : const Color(0xFF1A1A1A);
  Color get _textSub =>
      _isDark ? const Color(0xFF8B93B8) : Colors.grey.shade500;

  // ─── INIT STATE - Cargar datos desde JSON ─────────────────────────
  @override
  void initState() {
    super.initState();
    _cargarVehiculos();
    _cargarUsuarioActual();
  }

  Future<void> _cargarUsuarioActual() async {
    final currentUser = await _accountRepository.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _currentUserName = currentUser?.fullName.split(' ').first ?? 'Invitado';
    });
  }

  /// Carga vehículos desde el JSON usando dart:convert
  Future<void> _cargarVehiculos() async {
    await _vehiculoService.init();
    setState(() {
      _vehiculos = _vehiculoService.getVehiculos();
      _isLoading = false;
    });
  }

  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildPromoBanner(),
              const SizedBox(height: 20),
              _buildDateSelector(),
              const SizedBox(height: 20),
              _buildCategories(),
              const SizedBox(height: 20),
              if (_selectedCategory == 'Todos') ...[
                _buildDestacadosSection(),
                const SizedBox(height: 24),
                _buildAllVehiclesSection(),
                const SizedBox(height: 24),
              ] else if (_selectedCategory == 'Sedán') ...[
                _buildSedanSection(),
                const SizedBox(height: 24),
              ] else if (_selectedCategory == 'SUV') ...[
                _buildSUVSection(),
                const SizedBox(height: 24),
              ] else if (_selectedCategory == 'Compacto') ...[
                _buildCompactoSection(),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 60,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => MainPage.of(context).setIndex(3),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                      width: 2),
                                ),
                                child: const Icon(Icons.person,
                                    color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Buenas tardes 👋',
                                      style: GoogleFonts.inter(
                                          color: Colors.white
                                              .withValues(alpha: 0.75),
                                          fontSize: 12)),
                                  Text(_currentUserName,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => MainPage.of(context).setIndex(2),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.notifications_none_rounded,
                                    color: Colors.white, size: 22),
                                Positioned(
                                  top: 9,
                                  right: 9,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                        color: Color(0xFFEF4444),
                                        shape: BoxShape.circle),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Text('¿A dónde vas hoy?',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8)),
                          child:
                              const Text('🏞️', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Encuentra el vehículo perfecto para ti',
                        style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13)),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
              _buildSearchBar(),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 52,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.30)
                : Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search_rounded, color: theme.hintColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar vehículo, marca...',
                hintStyle: GoogleFonts.inter(
                  color: theme.hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: GoogleFonts.inter(
                  fontSize: 14, color: theme.textTheme.bodyLarge?.color),
            ),
          ),
          GestureDetector(
            onTap: _showCitySelector,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF4F46E5).withValues(alpha: 0.2)
                    : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                        color: Color(0xFF4F46E5), shape: BoxShape.circle),
                    child: const Icon(Icons.location_on,
                        color: Colors.white, size: 12),
                  ),
                  const SizedBox(width: 5),
                  Text(_selectedCity,
                      style: GoogleFonts.inter(
                          color: const Color(0xFF4F46E5),
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PROMO BANNER ────────────────────────────────────────────────
  Widget _buildPromoBanner() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? colorScheme.outline : const Color(0xFFD1FAE5),
              width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981)
                  .withValues(alpha: isDark ? 0.15 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.trending_down_rounded,
                  color: const Color(0xFF10B981), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🌿 Ahorra hasta un 60%',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'vs. taxi tradicional en Bogotá',
                    style: GoogleFonts.inter(
                      color: theme.hintColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  'Ver más',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF10B981), size: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── DATE SELECTOR ───────────────────────────────────────────────
  Widget _buildDateSelector() {
    final dates = [
      {'label': 'Hoy', 'date': '22 Feb'},
      {'label': '2 días', 'date': '23-24 Feb'},
      {'label': '1 semana', 'date': '22 Feb-1 Mar'},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: dates
            .map((d) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildDateButton(d['label']!, d['date']!),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildDateButton(String label, String date) {
    final isSelected = _selectedDate == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedDate = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: isSelected
            ? BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              )
            : BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _borderColor),
              ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : _textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                )),
            const SizedBox(height: 2),
            Text(date,
                style: GoogleFonts.inter(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.85)
                      : _textSub,
                  fontSize: 11,
                )),
          ],
        ),
      ),
    );
  }

  // ─── CATEGORIES ──────────────────────────────────────────────────
  Widget _buildCategories() {
    final categories = [
      {'name': 'Todos', 'icon': null},
      {'name': 'Sedán', 'icon': '🚗'},
      {'name': 'SUV', 'icon': '🚙'},
      {'name': 'Compacto', 'icon': '🚗'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Categorías',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary)),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: categories
                .map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _buildCategoryButton(cat['name']!, cat['icon']),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryButton(String category, String? emoji) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? null : Border.all(color: _borderColor),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF4F46E5).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: _isDark ? 0.2 : 0.04),
              blurRadius: isSelected ? 12 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6)
            ],
            Text(category,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : _textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                )),
          ],
        ),
      ),
    );
  }

  // ─── DESTACADOS ──────────────────────────────────────────────────
  Widget _buildDestacadosSection() {
    final destacados = _vehiculos.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('✨ Destacados',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary)),
              GestureDetector(
                onTap: () {},
                child: Text('Ver todos',
                    style: GoogleFonts.inter(
                        color: const Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_isLoading)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ))
        else if (destacados.isEmpty)
          const Center(child: Text('No hay vehículos destacados'))
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: destacados.map((v) {
                final typeColor = _getTypeColor(v['categoria']);
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildFeaturedCard(
                    title: '${v['marca']} ${v['modelo']} ${v['anio']}',
                    type: v['categoria'],
                    typeColor: typeColor,
                    rating: v['calificacion'],
                    reviews: v['resenas'],
                    price: v['precio_hora'],
                    precioDia: v['precio_dia'],
                    precioSemana: v['precio_semana'],
                    image: v['imagen'],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Color _getTypeColor(String categoria) {
    switch (categoria) {
      case 'SUV':
        return const Color(0xFF4F46E5);
      case 'Sedán':
        return const Color(0xFFE53935);
      case 'Compacto':
        return const Color(0xFF10B981);
      case 'Premium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF4F46E5);
    }
  }

  Widget _buildFeaturedCard({
    required String title,
    required String type,
    required Color typeColor,
    required double rating,
    required int reviews,
    required int price,
    required int precioDia,
    required int precioSemana,
    required String image,
  }) {
    return Container(
      width: 210,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: _isDark ? Border.all(color: _borderColor) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: Stack(
              children: [
                Image.asset(image,
                    height: 135,
                    width: 210,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                          height: 135,
                          width: 210,
                          color: _isDark
                              ? const Color(0xFF1F2235)
                              : const Color(0xFF1E1B4B),
                          child: Icon(Icons.directions_car,
                              size: 50,
                              color: Colors.white.withValues(alpha: 0.25)),
                        )),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.directions_car,
                          color: Colors.white, size: 10),
                      const SizedBox(width: 3),
                      Text(type,
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle)),
                      const SizedBox(width: 3),
                      Text('DISPONIBLE',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFBBF24), size: 14),
                  const SizedBox(width: 3),
                  Text('$rating',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: _textPrimary)),
                  const SizedBox(width: 2),
                  Text('($reviews)',
                      style: GoogleFonts.inter(color: _textSub, fontSize: 11)),
                ]),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: '\$ ${_formatPrice(price)}',
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF4F46E5),
                              fontWeight: FontWeight.w700,
                              fontSize: 17)),
                      TextSpan(
                          text: '/hora',
                          style:
                              GoogleFonts.inter(color: _textSub, fontSize: 11)),
                    ])),
                    GestureDetector(
                      onTap: () {
                        final specs = '$type • 2024 • Automático • 5 puestos';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ReservaDetallePage(
                                    vehicleName: title,
                                    vehicleSpecs: specs,
                                    vehicleRating: rating,
                                    vehicleReviews: reviews,
                                    vehiclePrice: price,
                                    vehicleImage: image,
                                    precioHora: price,
                                    precioDia: precioDia,
                                    precioSemana: precioSemana,
                                  )),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('RENTAR',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── ALL VEHICLES ────────────────────────────────────────────────
  Widget _buildAllVehiclesSection() {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallPhone ? 16 : 20),
          child: Row(children: [
            const Text('🚗', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
                child: Text('Todos los vehículos',
                    style: GoogleFonts.poppins(
                        fontSize: isSmallPhone ? 16 : 18,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _isDark ? const Color(0xFF1F2235) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${_vehiculos.length} disponibles',
                  style: GoogleFonts.inter(
                      color: _textSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        if (_isLoading)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ))
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallPhone ? 16 : 20),
            child: Column(
                children: _vehiculos
                    .map((v) => _buildVehicleListItem(v, isSmallPhone))
                    .toList()),
          ),
        const SizedBox(height: 20),
        _buildCompareSection(isSmallPhone),
      ],
    );
  }

  Widget _buildVehicleListItem(Map<String, dynamic> v, bool isSmallPhone) {
    final name = '${v['marca']} ${v['modelo']} ${v['anio']}';
    final specs =
        '${v['anio']} • ${v['transmision']} • ${v['puertos']} puestos';
    final rating = v['calificacion'] as double;
    final reviews = v['resenas'] as int;
    final price = v['precio_hora'] as int;
    final precioDia = v['precio_dia'] as int;
    final precioSemana = v['precio_semana'] as int;
    final image = v['imagen'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: _isDark ? Border.all(color: _borderColor) : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
          child: Image.asset(
            image,
            width: isSmallPhone ? 100 : 120,
            height: isSmallPhone ? 100 : 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: isSmallPhone ? 100 : 120,
              height: isSmallPhone ? 100 : 120,
              color:
                  _isDark ? const Color(0xFF1F2235) : const Color(0xFF1E1B4B),
              child: Icon(Icons.directions_car,
                  size: 36, color: Colors.white.withValues(alpha: 0.3)),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(isSmallPhone ? 12 : 14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(name,
                        style: GoogleFonts.poppins(
                            fontSize: isSmallPhone ? 13 : 15,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary))),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _isDark
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('LIBRE',
                      style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF10B981))),
                ),
              ]),
              const SizedBox(height: 4),
              Text(specs,
                  style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 11 : 12, color: _textSub)),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFBBF24), size: 14),
                const SizedBox(width: 3),
                Text('$rating',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: _textPrimary)),
                const SizedBox(width: 2),
                Text('($reviews reseñas)',
                    style: GoogleFonts.inter(
                        color: _textSub, fontSize: isSmallPhone ? 10 : 11)),
              ]),
              SizedBox(height: isSmallPhone ? 8 : 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: '\$ ${_formatPrice(price)}',
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF4F46E5),
                            fontWeight: FontWeight.w700,
                            fontSize: isSmallPhone ? 15 : 17)),
                    TextSpan(
                        text: '/h',
                        style:
                            GoogleFonts.inter(color: _textSub, fontSize: 11)),
                  ])),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ReservaDetallePage(
                                vehicleName: name,
                                vehicleSpecs: specs,
                                vehicleRating: rating,
                                vehicleReviews: reviews,
                                vehiclePrice: price,
                                vehicleImage: image,
                                precioHora: price,
                                precioDia: precioDia,
                                precioSemana: precioSemana,
                              )),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: isSmallPhone ? 12 : 14,
                          vertical: isSmallPhone ? 7 : 9),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('Ver',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: isSmallPhone ? 12 : 13,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white, size: 12),
                      ]),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  // ─── COMPARE SECTION ─────────────────────────────────────────────
  Widget _buildCompareSection(bool isSmallPhone) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallPhone ? 16 : 20),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: _isDark
              ? Border.all(color: _borderColor)
              : Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
        child: Column(children: [
          Row(children: [
            const Icon(Icons.bolt_rounded, color: Color(0xFF4F46E5), size: 22),
            const SizedBox(width: 8),
            Text('Compara y ahorra 💰',
                style: GoogleFonts.poppins(
                    fontSize: isSmallPhone ? 15 : 16,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary)),
          ]),
          SizedBox(height: isSmallPhone ? 16 : 20),
          Row(children: [
            Expanded(
                child: Column(children: [
              const Text('🚕', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text('Taxi (8h)',
                  style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 11 : 12, color: _textSub)),
              const SizedBox(height: 4),
              Text('\$ 180.000',
                  style: GoogleFonts.poppins(
                      fontSize: isSmallPhone ? 18 : 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444))),
            ])),
            Container(width: 1, height: 70, color: _dividerColor),
            Expanded(
                child: Column(children: [
              const Text('🚗', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text('FlexiDrive (8h)',
                  style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 11 : 12, color: _textSub)),
              const SizedBox(height: 4),
              Text('\$ 72.000',
                  style: GoogleFonts.poppins(
                      fontSize: isSmallPhone ? 18 : 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF10B981))),
            ])),
          ]),
          SizedBox(height: isSmallPhone ? 12 : 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isSmallPhone ? 10 : 12),
            decoration: BoxDecoration(
              color: _isDark
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: _isDark
                  ? Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2))
                  : null,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🎉', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('Ahorro estimado: \$ 108.000 (60%)',
                  style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 12 : 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981))),
            ]),
          ),
        ]),
      ),
    );
  }

  // ─── CATEGORY SECTIONS ───────────────────────────────────────────
  Widget _buildSedanSection() {
    final sedanes = _vehiculos.where((v) => v['categoria'] == 'Sedán').toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildCategoryHeader('🚗', 'Sedán', '${sedanes.length} disponibles'),
      const SizedBox(height: 16),
      if (_isLoading)
        const Center(child: CircularProgressIndicator())
      else
        ...sedanes.map((v) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: _buildHorizontalCardFromJson(v),
            )),
      const SizedBox(height: 24),
      _buildCompareSection(true),
    ]);
  }

  Widget _buildSUVSection() {
    final suvs = _vehiculos.where((v) => v['categoria'] == 'SUV').toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildCategoryHeader('🚙', 'SUV', '${suvs.length} disponibles'),
      const SizedBox(height: 16),
      if (_isLoading)
        const Center(child: CircularProgressIndicator())
      else
        ...suvs.map((v) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: _buildHorizontalCardFromJson(v),
            )),
      const SizedBox(height: 24),
      _buildCompareSection(true),
    ]);
  }

  Widget _buildCompactoSection() {
    final compactos =
        _vehiculos.where((v) => v['categoria'] == 'Compacto').toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildCategoryHeader('🚗', 'Compacto', '${compactos.length} disponibles'),
      const SizedBox(height: 16),
      if (_isLoading)
        const Center(child: CircularProgressIndicator())
      else
        ...compactos.map((v) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: _buildHorizontalCardFromJson(v),
            )),
      const SizedBox(height: 24),
      _buildCompareSection(true),
    ]);
  }

  Widget _buildCategoryHeader(String emoji, String title, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF1F2235) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(count,
              style: GoogleFonts.inter(
                  color: _textSub, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }

  Widget _buildHorizontalCardFromJson(Map<String, dynamic> v) {
    final name = '${v['marca']} ${v['modelo']} ${v['anio']}';
    final specs =
        '${v['anio']} • ${v['transmision']} • ${v['puertos']} puestos';
    final rating = v['calificacion'] as double;
    final reviews = v['resenas'] as int;
    final price = v['precio_hora'] as int;
    final precioDia = v['precio_dia'] as int;
    final precioSemana = v['precio_semana'] as int;
    final image = v['imagen'] as String;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: _isDark ? Border.all(color: _borderColor) : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
          child: Image.asset(
            image,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 120,
              height: 120,
              color:
                  _isDark ? const Color(0xFF1F2235) : const Color(0xFF1E1B4B),
              child: Icon(Icons.directions_car,
                  size: 50, color: Colors.white.withValues(alpha: 0.25)),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary)),
              const SizedBox(height: 4),
              Text(specs,
                  style: GoogleFonts.inter(fontSize: 11, color: _textSub)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFBBF24), size: 15),
                const SizedBox(width: 4),
                Text('$rating',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _textPrimary)),
                const SizedBox(width: 2),
                Text('($reviews reseñas)',
                    style: GoogleFonts.inter(color: _textSub, fontSize: 11)),
              ]),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: '\$ ${_formatPrice(price)}',
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF4F46E5),
                            fontWeight: FontWeight.w700,
                            fontSize: 17)),
                    TextSpan(
                        text: '/h',
                        style:
                            GoogleFonts.inter(color: _textSub, fontSize: 12)),
                  ])),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ReservaDetallePage(
                                vehicleName: name,
                                vehicleSpecs: specs,
                                vehicleRating: rating,
                                vehicleReviews: reviews,
                                vehiclePrice: price,
                                vehicleImage: image,
                                precioHora: price,
                                precioDia: precioDia,
                                precioSemana: precioSemana,
                              )),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('Ver',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 14),
                      ]),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  // ─── CITY SELECTOR ───────────────────────────────────────────────
  void _showCitySelector() {
    final sheetBg = _isDark ? const Color(0xFF161827) : Colors.white;
    final inputBg = _isDark ? const Color(0xFF1F2235) : Colors.grey.shade100;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(builder: (context, setModalState) {
          final filtered = _cityData
              .where((c) => (c['name'] as String)
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
              .toList();
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Column(children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      _isDark ? const Color(0xFF2E3355) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Selecciona tu ciudad',
                              style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary)),
                          const SizedBox(height: 2),
                          Text(
                              '${_cityData.length} ciudades disponibles en Colombia',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: _textSub)),
                        ])),
                    IconButton(
                      icon:
                          Icon(Icons.close_rounded, color: _textSub, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                      color: inputBg, borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    onChanged: (v) => setModalState(() => searchQuery = v),
                    style: GoogleFonts.inter(color: _textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Buscar ciudad...',
                      hintStyle:
                          GoogleFonts.inter(color: _textSub, fontSize: 14),
                      prefixIcon:
                          Icon(Icons.search_rounded, color: _textSub, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final city = filtered[index];
                    final cityName = city['name'] as String;
                    final isSel = cityName == _selectedCity;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedCity = cityName);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSel
                              ? (_isDark
                                  ? const Color(0xFF4F46E5)
                                      .withValues(alpha: 0.15)
                                  : const Color(0xFFEEF2FF))
                              : (_isDark
                                  ? const Color(0xFF1F2235)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                isSel ? const Color(0xFF4F46E5) : _borderColor,
                            width: isSel ? 2 : 1,
                          ),
                        ),
                        child: Row(children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSel
                                  ? (_isDark
                                      ? const Color(0xFF4F46E5)
                                          .withValues(alpha: 0.2)
                                      : const Color(0xFFDDE4FF))
                                  : (_isDark
                                      ? const Color(0xFF272B40)
                                      : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                                child: Text(city['emoji'] as String,
                                    style: const TextStyle(fontSize: 20))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(cityName,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: isSel
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSel
                                          ? const Color(0xFF4F46E5)
                                          : _textPrimary,
                                    )),
                                Text(
                                    '${city['vehicles']} vehículos disponibles',
                                    style: GoogleFonts.inter(
                                        fontSize: 12, color: _textSub)),
                              ])),
                          if (isSel)
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF4F46E5), size: 22),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ]),
          );
        });
      },
    );
  }

  String _formatPrice(int price) => price
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
}

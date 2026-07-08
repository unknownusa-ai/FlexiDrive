import 'dart:async';

import 'package:flexidrive/core/session/local_session_store.dart';
import 'package:flexidrive/core/utils/responsive_utils.dart';
import 'package:flexidrive/features/accounts/application/use_cases/account_access_use_case.dart';
import 'package:flexidrive/features/accounts/application/use_cases/user_preferences_use_case.dart';
import 'package:flexidrive/features/accounts/domain/entities/account_models.dart';
import 'package:flexidrive/features/auth/presentation/pages/login/login_page.dart';
import 'package:flexidrive/features/auth/presentation/pages/register/register_page.dart';
import 'package:flexidrive/features/home/presentation/pages/main_page.dart';
import 'package:flexidrive/features/profile/presentation/pages/profile/arrendatario_main_page.dart';
import 'package:flexidrive/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeLandingPage extends StatefulWidget {
  const WelcomeLandingPage({super.key});

  @override
  State<WelcomeLandingPage> createState() => _WelcomeLandingPageState();
}

class _WelcomeSlideData {
  const _WelcomeSlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.metric,
    required this.metricLabel,
    required this.colors,
    required this.backgroundImage,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String metric;
  final String metricLabel;
  final List<Color> colors;
  final String backgroundImage;
}

enum _LandingState {
  guest,
  rememberedUser,
  activeSession,
}

class _WelcomeLandingPageState extends State<WelcomeLandingPage> {
  static const List<_WelcomeSlideData> _slides = [
    _WelcomeSlideData(
      icon: Icons.schedule_rounded,
      title: 'Alquila por horas,\ndias o semanas',
      subtitle:
          'Reserva el vehiculo que encaja con tu ritmo sin contratos largos ni vueltas innecesarias.',
      metric: '24/7',
      metricLabel: 'disponibilidad digital',
      colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
      backgroundImage: 'assets/imagenes_carros/imagen_fondo_carrusel_1.png',
    ),
    _WelcomeSlideData(
      icon: Icons.place_rounded,
      title: 'Encuentra opciones\ncerca de ti',
      subtitle:
          'Explora carros listos para rentar en las ciudades donde ya se mueve la comunidad FlexiDrive.',
      metric: '+120',
      metricLabel: 'vehiculos publicados',
      colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
      backgroundImage: 'assets/imagenes_carros/imagen_fondo_carrusel_2.png',
    ),
    _WelcomeSlideData(
      icon: Icons.verified_user_rounded,
      title: 'Todo listo para\nvolver a conducir',
      subtitle:
          'Acceso rapido, pagos protegidos y soporte en cada paso de tu reserva.',
      metric: '100%',
      metricLabel: 'flujo movil',
      colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
      backgroundImage: 'assets/imagenes_carros/imagen_fondo_carrusel_3.png',
    ),
  ];

  final PageController _pageController = PageController(viewportFraction: 0.88);
  final AccountAccessUseCase _accountRepository =
      InjectionContainer.instance.accountAccessUseCase;
  final UserPreferencesUseCase _preferencesUseCase =
      InjectionContainer.instance.userPreferencesUseCase;

  Timer? _carouselTimer;
  int _currentPage = 0;
  bool _isLoading = true;
  bool _isContinuing = false;
  _LandingState _state = _LandingState.guest;
  UserModel? _rememberedUser;

  @override
  void initState() {
    super.initState();
    _loadLandingState();
    _startCarouselAutoPlay();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startCarouselAutoPlay() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients || _slides.length <= 1) {
        return;
      }

      final nextPage = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _loadLandingState() async {
    await LocalSessionStore.instance.init();

    final lastEmail = LocalSessionStore.instance.lastLoggedEmail;
    if (lastEmail == null || lastEmail.isEmpty) {
      if (!mounted) return;
      setState(() {
        _state = _LandingState.guest;
        _rememberedUser = null;
        _isLoading = false;
      });
      return;
    }

    final user = await _accountRepository.findUserByEmail(lastEmail);
    if (!mounted) return;

    if (user == null) {
      await LocalSessionStore.instance.setLastLoggedEmail('');
      if (!mounted) return;
      setState(() {
        _state = _LandingState.guest;
        _rememberedUser = null;
        _isLoading = false;
      });
      return;
    }

    final hasActiveSession = LocalSessionStore.instance.userId == user.id;
    setState(() {
      _rememberedUser = user;
      _state = hasActiveSession
          ? _LandingState.activeSession
          : _LandingState.rememberedUser;
      _isLoading = false;
    });
  }

  Future<void> _continueWithSavedSession() async {
    final user = _rememberedUser;
    if (user == null ||
        _isContinuing ||
        _state != _LandingState.activeSession) {
      return;
    }

    setState(() {
      _isContinuing = true;
    });

    final isArrendatarioMode = await _preferencesUseCase.getArrendatarioMode(
      userId: user.id,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isArrendatarioMode
            ? const ArrendatarioMainPage()
            : const MainPage(),
      ),
    );
  }

  void _goToRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterPage())).then((_) {
      _loadLandingState();
    });
  }

  void _goToLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginPage())).then((_) {
      _loadLandingState();
    });
  }

  Future<void> _forgetRememberedUser() async {
    await _accountRepository.logout();
    await LocalSessionStore.instance.setLastLoggedEmail('');
    if (!mounted) return;
    setState(() {
      _rememberedUser = null;
      _state = _LandingState.guest;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scale = ResponsiveUtils.scale(context, 1.0);
    final isGuestState = _state == _LandingState.guest;
    final backgroundTop =
        isDark ? const Color(0xFF081226) : const Color(0xFFEAF2FF);
    final backgroundBottom =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFF);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundTop, backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, viewport) {
                    final overlap = 4 * scale;

                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        16 * scale,
                        0,
                        16 * scale,
                        14 * scale,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              8 * scale,
                              12 * scale,
                              8 * scale,
                              8 * scale,
                            ),
                            child: _buildTopBrand(scale, isDark),
                          ),
                          SizedBox(height: 8 * scale),
                          Expanded(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  bottom: (viewport.maxHeight * 0.39) - overlap,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: PageView.builder(
                                          controller: _pageController,
                                          itemCount: _slides.length,
                                          onPageChanged: (index) {
                                            setState(() {
                                              _currentPage = index;
                                            });
                                          },
                                          itemBuilder: (context, index) =>
                                              Padding(
                                            padding: EdgeInsets.only(
                                              right: index == _slides.length - 1
                                                  ? 0
                                                  : 12 * scale,
                                            ),
                                            child: _buildSlide(
                                              _slides[index],
                                              scale,
                                              isDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            (isGuestState ? 12 : 14) * scale,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          _slides.length,
                                          (index) => AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 220,
                                            ),
                                            width: _currentPage == index
                                                ? 28 * scale
                                                : 8 * scale,
                                            height: 8 * scale,
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 4 * scale,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _currentPage == index
                                                  ? const Color(0xFF4F46E5)
                                                  : const Color(0xFFD6DBEB),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  top: viewport.maxHeight *
                                      (isGuestState ? 0.505 : 0.535),
                                  child:
                                      _buildBottomCard(scale, isDark, overlap),
                                ),
                                Positioned(
                                  left: 40 * scale,
                                  right: 40 * scale,
                                  bottom: (viewport.maxHeight * 0.38) -
                                      (overlap * 1.05),
                                  child: IgnorePointer(
                                    child: Container(
                                      height: 18 * scale,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withValues(alpha: 0),
                                            (isDark
                                                    ? const Color(0xFF111A2C)
                                                    : Colors.white)
                                                .withValues(alpha: 0.16),
                                            (isDark
                                                    ? const Color(0xFF111A2C)
                                                    : Colors.white)
                                                .withValues(alpha: 0.04),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildBottomCard(double scale, bool isDark, double overlap) {
    return Transform.translate(
      offset: Offset(0, -overlap),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          20 * scale,
          22 * scale,
          20 * scale,
          20 * scale,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF111A2C).withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(30 * scale),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE5EAF8),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF101828).withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: _buildScrollableBottomPanel(
                scale: scale,
                isDark: isDark,
                minHeight: constraints.maxHeight,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBrand(double scale, bool isDark) {
    return Row(
      children: [
        Container(
          width: 48 * scale,
          height: 48 * scale,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(16 * scale),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.directions_car_filled_rounded,
            color: Colors.white,
            size: 24 * scale,
          ),
        ),
        SizedBox(width: 14 * scale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FlexiDrive',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize(context, 24),
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              Text(
                'Movilidad flexible para Colombia',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize(context, 12),
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlide(_WelcomeSlideData slide, double scale, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34 * scale),
        boxShadow: [
          BoxShadow(
            color: slide.colors.first.withValues(alpha: 0.28),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34 * scale),
        child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              slide.backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: slide.colors
                      .map((c) => c.withValues(alpha: 0.55))
                      .toList(),
                ),
              ),
            ),
          ),
          Positioned(
            top: -34 * scale,
            right: -24 * scale,
            child: Container(
              width: 150 * scale,
              height: 150 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -40 * scale,
            left: -20 * scale,
            child: Container(
              width: 130 * scale,
              height: 130 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(18 * scale),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 280;
                final iconBox = compact ? 38.0 * scale : 44.0 * scale;
                final titleSize = compact ? 20.0 : 23.0;
                final bodySize = compact ? 10.5 : 11.5;
                final chipBodySize = compact ? 8.5 : 9.5;
                final slideBottomInset = compact ? 0.0 : 2.0 * scale;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: iconBox,
                          height: iconBox,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(
                              (compact ? 12 : 14) * scale,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Icon(
                            slide.icon,
                            color: Colors.white,
                            size: (compact ? 20 : 24) * scale,
                          ),
                        ),
                        const Spacer(),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: (compact ? 108 : 124) * scale,
                            maxWidth: (compact ? 128 : 142) * scale,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: (compact ? 8 : 12) * scale,
                              vertical: (compact ? 6 : 8) * scale,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(18 * scale),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  slide.metric,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: ResponsiveUtils.fontSize(
                                      context,
                                      compact ? 14 : 16,
                                    ),
                                  ),
                                ),
                                Text(
                                  slide.metricLabel,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(alpha: 0.82),
                                    fontSize: ResponsiveUtils.fontSize(
                                      context,
                                      chipBodySize,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: (compact ? 3 : 4) * scale),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: slideBottomInset),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slide.title,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: ResponsiveUtils.fontSize(
                                    context,
                                    titleSize,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: (compact ? 2 : 4) * scale),
                              Text(
                                slide.subtitle,
                                maxLines: compact ? 3 : 4,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.86),
                                  fontSize: ResponsiveUtils.fontSize(
                                    context,
                                    bodySize,
                                  ),
                                  height: 1.45,
                                ),
                              ),
                              SizedBox(height: (compact ? 4 : 6) * scale),
                              Container(
                                padding: EdgeInsets.all(
                                  (compact ? 8 : 10) * scale,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(20 * scale),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.bolt_rounded,
                                      color: Colors.white,
                                      size: (compact ? 14 : 16) * scale,
                                    ),
                                    SizedBox(width: 8 * scale),
                                    Expanded(
                                      child: Text(
                                        'Reserva simple, acceso rapido y una entrada clara a tu cuenta.',
                                        maxLines: compact ? 2 : 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: ResponsiveUtils.fontSize(
                                            context,
                                            compact ? 10.5 : 11,
                                          ),
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
                  ],
                );
              },
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel(double scale, bool isDark) {
    switch (_state) {
      case _LandingState.activeSession:
        return _buildActiveSessionPanel(scale, isDark);
      case _LandingState.rememberedUser:
        return _buildRememberedUserPanel(scale, isDark);
      case _LandingState.guest:
        return _buildGuestPanel(scale, isDark);
    }
  }

  Widget _buildScrollableBottomPanel({
    required double scale,
    required bool isDark,
    required double minHeight,
  }) {
    return SingleChildScrollView(
      key: ValueKey('scrollable-${_state.name}'),
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: IntrinsicHeight(child: _buildBottomPanel(scale, isDark)),
      ),
    );
  }

  Widget _buildGuestPanel(double scale, bool isDark) {
    return Column(
      key: const ValueKey('guest-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPanelBadge(
          label: 'Empieza hoy',
          icon: Icons.waving_hand_rounded,
          scale: scale,
        ),
        SizedBox(height: 10 * scale),
        Text(
          'Tu siguiente viaje empieza aqui',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize(context, 22),
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF111827),
            height: 1.15,
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          'Crea tu cuenta para rentar, administrar reservas o publicar tu vehiculo con una experiencia mas cuidada.',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize(context, 12.5),
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085),
            height: 1.45,
          ),
        ),
        SizedBox(height: 14 * scale),
        _buildInfoStrip(
          label: 'Registro sencillo',
          value: 'Datos claros y acceso seguro',
          scale: scale,
          isDark: isDark,
        ),
        _buildBottomActions(
          scale: scale,
          primaryLabel: 'Registrate',
          primaryAction: _goToRegister,
          secondaryLabel: 'Iniciar Sesion',
          secondaryAction: _goToLogin,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildRememberedUserPanel(double scale, bool isDark) {
    final user = _rememberedUser!;
    final firstName = user.fullName.trim().split(' ').first;

    return Column(
      key: const ValueKey('remembered-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserHeader(
          title: 'Hola de nuevo, $firstName',
          subtitle: 'Tu cuenta sigue recordada en este dispositivo.',
          initial: _getInitial(user),
          scale: scale,
          isDark: isDark,
        ),
        SizedBox(height: 18 * scale),
        _buildInfoStrip(
          label: user.email,
          value: 'Ingresa con tu contrasena para continuar',
          scale: scale,
          isDark: isDark,
        ),
        _buildBottomActions(
          scale: scale,
          primaryLabel: 'Ingresar con contrasena',
          primaryAction: _goToLogin,
          secondaryLabel: 'Cerrar sesion',
          secondaryAction: _forgetRememberedUser,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildActiveSessionPanel(double scale, bool isDark) {
    final user = _rememberedUser!;
    final firstName = user.fullName.trim().split(' ').first;

    return Column(
      key: const ValueKey('active-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserHeader(
          title: 'Bienvenido, $firstName',
          subtitle: 'Tu sesion sigue activa. Entras en segundos.',
          initial: _getInitial(user),
          scale: scale,
          isDark: isDark,
        ),
        SizedBox(height: 18 * scale),
        _buildInfoStrip(
          label: 'Acceso rapido',
          value: 'Puedes continuar directo o volver a ingresar con contrasena',
          scale: scale,
          isDark: isDark,
        ),
        _buildBottomActions(
          scale: scale,
          primaryLabel: _isContinuing ? 'Ingresando...' : 'Continuar',
          primaryAction: _isContinuing ? null : _continueWithSavedSession,
          secondaryLabel: 'Ingresar con contrasena',
          secondaryAction: _goToLogin,
          isDark: isDark,
          showLoader: _isContinuing,
        ),
      ],
    );
  }

  Widget _buildBottomActions({
    required double scale,
    required String primaryLabel,
    required VoidCallback? primaryAction,
    required String secondaryLabel,
    required VoidCallback secondaryAction,
    required bool isDark,
    bool showLoader = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 14 * scale),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPrimaryAction(
            label: primaryLabel,
            onTap: primaryAction,
            scale: scale,
            showLoader: showLoader,
          ),
          SizedBox(height: 12 * scale),
          _buildSecondaryAction(
            label: secondaryLabel,
            onTap: secondaryAction,
            scale: scale,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader({
    required String title,
    required String subtitle,
    required String initial,
    required double scale,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 62 * scale,
          height: 62 * scale,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initial,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: ResponsiveUtils.fontSize(context, 24),
              ),
            ),
          ),
        ),
        SizedBox(width: 14 * scale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize(context, 22),
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize(context, 12),
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPanelBadge({
    required String label,
    required IconData icon,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 8 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16 * scale, color: const Color(0xFF6D28D9)),
          SizedBox(width: 6 * scale),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: const Color(0xFF6D28D9),
              fontSize: ResponsiveUtils.fontSize(context, 12),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStrip({
    required String label,
    required String value,
    required double scale,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162133) : const Color(0xFFF4F7FE),
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize(context, 12),
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFC7D2FE) : const Color(0xFF4F46E5),
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize(context, 13),
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475467),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryAction({
    required String label,
    required VoidCallback? onTap,
    required double scale,
    bool showLoader = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(18 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.26),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: Size(double.infinity, 56 * scale),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18 * scale),
          ),
        ),
        child: showLoader
            ? SizedBox(
                width: 20 * scale,
                height: 20 * scale,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: ResponsiveUtils.fontSize(context, 16),
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18 * scale,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSecondaryAction({
    required String label,
    required VoidCallback onTap,
    required double scale,
    required bool isDark,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 54 * scale),
        side: BorderSide(
          color: isDark ? const Color(0xFF314158) : const Color(0xFFD6DCEB),
          width: 1.4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18 * scale),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: isDark ? Colors.white : const Color(0xFF111827),
          fontWeight: FontWeight.w600,
          fontSize: ResponsiveUtils.fontSize(context, 15),
        ),
      ),
    );
  }

  String _getInitial(UserModel user) {
    final trimmed = user.fullName.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }
}

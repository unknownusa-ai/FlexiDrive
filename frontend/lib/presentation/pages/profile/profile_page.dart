import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flexidrive/presentation/pages/main_page.dart';
import 'package:flexidrive/core/theme/flexi_drive_app.dart';
import 'package:flexidrive/services/accounts/local_account_repository.dart';
import 'package:flexidrive/services/accounts/user_preference_service.dart';
import 'edit_profile_page.dart';
import '../login/login_page.dart';
import 'security_page.dart';
import 'payment_methods_page.dart';
import 'my_reviews_page.dart';
import 'help_center_page.dart';
import 'arrendatario_main_page.dart';
import '../../../core/utils/responsive_utils.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final LocalAccountRepository _accountRepository = LocalAccountRepository();
  final UserPreferenceService _preferenceService = UserPreferenceService();
  bool _isModoArrendatarioActive = false;
  int? _currentUserId;
  String _profileName = 'Invitado';
  String _profileEmail = 'sin_sesion@flexidrive.local';

  @override
  void initState() {
    super.initState();
    _cargarUsuarioPerfil();
  }

  Future<void> _cargarUsuarioPerfil() async {
    final currentUser = await _accountRepository.getCurrentUser();
    if (!mounted || currentUser == null) return;

    _currentUserId = currentUser.id;
    final userPreference =
        await _preferenceService.findEffectiveByUserId(currentUser.id);
    final isArrendatarioActive = await _preferenceService.getArrendatarioMode(
      userId: currentUser.id,
      defaultValue: false,
    );

    setState(() {
      _profileName = currentUser.fullName;
      _profileEmail = currentUser.email;
      _isModoArrendatarioActive = isArrendatarioActive;
    });

    if (userPreference != null) {
      final appState = FlexiDriveApp.of(context);
      appState?.setDarkMode(userPreference.darkMode);
    }
  }

  Future<void> _persistDarkModePreference(bool isDarkMode) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _preferenceService.setDarkMode(
      userId: userId,
      darkMode: isDarkMode,
    );
  }

  Future<void> _persistArrendatarioMode(bool enabled) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _preferenceService.setArrendatarioMode(
      userId: userId,
      enabled: enabled,
    );

    if (!mounted) return;
    setState(() {
      _isModoArrendatarioActive = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ConstrainedContainer(
          maxWidth: 800,
          child: Column(
            children: [
              _buildHeaderWithStats(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                      isSmallPhone ? 12 : 16, 8, isSmallPhone ? 12 : 16, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPreferencesSection(),
                      SizedBox(height: isSmallPhone ? 6 : 8),
                      _buildAccountSection(),
                      SizedBox(height: isSmallPhone ? 6 : 8),
                      _buildModoSection(),
                      SizedBox(height: isSmallPhone ? 6 : 8),
                      _buildActivitySection(),
                      SizedBox(height: isSmallPhone ? 6 : 8),
                      _buildLogoutButton(),
                      const SizedBox(height: 4),
                      _buildVersionInfo(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderWithStats() {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(isSmallPhone ? 12 : 20, 8,
                  isSmallPhone ? 12 : 20, isSmallPhone ? 10 : 14),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mi Perfil',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: isSmallPhone ? 18 : 22,
                              fontWeight: FontWeight.bold)),
                      Container(
                        width: isSmallPhone ? 32 : 40,
                        height: isSmallPhone ? 32 : 40,
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle),
                        child: Icon(Icons.nights_stay_outlined,
                            color: const Color(0xFF2563EB),
                            size: isSmallPhone ? 16 : 20),
                      ),
                    ]),
                const SizedBox(height: 8),
                Row(children: [
                  CircleAvatar(
                    radius: isSmallPhone ? 24 : 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        color: const Color(0xFF2563EB),
                        size: isSmallPhone ? 26 : 32),
                  ),
                  SizedBox(width: isSmallPhone ? 10 : 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(_profileName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.inter(
                                fontSize: isSmallPhone ? 14 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text(_profileEmail,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.inter(
                                fontSize: isSmallPhone ? 10 : 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.8))),
                        const SizedBox(height: 2),
                        Row(children: [
                          const Icon(Icons.star,
                              color: Color(0xFFFBBF24), size: 12),
                          const SizedBox(width: 2),
                          Text('4.9',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallPhone ? 11 : 13,
                                  color: Colors.white)),
                          SizedBox(width: isSmallPhone ? 6 : 10),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: isSmallPhone ? 5 : 7, vertical: 1),
                            decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(12)),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.check,
                                  color: Colors.white, size: 8),
                              const SizedBox(width: 2),
                              Text('Verificado',
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: isSmallPhone ? 9 : 10,
                                      fontWeight: FontWeight.bold)),
                            ]),
                          ),
                        ]),
                      ])),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: _buildStatCard(
                          icon: Icons.directions_car_outlined,
                          value: '2',
                          label: isSmallPhone ? 'Viajes' : 'Viajes')),
                  SizedBox(width: isSmallPhone ? 6 : 10),
                  Expanded(
                      child: _buildStatCard(
                          icon: Icons.account_balance_wallet_outlined,
                          value: isSmallPhone ? '\$1.3M' : '\$1.3M',
                          label: isSmallPhone ? 'Gasto' : 'Gastado')),
                  SizedBox(width: isSmallPhone ? 6 : 10),
                  Expanded(
                      child: _buildStatCard(
                          icon: Icons.star_outline,
                          value: '1,240',
                          label: isSmallPhone ? 'Pts' : 'Puntos')),
                ]),
              ]),
            ),
          ),
        ),
        // Decorative bubble in top-right corner
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      {required IconData icon, required String value, required String label}) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: isSmallPhone ? 6 : 10, horizontal: isSmallPhone ? 4 : 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        Container(
            width: isSmallPhone ? 28 : 34,
            height: isSmallPhone ? 28 : 34,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle),
            child:
                Icon(icon, color: Colors.white, size: isSmallPhone ? 14 : 17)),
        SizedBox(height: isSmallPhone ? 4 : 7),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: isSmallPhone ? 12 : 15,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: isSmallPhone ? 9 : 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9))),
      ]),
    );
  }

  Widget _buildModoSection() {
    final theme = Theme.of(context);
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
                child: Text('MODO',
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                        letterSpacing: 0.5))),
            InkWell(
              onTap: () {
                _showModoArrendatarioDialog(context);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallPhone ? 10 : 14,
                    vertical: isSmallPhone ? 10 : 12),
                child: Row(
                  children: [
                    Container(
                        width: isSmallPhone ? 32 : 36,
                        height: isSmallPhone ? 32 : 36,
                        decoration: BoxDecoration(
                            color: _isModoArrendatarioActive
                                ? const Color(0xFFFFF4E6)
                                : const Color(0xFFFFF4E6),
                            borderRadius: BorderRadius.circular(9)),
                        child: Icon(
                            _isModoArrendatarioActive
                                ? Icons.home
                                : Icons.home_outlined,
                            color: const Color(0xFFEF4444),
                            size: isSmallPhone ? 16 : 18)),
                    SizedBox(width: isSmallPhone ? 8 : 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                              _isModoArrendatarioActive
                                  ? 'Cambiar a modo arrendatario'
                                  : 'Activar modo arrendatario',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.poppins(
                                  fontSize: isSmallPhone ? 12 : 13,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface)),
                          Text(
                              _isModoArrendatarioActive
                                  ? '✓ Verificado - Gestiona tus vehículos'
                                  : 'Renta tu vehículo y gana dinero',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.poppins(
                                  fontSize: isSmallPhone ? 9 : 11,
                                  color: _isModoArrendatarioActive
                                      ? const Color(0xFF10B981)
                                      : theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6))),
                        ])),
                    _isModoArrendatarioActive
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Color(0xFF10B981),
                              size: 16,
                            ),
                          )
                        : const Text('🚗', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        size: isSmallPhone ? 16 : 18),
                  ],
                ),
              ),
            ),
          ]),
    );
  }

  Widget _buildAccountSection() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
                child: Text('MI CUENTA',
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                        letterSpacing: 0.5))),
            _buildMenuItem(
                icon: Icons.person_outline,
                iconColor: const Color(0xFF2563EB),
                iconBgColor: const Color(0xFFF0F4FF),
                title: 'Editar perfil',
                subtitle: 'Nombre, foto, documento',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditProfilePage()),
                  );
                }),
            Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: Theme.of(context).dividerTheme.color),
            _buildMenuItem(
                icon: Icons.credit_card_outlined,
                iconColor: const Color(0xFF8B5CF6),
                iconBgColor: const Color(0xFFF3E8FF),
                title: 'Métodos de pago',
                subtitle: 'Tarjetas y PSE guardadas',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaymentMethodsPage()),
                  );
                }),
            Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: Theme.of(context).dividerTheme.color),
            _buildMenuItem(
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFF10B981),
                iconBgColor: const Color(0xFFD1FAE5),
                title: 'Seguridad',
                subtitle: 'Contraseña y verificación',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SecurityPage()),
                  );
                }),
          ]),
    );
  }

  Widget _buildActivitySection() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
                child: Text('ACTIVIDAD & SOPORTE',
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                        letterSpacing: 0.5))),
            _buildMenuItem(
                icon: Icons.history,
                iconColor: const Color(0xFFEF4444),
                iconBgColor: const Color(0xFFFFF4E6),
                title: 'Historial',
                subtitle: '4 reservas totales',
                onTap: () => MainPage.of(context).setIndex(1)),
            Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: Theme.of(context).dividerTheme.color),
            _buildMenuItem(
                icon: Icons.notifications_outlined,
                iconColor: const Color(0xFFEF4444),
                iconBgColor: const Color(0xFFFEE2E2),
                title: 'Notificaciones',
                subtitle: 'Gestionar alertas',
                onTap: () => MainPage.of(context).setIndex(2)),
            Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: Theme.of(context).dividerTheme.color),
            _buildMenuItem(
                icon: Icons.star_border,
                iconColor: const Color(0xFFFBBF24),
                iconBgColor: const Color(0xFFFEF3C7),
                title: 'Mis reseñas',
                subtitle: '3 reseñas escritas',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyReviewsPage()),
                  );
                }),
            Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: Theme.of(context).dividerTheme.color),
            _buildMenuItem(
                icon: Icons.headset_outlined,
                iconColor: const Color(0xFF3B82F6),
                iconBgColor: const Color(0xFFDBEAFE),
                title: 'Centro de ayuda',
                subtitle: 'Chat en vivo 24/7',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HelpCenterPage()),
                  );
                }),
          ]),
    );
  }

  Widget _buildPreferencesSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
                child: Text('PREFERENCIAS',
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                        letterSpacing: 0.5))),
            _buildThemeToggleItem(isDarkMode, isSmallPhone),
          ]),
    );
  }

  Widget _buildThemeToggleItem(bool isDarkMode, bool isSmallPhone) {
    return InkWell(
      onTap: () {
        final appState = FlexiDriveApp.of(context);
        appState?.toggleTheme();
        _persistDarkModePreference(!isDarkMode);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isSmallPhone ? 10 : 14, vertical: isSmallPhone ? 4 : 6),
        child: Row(children: [
          Container(
              width: isSmallPhone ? 32 : 36,
              height: isSmallPhone ? 32 : 36,
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(Icons.wb_sunny_outlined,
                  color: const Color(0xFFEF4444),
                  size: isSmallPhone ? 16 : 18)),
          SizedBox(width: isSmallPhone ? 8 : 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Modo Oscuro',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                        fontSize: isSmallPhone ? 12 : 13,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                Text(isDarkMode ? 'Activado' : 'Desactivado',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                        fontSize: isSmallPhone ? 9 : 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6))),
              ])),
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              final appState = FlexiDriveApp.of(context);
              appState?.setDarkMode(value);
              _persistDarkModePreference(value);
            },
            activeThumbColor: const Color(0xFFEF4444),
          ),
        ]),
      ),
    );
  }

  Widget _buildMenuItem(
      {required IconData icon,
      required Color iconColor,
      required Color iconBgColor,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isSmallPhone ? 10 : 14, vertical: isSmallPhone ? 4 : 6),
        child: Row(children: [
          Container(
              width: isSmallPhone ? 32 : 36,
              height: isSmallPhone ? 32 : 36,
              decoration: BoxDecoration(
                  color: iconBgColor, borderRadius: BorderRadius.circular(9)),
              child:
                  Icon(icon, color: iconColor, size: isSmallPhone ? 16 : 18)),
          SizedBox(width: isSmallPhone ? 8 : 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                        fontSize: isSmallPhone ? 12 : 13,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface)),
                Text(subtitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                        fontSize: isSmallPhone ? 9 : 11,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6))),
              ])),
          Icon(Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: isSmallPhone ? 16 : 18),
        ]),
      ),
    );
  }

  Widget _buildLogoutButton() {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);

    return GestureDetector(
      onTap: () async {
        await _accountRepository.logout();
        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmallPhone ? 8 : 11),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.logout,
              color: const Color(0xFFEF4444), size: isSmallPhone ? 16 : 18),
          SizedBox(width: isSmallPhone ? 6 : 8),
          Text('Cerrar Sesión',
              style: GoogleFonts.poppins(
                  color: const Color(0xFFEF4444),
                  fontSize: isSmallPhone ? 12 : 14,
                  fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('FlexiDrive v2.1.0 · Colombia',
          style:
              GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400)),
      const SizedBox(width: 4),
      const Text('🇨🇴', style: TextStyle(fontSize: 11)),
    ]);
  }

  void _showModoArrendatarioDialog(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: isSmallPhone ? 280 : 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).cardTheme.color,
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallPhone ? 20 : 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono naranja
                  Container(
                    width: isSmallPhone ? 56 : 64,
                    height: isSmallPhone ? 56 : 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.home,
                      color: Colors.white,
                      size: isSmallPhone ? 28 : 32,
                    ),
                  ),
                  SizedBox(height: isSmallPhone ? 16 : 20),
                  // Título
                  Text(
                    'Cambiar a Modo Arrendatario',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: isSmallPhone ? 10 : 12),
                  // Descripción
                  Text(
                    'Activarás tu perfil de arrendatario para gestionar tus vehículos publicados y solicitudes de renta. Podrás volver al modo arrendador cuando quieras.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 12 : 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: isSmallPhone ? 16 : 20),
                  // Lista de características con container
                  Container(
                    padding: EdgeInsets.all(isSmallPhone ? 14 : 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildFeatureItem(
                          Icons.time_to_leave,
                          'Gestiona tus vehículos publicados',
                          isSmallPhone,
                        ),
                        SizedBox(height: isSmallPhone ? 10 : 12),
                        _buildFeatureItem(
                          Icons.insert_drive_file_outlined,
                          'Revisa solicitudes de renta',
                          isSmallPhone,
                        ),
                        SizedBox(height: isSmallPhone ? 10 : 12),
                        _buildFeatureItem(
                          Icons.account_balance_wallet,
                          'Consulta tus ganancias',
                          isSmallPhone,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallPhone ? 24 : 28),
                  // Botón principal
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _persistArrendatarioMode(true);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ArrendatarioMainPage(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallPhone ? 13 : 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Sí, cambiar ahora',
                          style: GoogleFonts.inter(
                            fontSize: isSmallPhone ? 14 : 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Botón secundario
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallPhone ? 13 : 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.05),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.inter(
                          fontSize: isSmallPhone ? 14 : 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, bool isSmallPhone) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFF59E0B),
          size: isSmallPhone ? 18 : 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF59E0B),
            ),
          ),
        ),
      ],
    );
  }
}

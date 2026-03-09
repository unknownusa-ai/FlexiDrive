import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flexidrive/presentation/pages/main_page.dart';
import 'package:flexidrive/core/theme/flexi_drive_app.dart';
import 'arrendatario_main_page.dart';
import 'edit_profile_page.dart';
import 'security_page.dart';
import 'payment_methods_page.dart';
import 'my_reviews_page.dart';
import 'help_center_page.dart';
import 'principal_arrendatario_page.dart';
import 'mi_saldo_page.dart';
import 'alertas_page.dart';
import '../../../core/utils/responsive_utils.dart';

class ProfileArrendatarioPage extends StatefulWidget {
  const ProfileArrendatarioPage({super.key});

  @override
  State<ProfileArrendatarioPage> createState() => _ProfileArrendatarioPageState();
}

class _ProfileArrendatarioPageState extends State<ProfileArrendatarioPage> {
  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
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
                        _buildModoArrendatarioSection(),
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
              colors: [Color(0xFFF59E0B), Color(0xFFFF7A00)],
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
                            color: const Color(0xFFF59E0B),
                            size: isSmallPhone ? 16 : 20),
                      ),
                    ]),
                const SizedBox(height: 8),
                Row(children: [
                  CircleAvatar(
                    radius: isSmallPhone ? 24 : 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        color: const Color(0xFFF59E0B),
                        size: isSmallPhone ? 26 : 32),
                  ),
                  SizedBox(width: isSmallPhone ? 10 : 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('Carlos Rodríguez',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.inter(
                                fontSize: isSmallPhone ? 14 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text('carlos.rodriguez@email.com',
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
                          label: isSmallPhone ? 'Vehic' : 'Vehículos')),
                  SizedBox(width: isSmallPhone ? 6 : 10),
                  Expanded(
                      child: _buildStatCard(
                          icon: Icons.account_balance_wallet_outlined,
                          value: isSmallPhone ? '\$1.4M' : '\$1.44M',
                          label: isSmallPhone ? 'Gananc' : 'Ganancias')),
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

  Widget _buildModoArrendatarioSection() {
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
                child: Text('MODO ARRENDATARIO (ACTIVO)',
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                        letterSpacing: 0.5))),
            // Cambiar a modo arrendador
            _buildMenuItem(
                icon: Icons.swap_horiz,
                iconColor: const Color(0xFF3B82F6),
                iconBgColor: const Color(0xFFDBEAFE),
                title: 'Cambiar a modo arrendador',
                subtitle: 'Volver a buscar vehículos para rentar',
                onTap: () {
                  _showSwitchToArrendadorDialog(context);
                }),
            Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: Theme.of(context).dividerTheme.color),
            // Gestionar modo arrendatario
            _buildMenuItemWithCheck(
                icon: Icons.home_outlined,
                iconColor: const Color(0xFFF59E0B),
                iconBgColor: const Color(0xFFFFF4E6),
                title: 'Gestionar modo arrendatario',
                subtitle: '✓ Verificado y activo',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrincipalArrendatarioPage()),
                  );
                }),
            Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: Theme.of(context).dividerTheme.color),
            // Mi saldo
            _buildMenuItem(
                icon: Icons.account_balance_wallet,
                iconColor: const Color(0xFF10B981),
                iconBgColor: const Color(0xFFD1FAE5),
                title: 'Mi saldo',
                subtitle: '\$ 1.440.000 disponible',
                trailingIcon: Icons.lock,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MiSaldoPage()),
                  );
                }),
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
                icon: Icons.description_outlined,
                iconColor: const Color(0xFFF59E0B),
                iconBgColor: const Color(0xFFFFF4E6),
                title: 'Historial',
                subtitle: '4 reservas totales',
                onTap: () => ArrendatarioMainPage.of(context).setHistorialTab(2)),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AlertasPage(),
                    ),
                  );
                }),
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
                  color: const Color(0xFFF59E0B),
                  size: isSmallPhone ? 16 : 18)),
          SizedBox(width: isSmallPhone ? 8 : 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Modo Claro',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                        fontSize: isSmallPhone ? 12 : 13,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                Text('Cambiar apariencia',
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
            value: !isDarkMode,
            onChanged: (value) {
              final appState = FlexiDriveApp.of(context);
              appState?.setDarkMode(!value);
            },
            activeThumbColor: const Color(0xFFF59E0B),
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
      IconData? trailingIcon,
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
          if (trailingIcon != null)
            Icon(trailingIcon,
                color: const Color(0xFFF59E0B),
                size: isSmallPhone ? 14 : 16),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: isSmallPhone ? 16 : 18),
        ]),
      ),
    );
  }

  Widget _buildMenuItemWithCheck(
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
                        color: const Color(0xFF10B981))),
              ])),
          Icon(Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: isSmallPhone ? 16 : 18),
        ]),
      ),
    );
  }

  void _showSwitchToArrendadorDialog(BuildContext context) {
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
                  // Icono azul con símbolo de sync
                  Container(
                    width: isSmallPhone ? 56 : 64,
                    height: isSmallPhone ? 56 : 64,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sync,
                      color: Colors.white,
                      size: isSmallPhone ? 28 : 32,
                    ),
                  ),
                  SizedBox(height: isSmallPhone ? 16 : 20),
                  // Título
                  Text(
                    'Cambiar a Modo Arrendador',
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
                    'Volverás a modo cliente para buscar y rentar vehículos. Tus publicaciones seguirán activas.',
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
                  // Botón principal azul
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainPage(initialIndex: 3),
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
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallPhone ? 12 : 16),
                  // Botón cancelar
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallPhone ? 12 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.inter(
                          fontSize: isSmallPhone ? 14 : 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildLogoutButton() {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);

    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
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
}

class ConstrainedContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ConstrainedContainer({
    super.key,
    required this.child,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

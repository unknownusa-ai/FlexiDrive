// Flutter framework
import 'package:flutter/material.dart';
// Fuentes bonitas de Google
import 'package:google_fonts/google_fonts.dart';
import 'package:flexidrive/features/accounts/application/use_cases/account_access_use_case.dart';
import 'package:flexidrive/features/accounts/application/use_cases/user_preferences_use_case.dart';
import 'package:flexidrive/features/notifications/application/use_cases/notification_access_use_case.dart';
// Paginas del arrendador
import 'principal_arrendatario_page.dart'; // Dashboard principal
import 'profile_arrendatario_page.dart'; // Perfil del arrendador
import 'solicitudes_page.dart'; // Solicitudes de renta
import 'publicar_vehiculo_page.dart'; // Publicar nuevo carro
import 'alertas_page.dart'; // Notificaciones y alertas
import 'package:flexidrive/injection_container.dart';
// Utilidades responsive
import 'package:flexidrive/core/utils/responsive_utils.dart';

// Pagina principal del arrendador (dueño de carros)
// Es el menu con navegacion inferior para gestionar sus carros
class ArrendatarioMainPage extends StatefulWidget {
  // Indice inicial de la pagina a mostrar
  final int initialIndex;

  const ArrendatarioMainPage({super.key, this.initialIndex = 0});

  // Metodo estatico para acceder al estado desde cualquier widget hijo
  static ArrendatarioMainPageState of(BuildContext context) {
    final state = context.findAncestorStateOfType<ArrendatarioMainPageState>();
    assert(state != null, 'No ArrendatarioMainPage found in context');
    return state!;
  }

  /// Gestiona crear estado dentro de esta parte del flujo.
  @override
  State<ArrendatarioMainPage> createState() => ArrendatarioMainPageState();
}

// Estado de la pagina principal del arrendador
class ArrendatarioMainPageState extends State<ArrendatarioMainPage> {
  static const Color _brandPrimary = Color(0xFF4F46E5);
  static const Color _brandSecondary = Color(0xFF7C3AED);
  final AccountAccessUseCase _accountRepository =
      InjectionContainer.instance.accountAccessUseCase;
  final UserPreferencesUseCase _preferenceService =
      InjectionContainer.instance.userPreferencesUseCase;
  final NotificationAccessUseCase _notificationDb =
      InjectionContainer.instance.notificationAccessUseCase;

  late int _selectedIndex; // Tab seleccionada actualmente
  late PageController _pageController; // Controlador del PageView
  int _historialTabIndex = 0; // Tab del historial (activas/completadas)
  int _dashboardRefreshToken = 0;
  bool _hasUnreadAlerts = false;

  // Lista de paginas disponibles en el menu inferior
  List<Widget> get _pages => [
        PrincipalArrendatarioPage(
          refreshToken: _dashboardRefreshToken,
          onOpenRequests: () => setHistorialTab(0),
        ),
        SolicitudesPage(
          key: ValueKey<int>(_historialTabIndex),
          initialTab: _historialTabIndex,
        ),
        const AlertasPage(),
        const ProfileArrendatarioPage(),
      ];

  /// Inicializa el proceso de inicialización del estado antes de su uso.
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, _pages.length - 1);
    _pageController = PageController(initialPage: _selectedIndex);
    _markArrendatarioModeAsActive();
    _notificationDb.changes.addListener(_onNotificationsChanged);
    _loadUnreadAlerts();
  }

  /// Gestiona dispose dentro de esta parte del flujo.
  @override
  void dispose() {
    _notificationDb.changes.removeListener(_onNotificationsChanged);
    _pageController.dispose();
    super.dispose();
  }

  /// Actualiza el estado relacionado con definir index.
  void setIndex(int index) {
    if (index >= 0 && index < _pages.length) {
      // Restablecer historialTabIndex a 0 (Pendientes) cuando se navega desde la tabbar
      if (index == 1 && _historialTabIndex != 0) {
        setState(() {
          _historialTabIndex = 0;
          _selectedIndex = index;
        });
      } else {
        setState(() {
          _selectedIndex = index;
        });
      }
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Actualiza el estado relacionado con definir historial tab.
  void setHistorialTab(int tabIndex) {
    setState(() {
      _historialTabIndex = tabIndex;
      _selectedIndex = 1;
    });
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Marca el modo arrendatario como activo para el usuario.
  Future<void> _markArrendatarioModeAsActive() async {
    final currentUser = await _accountRepository.getCurrentUser();
    if (currentUser == null) return;
    await _preferenceService.setArrendatarioMode(
      userId: currentUser.id,
      enabled: true,
    );
  }

  /// Gestiona on notificaciones changed dentro de esta parte del flujo.
  void _onNotificationsChanged() {
    _loadUnreadAlerts();
  }

  /// Carga los datos necesarios para cargar unread alerts.
  Future<void> _loadUnreadAlerts() async {
    await _notificationDb.loadIfNeeded();
    final currentUser = await _accountRepository.getCurrentUser();
    if (!mounted) return;

    if (currentUser == null) {
      setState(() {
        _hasUnreadAlerts = false;
      });
      return;
    }

    final unreadCount = _notificationDb.notifications
        .where(
          (notification) =>
              notification.userId == currentUser.id &&
              notification.status == 'no_leida',
        )
        .length;

    setState(() {
      _hasUnreadAlerts = unreadCount > 0;
    });
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildBottomNavBar() {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
            top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isSmallPhone ? 10 : 14,
            8,
            isSmallPhone ? 10 : 14,
            8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _buildNavItem(
                  icon: Icons.home_outlined,
                  label: 'Mis vehículos',
                  index: 0,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.description_outlined,
                  label: 'Solicitudes',
                  index: 1,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final didPublish = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PublicarVehiculoPage(),
                    ),
                  );
                  if (didPublish == true) {
                    setState(() {
                      _dashboardRefreshToken++;
                      _selectedIndex = 0;
                    });
                    _pageController.jumpToPage(0);
                  }
                },
                child: Container(
                  width: isSmallPhone ? 68 : 74,
                  height: isSmallPhone ? 58 : 62,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_brandPrimary, _brandSecondary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _brandPrimary.withValues(alpha: 0.32),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 36),
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.notifications_none,
                  label: 'Alertas',
                  index: 2,
                  dot: _hasUnreadAlerts,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.person_outline,
                  label: 'Perfil',
                  index: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool dot = false,
  }) {
    final isSelected = _selectedIndex == index && index >= 0;
    final theme = Theme.of(context);
    final activeColor = _brandPrimary;
    final inactiveColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: () => setIndex(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? activeColor : inactiveColor,
                    size: 24,
                  ),
                  if (dot && !isSelected)
                    const Positioned(
                      right: -2,
                      top: -1,
                      child: CircleAvatar(
                        radius: 3,
                        backgroundColor: Color(0xFFEF4444),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.fade,
            ),
          ],
        ),
      ),
    );
  }
}

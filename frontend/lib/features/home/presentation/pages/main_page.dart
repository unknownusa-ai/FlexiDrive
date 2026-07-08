// Página principal de la aplicación
// Contiene la navegación inferior entre las secciones principales
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flexidrive/features/accounts/application/use_cases/account_access_use_case.dart';
import 'package:flexidrive/features/notifications/application/use_cases/notification_access_use_case.dart';
import 'home/home_page.dart';
import 'package:flexidrive/features/reservations/presentation/pages/reservas/reservas_page.dart';
import 'package:flexidrive/features/notifications/presentation/pages/notifications/notifications_page.dart';
import 'package:flexidrive/features/profile/presentation/pages/profile/profile_page.dart';
import 'package:flexidrive/injection_container.dart';

// Widget principal que maneja la navegación por tabs
// Proporciona acceso a las 4 secciones principales de la app
class MainPage extends StatefulWidget {
  // Constructor con índice inicial opcional
  const MainPage({super.key, this.initialIndex = 0});

  // Índice de la página a mostrar al iniciar
  final int initialIndex;

  // Método estático para acceder al estado desde cualquier widget
  static MainPageState of(BuildContext context) {
    final state = context.findAncestorStateOfType<MainPageState>();
    assert(state != null, 'No MainPage found in context');
    return state!;
  }

  /// Gestiona crear estado dentro de esta parte del flujo.
  @override
  State<MainPage> createState() => MainPageState();
}

/// Define la responsabilidad de `MainPageState` dentro de este módulo.
class MainPageState extends State<MainPage> {
  late int _selectedIndex;
  final NotificationAccessUseCase _notificationDb =
      InjectionContainer.instance.notificationAccessUseCase;
  final AccountAccessUseCase _accountRepository =
      InjectionContainer.instance.accountAccessUseCase;
  bool _hasUnreadNotifications = false;

  final List<Widget> _pages = const [
    HomePage(),
    ReservasPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  /// Inicializa el proceso de inicialización del estado antes de su uso.
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, _pages.length - 1);
    _notificationDb.changes.addListener(_onNotificationsChanged);
    _loadUnreadNotifications();
  }

  /// Gestiona dispose dentro de esta parte del flujo.
  @override
  void dispose() {
    _notificationDb.changes.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  /// Gestiona on notificaciones changed dentro de esta parte del flujo.
  void _onNotificationsChanged() {
    _loadUnreadNotifications();
  }

  /// Carga los datos necesarios para cargar unread notificaciones.
  Future<void> _loadUnreadNotifications() async {
    await _notificationDb.loadIfNeeded();
    final currentUser = await _accountRepository.getCurrentUser();
    if (!mounted) return;

    if (currentUser == null) {
      setState(() {
        _hasUnreadNotifications = false;
      });
      return;
    }

    final hasUnread = _notificationDb.notifications.any(
      (notification) =>
          notification.userId == currentUser.id &&
          notification.status == 'no_leida',
    );

    setState(() {
      _hasUnreadNotifications = hasUnread;
    });
  }

  /// Actualiza el estado relacionado con definir index.
  void setIndex(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildBottomNavBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Explorar', 0),
              _buildNavItem(Icons.description_outlined, 'Reservas', 1),
              _buildNavItem(
                Icons.notifications_outlined,
                'Alertas',
                2,
                showBadge: _hasUnreadNotifications,
              ),
              _buildNavItem(Icons.person_outline, 'Perfil', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index, {
    bool showBadge = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedIndex == index;

    final selectedColor = const Color(0xFF2563EB);
    final unselectedColor = isDark
        ? const Color(0xFF8B93B8) // dark text secondary
        : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => setIndex(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? selectedColor.withValues(alpha: isDark ? 0.2 : 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? selectedColor : unselectedColor,
                  size: 24,
                ),
                if (showBadge)
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? selectedColor : unselectedColor,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

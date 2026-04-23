import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'principal_arrendatario_page.dart';
import 'profile_arrendatario_page.dart';
import 'solicitudes_page.dart';
import 'publicar_vehiculo_page.dart';
import 'alertas_page.dart';
import '../../../core/utils/responsive_utils.dart';

class ArrendatarioMainPage extends StatefulWidget {
  final int initialIndex;

  const ArrendatarioMainPage({super.key, this.initialIndex = 0});

  static ArrendatarioMainPageState of(BuildContext context) {
    final state = context.findAncestorStateOfType<ArrendatarioMainPageState>();
    assert(state != null, 'No ArrendatarioMainPage found in context');
    return state!;
  }

  @override
  State<ArrendatarioMainPage> createState() => ArrendatarioMainPageState();
}

class ArrendatarioMainPageState extends State<ArrendatarioMainPage> {
  late int _selectedIndex;
  late PageController _pageController;
  int _historialTabIndex = 0;

  List<Widget> get _pages => [
        const PrincipalArrendatarioPage(),
        SolicitudesPage(
          key: ValueKey<int>(_historialTabIndex),
          initialTab: _historialTabIndex,
        ),
        const AlertasPage(),
        const ProfileArrendatarioPage(),
      ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, _pages.length - 1);
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                label: 'Inicio',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.description_outlined,
                label: 'Solicitudes',
                index: 1,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PublicarVehiculoPage(),
                    ),
                  );
                },
                child: Container(
                  width: 74,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 36),
                ),
              ),
              _buildNavItem(
                icon: Icons.notifications_none,
                label: 'Alertas',
                index: 2,
                dot: true,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                label: 'Perfil',
                index: 3,
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
    final activeColor = const Color(0xFFF59E0B);
    final inactiveColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: () => setIndex(index),
      child: Container(
        width: 70,
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
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

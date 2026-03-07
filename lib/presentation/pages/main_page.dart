import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home/home_page.dart';
import 'reservas/reservas_page.dart';
import 'notifications/notifications_page.dart';
import 'profile/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  static _MainPageState of(BuildContext context) {
    final state = context.findAncestorStateOfType<_MainPageState>();
    assert(state != null, 'No MainPage found in context');
    return state!;
  }

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ReservasPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  void setIndex(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

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

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              _buildNavItem(Icons.home_outlined, 'Inicio', 0),
              _buildNavItem(Icons.description_outlined, 'Reservas', 1),
              _buildNavItem(Icons.notifications_outlined, 'Alertas', 2),
              _buildNavItem(Icons.person_outline, 'Perfil', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setIndex(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF5B6FED).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFF5B6FED) : Colors.grey.shade400,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? const Color(0xFF5B6FED) : Colors.grey.shade400,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

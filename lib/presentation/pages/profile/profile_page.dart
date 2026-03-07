import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flexidrive/presentation/pages/main_page.dart';
import '../../../core/utils/responsive_utils.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: ConstrainedContainer(
        maxWidth: 800,
        child: Column(
          children: [
            _buildHeaderWithStats(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(children: [
                  _buildDarkModeToggle(),
                  const SizedBox(height: 8),
                  _buildAccountSection(),
                  const SizedBox(height: 8),
                  _buildActivitySection(),
                  const SizedBox(height: 8),
                  _buildLogoutButton(),
                  const SizedBox(height: 4),
                  _buildVersionInfo(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWithStats() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF5B6FED), Color(0xFF6B5BCD)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Mi Perfil',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.nights_stay_outlined, color: Colors.white, size: 20),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: const Icon(Icons.person, color: Color(0xFF5B6FED), size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Carlos Rodríguez',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('carlos.rodriguez@email.com',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star, color: Color(0xFFFBBF24), size: 13),
                  const SizedBox(width: 3),
                  Text('4.9',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check, color: Colors.white, size: 9),
                      const SizedBox(width: 2),
                      Text('Verificado',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ]),
              ])),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _buildStatCard(icon: Icons.directions_car_outlined, value: '2', label: 'Viajes')),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard(icon: Icons.account_balance_wallet_outlined, value: '\$1.3M', label: 'Gastado')),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard(icon: Icons.star_outline, value: '1,240', label: 'Puntos')),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(children: [
        Container(width: 34, height: 34,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 17)),
        const SizedBox(height: 7),
        Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.9))),
      ]),
    );
  }

  Widget _buildDarkModeToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFFFFF4E6), borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.wb_sunny_outlined, color: Color(0xFFF59E0B), size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Modo Claro',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A))),
          Text('Cambiar apariencia de la app',
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
        ])),
        Transform.scale(scale: 0.8, child: CupertinoSwitch(
          value: _isDarkMode,
          onChanged: (v) => setState(() => _isDarkMode = v),
          activeColor: const Color(0xFF5B6FED),
          trackColor: Colors.grey.shade300,
        )),
      ]),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
            child: Text('MI CUENTA', style: GoogleFonts.poppins(
                fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade400, letterSpacing: 0.5))),
        _buildMenuItem(icon: Icons.person_outline, iconColor: const Color(0xFF5B6FED),
            iconBgColor: const Color(0xFFF0F4FF), title: 'Editar perfil', subtitle: 'Nombre, foto, documento', onTap: () {}),
        Divider(height: 1, indent: 14, endIndent: 14, color: Colors.grey.shade100),
        _buildMenuItem(icon: Icons.credit_card_outlined, iconColor: const Color(0xFF8B5CF6),
            iconBgColor: const Color(0xFFF3E8FF), title: 'Métodos de pago', subtitle: 'Tarjetas y PSE guardadas', onTap: () {}),
        Divider(height: 1, indent: 14, endIndent: 14, color: Colors.grey.shade100),
        _buildMenuItem(icon: Icons.shield_outlined, iconColor: const Color(0xFF10B981),
            iconBgColor: const Color(0xFFD1FAE5), title: 'Seguridad', subtitle: 'Contraseña y verificación', onTap: () {}),
      ]),
    );
  }

  Widget _buildActivitySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
            child: Text('ACTIVIDAD & SOPORTE', style: GoogleFonts.poppins(
                fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade400, letterSpacing: 0.5))),
        _buildMenuItem(icon: Icons.history, iconColor: const Color(0xFFF59E0B), iconBgColor: const Color(0xFFFFF4E6), title: 'Historial', subtitle: '4 reservas totales', onTap: () => MainPage.of(context).setIndex(1)),
        Divider(height: 1, indent: 14, endIndent: 14, color: Colors.grey.shade100),
        _buildMenuItem(icon: Icons.notifications_outlined, iconColor: const Color(0xFFEF4444), iconBgColor: const Color(0xFFFEE2E2), title: 'Notificaciones', subtitle: 'Gestionar alertas', onTap: () => MainPage.of(context).setIndex(2)),
        Divider(height: 1, indent: 14, endIndent: 14, color: Colors.grey.shade100),
        _buildMenuItem(icon: Icons.star_border, iconColor: const Color(0xFFFBBF24),
            iconBgColor: const Color(0xFFFEF3C7), title: 'Mis reseñas', subtitle: '3 reseñas escritas', onTap: () {}),
        Divider(height: 1, indent: 14, endIndent: 14, color: Colors.grey.shade100),
        _buildMenuItem(icon: Icons.headset_outlined, iconColor: const Color(0xFF3B82F6),
            iconBgColor: const Color(0xFFDBEAFE), title: 'Centro de ayuda', subtitle: 'Chat en vivo 24/7', onTap: () {}),
      ]),
    );
  }

  Widget _buildMenuItem({required IconData icon, required Color iconColor, required Color iconBgColor,
      required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(children: [
          Container(width: 36, height: 36,
              decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: iconColor, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A))),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
          ])),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
        ]),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.logout, color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 8),
          Text('Cerrar Sesión',
              style: GoogleFonts.poppins(color: const Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('FlexiDrive v2.1.0 · Colombia',
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400)),
      const SizedBox(width: 4),
      const Text('🇨🇴', style: TextStyle(fontSize: 11)),
    ]);
  }
}
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
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: ConstrainedContainer(
          maxWidth: 800,
          child: Column(
            children: [
              _buildHeaderWithStats(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isSmallPhone ? 12 : 16, 
                    8, 
                    isSmallPhone ? 12 : 16, 
                    0
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDarkModeToggle(),
                      SizedBox(height: isSmallPhone ? 6 : 8),
                      _buildAccountSection(),
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
          padding: EdgeInsets.fromLTRB(
            isSmallPhone ? 12 : 20, 
            8, 
            isSmallPhone ? 12 : 20, 
            isSmallPhone ? 10 : 14
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Mi Perfil',
                  style: GoogleFonts.poppins(
                    color: Colors.white, 
                    fontSize: isSmallPhone ? 18 : 22, 
                    fontWeight: FontWeight.bold
                  )),
              Container(
                width: isSmallPhone ? 32 : 40, 
                height: isSmallPhone ? 32 : 40,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(Icons.nights_stay_outlined, color: Colors.white, size: isSmallPhone ? 16 : 20),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              CircleAvatar(
                radius: isSmallPhone ? 24 : 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: const Color(0xFF5B6FED), size: isSmallPhone ? 26 : 32),
              ),
              SizedBox(width: isSmallPhone ? 10 : 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Carlos Rodríguez',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallPhone ? 14 : 18, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    )),
                Text('carlos.rodriguez@email.com',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallPhone ? 10 : 12, 
                      color: Colors.white.withOpacity(0.8)
                    )),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.star, color: Color(0xFFFBBF24), size: 12),
                  const SizedBox(width: 2),
                  Text('4.9',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, 
                        fontSize: isSmallPhone ? 11 : 13, 
                        color: Colors.white
                      )),
                  SizedBox(width: isSmallPhone ? 6 : 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isSmallPhone ? 5 : 7, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981), 
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check, color: Colors.white, size: 8),
                      const SizedBox(width: 2),
                      Text('Verificado',
                          style: GoogleFonts.poppins(
                            color: Colors.white, 
                            fontSize: isSmallPhone ? 9 : 10, 
                            fontWeight: FontWeight.bold
                          )),
                    ]),
                  ),
                ]),
              ])),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _buildStatCard(
                icon: Icons.directions_car_outlined, 
                value: '2', 
                label: isSmallPhone ? 'Viajes' : 'Viajes'
              )),
              SizedBox(width: isSmallPhone ? 6 : 10),
              Expanded(child: _buildStatCard(
                icon: Icons.account_balance_wallet_outlined, 
                value: isSmallPhone ? '\$1.3M' : '\$1.3M', 
                label: isSmallPhone ? 'Gasto' : 'Gastado'
              )),
              SizedBox(width: isSmallPhone ? 6 : 10),
              Expanded(child: _buildStatCard(
                icon: Icons.star_outline, 
                value: '1,240', 
                label: isSmallPhone ? 'Pts' : 'Puntos'
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String value, required String label}) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: isSmallPhone ? 6 : 10, horizontal: isSmallPhone ? 4 : 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(children: [
        Container(
          width: isSmallPhone ? 28 : 34, 
          height: isSmallPhone ? 28 : 34,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: isSmallPhone ? 14 : 17)
        ),
        SizedBox(height: isSmallPhone ? 4 : 7),
        Text(value, style: GoogleFonts.poppins(
          fontSize: isSmallPhone ? 12 : 15, 
          fontWeight: FontWeight.bold, 
          color: Colors.white
        )),
        Text(label, style: GoogleFonts.poppins(
          fontSize: isSmallPhone ? 9 : 11, 
          fontWeight: FontWeight.w500, 
          color: Colors.white.withOpacity(0.9)
        )),
      ]),
    );
  }

  Widget _buildDarkModeToggle() {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallPhone ? 10 : 14, vertical: isSmallPhone ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: isSmallPhone ? 32 : 36, 
          height: isSmallPhone ? 32 : 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E6), 
            borderRadius: BorderRadius.circular(9)
          ),
          child: Icon(Icons.wb_sunny_outlined, color: const Color(0xFFF59E0B), size: isSmallPhone ? 16 : 18)
        ),
        SizedBox(width: isSmallPhone ? 8 : 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Modo Claro',
              style: GoogleFonts.poppins(
                fontSize: isSmallPhone ? 12 : 14, 
                fontWeight: FontWeight.bold, 
                color: const Color(0xFF1A1A1A)
              )),
          Text('Cambiar apariencia',
              style: GoogleFonts.poppins(
                fontSize: isSmallPhone ? 9 : 11, 
                color: Colors.grey.shade500
              )),
        ])),
        Transform.scale(
          scale: isSmallPhone ? 0.7 : 0.8, 
          child: CupertinoSwitch(
            value: _isDarkMode,
            onChanged: (v) => setState(() => _isDarkMode = v),
            activeColor: const Color(0xFF5B6FED),
            trackColor: Colors.grey.shade300,
          )
        ),
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
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmallPhone ? 10 : 14, vertical: isSmallPhone ? 4 : 6),
        child: Row(children: [
          Container(
            width: isSmallPhone ? 32 : 36, 
            height: isSmallPhone ? 32 : 36,
            decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: iconColor, size: isSmallPhone ? 16 : 18)
          ),
          SizedBox(width: isSmallPhone ? 8 : 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, 
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: isSmallPhone ? 12 : 13, 
                fontWeight: FontWeight.bold, 
                color: const Color(0xFF1A1A1A)
              )),
            Text(subtitle, 
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: isSmallPhone ? 9 : 11, 
                color: Colors.grey.shade500
              )),
          ])),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: isSmallPhone ? 16 : 18),
        ]),
      ),
    );
  }

  Widget _buildLogoutButton() {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    
    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmallPhone ? 8 : 11),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.logout, color: const Color(0xFFEF4444), size: isSmallPhone ? 16 : 18),
          SizedBox(width: isSmallPhone ? 6 : 8),
          Text('Cerrar Sesión',
              style: GoogleFonts.poppins(
                color: const Color(0xFFEF4444), 
                fontSize: isSmallPhone ? 12 : 14, 
                fontWeight: FontWeight.bold
              )),
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
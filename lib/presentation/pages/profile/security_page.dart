import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_utils.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isTwoFactorEnabled = true;
  bool _isBiometricEnabled = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildGradientHeader(isSmallPhone),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallPhone ? 16 : 20,
                vertical: isSmallPhone ? 16 : 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPasswordSection(isSmallPhone),
                  SizedBox(height: isSmallPhone ? 16 : 20),
                  _buildSecurityOptionsSection(isSmallPhone),
                  SizedBox(height: isSmallPhone ? 16 : 20),
                  _buildActiveSessionsSection(isSmallPhone),
                  SizedBox(height: isSmallPhone ? 16 : 20),
                  _buildDeleteAccountButton(isSmallPhone),
                  SizedBox(height: isSmallPhone ? 32 : 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientHeader(bool isSmallPhone) {
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
              padding: EdgeInsets.fromLTRB(
                isSmallPhone ? 16 : 20,
                isSmallPhone ? 8 : 12,
                isSmallPhone ? 16 : 20,
                isSmallPhone ? 16 : 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button and title in same row
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: isSmallPhone ? 36 : 40,
                          height: isSmallPhone ? 36 : 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                            size: isSmallPhone ? 16 : 18,
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallPhone ? 12 : 16),
                      Text(
                        'Seguridad',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isSmallPhone ? 20 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallPhone ? 4 : 6),
                  // Subtitle
                  Text(
                    'Protege tu cuenta FlexiDrive',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: isSmallPhone ? 12 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isSmallPhone ? 16 : 20),
                  // Verified badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallPhone ? 12 : 16,
                      vertical: isSmallPhone ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          color: Colors.white,
                          size: isSmallPhone ? 16 : 18,
                        ),
                        SizedBox(width: isSmallPhone ? 6 : 8),
                        Text(
                          'Cuenta verificada y segura',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: isSmallPhone ? 12 : 14,
                            fontWeight: FontWeight.w500,
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
        // Decorative bubble
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSection(bool isSmallPhone) {
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lock icon and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: isSmallPhone ? 36 : 40,
                height: isSmallPhone ? 36 : 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: const Color(0xFF2563EB),
                  size: isSmallPhone ? 18 : 20,
                ),
              ),
              SizedBox(width: isSmallPhone ? 10 : 12),
              Text(
                'Cambiar Contraseña',
                style: GoogleFonts.inter(
                  fontSize: isSmallPhone ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallPhone ? 16 : 20),
          // Password fields
          _buildPasswordField(
            label: 'CONTRASEÑA ACTUAL',
            controller: _currentPasswordController,
            obscureText: _obscureCurrentPassword,
            onToggle: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
            isSmallPhone: isSmallPhone,
          ),
          SizedBox(height: isSmallPhone ? 12 : 16),
          _buildPasswordField(
            label: 'NUEVA CONTRASEÑA',
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            onToggle: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
            isSmallPhone: isSmallPhone,
          ),
          SizedBox(height: isSmallPhone ? 12 : 16),
          _buildPasswordField(
            label: 'CONFIRMAR NUEVA CONTRASEÑA',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            isSmallPhone: isSmallPhone,
          ),
          SizedBox(height: isSmallPhone ? 16 : 20),
          // Update button
          GestureDetector(
            onTap: () => _showSnackBar('Contraseña actualizada'),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: isSmallPhone ? 14 : 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Actualizar contraseña',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: isSmallPhone ? 14 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    required bool isSmallPhone,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isSmallPhone ? 10 : 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: isSmallPhone ? 6 : 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 14 : 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A1A),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.lock_outline,
                color: Colors.grey.shade400,
                size: isSmallPhone ? 18 : 20,
              ),
              hintText: '••••••••',
              hintStyle: GoogleFonts.inter(
                fontSize: isSmallPhone ? 14 : 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.grey.shade400,
                  size: isSmallPhone ? 18 : 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallPhone ? 12 : 16,
                vertical: isSmallPhone ? 12 : 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityOptionsSection(bool isSmallPhone) {
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildToggleOption(
            icon: Icons.key_outlined,
            iconColor: const Color(0xFF8B5CF6),
            iconBgColor: const Color(0xFFF3E8FF),
            title: 'Verificación en 2 pasos',
            subtitle: 'SMS o app de autenticación',
            value: _isTwoFactorEnabled,
            onChanged: (v) => setState(() => _isTwoFactorEnabled = v),
            isSmallPhone: isSmallPhone,
          ),
          Divider(height: 24, color: Colors.grey.shade100),
          _buildToggleOption(
            icon: Icons.fingerprint_outlined,
            iconColor: const Color(0xFF10B981),
            iconBgColor: const Color(0xFFD1FAE5),
            title: 'Acceso biométrico',
            subtitle: 'Huella dactilar o Face ID',
            value: _isBiometricEnabled,
            onChanged: (v) => setState(() => _isBiometricEnabled = v),
            isSmallPhone: isSmallPhone,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isSmallPhone,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: isSmallPhone ? 36 : 40,
          height: isSmallPhone ? 36 : 40,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: isSmallPhone ? 18 : 20,
          ),
        ),
        SizedBox(width: isSmallPhone ? 10 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: isSmallPhone ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: isSmallPhone ? 11 : 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        Transform.scale(
          scale: isSmallPhone ? 0.8 : 0.9,
          child: CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2563EB),
            trackColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSessionsSection(bool isSmallPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sesiones activas',
          style: GoogleFonts.inter(
            fontSize: isSmallPhone ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: isSmallPhone ? 10 : 12),
        Container(
          padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSessionItem(
                device: 'iPhone 15 Pro',
                location: 'Bogotá, Colombia · Ahora',
                isCurrent: true,
                isSmallPhone: isSmallPhone,
              ),
              Divider(height: 20, color: Colors.grey.shade100),
              _buildSessionItem(
                device: 'Chrome / Mac',
                location: 'Medellín, Colombia · Hace 2h',
                isCurrent: false,
                isSmallPhone: isSmallPhone,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionItem({
    required String device,
    required String location,
    required bool isCurrent,
    required bool isSmallPhone,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          device.contains('iPhone') ? Icons.phone_iphone : Icons.laptop_mac,
          color: Colors.grey.shade600,
          size: isSmallPhone ? 20 : 24,
        ),
        SizedBox(width: isSmallPhone ? 10 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device,
                style: GoogleFonts.inter(
                  fontSize: isSmallPhone ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 2),
              Text(
                location,
                style: GoogleFonts.inter(
                  fontSize: isSmallPhone ? 11 : 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        if (isCurrent)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallPhone ? 8 : 12,
              vertical: isSmallPhone ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'ACTUAL',
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 9 : 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF10B981),
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () => _showSnackBar('Sesión cerrada'),
            child: Text(
              'Cerrar',
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDeleteAccountButton(bool isSmallPhone) {
    return GestureDetector(
      onTap: () => _showDeleteAccountDialog(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmallPhone ? 14 : 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFEF4444).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_outlined,
              color: const Color(0xFFEF4444),
              size: isSmallPhone ? 18 : 20,
            ),
            SizedBox(width: isSmallPhone ? 8 : 10),
            Text(
              'Eliminar cuenta',
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 14 : 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar cuenta',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Cuenta eliminada');
            },
            child: Text(
              'Eliminar',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

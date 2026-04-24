import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flexidrive/core/session/local_session_store.dart';
import 'package:flexidrive/models/security/security_models.dart';
import 'package:flexidrive/services/accounts/local_account_repository.dart';
import 'package:flexidrive/services/security/local_security_db.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/theme/app_themes.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final LocalAccountRepository _accountRepository = LocalAccountRepository();
  final LocalSessionStore _sessionStore = LocalSessionStore.instance;
  final LocalSecurityDb _securityDb = LocalSecurityDb.instance;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isTwoFactorEnabled = false;
  bool _isBiometricEnabled = false;
  bool _isUpdatingPassword = false;
  bool _isLoadingSecurityData = true;
  int? _currentUserId;
  List<UserSessionModel> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSecurityData();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadSecurityData() async {
    await Future.wait([
      _sessionStore.init(),
      _securityDb.loadIfNeeded(),
    ]);

    final currentUserId = _sessionStore.userId;
    _currentUserId = currentUserId;

    UserSecurityModel? userSecurity;
    if (currentUserId != null) {
      for (final item in _securityDb.userSecurities) {
        if (item.userId == currentUserId) {
          userSecurity = item;
          break;
        }
      }
    }

    final sessions = currentUserId == null
        ? <UserSessionModel>[]
        : _securityDb.userSessions
            .where((session) => session.userId == currentUserId)
            .toList();

    sessions.sort((a, b) {
      if (a.active != b.active) {
        return a.active ? -1 : 1;
      }
      return b.startDate.compareTo(a.startDate);
    });

    if (!mounted) return;
    setState(() {
      _isTwoFactorEnabled = userSecurity?.twoFactorVerification ?? false;
      _isBiometricEnabled = userSecurity?.biometricAccess ?? false;
      _sessions = sessions;
      _isLoadingSecurityData = false;
    });
  }

  Future<void> _persistSecuritySettings() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _securityDb.upsertUserSecurity(
        userId: userId,
        twoFactorVerification: _isTwoFactorEnabled,
        biometricAccess: _isBiometricEnabled,
      );
    } catch (_) {
      _showErrorSnackBar(
          'No fue posible guardar la configuración de seguridad');
    }
  }

  Future<void> _updatePassword() async {
    if (_isUpdatingPassword) return;

    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorSnackBar(
          'Completa todos los campos para cambiar la contraseña');
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorSnackBar('La nueva contraseña y su confirmación no coinciden');
      return;
    }

    if (newPassword.length < 8) {
      _showErrorSnackBar(
          'La nueva contraseña debe tener al menos 8 caracteres');
      return;
    }

    setState(() {
      _isUpdatingPassword = true;
    });

    try {
      final currentUser = await _accountRepository.getCurrentUser();
      if (currentUser == null) {
        _showErrorSnackBar('No hay una sesión activa');
        return;
      }

      if (currentUser.password != currentPassword) {
        _showErrorSnackBar('La contraseña actual no es correcta');
        return;
      }

      if (currentPassword == newPassword) {
        _showErrorSnackBar(
            'La nueva contraseña debe ser diferente a la actual');
        return;
      }

      await _accountRepository.updatePassword(currentUser.id, newPassword);

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      _showSnackBar('Contraseña actualizada correctamente');
    } catch (_) {
      _showErrorSnackBar('No fue posible actualizar la contraseña');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingPassword = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? AppThemes.darkBg : AppThemes.lightBg;
    final cardColor = isDark ? AppThemes.darkSurface : AppThemes.lightSurface;
    final textColor = isDark ? AppThemes.darkText : AppThemes.lightText;
    final secondaryTextColor =
        isDark ? AppThemes.darkTextSub : AppThemes.lightTextSub;
    final inputBackground =
        isDark ? AppThemes.darkSurfaceHi : AppThemes.lightSurface;
    final borderColor = isDark ? AppThemes.darkBorder : AppThemes.lightBorder;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildGradientHeader(isSmallPhone, isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallPhone ? 16 : 20,
                vertical: isSmallPhone ? 16 : 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPasswordSection(
                      isSmallPhone,
                      isDark,
                      cardColor,
                      textColor,
                      inputBackground,
                      borderColor,
                      secondaryTextColor),
                  SizedBox(height: isSmallPhone ? 16 : 20),
                  _buildSecurityOptionsSection(isSmallPhone, isDark, cardColor,
                      textColor, secondaryTextColor),
                  SizedBox(height: isSmallPhone ? 16 : 20),
                  _buildActiveSessionsSection(isSmallPhone, isDark, cardColor,
                      textColor, secondaryTextColor),
                  SizedBox(height: isSmallPhone ? 16 : 20),
                  _buildDeleteAccountButton(isSmallPhone, isDark),
                  SizedBox(height: isSmallPhone ? 32 : 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientHeader(bool isSmallPhone, bool isDark) {
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
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.2),
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
                      color: Colors.white.withValues(alpha: 0.8),
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
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.2),
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
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSection(
      bool isSmallPhone,
      bool isDark,
      Color cardColor,
      Color textColor,
      Color inputBackground,
      Color borderColor,
      Color labelColor) {
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
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
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.lock_outline,
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
                  color: textColor,
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
            onToggle: () => setState(
                () => _obscureCurrentPassword = !_obscureCurrentPassword),
            isSmallPhone: isSmallPhone,
            isDark: isDark,
            inputBackground: inputBackground,
            textColor: textColor,
            labelColor: labelColor,
          ),
          SizedBox(height: isSmallPhone ? 12 : 16),
          _buildPasswordField(
            label: 'NUEVA CONTRASEÑA',
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            onToggle: () =>
                setState(() => _obscureNewPassword = !_obscureNewPassword),
            isSmallPhone: isSmallPhone,
            isDark: isDark,
            inputBackground: inputBackground,
            textColor: textColor,
            labelColor: labelColor,
          ),
          SizedBox(height: isSmallPhone ? 12 : 16),
          _buildPasswordField(
            label: 'CONFIRMAR NUEVA CONTRASEÑA',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            onToggle: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword),
            isSmallPhone: isSmallPhone,
            isDark: isDark,
            inputBackground: inputBackground,
            textColor: textColor,
            labelColor: labelColor,
          ),
          SizedBox(height: isSmallPhone ? 16 : 20),
          // Update button
          GestureDetector(
            onTap: _isUpdatingPassword ? null : _updatePassword,
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
                child: _isUpdatingPassword
                    ? SizedBox(
                        width: isSmallPhone ? 18 : 20,
                        height: isSmallPhone ? 18 : 20,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
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
    required bool isDark,
    required Color inputBackground,
    required Color textColor,
    required Color labelColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isSmallPhone ? 10 : 11,
            fontWeight: FontWeight.w500,
            color: labelColor,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: isSmallPhone ? 6 : 8),
        Container(
          decoration: BoxDecoration(
            color: inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.transparent,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 14 : 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.lock_outline,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                size: isSmallPhone ? 18 : 20,
              ),
              hintText: '••••••••',
              hintStyle: GoogleFonts.inter(
                fontSize: isSmallPhone ? 14 : 15,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade600,
              ),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
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

  Widget _buildSecurityOptionsSection(bool isSmallPhone, bool isDark,
      Color cardColor, Color textColor, Color secondaryTextColor) {
    if (_isLoadingSecurityData) {
      return Container(
        padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildToggleOption(
            icon: Icons.smartphone_outlined,
            iconColor: const Color(0xFF8B5CF6),
            iconBgColor:
                isDark ? const Color(0xFF4C1D95) : const Color(0xFFF3E8FF),
            title: 'Verificación en 2 pasos',
            subtitle: 'SMS o app de autenticación',
            value: _isTwoFactorEnabled,
            onChanged: (v) {
              setState(() => _isTwoFactorEnabled = v);
              _persistSecuritySettings();
            },
            isSmallPhone: isSmallPhone,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
          ),
          Divider(
              height: 24,
              color: isDark ? AppThemes.darkDivider : AppThemes.lightBorder),
          _buildToggleOption(
            icon: Icons.fingerprint_outlined,
            iconColor: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
            iconBgColor:
                isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            title: 'Acceso biométrico',
            subtitle: 'Huella dactilar o Face ID',
            value: _isBiometricEnabled,
            onChanged: (v) {
              setState(() => _isBiometricEnabled = v);
              _persistSecuritySettings();
            },
            isSmallPhone: isSmallPhone,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
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
    required Color textColor,
    required Color secondaryTextColor,
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
                  color: textColor,
                ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: isSmallPhone ? 11 : 12,
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: isSmallPhone ? 44 : 48,
          height: isSmallPhone ? 24 : 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: value
                ? const Color(0xFF8B5CF6)
                : (secondaryTextColor.withValues(alpha: 0.3)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: () => onChanged(!value),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment:
                      value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: isSmallPhone ? 20 : 24,
                    height: isSmallPhone ? 20 : 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSessionsSection(bool isSmallPhone, bool isDark,
      Color cardColor, Color textColor, Color secondaryTextColor) {
    if (_isLoadingSecurityData) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sesiones activas',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : secondaryTextColor,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: isSmallPhone ? 10 : 12),
          Container(
            padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sesiones activas',
          style: GoogleFonts.inter(
            fontSize: isSmallPhone ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : secondaryTextColor,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: isSmallPhone ? 10 : 12),
        Container(
          padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _sessions.isEmpty
                ? [
                    Text(
                      'No hay sesiones registradas para este usuario',
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 12 : 13,
                        fontWeight: FontWeight.w500,
                        color: secondaryTextColor,
                      ),
                    ),
                  ]
                : [
                    for (int i = 0; i < _sessions.length; i++) ...[
                      _buildSessionItem(
                        session: _sessions[i],
                        isSmallPhone: isSmallPhone,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      if (i < _sessions.length - 1)
                        Divider(
                          height: 20,
                          color: isDark
                              ? AppThemes.darkDivider
                              : AppThemes.lightBorder,
                        ),
                    ]
                  ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionItem({
    required UserSessionModel session,
    required bool isSmallPhone,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final location =
        '${session.operatingSystem} · ${session.ipAddress} · ${_formatSessionTime(session.startDate)}';
    final isCurrent = session.active;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          _iconByDevice(session.device, session.operatingSystem),
          color: secondaryTextColor,
          size: isSmallPhone ? 20 : 24,
        ),
        SizedBox(width: isSmallPhone ? 10 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.device,
                style: GoogleFonts.inter(
                  fontSize: isSmallPhone ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              SizedBox(height: 2),
              Text(
                location,
                style: GoogleFonts.inter(
                  fontSize: isSmallPhone ? 11 : 12,
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor,
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
              color: AppThemes.accentGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'ACTUAL',
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 9 : 10,
                fontWeight: FontWeight.w600,
                color: AppThemes.accentGreen,
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () => _showSnackBar('Sesión cerrada en este dispositivo'),
            child: Text(
              'Cerrar',
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: AppThemes.accentRed,
              ),
            ),
          ),
      ],
    );
  }

  String _formatSessionTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime.toLocal());
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    return 'Hace ${diff.inDays} dias';
  }

  IconData _iconByDevice(String device, String operatingSystem) {
    final source = '${device.toLowerCase()} ${operatingSystem.toLowerCase()}';
    if (source.contains('iphone') || source.contains('ios')) {
      return Icons.phone_iphone;
    }
    if (source.contains('android') || source.contains('samsung')) {
      return Icons.smartphone;
    }
    if (source.contains('mac') ||
        source.contains('windows') ||
        source.contains('linux') ||
        source.contains('chrome')) {
      return Icons.laptop_mac;
    }
    return Icons.devices;
  }

  Widget _buildDeleteAccountButton(bool isSmallPhone, bool isDark) {
    return GestureDetector(
      onTap: () => _showDeleteAccountDialog(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmallPhone ? 14 : 16),
        decoration: BoxDecoration(
          color: isDark ? AppThemes.darkSurface : const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppThemes.accentRed.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_outlined,
              color: AppThemes.accentRed,
              size: isSmallPhone ? 18 : 20,
            ),
            SizedBox(width: isSmallPhone ? 8 : 10),
            Text(
              'Eliminar cuenta',
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 14 : 15,
                fontWeight: FontWeight.w600,
                color: AppThemes.accentRed,
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
        backgroundColor: AppThemes.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppThemes.accentRed,
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
            color: Theme.of(context).brightness == Brightness.dark
                ? AppThemes.darkTextSub
                : AppThemes.lightTextSub,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppThemes.darkTextSub,
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
                color: AppThemes.accentRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

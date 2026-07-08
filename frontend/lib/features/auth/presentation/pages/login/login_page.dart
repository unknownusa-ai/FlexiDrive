import 'package:flexidrive/core/session/local_session_store.dart';
import 'package:flexidrive/core/utils/responsive_utils.dart';
import 'package:flexidrive/features/accounts/application/use_cases/account_access_use_case.dart';
import 'package:flexidrive/features/accounts/application/use_cases/user_preferences_use_case.dart';
import 'package:flexidrive/features/auth/presentation/pages/login/forgot_password_page.dart';
import 'package:flexidrive/features/home/presentation/pages/main_page.dart';
import 'package:flexidrive/features/onboarding/presentation/pages/welcome/welcome_landing_page.dart';
import 'package:flexidrive/features/profile/presentation/pages/profile/arrendatario_main_page.dart';
import 'package:flexidrive/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AccountAccessUseCase _accountRepository =
      InjectionContainer.instance.accountAccessUseCase;
  final UserPreferencesUseCase _preferenceService =
      InjectionContainer.instance.userPreferencesUseCase;

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadLastLoggedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadLastLoggedEmail() async {
    await LocalSessionStore.instance.init();
    final lastEmail = LocalSessionStore.instance.lastLoggedEmail;
    if (!mounted || lastEmail == null || lastEmail.isEmpty) return;
    _emailController.text = lastEmail;
  }

  Future<void> _showErrorDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitLogin() async {
    if (_isSubmitting) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      await _showErrorDialog(
        'Campos obligatorios',
        'Ingresa correo y contrasena para continuar.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = await _accountRepository
          .login(email: email, password: password)
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (user == null) {
        await _showErrorDialog(
          'Credenciales invalidas',
          'El correo o la contrasena no son correctos.',
        );
        return;
      }

      final isArrendatarioMode = user.userTypeId == 2;
      await _preferenceService.setArrendatarioMode(
        userId: user.id,
        enabled: isArrendatarioMode,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => isArrendatarioMode
              ? const ArrendatarioMainPage()
              : const MainPage(),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      await _showErrorDialog(
        'Error al iniciar sesion',
        'No fue posible iniciar sesion. Intenta nuevamente.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeLandingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveUtils.scale(context, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? const Color(0xFF0B1220) : const Color(0xFFE8F0FF),
              isDark ? const Color(0xFF101828) : const Color(0xFFF8FAFF),
            ],
          ),
        ),
        child: SafeArea(
          child: ConstrainedContainer(
            maxWidth: 620,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20 * scale,
                12 * scale,
                20 * scale,
                24 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackButton(scale),
                  SizedBox(height: 18 * scale),
                  _buildHero(scale, isDark),
                  SizedBox(height: 20 * scale),
                  _buildLoginCard(scale, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(double scale) {
    return GestureDetector(
      onTap: _goBack,
      child: Container(
        width: 44 * scale,
        height: 44 * scale,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: const Color(0xFF1D4ED8),
          size: 22 * scale,
        ),
      ),
    );
  }

  Widget _buildHero(double scale, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(32 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30 * scale,
            right: -12 * scale,
            child: Container(
              width: 132 * scale,
              height: 132 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -52 * scale,
            left: -24 * scale,
            child: Container(
              width: 148 * scale,
              height: 148 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52 * scale,
                    height: 52 * scale,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(18 * scale),
                    ),
                    child: Icon(
                      Icons.directions_car_filled_rounded,
                      color: Colors.white,
                      size: 28 * scale,
                    ),
                  ),
                  SizedBox(width: 12 * scale),
                  Text(
                    'FlexiDrive',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.fontSize(context, 24),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28 * scale),
              Text(
                'Bienvenido de vuelta',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.fontSize(context, 32),
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 10 * scale),
              Text(
                'Accede a tus reservas, tu perfil y tus vehiculos con un inicio de sesion mucho mas claro.',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                  height: 1.55,
                ),
              ),
              SizedBox(height: 18 * scale),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * scale,
                  vertical: 12 * scale,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18 * scale),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_clock_rounded,
                      color: Colors.white,
                      size: 18 * scale,
                    ),
                    SizedBox(width: 8 * scale),
                    Expanded(
                      child: Text(
                        'Tus datos quedan recordados para que volver sea rapido, pero el acceso sigue protegido.',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.fontSize(context, 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(double scale, bool isDark) {
    final cardColor = isDark ? const Color(0xFF111A2C) : Colors.white;
    final fieldColor =
        isDark ? const Color(0xFF172338) : const Color(0xFFF4F7FC);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final secondaryColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22 * scale),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30 * scale),
        border: Border.all(
          color: isDark ? const Color(0xFF243147) : const Color(0xFFE6EBF5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.12),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inicia sesion',
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: ResponsiveUtils.fontSize(context, 22),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            'Usa tu correo y tu contrasena para retomar tu experiencia.',
            style: GoogleFonts.poppins(
              color: secondaryColor,
              fontSize: ResponsiveUtils.fontSize(context, 13),
            ),
          ),
          SizedBox(height: 22 * scale),
          _buildLabel('CORREO ELECTRONICO', secondaryColor),
          SizedBox(height: 8 * scale),
          _buildTextField(
            controller: _emailController,
            hintText: 'tu@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            fieldColor: fieldColor,
            textColor: textColor,
            secondaryColor: secondaryColor,
            scale: scale,
          ),
          SizedBox(height: 18 * scale),
          _buildLabel('CONTRASENA', secondaryColor),
          SizedBox(height: 8 * scale),
          _buildTextField(
            controller: _passwordController,
            hintText: 'Ingresa tu contrasena',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            fieldColor: fieldColor,
            textColor: textColor,
            secondaryColor: secondaryColor,
            scale: scale,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: secondaryColor,
                size: 20 * scale,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                );
              },
              child: Text(
                'Olvidaste tu contrasena?',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF4F46E5),
                  fontSize: ResponsiveUtils.fontSize(context, 13),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 10 * scale),
          _buildPrimaryButton(scale),
          SizedBox(height: 24 * scale),
          Row(
            children: [
              Expanded(
                  child: Divider(color: secondaryColor.withValues(alpha: 0.3))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                child: Text(
                  'o continua con',
                  style: GoogleFonts.poppins(
                    color: secondaryColor,
                    fontSize: ResponsiveUtils.fontSize(context, 12),
                  ),
                ),
              ),
              Expanded(
                  child: Divider(color: secondaryColor.withValues(alpha: 0.3))),
            ],
          ),
          SizedBox(height: 18 * scale),
          Row(
            children: [
              Expanded(
                child: _buildSocialButton(
                  svgPath: 'assets/icons/google_logo.svg',
                  label: 'Google',
                  scale: scale,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: _buildSocialButton(
                  svgPath: 'assets/icons/apple_logo.svg',
                  label: 'Apple',
                  scale: scale,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: color,
        fontSize: ResponsiveUtils.fontSize(context, 12),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required Color fieldColor,
    required Color textColor,
    required Color secondaryColor,
    required double scale,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      cursorColor: textColor,
      style: GoogleFonts.poppins(
        color: textColor,
        fontSize: ResponsiveUtils.fontSize(context, 14),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          color: secondaryColor,
          fontSize: ResponsiveUtils.fontSize(context, 14),
        ),
        prefixIcon: Icon(prefixIcon, color: secondaryColor, size: 20 * scale),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18 * scale),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18 * scale),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18 * scale),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 18 * scale,
          vertical: 18 * scale,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(double scale) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(18 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: Size(double.infinity, 56 * scale),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18 * scale),
          ),
        ),
        child: _isSubmitting
            ? SizedBox(
                width: 20 * scale,
                height: 20 * scale,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Iniciar sesion',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.fontSize(context, 16),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18 * scale,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String svgPath,
    required String label,
    required double scale,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14 * scale),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF172338) : Colors.white,
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(
          color: isDark ? const Color(0xFF243147) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(svgPath, width: 18 * scale, height: 18 * scale),
          SizedBox(width: 8 * scale),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : const Color(0xFF111827),
              fontSize: ResponsiveUtils.fontSize(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Flutter framework
import 'package:flutter/material.dart';
// Para mostrar SVGs (el logo)
import 'package:flutter_svg/flutter_svg.dart';
// Fuentes bonitas
import 'package:google_fonts/google_fonts.dart';
// Servicio para validar el login
import 'package:flexidrive/services/accounts/local_account_repository.dart';
// Utilidades responsive
import '../../../core/utils/responsive_utils.dart';
// Página de registro si no tiene cuenta
import '../register/register_page.dart';
// Página principal después de loguear
import '../main_page.dart';
// Si olvidó la contraseña
import 'forgot_password_page.dart';

// Página de login - donde el usuario entra a la app
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Estado del login
class _LoginPageState extends State<LoginPage> {
  // Controlador del campo de email
  final _emailController = TextEditingController();
  // Controlador del campo de contraseña
  final _passwordController = TextEditingController();
  // Repositorio para validar credenciales
  final LocalAccountRepository _accountRepository = LocalAccountRepository();
  // Ocultar/mostrar contraseña
  bool _obscurePassword = true;
  // Está enviando el formulario? (para evitar doble clic)
  bool _isSubmitting = false;

  // Muestra alerta cuando hay error
  Future<void> _showErrorDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  // Procesa el login cuando tocan el botón
  Future<void> _submitLogin() async {
    // Si ya está procesando, no hace nada
    if (_isSubmitting) return;

    // Toma el email y limpia espacios
    final email = _emailController.text.trim();
    // Toma la contraseña
    final password = _passwordController.text;

    // Valida que no estén vacíos
    if (email.isEmpty || password.isEmpty) {
      await _showErrorDialog(
        'Campos obligatorios',
        'Ingresa correo y contraseña para continuar.',
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
          'Credenciales inválidas',
          'El correo o la contraseña no son correctos.',
        );
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } catch (_) {
      if (!mounted) return;
      await _showErrorDialog(
        'Error al iniciar sesión',
        'No fue posible iniciar sesión. Intenta nuevamente.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.horizontalPadding(context);
    final scale = ResponsiveUtils.scale(context, 1.0);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: ConstrainedContainer(
        maxWidth: 600,
        child: Column(
          children: [
            // Header Section with gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circle
                  Positioned(
                    top: -50,
                    right: -80,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha((0.1 * 255).round()),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding, vertical: 16 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16 * scale),
                          // Logo
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8 * scale),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withAlpha((0.2 * 255).round()),
                                  borderRadius:
                                      BorderRadius.circular(12 * scale),
                                ),
                                child: Icon(
                                  Icons.directions_car_filled,
                                  color: Colors.white,
                                  size: 24 * scale,
                                ),
                              ),
                              SizedBox(width: 12 * scale),
                              Text(
                                'FlexiDrive',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize:
                                      ResponsiveUtils.fontSize(context, 24),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24 * scale),
                          // Welcome text
                          Text(
                            '¡Bienvenido de\nvuelta!',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: ResponsiveUtils.fontSize(context, 32),
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          Text(
                            'Inicia sesión para continuar',
                            style: GoogleFonts.poppins(
                              color:
                                  Colors.white.withAlpha((0.8 * 255).round()),
                              fontSize: ResponsiveUtils.fontSize(context, 14),
                            ),
                          ),
                          SizedBox(height: 32 * scale),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // White Card Section
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email Field
                      _buildLabel('CORREO ELECTRÓNICO', scale),
                      SizedBox(height: 8 * scale),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'tu@email.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        scale: scale,
                      ),
                      SizedBox(height: 20 * scale),
                      // Password Field
                      _buildLabel('CONTRASEÑA', scale),
                      SizedBox(height: 8 * scale),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: '••••••••',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        scale: scale,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey,
                            size: 20 * scale,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordPage(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF4F7DF3),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Login Button
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                          ),
                          borderRadius: BorderRadius.circular(16 * scale),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4F46E5)
                                  .withAlpha((0.15 * 255).round()),
                              blurRadius: 12 * scale,
                              offset: Offset(0, 6 * scale),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 16 * scale),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16 * scale),
                            ),
                          ),
                          child: _isSubmitting
                              ? SizedBox(
                                  height: 20 * scale,
                                  width: 20 * scale,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Iniciar Sesión',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: ResponsiveUtils.fontSize(
                                            context, 16),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 8 * scale),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.white,
                                      size: 20 * scale,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: 24 * scale),
                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey.withAlpha((0.3 * 255).round()),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'o continúa con',
                              style: GoogleFonts.poppins(
                                color:
                                    Colors.grey.withAlpha((0.7 * 255).round()),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey.withAlpha((0.3 * 255).round()),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24 * scale),
                      // Social Login Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildSocialButton(
                              svgPath: 'assets/icons/google_logo.svg',
                              label: 'Google',
                              onTap: () {},
                              scale: scale,
                            ),
                          ),
                          SizedBox(width: 12 * scale),
                          Expanded(
                            child: _buildSocialButton(
                              svgPath: 'assets/icons/apple_logo.svg',
                              label: 'Apple',
                              onTap: () {},
                              scale: scale,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32 * scale),
                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿No tienes cuenta? ',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.withAlpha((0.8 * 255).round()),
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Regístrate',
                              style: GoogleFonts.poppins(
                                color: Color(0xFF4F7DF3),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, double scale) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: const Color(0xFF9CA3AF),
        fontSize: ResponsiveUtils.fontSize(context, 12),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    required double scale,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          color: const Color(0xFF9CA3AF),
          fontSize: ResponsiveUtils.fontSize(context, 14),
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: const Color(0xFF9CA3AF),
          size: 20 * scale,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16 * scale),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16 * scale),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16 * scale),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 16 * scale,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String svgPath,
    required String label,
    required VoidCallback onTap,
    required double scale,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 20 * scale,
              height: 20 * scale,
            ),
            SizedBox(width: 8 * scale),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: ResponsiveUtils.fontSize(context, 14),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

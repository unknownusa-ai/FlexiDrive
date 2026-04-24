// Flutter framework
import 'package:flutter/material.dart';
// Fuentes bonitas de Google
import 'package:google_fonts/google_fonts.dart';
// Servicio para manejar usuarios y recuperación
import 'package:flexidrive/services/accounts/local_account_repository.dart';
// Utilidades responsive
import '../../../core/utils/responsive_utils.dart';
// Pagina de login (despues de recuperar)
import 'login_page.dart';

// Pagina de recuperación de contraseña
// Flujo de 2 pasos: 1) verificar email, 2) cambiar contraseña
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

// Estado de la pagina de recuperación
class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Controladores de los campos
  final _emailController = TextEditingController(); // Email del usuario
  final _newPasswordController = TextEditingController(); // Nueva contraseña
  final _confirmPasswordController =
      TextEditingController(); // Confirmar contraseña

  // Servicio para manejar usuarios
  final LocalAccountRepository _accountRepository = LocalAccountRepository();

  // Estados de la UI
  bool _isLoading = false; // Esta procesando?
  bool _obscureNewPassword = true; // Ocultar nueva contraseña
  bool _obscureConfirmPassword = true; // Ocultar confirmacion
  int _currentStep = 1; // Paso actual (1 o 2)
  int? _userId; // ID del usuario encontrado

  // Muestra dialogo de error
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

  // Muestra dialogo de exito
  Future<void> _showSuccessDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando fuera
      builder: (context) {
        return AlertDialog(
          title: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 64,
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _validateEmail() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      await _showErrorDialog(
        'Campo obligatorio',
        'Por favor digita tu correo electrónico.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    try {
      final user = await _accountRepository.findUserByEmail(email);

      if (!mounted) return;

      if (user == null) {
        await _showErrorDialog(
          'Correo no encontrado',
          'El correo electrónico ingresado no está registrado en nuestro sistema.',
        );
        return;
      }

      setState(() {
        _userId = user.id;
        _currentStep = 2;
      });
    } catch (_) {
      if (!mounted) return;
      await _showErrorDialog(
        'Error',
        'No fue posible validar el correo. Intenta nuevamente.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _changePassword() async {
    if (_isLoading) return;

    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      await _showErrorDialog(
        'Campos obligatorios',
        'Por favor completa todos los campos de contraseña.',
      );
      return;
    }

    if (newPassword.length < 6) {
      await _showErrorDialog(
        'Contraseña muy corta',
        'La contraseña debe tener al menos 6 caracteres.',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      await _showErrorDialog(
        'Contraseñas no coinciden',
        'La nueva contraseña y la confirmación no coinciden.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    try {
      if (_userId != null) {
        await _accountRepository.updatePassword(_userId!, newPassword);
      }

      if (!mounted) return;

      await _showSuccessDialog(
        '¡Tu contraseña fue actualizada correctamente!',
      );
    } catch (_) {
      if (!mounted) return;
      await _showErrorDialog(
        'Error',
        'No fue posible actualizar la contraseña. Intenta nuevamente.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
                        horizontal: horizontalPadding,
                        vertical: 16 * scale,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_currentStep == 2) {
                                setState(() {
                                  _currentStep = 1;
                                });
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white
                                      .withAlpha((0.9 * 255).round()),
                                  size: 18,
                                ),
                                Text(
                                  'Atrás',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white
                                        .withAlpha((0.9 * 255).round()),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24 * scale),
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
                                  Icons.lock_reset,
                                  color: Colors.white,
                                  size: 24 * scale,
                                ),
                              ),
                              SizedBox(width: 12 * scale),
                              Text(
                                'Recuperar Contraseña',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize:
                                      ResponsiveUtils.fontSize(context, 22),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24 * scale),
                          Text(
                            _currentStep == 1
                                ? '¿Olvidaste tu\ncontraseña?'
                                : 'Crear nueva\ncontraseña',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: ResponsiveUtils.fontSize(context, 32),
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          Text(
                            _currentStep == 1
                                ? 'No te preocupes, te ayudaremos a recuperarla'
                                : 'Ingresa tu nueva contraseña',
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
                  child: _currentStep == 1
                      ? _buildEmailStep(scale)
                      : _buildPasswordStep(scale),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailStep(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF4F7DF3),
                size: 24 * scale,
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Text(
                  'Si olvidaste tu contraseña, digita tu correo electrónico y te ayudaremos a restablecerla.',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[700],
                    fontSize: ResponsiveUtils.fontSize(context, 13),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24 * scale),
        _buildLabel('CORREO ELECTRÓNICO', scale),
        SizedBox(height: 8 * scale),
        _buildTextField(
          controller: _emailController,
          hintText: 'tu@email.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          scale: scale,
        ),
        SizedBox(height: 32 * scale),
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
                color: const Color(0xFF4F46E5).withAlpha((0.15 * 255).round()),
                blurRadius: 12 * scale,
                offset: Offset(0, 6 * scale),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _validateEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 16 * scale),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16 * scale),
              ),
            ),
            child: _isLoading
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
                        'Validar',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.fontSize(context, 16),
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
      ],
    );
  }

  Widget _buildPasswordStep(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 24 * scale,
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Text(
                  '¡Correo validado! Ahora puedes crear tu nueva contraseña.',
                  style: GoogleFonts.poppins(
                    color: Colors.green[700],
                    fontSize: ResponsiveUtils.fontSize(context, 13),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24 * scale),
        _buildLabel('NUEVA CONTRASEÑA', scale),
        SizedBox(height: 8 * scale),
        _buildTextField(
          controller: _newPasswordController,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureNewPassword,
          scale: scale,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureNewPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.grey,
              size: 20 * scale,
            ),
            onPressed: () {
              setState(() {
                _obscureNewPassword = !_obscureNewPassword;
              });
            },
          ),
        ),
        SizedBox(height: 20 * scale),
        _buildLabel('CONFIRMAR CONTRASEÑA', scale),
        SizedBox(height: 8 * scale),
        _buildTextField(
          controller: _confirmPasswordController,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          scale: scale,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.grey,
              size: 20 * scale,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ),
        SizedBox(height: 32 * scale),
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
                color: const Color(0xFF4F46E5).withAlpha((0.15 * 255).round()),
                blurRadius: 12 * scale,
                offset: Offset(0, 6 * scale),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 16 * scale),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16 * scale),
              ),
            ),
            child: _isLoading
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
                        'Cambiar Contraseña',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.fontSize(context, 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20 * scale,
                      ),
                    ],
                  ),
          ),
        ),
      ],
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
}

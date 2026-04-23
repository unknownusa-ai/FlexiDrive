import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flexidrive/services/accounts/local_account_repository.dart';
import 'package:flexidrive/services/catalogs/local_catalog_db.dart';
import 'package:flexidrive/models/catalogs/catalog_models.dart';
import '../../../core/utils/responsive_utils.dart';
import '../login/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _documentController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final LocalAccountRepository _accountRepository = LocalAccountRepository();
  final LocalCatalogDb _catalogDb = LocalCatalogDb.instance;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isSubmitting = false;
  bool _isLoadingCatalogs = true;

  List<IdentificationTypeModel> _identificationTypes = [];
  IdentificationTypeModel? _selectedIdentificationType;

  Future<void> _showDialogMessage(String title, String message) async {
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

  @override
  void initState() {
    super.initState();
    _loadIdentificationTypes();
  }

  Future<void> _loadIdentificationTypes() async {
    await _catalogDb.loadIfNeeded();
    setState(() {
      _identificationTypes = _catalogDb.identificationTypes;
      if (_identificationTypes.isNotEmpty) {
        _selectedIdentificationType = _identificationTypes.first;
      }
      _isLoadingCatalogs = false;
    });
  }

  Future<void> _submitRegister() async {
    if (_isSubmitting) return;

    final fullName = _nameController.text.trim();
    final document = _documentController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullName.isEmpty ||
        document.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        _selectedIdentificationType == null) {
      await _showDialogMessage(
        'Campos obligatorios',
        'Completa todos los campos para crear la cuenta.',
      );
      return;
    }

    if (password != confirmPassword) {
      await _showDialogMessage(
        'Contraseñas distintas',
        'La contraseña y su confirmación deben coincidir.',
      );
      return;
    }

    if (!_acceptTerms) {
      await _showDialogMessage(
        'Términos requeridos',
        'Debes aceptar los términos y condiciones para continuar.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _accountRepository.register(
        fullName: fullName,
        identificationNumber: document,
        email: email,
        phone: phone,
        password: password,
        identificationTypeId: _selectedIdentificationType!.id,
      );

      if (!mounted) return;

      await _showDialogMessage(
        'Registro exitoso',
        'Tu cuenta fue creada correctamente. Ahora puedes iniciar sesión.',
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      if (!mounted) return;
      await _showDialogMessage('No se pudo registrar', e.toString());
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
    _nameController.dispose();
    _documentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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
          // Header Section
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white.withAlpha((0.9 * 255).round()),
                          size: 18,
                        ),
                        Text(
                          'Atrás',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withAlpha((0.9 * 255).round()),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                  // Title
                  Text(
                    'Crear Cuenta',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.fontSize(context, 32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    'Únete a miles de usuarios FlexiDrive',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withAlpha((0.8 * 255).round()),
                      fontSize: ResponsiveUtils.fontSize(context, 14),
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                ],
              ),
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
                    // Nombre Completo
                    _buildLabel('NOMBRE COMPLETO'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Tu nombre completo',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    // Tipo de Identificación
                    _buildLabel('TIPO DE IDENTIFICACIÓN'),
                    const SizedBox(height: 8),
                    _isLoadingCatalogs
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Cargando...',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.withValues(alpha: 0.6),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<IdentificationTypeModel>(
                                value: _selectedIdentificationType,
                                isExpanded: true,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey,
                                ),
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                items: _identificationTypes.map((type) {
                                  return DropdownMenuItem<IdentificationTypeModel>(
                                    value: type,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.badge_outlined,
                                          color: const Color(0xFF9CA3AF),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${type.name} - ${type.description}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedIdentificationType = value;
                                  });
                                },
                              ),
                            ),
                          ),
                    const SizedBox(height: 16),
                    // Documento
                    _buildLabel('NÚMERO DE IDENTIFICACIÓN'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _documentController,
                      hintText: 'Número de documento',
                      prefixIcon: Icons.numbers_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    // Correo Electrónico
                    _buildLabel('CORREO ELECTRÓNICO'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'tu@email.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    // Teléfono
                    _buildLabel('TELÉFONO'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _phoneController,
                      hintText: '+57 300 000 0000',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    // Contraseña
                    _buildLabel('CONTRASEÑA'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Mínimo 8 caracteres',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Confirmar Contraseña
                    _buildLabel('CONFIRMAR CONTRASEÑA'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Repite tu contraseña',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Terms and Conditions - Toggle Style
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Toggle Switch
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _acceptTerms = !_acceptTerms;
                              });
                            },
                            child: Container(
                              width: 44,
                              height: 24,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: _acceptTerms
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFD1D5DB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 200),
                                alignment: _acceptTerms
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Acepto los ',
                                  ),
                                  TextSpan(
                                    text: 'Términos y Condiciones',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF2563EB),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' y la ',
                                  ),
                                  TextSpan(
                                    text: 'Política de Privacidad',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF2563EB),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' de FlexiDrive.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Create Account Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (_acceptTerms && !_isSubmitting)
                            ? _submitRegister
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _acceptTerms
                              ? null
                              : const Color(0xFFE8ECF4),
                          foregroundColor: _acceptTerms ? Colors.white : const Color(0xFF9CA3AF),
                          disabledBackgroundColor: const Color(0xFFE8ECF4),
                          disabledForegroundColor: const Color(0xFF9CA3AF),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: _acceptTerms
                              ? BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                )
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isSubmitting)
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              else ...[
                                Text(
                                  'Crear Cuenta',
                                  style: GoogleFonts.poppins(
                                    color: _acceptTerms
                                        ? Colors.white
                                        : const Color(0xFF9CA3AF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right,
                                  color: _acceptTerms
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF),
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes cuenta? ',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Inicia sesión',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF2563EB),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.grey.withValues(alpha: 0.7),
        fontSize: 12,
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
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.grey,
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

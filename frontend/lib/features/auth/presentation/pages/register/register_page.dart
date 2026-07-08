import 'package:flexidrive/core/utils/responsive_utils.dart';
import 'package:flexidrive/features/accounts/application/use_cases/account_access_use_case.dart';
import 'package:flexidrive/features/auth/presentation/pages/login/login_page.dart';
import 'package:flexidrive/features/catalogs/application/use_cases/catalog_access_use_case.dart';
import 'package:flexidrive/features/catalogs/domain/entities/catalog_models.dart';
import 'package:flexidrive/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const List<String> _preferredColombianIdentificationTypes = [
    'Cedula de Ciudadania',
    'Tarjeta de Identidad',
    'Cedula de Extranjeria',
    'Pasaporte',
    'Permiso por Proteccion Temporal',
    'Permiso Especial de Permanencia',
    'Registro Civil',
    'Numero Unico de Identificacion Personal',
    'NIT',
  ];

  static const List<String> _preferredUserTypes = [
    'Arrendador',
    'Arrendatario',
  ];

  static const Map<int, String> _fallbackIdentificationNamesById = {
    1: 'Cedula de Ciudadania',
    2: 'Cedula de Extranjeria',
    3: 'Pasaporte',
    4: 'NIT',
    5: 'Tarjeta de Identidad',
    6: 'Registro Civil',
    7: 'Permiso Especial de Permanencia',
    8: 'Permiso por Proteccion Temporal',
    9: 'Numero Unico de Identificacion Personal',
  };

  static const Map<int, String> _fallbackUserTypeNamesById = {
    1: 'Arrendador',
    2: 'Arrendatario',
  };

  final _nameController = TextEditingController();
  final _documentController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AccountAccessUseCase _accountRepository =
      InjectionContainer.instance.accountAccessUseCase;
  final CatalogAccessUseCase _catalogDb =
      InjectionContainer.instance.catalogAccessUseCase;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isSubmitting = false;
  bool _isLoadingCatalogs = true;

  List<IdentificationTypeModel> _identificationTypes = [];
  IdentificationTypeModel? _selectedIdentificationType;
  List<UserTypeModel> _userTypes = [];
  UserTypeModel? _selectedUserType;

  @override
  void initState() {
    super.initState();
    _loadIdentificationTypes();
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

  Future<void> _showDialogMessage(String title, String message) async {
    final isSuccess = title.toLowerCase().contains('exitoso');
    final accentColor =
        isSuccess ? const Color(0xFF2563EB) : const Color(0xFFEF4444);
    final secondAccentColor =
        isSuccess ? const Color(0xFF7C3AED) : const Color(0xFFF97316);
    final icon =
        isSuccess ? Icons.check_circle_outline : Icons.info_outline_rounded;

    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, secondAccentColor],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF111827),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                message,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF4B5563),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Aceptar',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadIdentificationTypes() async {
    setState(() {
      _isLoadingCatalogs = true;
    });

    try {
      await _catalogDb.loadIfNeeded();

      final normalizedTypes = _catalogDb.identificationTypes
          .map(
            (type) => IdentificationTypeModel(
              id: type.id,
              name: _resolveIdentificationTypeName(type),
              description: type.description,
            ),
          )
          .where((type) => type.name.trim().isNotEmpty)
          .toList();

      final selectedOrderedTypes =
          _buildOrderedIdentificationTypes(normalizedTypes);
      final orderedUserTypes =
          _buildOrderedUserTypes(_catalogDb.userTypes.toList());

      if (selectedOrderedTypes.isEmpty) {
        final localTypes = _buildLocalColombianIdentificationTypes();
        final localUserTypes = _buildLocalUserTypes();
        setState(() {
          _identificationTypes = localTypes;
          _selectedIdentificationType =
              localTypes.isNotEmpty ? localTypes.first : null;
          _userTypes = localUserTypes;
          _selectedUserType =
              localUserTypes.isNotEmpty ? localUserTypes.first : null;
          _isLoadingCatalogs = false;
        });
        return;
      }

      final finalUserTypes =
          orderedUserTypes.isEmpty ? _buildLocalUserTypes() : orderedUserTypes;

      setState(() {
        _identificationTypes = selectedOrderedTypes;
        _selectedIdentificationType =
            _identificationTypes.isNotEmpty ? _identificationTypes.first : null;
        _userTypes = finalUserTypes;
        _selectedUserType = _userTypes.isNotEmpty ? _userTypes.first : null;
        _isLoadingCatalogs = false;
      });
    } catch (_) {
      final localTypes = _buildLocalColombianIdentificationTypes();
      final localUserTypes = _buildLocalUserTypes();
      setState(() {
        _identificationTypes = localTypes;
        _selectedIdentificationType =
            localTypes.isNotEmpty ? localTypes.first : null;
        _userTypes = localUserTypes;
        _selectedUserType =
            localUserTypes.isNotEmpty ? localUserTypes.first : null;
        _isLoadingCatalogs = false;
      });
    }
  }

  List<IdentificationTypeModel> _buildOrderedIdentificationTypes(
    List<IdentificationTypeModel> normalizedTypes,
  ) {
    final uniqueByNormalizedName = <String, IdentificationTypeModel>{};
    for (final type in normalizedTypes) {
      uniqueByNormalizedName.putIfAbsent(_normalizeText(type.name), () => type);
    }

    final uniqueTypes = uniqueByNormalizedName.values.toList();
    final typesByNormalizedName = <String, IdentificationTypeModel>{
      for (final type in uniqueTypes) _normalizeText(type.name): type,
    };

    final ordered = <IdentificationTypeModel>[];
    for (final preferredName in _preferredColombianIdentificationTypes) {
      final matched = typesByNormalizedName[_normalizeText(preferredName)];
      if (matched != null && !ordered.any((item) => item.id == matched.id)) {
        ordered.add(matched);
      }
    }

    for (final type in uniqueTypes) {
      if (!ordered.any((item) => item.id == type.id)) {
        ordered.add(type);
      }
    }

    return ordered;
  }

  List<UserTypeModel> _buildOrderedUserTypes(List<UserTypeModel> userTypes) {
    final uniqueByNormalizedName = <String, UserTypeModel>{};
    for (final type in userTypes) {
      uniqueByNormalizedName.putIfAbsent(_normalizeText(type.name), () => type);
    }

    final uniqueTypes = uniqueByNormalizedName.values.toList();
    final typesByName = <String, UserTypeModel>{
      for (final type in uniqueTypes) _normalizeText(type.name): type,
    };

    final ordered = <UserTypeModel>[];
    for (final preferredName in _preferredUserTypes) {
      final matched = typesByName[_normalizeText(preferredName)];
      if (matched != null && !ordered.any((item) => item.id == matched.id)) {
        ordered.add(matched);
      }
    }

    for (final type in uniqueTypes) {
      if (!ordered.any((item) => item.id == type.id)) {
        ordered.add(type);
      }
    }

    return ordered;
  }

  List<IdentificationTypeModel> _buildLocalColombianIdentificationTypes() {
    return _fallbackIdentificationNamesById.entries
        .map(
          (entry) => IdentificationTypeModel(
            id: entry.key,
            name: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) {
        final indexA = _preferredColombianIdentificationTypes
            .indexOf(_resolveIdentificationTypeName(a));
        final indexB = _preferredColombianIdentificationTypes
            .indexOf(_resolveIdentificationTypeName(b));
        if (indexA == -1 && indexB == -1) return a.id.compareTo(b.id);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });
  }

  List<UserTypeModel> _buildLocalUserTypes() {
    return _fallbackUserTypeNamesById.entries
        .map((entry) => UserTypeModel(id: entry.key, name: entry.value))
        .toList()
      ..sort((a, b) {
        final indexA = _preferredUserTypes.indexOf(_resolveUserTypeName(a));
        final indexB = _preferredUserTypes.indexOf(_resolveUserTypeName(b));
        if (indexA == -1 && indexB == -1) return a.id.compareTo(b.id);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });
  }

  String _resolveIdentificationTypeName(IdentificationTypeModel type) {
    final rawName = type.name.trim();
    if (rawName.isNotEmpty) return rawName;
    return _fallbackIdentificationNamesById[type.id] ?? '';
  }

  String _resolveUserTypeName(UserTypeModel type) {
    final rawName = type.name.trim();
    if (rawName.isNotEmpty) return rawName;
    return _fallbackUserTypeNamesById[type.id] ?? '';
  }

  String _normalizeText(String text) {
    final lower = text.toLowerCase();
    return lower
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
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
        _selectedIdentificationType == null ||
        _selectedUserType == null) {
      await _showDialogMessage(
        'Campos obligatorios',
        'Completa todos los campos para crear la cuenta.',
      );
      return;
    }

    if (password != confirmPassword) {
      await _showDialogMessage(
        'Contrasenas distintas',
        'La contrasena y su confirmacion deben coincidir.',
      );
      return;
    }

    if (!_acceptTerms) {
      await _showDialogMessage(
        'Terminos requeridos',
        'Debes aceptar los terminos y condiciones para continuar.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final selectedType = _selectedIdentificationType!;
      final selectedUserType = _selectedUserType!;
      await _accountRepository.register(
        fullName: fullName,
        identificationNumber: document,
        identificationTypeName: _resolveIdentificationTypeName(selectedType),
        userTypeName: _resolveUserTypeName(selectedUserType),
        email: email,
        phone: phone,
        password: password,
        identificationTypeId: selectedType.id,
        userTypeId: selectedUserType.id,
      );

      if (!mounted) return;

      await _showDialogMessage(
        'Registro exitoso',
        'Tu cuenta fue creada correctamente. Ahora puedes iniciar sesion.',
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
  Widget build(BuildContext context) {
    final scale = ResponsiveUtils.scale(context, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111A2C) : Colors.white;
    final fieldColor =
        isDark ? const Color(0xFF172338) : const Color(0xFFF4F7FC);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final secondaryColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF2FF),
              isDark ? const Color(0xFF101828) : const Color(0xFFF8FAFF),
            ],
          ),
        ),
        child: SafeArea(
          child: ConstrainedContainer(
            maxWidth: 680,
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
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44 * scale,
                      height: 44 * scale,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.8)),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: const Color(0xFF1D4ED8),
                        size: 22 * scale,
                      ),
                    ),
                  ),
                  SizedBox(height: 18 * scale),
                  _buildHero(scale),
                  SizedBox(height: 20 * scale),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(22 * scale),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(30 * scale),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF243147)
                            : const Color(0xFFE6EBF5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF0F172A).withValues(alpha: 0.12),
                          blurRadius: 26,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Crear cuenta',
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontSize: ResponsiveUtils.fontSize(context, 24),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6 * scale),
                        Text(
                          'Completa tus datos para rentar o publicar vehiculos dentro de FlexiDrive.',
                          style: GoogleFonts.poppins(
                            color: secondaryColor,
                            fontSize: ResponsiveUtils.fontSize(context, 13),
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 20 * scale),
                        _buildQuickTips(scale, isDark),
                        SizedBox(height: 22 * scale),
                        _buildLabel('NOMBRE COMPLETO', secondaryColor),
                        SizedBox(height: 8 * scale),
                        _buildTextField(
                          controller: _nameController,
                          hintText: 'Tu nombre completo',
                          prefixIcon: Icons.person_outline_rounded,
                          fieldColor: fieldColor,
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          scale: scale,
                        ),
                        SizedBox(height: 16 * scale),
                        _buildLabel('TIPO DE IDENTIFICACION', secondaryColor),
                        SizedBox(height: 8 * scale),
                        _buildDropdownField<IdentificationTypeModel>(
                          value: _selectedIdentificationType,
                          items: _identificationTypes,
                          isLoading: _isLoadingCatalogs,
                          fieldColor: fieldColor,
                          scale: scale,
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          getLabel: _resolveIdentificationTypeName,
                          icon: Icons.badge_outlined,
                          onChanged: (value) {
                            setState(() {
                              _selectedIdentificationType = value;
                            });
                          },
                        ),
                        SizedBox(height: 16 * scale),
                        _buildLabel('TIPO DE USUARIO', secondaryColor),
                        SizedBox(height: 8 * scale),
                        _buildDropdownField<UserTypeModel>(
                          value: _selectedUserType,
                          items: _userTypes,
                          isLoading: _isLoadingCatalogs,
                          fieldColor: fieldColor,
                          scale: scale,
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          getLabel: _resolveUserTypeName,
                          icon: Icons.groups_outlined,
                          onChanged: (value) {
                            setState(() {
                              _selectedUserType = value;
                            });
                          },
                        ),
                        SizedBox(height: 16 * scale),
                        _buildLabel('NUMERO DE IDENTIFICACION', secondaryColor),
                        SizedBox(height: 8 * scale),
                        _buildTextField(
                          controller: _documentController,
                          hintText: 'Numero de documento',
                          prefixIcon: Icons.numbers_rounded,
                          keyboardType: TextInputType.number,
                          fieldColor: fieldColor,
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          scale: scale,
                        ),
                        SizedBox(height: 16 * scale),
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
                        SizedBox(height: 16 * scale),
                        _buildLabel('TELEFONO', secondaryColor),
                        SizedBox(height: 8 * scale),
                        _buildTextField(
                          controller: _phoneController,
                          hintText: '+57 300 000 0000',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          fieldColor: fieldColor,
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          scale: scale,
                        ),
                        SizedBox(height: 16 * scale),
                        _buildLabel('CONTRASENA', secondaryColor),
                        SizedBox(height: 8 * scale),
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'Minimo 8 caracteres',
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
                        SizedBox(height: 16 * scale),
                        _buildLabel('CONFIRMAR CONTRASENA', secondaryColor),
                        SizedBox(height: 8 * scale),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Repite tu contrasena',
                          prefixIcon: Icons.lock_person_outlined,
                          obscureText: _obscureConfirmPassword,
                          fieldColor: fieldColor,
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          scale: scale,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: secondaryColor,
                              size: 20 * scale,
                            ),
                          ),
                        ),
                        SizedBox(height: 18 * scale),
                        _buildTermsCard(scale, isDark, secondaryColor),
                        SizedBox(height: 22 * scale),
                        _buildPrimaryButton(scale),
                        SizedBox(height: 18 * scale),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ya tienes cuenta? ',
                              style: GoogleFonts.poppins(
                                color: secondaryColor,
                                fontSize: ResponsiveUtils.fontSize(context, 14),
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
                                'Inicia sesion',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF2563EB),
                                  fontSize:
                                      ResponsiveUtils.fontSize(context, 14),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(double scale) {
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
            top: -26 * scale,
            right: -18 * scale,
            child: Container(
              width: 140 * scale,
              height: 140 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -42 * scale,
            left: -24 * scale,
            child: Container(
              width: 150 * scale,
              height: 150 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54 * scale,
                height: 54 * scale,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18 * scale),
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Colors.white,
                  size: 28 * scale,
                ),
              ),
              SizedBox(height: 20 * scale),
              Text(
                'Crea tu cuenta y\nempieza con fuerza',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.fontSize(context, 30),
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 10 * scale),
              Text(
                'Un registro mas limpio, mas serio y mas alineado con el proyecto para que el primer contacto se sienta premium.',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                  height: 1.55,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTips(double scale, bool isDark) {
    final bgColor = isDark ? const Color(0xFF172338) : const Color(0xFFF4F7FE);
    final textColor =
        isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475467);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22 * scale),
      ),
      child: Column(
        children: [
          _buildTipRow(Icons.verified_user_outlined,
              'Datos verificados y claros', textColor, scale),
          SizedBox(height: 10 * scale),
          _buildTipRow(Icons.speed_rounded,
              'Entrada mas rapida en futuras visitas', textColor, scale),
          SizedBox(height: 10 * scale),
          _buildTipRow(Icons.shield_outlined,
              'Control de acceso desde tu dispositivo', textColor, scale),
        ],
      ),
    );
  }

  Widget _buildTipRow(
    IconData icon,
    String text,
    Color textColor,
    double scale,
  ) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4F46E5), size: 18 * scale),
        SizedBox(width: 10 * scale),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: ResponsiveUtils.fontSize(context, 12),
            ),
          ),
        ),
      ],
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

  Widget _buildDropdownField<T>({
    required T? value,
    required List<T> items,
    required bool isLoading,
    required Color fieldColor,
    required double scale,
    required Color textColor,
    required Color secondaryColor,
    required String Function(T item) getLabel,
    required IconData icon,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      child: isLoading
          ? SizedBox(
              height: 56 * scale,
              child: Row(
                children: [
                  Icon(icon, color: secondaryColor, size: 20 * scale),
                  SizedBox(width: 12 * scale),
                  Text(
                    'Cargando...',
                    style: GoogleFonts.poppins(
                      color: secondaryColor,
                      fontSize: ResponsiveUtils.fontSize(context, 14),
                    ),
                  ),
                ],
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: secondaryColor,
                  size: 22 * scale,
                ),
                dropdownColor: fieldColor,
                borderRadius: BorderRadius.circular(18 * scale),
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                  fontWeight: FontWeight.w500,
                ),
                items: items
                    .map(
                      (item) => DropdownMenuItem<T>(
                        value: item,
                        child: Row(
                          children: [
                            Icon(icon, color: secondaryColor, size: 20 * scale),
                            SizedBox(width: 12 * scale),
                            Expanded(
                              child: Text(
                                getLabel(item),
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: textColor,
                                  fontSize:
                                      ResponsiveUtils.fontSize(context, 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
    );
  }

  Widget _buildTermsCard(double scale, bool isDark, Color secondaryColor) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF172338) : const Color(0xFFF4F7FE),
        borderRadius: BorderRadius.circular(22 * scale),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 24 * scale,
              height: 24 * scale,
              decoration: BoxDecoration(
                color:
                    _acceptTerms ? const Color(0xFF2563EB) : Colors.transparent,
                borderRadius: BorderRadius.circular(8 * scale),
                border: Border.all(
                  color: _acceptTerms
                      ? const Color(0xFF2563EB)
                      : secondaryColor.withValues(alpha: 0.45),
                  width: 1.4,
                ),
              ),
              child: _acceptTerms
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16 * scale,
                    )
                  : null,
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  color: secondaryColor,
                  fontSize: ResponsiveUtils.fontSize(context, 12),
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Acepto los '),
                  TextSpan(
                    text: 'Terminos y Condiciones',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' y la '),
                  TextSpan(
                    text: 'Politica de Privacidad',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' para continuar en FlexiDrive.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(double scale) {
    return Container(
      decoration: BoxDecoration(
        gradient: _acceptTerms
            ? const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
              )
            : null,
        color: _acceptTerms ? null : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(18 * scale),
        boxShadow: _acceptTerms
            ? [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: (_acceptTerms && !_isSubmitting) ? _submitRegister : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
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
                    'Crear cuenta',
                    style: GoogleFonts.poppins(
                      color:
                          _acceptTerms ? Colors.white : const Color(0xFF9CA3AF),
                      fontSize: ResponsiveUtils.fontSize(context, 16),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color:
                        _acceptTerms ? Colors.white : const Color(0xFF9CA3AF),
                    size: 18 * scale,
                  ),
                ],
              ),
      ),
    );
  }
}

// Flutter framework
import 'package:flutter/material.dart';
// Fuentes bonitas de Google
import 'package:google_fonts/google_fonts.dart';
// Servicios para manejar usuarios y catalogos
import 'package:flexidrive/features/accounts/application/use_cases/account_access_use_case.dart';
import 'package:flexidrive/features/catalogs/application/use_cases/catalog_access_use_case.dart';
// Modelos de catalogos (tipos de documento, etc)
import 'package:flexidrive/features/catalogs/domain/entities/catalog_models.dart';
// Utilidades responsive
import 'package:flexidrive/core/utils/responsive_utils.dart';
import 'package:flexidrive/injection_container.dart';
// Pagina de inicio de sesión (si ya tiene cuenta)
import 'package:flexidrive/features/auth/presentation/pages/login/login_page.dart';

// Pagina de registro de nuevos usuarios
// Formulario para crear una cuenta en FlexiDrive
class RegisterPage extends StatefulWidget {
  /// Crea una instancia y prepara el estado inicial de `RegisterPage`.
  const RegisterPage({super.key});

  /// Gestiona crear estado dentro de esta parte del flujo.
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// Estado de la pagina de registro
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

  // Controladores de los campos del formulario
  final _nameController = TextEditingController(); // Nombre completo
  final _documentController = TextEditingController(); // Numero de documento
  final _emailController = TextEditingController(); // Email
  final _phoneController = TextEditingController(); // Telefono
  final _passwordController = TextEditingController(); // Contraseña
  final _confirmPasswordController =
      TextEditingController(); // Confirmar contraseña

  // Servicios para registro y catalogos
  final AccountAccessUseCase _accountRepository =
      InjectionContainer.instance.accountAccessUseCase;
  final CatalogAccessUseCase _catalogDb =
      InjectionContainer.instance.catalogAccessUseCase;

  // Estados de la UI
  bool _obscurePassword = true; // Ocultar contraseña
  bool _obscureConfirmPassword = true; // Ocultar confirmacion
  bool _acceptTerms = false; // Acepta terminos y condiciones
  bool _isSubmitting = false; // Esta enviando el formulario?
  bool _isLoadingCatalogs = true; // Cargando tipos de documento?

  // Catalogo de tipos de documento (CC, CE, Pasaporte, etc)
  List<IdentificationTypeModel> _identificationTypes = [];
  IdentificationTypeModel? _selectedIdentificationType; // Tipo seleccionado
  List<UserTypeModel> _userTypes = [];
  UserTypeModel? _selectedUserType;

  // Muestra un dialogo con mensaje
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  /// Inicializa el proceso de inicialización del estado antes de su uso.
  @override
  void initState() {
    super.initState();
    _loadIdentificationTypes();
  }

  /// Carga los datos necesarios para cargar identification types.
  Future<void> _loadIdentificationTypes() async {
    setState(() {
      _isLoadingCatalogs = true;
    });

    try {
      await _catalogDb.loadIfNeeded();

      final normalizedTypes = _catalogDb.identificationTypes
          .map((type) => IdentificationTypeModel(
                id: type.id,
                name: _resolveIdentificationTypeName(type),
                description: type.description,
              ))
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
        if (_identificationTypes.isNotEmpty) {
          _selectedIdentificationType = _identificationTypes.first;
        }
        _userTypes = finalUserTypes;
        if (_userTypes.isNotEmpty) {
          _selectedUserType = _userTypes.first;
        }
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
      final normalizedName = _normalizeText(type.name);
      // Priorizamos el primer elemento para mantener estabilidad en el orden inicial.
      uniqueByNormalizedName.putIfAbsent(normalizedName, () => type);
    }
    final uniqueTypes = uniqueByNormalizedName.values.toList();

    final typesByNormalizedName = <String, IdentificationTypeModel>{
      for (final type in uniqueTypes) _normalizeText(type.name): type,
    };

    final selectedOrderedTypes = <IdentificationTypeModel>[];
    for (final preferredName in _preferredColombianIdentificationTypes) {
      final matched = typesByNormalizedName[_normalizeText(preferredName)];
      if (matched != null &&
          !selectedOrderedTypes.any((item) => item.id == matched.id)) {
        selectedOrderedTypes.add(matched);
      }
    }

    for (final type in uniqueTypes) {
      if (!selectedOrderedTypes.any((item) => item.id == type.id)) {
        selectedOrderedTypes.add(type);
      }
    }

    return selectedOrderedTypes;
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  List<UserTypeModel> _buildOrderedUserTypes(List<UserTypeModel> userTypes) {
    final uniqueByNormalizedName = <String, UserTypeModel>{};
    for (final type in userTypes) {
      final normalizedName = _normalizeText(type.name);
      uniqueByNormalizedName.putIfAbsent(normalizedName, () => type);
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

  /// Construye y devuelve el widget correspondiente a esta sección.
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

  /// Construye y devuelve el widget correspondiente a esta sección.
  List<UserTypeModel> _buildLocalUserTypes() {
    return _fallbackUserTypeNamesById.entries
        .map(
          (entry) => UserTypeModel(
            id: entry.key,
            name: entry.value,
          ),
        )
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

  /// Gestiona resolve identification tipo name dentro de esta parte del flujo.
  String _resolveIdentificationTypeName(IdentificationTypeModel type) {
    final rawName = type.name.trim();
    if (rawName.isNotEmpty) return rawName;
    return _fallbackIdentificationNamesById[type.id] ?? '';
  }

  /// Gestiona resolve usuario tipo name dentro de esta parte del flujo.
  String _resolveUserTypeName(UserTypeModel type) {
    final rawName = type.name.trim();
    if (rawName.isNotEmpty) return rawName;
    return _fallbackUserTypeNamesById[type.id] ?? '';
  }

  /// Gestiona normalize text dentro de esta parte del flujo.
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

  /// Gestiona submit register dentro de esta parte del flujo.
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

  /// Gestiona dispose dentro de esta parte del flujo.
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

  /// Construye y devuelve el widget correspondiente a esta sección.
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
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 16 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              color:
                                  Colors.white.withAlpha((0.9 * 255).round()),
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
            // White tarjeta Section
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7FA),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<IdentificationTypeModel>(
                                  value: _selectedIdentificationType,
                                  isExpanded: true,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF111827),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey,
                                  ),
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  selectedItemBuilder: (context) {
                                    return _identificationTypes.map((type) {
                                      return _buildIdentificationTypeOption(
                                        type,
                                        selected: true,
                                      );
                                    }).toList();
                                  },
                                  items: _identificationTypes.map((type) {
                                    return DropdownMenuItem<
                                        IdentificationTypeModel>(
                                      value: type,
                                      child:
                                          _buildIdentificationTypeOption(type),
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
                      // Tipo de Usuario
                      _buildLabel('TIPO DE USUARIO'),
                      const SizedBox(height: 8),
                      _isLoadingCatalogs
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7FA),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.groups_outlined,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7FA),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<UserTypeModel>(
                                  value: _selectedUserType,
                                  isExpanded: true,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF111827),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey,
                                  ),
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  selectedItemBuilder: (context) {
                                    return _userTypes.map((type) {
                                      return _buildUserTypeOption(
                                        type,
                                        selected: true,
                                      );
                                    }).toList();
                                  },
                                  items: _userTypes.map((type) {
                                    return DropdownMenuItem<UserTypeModel>(
                                      value: type,
                                      child: _buildUserTypeOption(type),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedUserType = value;
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
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // alternar Switch
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
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (_acceptTerms && !_isSubmitting)
                              ? _submitRegister
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _acceptTerms ? null : const Color(0xFFE8ECF4),
                            foregroundColor: _acceptTerms
                                ? Colors.white
                                : const Color(0xFF9CA3AF),
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
                                      colors: [
                                        Color(0xFF2563EB),
                                        Color(0xFF7C3AED)
                                      ],
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
                      // inicio de sesión Link
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

  Widget _buildIdentificationTypeOption(
    IdentificationTypeModel type, {
    bool selected = false,
  }) {
    return Row(
      children: [
        Icon(
          Icons.badge_outlined,
          color: const Color(0xFF9CA3AF),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            type.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.black87, // Siempre negro para máxima visibilidad
              fontSize: 14,
              fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeOption(
    UserTypeModel type, {
    bool selected = false,
  }) {
    return Row(
      children: [
        Icon(
          Icons.groups_outlined,
          color: const Color(0xFF9CA3AF),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _resolveUserTypeName(type),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
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

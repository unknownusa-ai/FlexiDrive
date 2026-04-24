import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/theme/app_themes.dart';
import '../../../services/accounts/local_account_repository.dart';
import '../../../services/accounts/user_preference_service.dart';
import '../../../services/vehiculo_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final LocalAccountRepository _accountRepository = LocalAccountRepository();
  final VehiculoService _vehiculoService = VehiculoService();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _documentController = TextEditingController();
  
  String _selectedDocumentType = 'Cédula de Ciudadanía';
  int? _currentUserId;
  int? _documentTypeId;
  
  final List<String> _documentTypes = [
    'Cédula de Ciudadanía',
    'Cédula de Extranjería',
    'Pasaporte',
    'NIT',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = await _accountRepository.getCurrentUser();
      if (currentUser != null) {
        _currentUserId = currentUser.id;
        
        // Load users data to get document type
        await _vehiculoService.init();
        final users = _vehiculoService.usuarios;
        final userData = users.firstWhere(
          (user) => user['usuario_id'] == currentUser.id,
          orElse: () => {},
        );
        
        setState(() {
          _nameController.text = currentUser.fullName;
          _emailController.text = currentUser.email;
          _phoneController.text = userData['telefono']?.toString() ?? '';
          _documentController.text = userData['numero_identificacion']?.toString() ?? '';
          _documentTypeId = userData['tipo_identificacion_id'];
          
          // Set document type based on ID
          if (_documentTypeId != null) {
            switch (_documentTypeId) {
              case 1:
                _selectedDocumentType = 'Cédula de Ciudadanía';
                break;
              case 2:
                _selectedDocumentType = 'Cédula de Extranjería';
                break;
              case 3:
                _selectedDocumentType = 'Pasaporte';
                break;
              case 4:
                _selectedDocumentType = 'NIT';
                break;
            }
          }
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _documentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? AppThemes.darkBg : AppThemes.lightBg;
    final cardColor = isDark ? AppThemes.darkSurface : AppThemes.lightSurface;
    final textColor = isDark ? AppThemes.darkText : AppThemes.lightText;
    final labelColor = isDark ? AppThemes.darkTextSub : AppThemes.lightTextSub;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildGradientHeaderWithPhoto(isSmallPhone, isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallPhone ? 16 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isSmallPhone ? 20 : 24),
                  _buildTextField(
                    label: 'NOMBRE COMPLETO',
                    controller: _nameController,
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                    isSmallPhone: isSmallPhone,
                    borderColor: AppThemes.primaryIndigo,
                    iconColor: AppThemes.primaryIndigo,
                    cardColor: cardColor,
                    textColor: textColor,
                    labelColor: labelColor,
                  ),
                  SizedBox(height: isSmallPhone ? 12 : 16),
                  _buildTextField(
                    label: 'CORREO ELECTRÓNICO',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    isSmallPhone: isSmallPhone,
                    borderColor: AppThemes.primaryPurple,
                    iconColor: AppThemes.primaryPurple,
                    cardColor: cardColor,
                    textColor: textColor,
                    labelColor: labelColor,
                  ),
                  SizedBox(height: isSmallPhone ? 12 : 16),
                  _buildTextField(
                    label: 'TELÉFONO',
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    isSmallPhone: isSmallPhone,
                    borderColor: AppThemes.accentGreen,
                    iconColor: AppThemes.accentGreen,
                    cardColor: cardColor,
                    textColor: textColor,
                    labelColor: labelColor,
                  ),
                  SizedBox(height: isSmallPhone ? 12 : 16),
                  _buildDocumentTypeDropdown(isSmallPhone, cardColor, textColor, labelColor),
                  SizedBox(height: isSmallPhone ? 12 : 16),
                  _buildTextField(
                    label: 'NÚMERO DE DOCUMENTO',
                    controller: _documentController,
                    icon: Icons.folder_outlined,
                    keyboardType: TextInputType.number,
                    isSmallPhone: isSmallPhone,
                    borderColor: AppThemes.accentAmber,
                    iconColor: AppThemes.accentAmber,
                    cardColor: cardColor,
                    textColor: textColor,
                    labelColor: labelColor,
                  ),
                  SizedBox(height: isSmallPhone ? 32 : 48),
                ],
              ),
            ),
          ),
          _buildSaveButton(isSmallPhone, isDark),
        ],
      ),
    );
  }

  Widget _buildGradientHeaderWithPhoto(bool isSmallPhone, bool isDark) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isSmallPhone ? 16 : 20,
                    isSmallPhone ? 8 : 12,
                    isSmallPhone ? 16 : 20,
                    isSmallPhone ? 16 : 20,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: isSmallPhone ? 36 : 40,
                          height: isSmallPhone ? 36 : 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
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
                        'Editar Perfil',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isSmallPhone ? 18 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildProfilePhotoInGradient(isSmallPhone, isDark),
                SizedBox(height: isSmallPhone ? 20 : 24),
              ],
            ),
          ),
        ),
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhotoInGradient(bool isSmallPhone, bool isDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: isSmallPhone ? 90 : 110,
              height: isSmallPhone ? 90 : 110,
              decoration: BoxDecoration(
                color: isDark ? AppThemes.darkSurface : Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: isSmallPhone ? 45 : 55,
                      color: AppThemes.primaryIndigo,
                    );
                  },
                ),
              ),
            ),
            GestureDetector(
              onTap: _changePhoto,
              child: Container(
                width: isSmallPhone ? 30 : 34,
                height: isSmallPhone ? 30 : 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppThemes.primaryIndigo,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: AppThemes.primaryIndigo,
                  size: isSmallPhone ? 16 : 18,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallPhone ? 10 : 12),
        Text(
          'Toca el icono para cambiar tu foto',
          style: GoogleFonts.inter(
            fontSize: isSmallPhone ? 12 : 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required TextInputType keyboardType,
    required bool isSmallPhone,
    Color? borderColor,
    Color? iconColor,
    required Color cardColor,
    required Color textColor,
    required Color labelColor,
  }) {
    final actualBorderColor = borderColor ?? AppThemes.primaryIndigo;
    final actualIconColor = iconColor ?? AppThemes.primaryIndigo;
    
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
        SizedBox(height: isSmallPhone ? 4 : 6),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: actualBorderColor,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 14 : 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: actualIconColor,
                size: isSmallPhone ? 18 : 20,
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

  Widget _buildDocumentTypeDropdown(bool isSmallPhone, Color cardColor, Color textColor, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TIPO DE DOCUMENTO',
          style: GoogleFonts.inter(
            fontSize: isSmallPhone ? 10 : 11,
            fontWeight: FontWeight.w500,
            color: labelColor,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: isSmallPhone ? 4 : 6),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppThemes.accentAmber,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDocumentType,
              isExpanded: true,
              icon: Padding(
                padding: EdgeInsets.only(right: isSmallPhone ? 12 : 16),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppThemes.accentAmber,
                  size: isSmallPhone ? 20 : 22,
                ),
              ),
              selectedItemBuilder: (context) {
                return _documentTypes.map((type) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallPhone ? 12 : 16,
                        vertical: isSmallPhone ? 12 : 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            color: AppThemes.accentAmber,
                            size: isSmallPhone ? 18 : 20,
                          ),
                          SizedBox(width: isSmallPhone ? 8 : 12),
                          Text(
                            type,
                            style: GoogleFonts.inter(
                              fontSize: isSmallPhone ? 14 : 15,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();
              },
              items: _documentTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallPhone ? 13 : 14,
                      color: textColor,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedDocumentType = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isSmallPhone, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isSmallPhone ? 16 : 24,
        isSmallPhone ? 12 : 16,
        isSmallPhone ? 16 : 24,
        isSmallPhone ? 16 : 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkBg : AppThemes.lightSurface,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: _saveChanges,
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
                'Guardar Cambios',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: isSmallPhone ? 15 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _changePhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetColor = isDark ? AppThemes.darkSurface : AppThemes.lightSurface;
        final textColor = isDark ? AppThemes.darkText : AppThemes.lightText;
        
        return Container(
          decoration: BoxDecoration(
            color: sheetColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppThemes.darkBorder : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Cambiar foto de perfil',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildPhotoOption(
                        icon: Icons.camera_alt_outlined,
                        title: 'Tomar foto',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildPhotoOption(
                        icon: Icons.photo_library_outlined,
                        title: 'Elegir de la galería',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildPhotoOption(
                        icon: Icons.delete_outline,
                        title: 'Eliminar foto',
                        isDestructive: true,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDestructive
              ? const Color(0xFFFEF2F2)
              : isDark ? AppThemes.darkSurfaceHi : AppThemes.lightBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? AppThemes.accentRed
                  : AppThemes.primaryIndigo,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDestructive
                    ? AppThemes.accentRed
                    : isDark ? AppThemes.darkText : AppThemes.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() async {
    try {
      if (_currentUserId != null) {
        // Get document type ID from selected type
        int documentTypeId = 1; // Default
        switch (_selectedDocumentType) {
          case 'Cédula de Ciudadanía':
            documentTypeId = 1;
            break;
          case 'Cédula de Extranjería':
            documentTypeId = 2;
            break;
          case 'Pasaporte':
            documentTypeId = 3;
            break;
          case 'NIT':
            documentTypeId = 4;
            break;
        }
        
        // Note: In a real implementation, you would call a service method here
        // to update the user data. For now, we just show a success message.
        // The update would be similar to _accountRepository.updatePassword() pattern
        
        print('Profile update requested:');
        print('User ID: $_currentUserId');
        print('Name: ${_nameController.text.trim()}');
        print('Email: ${_emailController.text.trim()}');
        print('Phone: ${_phoneController.text.trim()}');
        print('Document: ${_documentController.text.trim()}');
        print('Document Type ID: $documentTypeId');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Perfil actualizado exitosamente',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: AppThemes.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al actualizar perfil: $e',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}

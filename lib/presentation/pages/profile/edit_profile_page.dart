import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_utils.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController(text: 'Carlos Rodríguez');
  final _emailController = TextEditingController(text: 'carlos.rodriguez@email.com');
  final _phoneController = TextEditingController(text: '310 456 7890');
  final _documentController = TextEditingController(text: '1.023.456.789');
  
  String _selectedDocumentType = 'Cédula de Ciudadanía';
  
  final List<String> _documentTypes = [
    'Cédula de Ciudadanía',
    'Cédula de Extranjería',
    'Pasaporte',
    'NIT',
  ];

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildGradientHeaderWithPhoto(isSmallPhone),
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
                    borderColor: const Color(0xFF2563EB),
                    iconColor: const Color(0xFF2563EB),
                  ),
                  SizedBox(height: isSmallPhone ? 12 : 16),
                  _buildTextField(
                    label: 'CORREO ELECTRÓNICO',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    isSmallPhone: isSmallPhone,
                    borderColor: const Color(0xFF8B5CF6),
                    iconColor: const Color(0xFF8B5CF6),
                  ),
                  SizedBox(height: isSmallPhone ? 12 : 16),
                  _buildTextField(
                    label: 'TELÉFONO',
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    isSmallPhone: isSmallPhone,
                    borderColor: const Color(0xFF10B981),
                    iconColor: const Color(0xFF10B981),
                  ),
                  SizedBox(height: isSmallPhone ? 12 : 16),
                  _buildDocumentTypeDropdown(isSmallPhone),
                  SizedBox(height: isSmallPhone ? 12 : 16),
                  _buildTextField(
                    label: 'NÚMERO DE DOCUMENTO',
                    controller: _documentController,
                    icon: Icons.folder_outlined,
                    keyboardType: TextInputType.number,
                    isSmallPhone: isSmallPhone,
                    borderColor: const Color(0xFFF59E0B),
                    iconColor: const Color(0xFFF59E0B),
                  ),
                  SizedBox(height: isSmallPhone ? 32 : 48),
                ],
              ),
            ),
          ),
          _buildSaveButton(isSmallPhone),
        ],
      ),
    );
  }

  Widget _buildGradientHeaderWithPhoto(bool isSmallPhone) {
    return Stack(
      children: [
        // Background gradient with bubble
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
                // Header with back button
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
                // Profile photo inside gradient area
                _buildProfilePhotoInGradient(isSmallPhone),
                SizedBox(height: isSmallPhone ? 20 : 24),
              ],
            ),
          ),
        ),
        // Decorative bubble in top-right corner
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhotoInGradient(bool isSmallPhone) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: isSmallPhone ? 90 : 110,
              height: isSmallPhone ? 90 : 110,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
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
                      color: const Color(0xFF2563EB),
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
                    color: const Color(0xFF2563EB),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: const Color(0xFF2563EB),
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
            color: Colors.white.withOpacity(0.9),
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
  }) {
    final actualBorderColor = borderColor ?? const Color(0xFF2563EB);
    final actualIconColor = iconColor ?? const Color(0xFF2563EB);
    
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
        SizedBox(height: isSmallPhone ? 4 : 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
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
              color: const Color(0xFF1A1A1A),
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

  Widget _buildDocumentTypeDropdown(bool isSmallPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TIPO DE DOCUMENTO',
          style: GoogleFonts.inter(
            fontSize: isSmallPhone ? 10 : 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: isSmallPhone ? 4 : 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFF59E0B),
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
                  color: const Color(0xFFF59E0B),
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
                            color: const Color(0xFFF59E0B),
                            size: isSmallPhone ? 18 : 20,
                          ),
                          SizedBox(width: isSmallPhone ? 8 : 12),
                          Text(
                            type,
                            style: GoogleFonts.inter(
                              fontSize: isSmallPhone ? 14 : 15,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A1A1A),
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

  Widget _buildSaveButton(bool isSmallPhone) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isSmallPhone ? 16 : 24,
        isSmallPhone ? 12 : 16,
        isSmallPhone ? 16 : 24,
        isSmallPhone ? 16 : 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: Colors.grey.shade300,
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
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildPhotoOption(
                      icon: Icons.camera_alt_outlined,
                      title: 'Tomar foto',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implement camera
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPhotoOption(
                      icon: Icons.photo_library_outlined,
                      title: 'Elegir de la galería',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implement gallery picker
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPhotoOption(
                      icon: Icons.delete_outline,
                      title: 'Eliminar foto',
                      isDestructive: true,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implement delete
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDestructive
              ? const Color(0xFFFEF2F2)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF2563EB),
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDestructive
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() {
    // TODO: Implement save logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Perfil actualizado exitosamente',
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    Navigator.pop(context);
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_utils.dart';
import 'principal_arrendatario_page.dart';

class PublicarVehiculoPage extends StatefulWidget {
  const PublicarVehiculoPage({super.key});

  @override
  State<PublicarVehiculoPage> createState() => _PublicarVehiculoPageState();
}

class _PublicarVehiculoPageState extends State<PublicarVehiculoPage> {
  int currentStep = 1;
  String? selectedCategory;
  String? selectedTransmission;
  int? selectedSeats;
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController marcaController = TextEditingController();
  final TextEditingController anoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController ubicacionController = TextEditingController();

  final List<String> categories = [
    'Sedán',
    'SUV',
    'Compacto',
    'Premium',
    'Deportivo',
    'Eléctrico',
  ];

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: Column(
        children: [
          _buildHeader(isSmallPhone),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isSmallPhone ? 14 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: currentStep == 1
                      ? _buildStepOneContent(isSmallPhone)
                      : currentStep == 2
                          ? _buildStepTwoContent(isSmallPhone)
                          : _buildStepThreeContent(isSmallPhone),
                ),
              ),
            ),
          ),
          _buildBottomButton(isSmallPhone),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSmallPhone) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isSmallPhone ? 16 : 20,
        MediaQuery.of(context).padding.top + (isSmallPhone ? 12 : 16),
        isSmallPhone ? 16 : 20,
        isSmallPhone ? 16 : 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFF7A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Publicar Vehículo',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Paso $currentStep de 3',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: currentStep / 3,
        minHeight: 7,
        backgroundColor: Colors.white.withValues(alpha: 0.28),
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  List<Widget> _buildStepOneContent(bool isSmallPhone) {
    return [
      _buildPhotoUploadArea(isSmallPhone),
      const SizedBox(height: 20),
      _buildFormField(
        label: 'Nombre del vehículo',
        hint: 'Ej: Mazda 3 Grand Touring',
        controller: nombreController,
        isSmallPhone: isSmallPhone,
      ),
      const SizedBox(height: 16),
      _buildFormField(
        label: 'Marca',
        hint: 'Ej: Mazda',
        controller: marcaController,
        isSmallPhone: isSmallPhone,
      ),
      const SizedBox(height: 20),
      _buildCategorySection(isSmallPhone),
      const SizedBox(height: 40),
    ];
  }

  List<Widget> _buildStepTwoContent(bool isSmallPhone) {
    return [
      _buildFormField(
        label: 'Año',
        hint: 'Ej: 2023',
        controller: anoController,
        isSmallPhone: isSmallPhone,
      ),
      const SizedBox(height: 20),
      _buildTransmissionSection(),
      const SizedBox(height: 20),
      _buildSeatsSection(),
      const SizedBox(height: 20),
      _buildDescriptionSection(),
      const SizedBox(height: 40),
    ];
  }

  List<Widget> _buildStepThreeContent(bool isSmallPhone) {
    return [
      _buildPriceField(),
      const SizedBox(height: 20),
      _buildLocationField(),
      const SizedBox(height: 24),
      _buildPotentialCard(),
      const SizedBox(height: 40),
    ];
  }

  Widget _buildPhotoUploadArea(bool isSmallPhone) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 48,
            color: const Color(0xFF7C3AED),
          ),
          const SizedBox(height: 12),
          Text(
            'Subir fotos del vehículo',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Máx. 5 fotos (JPG, PNG)',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isSmallPhone,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + ' *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            return TextField(
              controller: controller,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFFC5D0DD),
                ),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFF59E0B),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF0F172A),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection(bool isSmallPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransmissionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transmisión *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOptionChip(
                label: 'Manual',
                selected: selectedTransmission == 'Manual',
                onTap: () {
                  setState(() {
                    selectedTransmission = 'Manual';
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildOptionChip(
                label: 'Automática',
                selected: selectedTransmission == 'Automática',
                onTap: () {
                  setState(() {
                    selectedTransmission = 'Automática';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeatsSection() {
    const options = [2, 4, 5, 7];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Número de puestos *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: options
              .map(
                (item) => Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(right: item == options.last ? 0 : 10),
                    child: _buildOptionChip(
                      label: '$item',
                      selected: selectedSeats == item,
                      onTap: () {
                        setState(() {
                          selectedSeats = item;
                        });
                      },
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción (opcional)',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descripcionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText:
                'Describe tu vehículo, características especiales, etc...',
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Precio por día (COP) *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: precioController,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '150000',
            hintStyle: GoogleFonts.inter(
              fontSize: 32,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Text(
                '\$',
                style: GoogleFonts.inter(
                  fontSize: 38,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: GoogleFonts.inter(
            fontSize: 32,
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '💡 Recomendación: \$120,000 - \$200,000 por día para tu categoría',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubicación *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ubicacionController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFF94A3B8),
              size: 28,
            ),
            hintText: '',
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildPotentialCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F9F0),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF86E2B7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFBAEBD2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt, color: Color(0xFF10B981), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Potencial de ganancias',
                  style: GoogleFonts.inter(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Si rentas 15 días al mes, podrías ganar hasta',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF047857),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$2,250,000 mensuales',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF59E0B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }

  bool _isFormValid() {
    return nombreController.text.isNotEmpty &&
        marcaController.text.isNotEmpty &&
        selectedCategory != null;
  }

  bool _isStepTwoValid() {
    return anoController.text.isNotEmpty &&
        selectedTransmission != null &&
        selectedSeats != null;
  }

  bool _isStepThreeValid() {
    return precioController.text.trim().isNotEmpty &&
        ubicacionController.text.trim().isNotEmpty;
  }

  String _formatCopAmount(String rawValue) {
    final digitsOnly = rawValue.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return '\$0';

    final buffer = StringBuffer();
    int count = 0;
    for (int index = digitsOnly.length - 1; index >= 0; index--) {
      buffer.write(digitsOnly[index]);
      count++;
      if (count % 3 == 0 && index != 0) {
        buffer.write('.');
      }
    }

    return '\$${buffer.toString().split('').reversed.join()}';
  }

  String _capitalizeWords(String value) {
    if (value.trim().isEmpty) return value;
    return value
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  void _resetForNewVehicle() {
    setState(() {
      currentStep = 1;
      selectedCategory = null;
      selectedTransmission = null;
      selectedSeats = null;
      nombreController.clear();
      marcaController.clear();
      anoController.clear();
      descripcionController.clear();
      precioController.clear();
      ubicacionController.clear();
    });
  }

  void _handleGoHomeFromSuccess(BuildContext dialogContext) {
    Navigator.of(dialogContext).pop();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const PrincipalArrendatarioPage(),
      ),
      (route) => false,
    );
  }

  void _handlePublishAnotherVehicle(BuildContext dialogContext) {
    Navigator.of(dialogContext).pop();
    if (!mounted) return;
    _resetForNewVehicle();
  }

  Future<void> _showPublishSuccessDialog() async {
    final formattedPrice = _formatCopAmount(precioController.text);
    final location = _capitalizeWords(ubicacionController.text);
    final vehicleName = nombreController.text.trim().isEmpty
        ? 'vehículo'
        : nombreController.text.trim();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 20),
                const Text('🎉', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 12),
                Text(
                  '¡Vehículo Publicado con\nÉxito!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF94A3B8),
                      height: 1.45,
                    ),
                    children: [
                      const TextSpan(text: 'Tu '),
                      TextSpan(
                        text: vehicleName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' ya está disponible para que otros\nusuarios lo renten. ¡Comienza a generar\ningresos!',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFAF1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFF7D79B)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Precio/día',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formattedPrice,
                              style: GoogleFonts.inter(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 56,
                        color: const Color(0xFFF1DDB4),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Ubicación',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              location,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      _handleGoHomeFromSuccess(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Volver al Inicio',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      _handlePublishAnotherVehicle(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE2E8F0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Publicar Otro Vehículo',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButton(bool isSmallPhone) {
    final isStepOneValid = _isFormValid();
    final isStepTwoValid = _isStepTwoValid();
    final isStepThreeValid = _isStepThreeValid();
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F7F9),
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      padding: EdgeInsets.fromLTRB(
        isSmallPhone ? 14 : 16,
        12,
        isSmallPhone ? 14 : 16,
        isSmallPhone ? 16 : 20,
      ),
      child: currentStep == 1
          ? SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isStepOneValid
                    ? () {
                        setState(() {
                          currentStep = 2;
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isStepOneValid
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Continuar →',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isStepOneValid
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          : currentStep == 2
              ? Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              currentStep = 1;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Atrás',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isStepTwoValid
                              ? () {
                                  setState(() {
                                    currentStep = 3;
                                  });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isStepTwoValid
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Continuar →',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isStepTwoValid
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              currentStep = 2;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Atrás',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isStepThreeValid
                              ? () {
                                  _showPublishSuccessDialog();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isStepThreeValid
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Publicar Vehículo 🚗',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isStepThreeValid
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    marcaController.dispose();
    anoController.dispose();
    descripcionController.dispose();
    precioController.dispose();
    ubicacionController.dispose();
    super.dispose();
  }
}

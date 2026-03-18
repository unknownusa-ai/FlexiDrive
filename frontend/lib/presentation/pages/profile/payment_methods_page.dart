import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/theme/app_themes.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': '1',
      'type': 'card',
      'brand': 'visa',
      'last4': '4521',
      'expiry': '12/26',
      'isDefault': true,
      'name': 'Carlos Rodríguez',
    },
    {
      'id': '2',
      'type': 'card',
      'brand': 'mastercard',
      'last4': '8834',
      'expiry': '08/25',
      'isDefault': false,
      'name': 'Carlos Rodríguez',
    },
  ];

  final List<Map<String, dynamic>> _otherMethods = [
    {
      'id': 'pse',
      'title': 'PSE',
      'subtitle': 'Débito bancario directo',
      'icon': Icons.account_balance_outlined,
      'iconBg': const Color(0xFFEDE9FE),
      'iconColor': const Color(0xFF7C3AED),
      'isActive': true,
    },
    {
      'id': 'cash',
      'title': 'Efectivo',
      'subtitle': 'Pago al recibir el vehículo',
      'icon': Icons.attach_money_rounded,
      'iconBg': const Color(0xFFD1FAE5),
      'iconColor': const Color(0xFF10B981),
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? AppThemes.darkBg : AppThemes.lightBg;
    final cardColor = isDark ? AppThemes.darkSurface : AppThemes.lightSurface;
    final textColor = isDark ? AppThemes.darkText : AppThemes.lightText;
    final secondaryTextColor = isDark ? AppThemes.darkTextSub : AppThemes.lightTextSub;
    final dividerColor = isDark ? AppThemes.darkDivider : AppThemes.lightBorder;

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
                  _buildSavedCardsSection(isSmallPhone, isDark),
                  SizedBox(height: isSmallPhone ? 12 : 16),
                  _buildAddCardButton(isSmallPhone, isDark, cardColor),
                  SizedBox(height: isSmallPhone ? 16 : 20),
                  _buildOtherMethodsSection(isSmallPhone, isDark, cardColor, textColor, secondaryTextColor, dividerColor),
                  SizedBox(height: isSmallPhone ? 12 : 16),
                  _buildSecurityBadge(isSmallPhone, isDark),
                  SizedBox(height: isSmallPhone ? 20 : 24),
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: isSmallPhone ? 36 : 40,
                          height: isSmallPhone ? 36 : 40,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.2),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Métodos de Pago',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: isSmallPhone ? 20 : 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_paymentMethods.length} tarjetas guardadas',
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: isSmallPhone ? 12 : 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Decorative bubble top-right
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 30,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedCardsSection(bool isSmallPhone, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TARJETAS GUARDADAS',
          style: GoogleFonts.inter(
            fontSize: isSmallPhone ? 11 : 12,
            fontWeight: FontWeight.w700,
            color: isDark ? AppThemes.darkTextSub : AppThemes.lightTextSub,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: isSmallPhone ? 10 : 12),
        ..._paymentMethods
            .map((method) => _buildGradientCard(method, isSmallPhone, isDark)),
      ],
    );
  }

  Widget _buildGradientCard(Map<String, dynamic> method, bool isSmallPhone, bool isDark) {
    final bool isDefault = method['isDefault'] as bool;
    final bool isVisa = method['brand'] == 'visa';

    final List<Color> gradientColors = isDefault
        ? [const Color(0xFF4F46E5), const Color(0xFF6D28D9)]
        : [const Color(0xFF7C3AED), const Color(0xFF9D4EDD)];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: isDark ? 0.4 : 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -15,
            right: -15,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            right: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isSmallPhone ? 14 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: card number dots + delete icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '····  ····  ····  ${method['last4']}',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: isSmallPhone ? 13 : 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _confirmDeleteCard(method),
                      child: Container(
                        width: isSmallPhone ? 28 : 32,
                        height: isSmallPhone ? 28 : 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: isSmallPhone ? 14 : 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallPhone ? 8 : 10),
                // Cardholder name
                Text(
                  method['name'],
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isSmallPhone ? 14 : 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: isSmallPhone ? 2 : 3),
                Text(
                  '${isVisa ? 'Visa' : 'Mastercard'} · ${method['expiry']}',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: isSmallPhone ? 11 : 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: isSmallPhone ? 12 : 14),
                // Bottom row: default badge + set default button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isDefault)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallPhone ? 8 : 10,
                          vertical: isSmallPhone ? 3 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: isSmallPhone ? 10 : 12,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'PREDEFINIDA',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: isSmallPhone ? 9 : 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => _setAsDefault(method),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallPhone ? 8 : 10,
                            vertical: isSmallPhone ? 3 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Usar como predefinida',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: isSmallPhone ? 9 : 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    // Brand logo
                    _buildBrandLogo(isVisa, isSmallPhone),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandLogo(bool isVisa, bool isSmallPhone) {
    if (isVisa) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallPhone ? 10 : 12,
          vertical: isSmallPhone ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'VISA',
          style: GoogleFonts.inter(
            fontSize: isSmallPhone ? 11 : 13,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1F71),
            letterSpacing: 1,
          ),
        ),
      );
    } else {
      // Mastercard two-circle logo
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmallPhone ? 22 : 26,
            height: isSmallPhone ? 22 : 26,
            decoration: BoxDecoration(
              color: const Color(0xFFEB001B),
              shape: BoxShape.circle,
            ),
          ),
          Transform.translate(
            offset: const Offset(-8, 0),
            child: Container(
              width: isSmallPhone ? 22 : 26,
              height: isSmallPhone ? 22 : 26,
              decoration: BoxDecoration(
                color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildAddCardButton(bool isSmallPhone, bool isDark, Color cardColor) {
    return GestureDetector(
      onTap: _showAddPaymentMethodDialog,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: isSmallPhone ? 14 : 16),
        decoration: BoxDecoration(
          color: isDark ? cardColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppThemes.primaryIndigo.withValues(alpha: isDark ? 0.5 : 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: AppThemes.primaryIndigo,
              size: isSmallPhone ? 18 : 20,
            ),
            SizedBox(width: isSmallPhone ? 8 : 10),
            Text(
              '+ Agregar nueva tarjeta',
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: AppThemes.primaryIndigo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherMethodsSection(bool isSmallPhone, bool isDark, Color cardColor, Color textColor, Color secondaryTextColor, Color dividerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OTROS MÉTODOS',
          style: GoogleFonts.inter(
            fontSize: isSmallPhone ? 11 : 12,
            fontWeight: FontWeight.w700,
            color: secondaryTextColor,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: isSmallPhone ? 10 : 12),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _otherMethods.asMap().entries.map((entry) {
              final index = entry.key;
              final method = entry.value;
              final isLast = index == _otherMethods.length - 1;
              return _buildOtherMethodRow(method, isSmallPhone, isLast, isDark, textColor, secondaryTextColor, dividerColor);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherMethodRow(
      Map<String, dynamic> method, bool isSmallPhone, bool isLast, bool isDark, Color textColor, Color secondaryTextColor, Color dividerColor) {
    final bool isActive = method['isActive'] as bool;
    // Keep original icon backgrounds in both light and dark mode
    final iconBg = method['iconBg'] as Color;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallPhone ? 16 : 20,
            vertical: isSmallPhone ? 12 : 14,
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: isSmallPhone ? 36 : 40,
                height: isSmallPhone ? 36 : 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  method['icon'] as IconData,
                  color: method['iconColor'] as Color,
                  size: isSmallPhone ? 18 : 20,
                ),
              ),
              SizedBox(width: isSmallPhone ? 12 : 14),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['title'],
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      method['subtitle'],
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 11 : 12,
                        fontWeight: FontWeight.w400,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallPhone ? 8 : 10,
                  vertical: isSmallPhone ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppThemes.accentGreen.withValues(alpha: isDark ? 0.2 : 0.15)
                      : isDark ? AppThemes.darkSurfaceEl : AppThemes.lightBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isActive ? 'ACTIVO' : 'INACTIVO',
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 9 : 10,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? AppThemes.accentGreen
                        : secondaryTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: dividerColor,
            indent: isSmallPhone ? 62 : 68,
          ),
      ],
    );
  }

  Widget _buildSecurityBadge(bool isSmallPhone, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 14 : 16,
        vertical: isSmallPhone ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: AppThemes.accentGreen.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppThemes.accentGreen.withValues(alpha: isDark ? 0.3 : 0.2), 
          width: 1
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: AppThemes.accentGreen,
            size: isSmallPhone ? 12 : 14,
          ),
          SizedBox(width: isSmallPhone ? 6 : 8),
          Flexible(
            child: Text(
              'Datos encriptados con SSL 256-bit · Certificado PCI DSS',
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 10 : 11,
                fontWeight: FontWeight.w500,
                color: AppThemes.accentGreen,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _setAsDefault(Map<String, dynamic> selected) {
    setState(() {
      for (final method in _paymentMethods) {
        method['isDefault'] = method['id'] == selected['id'];
      }
    });
    _showSnackBar('Tarjeta predefinida actualizada');
  }

  void _confirmDeleteCard(Map<String, dynamic> method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Eliminar tarjeta',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          '¿Deseas eliminar la tarjeta terminada en ${method['last4']}?',
          style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? AppThemes.darkTextSub : AppThemes.lightTextSub),
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
              setState(() {
                _paymentMethods.removeWhere((m) => m['id'] == method['id']);
              });
              _showSnackBar('Tarjeta eliminada');
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

  void _showAddPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Agregar método de pago',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card, color: AppThemes.primaryIndigo),
              title: Text(
                'Tarjeta de crédito/débito',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Agregar tarjeta');
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.account_balance, color: AppThemes.primaryPurple),
              title: Text(
                'PSE',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Agregar cuenta PSE');
              },
            ),
          ],
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
        ],
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
}
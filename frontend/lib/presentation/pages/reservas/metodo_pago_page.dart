import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/session/local_session_store.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../models/reservations/reservation_models.dart';
import '../../../services/payments/local_payment_db.dart';
import '../../../services/reservations/local_reservation_db.dart';
import '../../../services/catalogs/local_catalog_db.dart';
import '../../../services/notifications/local_notification_db.dart';
import 'reserva_confirmada_page.dart';
import 'reservas_store.dart';

class MetodoPagoPage extends StatefulWidget {
  const MetodoPagoPage({
    super.key,
    this.total = 54900,
    this.alquilerVehiculo = 38000,
    this.servicioSeguro = 16900,
    this.periodo = 'Semanas',
    this.cantidad = 1,
    this.precioUnitario = 38000,
    this.vehiculoBrand = 'Mazda CX-5 2024',
    this.vehiculoImage = '',
    this.lugarRecogida = 'Av. El Dorado, Bogotá',
  });

  final int total;
  final int alquilerVehiculo;
  final int servicioSeguro;
  final String periodo;
  final int cantidad;
  final int precioUnitario;
  final String vehiculoBrand;
  final String vehiculoImage;
  final String lugarRecogida;

  @override
  State<MetodoPagoPage> createState() => _MetodoPagoPageState();
}

class _MetodoPagoPageState extends State<MetodoPagoPage> {
  static const _reservaCategoryId = 1;

  String _metodoPago = 'Tarjeta';
  final _numeroTarjetaCtrl = TextEditingController();
  final _titularCtrl = TextEditingController();
  final _vencimientoCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  final LocalSessionStore _sessionStore = LocalSessionStore.instance;
  final LocalPaymentDb _paymentDb = LocalPaymentDb.instance;
  final LocalCatalogDb _catalogDb = LocalCatalogDb.instance;
  final LocalReservationDb _reservationDb = LocalReservationDb.instance;
  final LocalNotificationDb _notificationDb = LocalNotificationDb.instance;

  List<dynamic> _userCards = [];
  List<dynamic> _userPseAccounts = [];
  Map<String, dynamic>? _selectedPaymentMethod;
  bool _isLoadingPaymentMethods = true;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _textPrimary =>
      _isDark ? const Color(0xFFF1F3FF) : const Color(0xFF0F172A);
  Color get _textSecondary =>
      _isDark ? const Color(0xFF8B93B8) : const Color(0xFF94A3B8);
  Color get _borderColor =>
      _isDark ? const Color(0xFF2E3355) : const Color(0xFFE2E8F0);
  Color get _cardBgColor => _isDark ? const Color(0xFF1A1F35) : Colors.white;

  Future<void> _crearNotificacionReserva({
    required String codigoReserva,
    required DateTime fechaInicio,
  }) async {
    await _sessionStore.init();
    final currentUserId = _sessionStore.userId;
    if (currentUserId == null) return;

    await _notificationDb.addNotification(
      userId: currentUserId,
      categoryId: _reservaCategoryId,
      subject: 'Reserva confirmada',
      description:
          'Tu reserva $codigoReserva de ${widget.vehiculoBrand} fue confirmada para ${_formatearFechaCorta(fechaInicio)} en ${widget.lugarRecogida}.',
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserPaymentMethods();
  }

  Future<void> _loadUserPaymentMethods() async {
    await Future.wait([
      _sessionStore.init(),
      _paymentDb.loadIfNeeded(),
      _catalogDb.loadIfNeeded(),
    ]);

    final currentUserId = _sessionStore.userId;
    if (currentUserId == null) {
      setState(() {
        _isLoadingPaymentMethods = false;
      });
      return;
    }

    // Get user's payment methods
    final userPaymentMethods = _paymentDb.getUserPaymentMethods(currentUserId);
    final userCards = _paymentDb.getUserCards(currentUserId);
    final userPseAccounts = _paymentDb.getUserPseAccounts(currentUserId);

    // Get card brands and banks for display
    final cardBrands = _catalogDb.cardBrands;
    final banks = _catalogDb.banks;

    // Prepare cards with additional info
    final cardsWithInfo = userCards.map((card) {
      final paymentMethod = userPaymentMethods.firstWhere(
        (method) => method.id == card.paymentMethodId,
      );
      final cardBrand = cardBrands.firstWhere(
        (brand) => brand.id == card.cardBrandId,
      );
      return {
        'id': card.id,
        'paymentMethodId': card.paymentMethodId,
        'cardNumber': card.cardNumber,
        'last4': card.cardNumber.substring(card.cardNumber.length - 4),
        'cardBrandId': card.cardBrandId,
        'brand': cardBrand.name,
        'expirationMonth': card.expirationMonth,
        'expirationYear': card.expirationYear,
        'isDefault': paymentMethod.isDefault,
        'type': 'Tarjeta',
      };
    }).toList();

    // Prepare PSE accounts with additional info
    final pseWithInfo = userPseAccounts.map((pse) {
      final paymentMethod = userPaymentMethods.firstWhere(
        (method) => method.id == pse.paymentMethodId,
      );
      final bank = banks.firstWhere(
        (bank) => bank.id == pse.bankId,
      );
      return {
        'id': pse.id,
        'paymentMethodId': pse.paymentMethodId,
        'bankId': pse.bankId,
        'bank': bank.name,
        'personTypeId': pse.personTypeId,
        'personType': pse.personTypeId == 1 ? 'Natural' : 'Jurídica',
        'isDefault': paymentMethod.isDefault,
        'type': 'PSE',
      };
    }).toList();

    setState(() {
      _userCards = cardsWithInfo;
      _userPseAccounts = pseWithInfo;
      _isLoadingPaymentMethods = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final padding = isSmallPhone ? 12.0 : 20.0;

    return Scaffold(
      backgroundColor: _isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Método de Pago',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetodoSeleccion(isSmallPhone),
                    SizedBox(height: isSmallPhone ? 16 : 24),
                    if (_metodoPago == 'Tarjeta' || _metodoPago == 'Tarjeta Nueva') ...[
                      _buildTarjetaCard(isSmallPhone),
                      SizedBox(height: isSmallPhone ? 16 : 20),
                      if (_metodoPago == 'Tarjeta Nueva')
                        _buildCamposTarjeta(isSmallPhone),
                    ],
                    if (_metodoPago == 'PSE') ...[
                      _buildPSEContent(isSmallPhone),
                    ],
                    if (_metodoPago == 'Efectivo') ...[
                      _buildEfectivoContent(isSmallPhone),
                    ],
                    SizedBox(height: isSmallPhone ? 16 : 24),
                    _buildResumenCobro(isSmallPhone),
                    SizedBox(height: isSmallPhone ? 16 : 20),
                    _buildSeguridad(isSmallPhone),
                    SizedBox(height: isSmallPhone ? 16 : 24),
                  ],
                ),
              ),
            ),
          ),
          _buildBotonPagar(isSmallPhone),
        ],
      ),
    );
  }

  Widget _buildMetodoSeleccion(bool isSmallPhone) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Método de pago',
          style: GoogleFonts.poppins(
            fontSize: isSmallPhone ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona cómo deseas pagar',
          style: GoogleFonts.poppins(
            fontSize: isSmallPhone ? 14 : 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 20),
        
        // Payment type selection
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildMetodoBoton('Tarjeta', Icons.credit_card, isSmallPhone),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: _buildMetodoBoton('PSE', Icons.account_balance, isSmallPhone),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: _buildMetodoBoton('Efectivo', Icons.money, isSmallPhone),
            ),
          ],
        ),
        
        // Show payment options based on selection
        if (_metodoPago == 'Tarjeta') ...[
          const SizedBox(height: 20),
          _buildCardOptions(isSmallPhone),
        ],
        if (_metodoPago == 'PSE') ...[
          const SizedBox(height: 20),
          _buildPSEOptions(isSmallPhone),
        ],
        if (_metodoPago == 'Efectivo') ...[
          const SizedBox(height: 20),
          _buildEfectivoContent(isSmallPhone),
        ],
      ],
    );
  }

  Widget _buildCardOptions(bool isSmallPhone) {
    if (_isLoadingPaymentMethods) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if we're adding a new card
    final isAddingNewCard = _metodoPago == 'Tarjeta Nueva';

    return Column(
      children: [
        // Show saved cards only if not adding new card
        if (!isAddingNewCard) ...[
          // Show saved cards
          ..._userCards.map((card) => _buildSavedCard(card, isSmallPhone)),
          
          // Add new card button
          _buildAddNewCardButton(isSmallPhone),
        ],
        
        // Show card form only when adding new card
        if (isAddingNewCard)
          _buildAddNewCardButton(isSmallPhone),
      ],
    );
  }

  Widget _buildPSEOptions(bool isSmallPhone) {
    if (_isLoadingPaymentMethods) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TUS CUENTAS PSE',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        
        // Show user's PSE accounts
        if (_userPseAccounts.isNotEmpty) ...[
          ..._userPseAccounts.map((pse) => _buildSavedPseAccount(pse, isSmallPhone)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildSavedCard(Map<String, dynamic> card, bool isSmallPhone) {
    final selected = _selectedPaymentMethod?['id'] == card['id'] && _selectedPaymentMethod?['type'] == 'Tarjeta';
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = card;
          _metodoPago = 'Tarjeta';
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF2FF) : _cardBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF4F46E5) : _borderColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: isSmallPhone ? 40 : 48,
              height: isSmallPhone ? 25 : 30,
              decoration: BoxDecoration(
                color: _getCardBrandColor(card['brand']),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  _getCardBrandAbbreviation(card['brand']),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isSmallPhone ? 10 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•••• ${card['last4']}',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallPhone ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${card['brand']} • Vence ${card['expiryMonth']}/${card['expiryYear']}',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallPhone ? 11 : 12,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!selected && card['isDefault'] != true)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallPhone ? 6 : 8,
                  vertical: isSmallPhone ? 2 : 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Default',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isSmallPhone ? 9 : 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (selected)
              Icon(
                Icons.check_circle,
                color: const Color(0xFF4F46E5),
                size: isSmallPhone ? 20 : 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPseAccount(Map<String, dynamic> pse, bool isSmallPhone) {
    final selected = _selectedPaymentMethod?['id'] == pse['id'] && _selectedPaymentMethod?['type'] == 'PSE';
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = pse;
          _metodoPago = 'PSE';
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF2FF) : _cardBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF4F46E5) : _borderColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: isSmallPhone ? 40 : 48,
              height: isSmallPhone ? 25 : 30,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PSE • ${pse['bank']}',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallPhone ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tipo ${pse['personType']}',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallPhone ? 11 : 12,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!selected && pse['isDefault'] != true)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallPhone ? 6 : 8,
                  vertical: isSmallPhone ? 2 : 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Default',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isSmallPhone ? 9 : 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (selected)
              Icon(
                Icons.check_circle,
                color: const Color(0xFF4F46E5),
                size: isSmallPhone ? 20 : 24,
              ),
          ],
        ),
      ),
    );
  }

  Color _getCardBrandColor(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'amex':
        return const Color(0xFF006FCF);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getCardBrandAbbreviation(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'VISA';
      case 'mastercard':
        return 'MC';
      case 'amex':
        return 'AMEX';
      default:
        return brand.substring(0, 3).toUpperCase();
    }
  }

  Widget _buildAddNewCardButton(bool isSmallPhone) {
    final isAddingNewCard = _metodoPago == 'Tarjeta Nueva';
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = null;
          _metodoPago = isAddingNewCard ? 'Tarjeta' : 'Tarjeta Nueva';
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
        decoration: BoxDecoration(
          color: isAddingNewCard ? const Color(0xFFEEF2FF) : _cardBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAddingNewCard ? const Color(0xFF4F46E5) : _borderColor,
            width: isAddingNewCard ? 2 : 1,
          ),
        ),
        child: isAddingNewCard ? _buildNewCardForm(isSmallPhone) : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: const Color(0xFF6366F1),
              size: isSmallPhone ? 20 : 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Otra tarjeta',
              style: GoogleFonts.poppins(
                fontSize: isSmallPhone ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6366F1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewCardForm(bool isSmallPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AGREGAR NUEVA TARJETA',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6366F1),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildInputField(
          'Número de tarjeta',
          _numeroTarjetaCtrl,
        ),
        const SizedBox(height: 12),
        _buildInputField(
          'Titular',
          _titularCtrl,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                'Vencimiento',
                _vencimientoCtrl,
                hintText: 'MM/AA',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInputField(
                'CVV',
                _cvvCtrl,
                obscureText: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetodoBoton(String label, IconData icon, bool isSmallPhone) {
    final selected = _metodoPago == label;

    return GestureDetector(
      onTap: () => setState(() => _metodoPago = label),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmallPhone ? 12 : 14,
          horizontal: isSmallPhone ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF2FF) : _cardBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF4F46E5) : _borderColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFF4F46E5) : _textSecondary,
              size: isSmallPhone ? 16 : 18,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: isSmallPhone ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? const Color(0xFF4F46E5) : _textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaCard(bool isSmallPhone) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                'FLEXIDRIVE',
                style: GoogleFonts.poppins(
                  fontSize: isSmallPhone ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            '• • • •    • • • •    • • • •    • • • •',
            style: GoogleFonts.poppins(
              fontSize: isSmallPhone ? 16 : 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'MM/AA',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCamposTarjeta(bool isSmallPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NÚMERO DE TARJETA',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        _buildInputField('1234 5678 9012 3456', _numeroTarjetaCtrl),
        const SizedBox(height: 16),
        Text(
          'TITULAR',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        _buildInputField('NOMBRE COMO EN LA TARJETA', _titularCtrl),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VENCIMIENTO',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInputField('MM/AA', _vencimientoCtrl),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CVV',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInputField('•••', _cvvCtrl),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPSEContent(bool isSmallPhone) {
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Serás redirigido al portal PSE para completar el pago de forma segura. Tiempo: 2-5 min.',
            style: GoogleFonts.poppins(
              fontSize: isSmallPhone ? 12 : 13,
              color: _textSecondary,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmallPhone ? 16 : 20),
          Container(
            padding: EdgeInsets.all(isSmallPhone ? 12 : 14),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: isSmallPhone ? 36 : 40,
                  height: isSmallPhone ? 36 : 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.apartment,
                    color: Color(0xFF4F46E5),
                    size: 20,
                  ),
                ),
                SizedBox(width: isSmallPhone ? 12 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Banco: Bancolombia',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallPhone ? 13 : 14,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                      SizedBox(height: isSmallPhone ? 2 : 4),
                      Text(
                        'Débito bancario directo',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallPhone ? 11 : 12,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEfectivoContent(bool isSmallPhone) {
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isSmallPhone ? 36 : 40,
                height: isSmallPhone ? 36 : 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              SizedBox(width: isSmallPhone ? 12 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pago en efectivo',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallPhone ? 14 : 15,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    SizedBox(height: isSmallPhone ? 2 : 4),
                    Text(
                      'Paga al recoger tu vehículo',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallPhone ? 11 : 12,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallPhone ? 14 : 16),
          Container(
            padding: EdgeInsets.all(isSmallPhone ? 12 : 14),
            decoration: BoxDecoration(
              color:
                  _isDark ? const Color(0xFF0F3D2D) : const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF10B981),
                  size: 18,
                ),
                SizedBox(width: isSmallPhone ? 10 : 12),
                Expanded(
                  child: Text(
                    'Av. El Dorado — Bogotá. Lleva el código de reserva.',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallPhone ? 11 : 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller, {bool obscureText = false, String? hintText}) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: _textPrimary,
      ),
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText ?? hint,
        hintStyle: GoogleFonts.poppins(
          color: _textSecondary,
          fontSize: 14,
        ),
        filled: true,
        fillColor: _cardBgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: const Color(0xFF6366F1)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildResumenCobro(bool isSmallPhone) {
    final totalFormateado = _formatearPrecio(widget.total);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del cobro',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildResumenLineaDetallada(),
          const SizedBox(height: 8),
          _buildResumenLinea('Servicio + Seguro', widget.servicioSeguro),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: _borderColor,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              Text(
                '\$ $totalFormateado',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumenLineaDetallada() {
    String unidadLabel = widget.cantidad == 1
        ? widget.periodo.toLowerCase().replaceAll('s', '')
        : widget.periodo.toLowerCase();

    final precioFormateado = _formatearPrecio(widget.precioUnitario);
    final totalAlquilerFormateado = _formatearPrecio(widget.alquilerVehiculo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alquiler vehículo',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '\$ $totalAlquilerFormateado',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '\$ $precioFormateado x ${widget.cantidad} $unidadLabel',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: _textSecondary.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  String _formatearPrecio(int precio) {
    final asString = precio.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < asString.length; i++) {
      final reverseIndex = asString.length - i;
      buffer.write(asString[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  Widget _buildResumenLinea(String label, int monto) {
    final montoFormateado = _formatearPrecio(monto);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: _textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '\$ $montoFormateado',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSeguridad(bool isSmallPhone) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF0F3D2D) : const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pago 100% seguro • SSL 256-bit',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonPagar(bool isSmallPhone) {
    final totalFormateado = _formatearPrecio(widget.total);
    
    return Container(
      padding: EdgeInsets.fromLTRB(
          isSmallPhone ? 12 : 20,
          isSmallPhone ? 10 : 14,
          isSmallPhone ? 12 : 20,
          isSmallPhone ? 10 : 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          top: BorderSide(color: _borderColor),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: isSmallPhone ? 48 : 56,
          child: ElevatedButton(
            onPressed: () async {
              // Validate card payment method
              if (_metodoPago == 'Tarjeta Nueva') {
                if (_numeroTarjetaCtrl.text.isEmpty ||
                    _titularCtrl.text.isEmpty ||
                    _vencimientoCtrl.text.isEmpty ||
                    _cvvCtrl.text.isEmpty) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor completa todos los campos de la tarjeta'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
              }
              
              // Validate payment method selection
              if (_metodoPago == 'Tarjeta' && _selectedPaymentMethod == null) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor selecciona un método de pago'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final codigoReserva = _generarCodigoReserva();
              final fechaInicio = DateTime.now();
              final fechaFin = _calcularFechaFin(fechaInicio);
              
              // Get current user ID
              await _sessionStore.init();
              final currentUserId = _sessionStore.userId;
              
              if (currentUserId == null) {
                // Show error if no user is logged in
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debes iniciar sesión para hacer una reserva'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              // Get payment method ID
              int paymentMethodId = 3; // Default to Efectivo
              if (_selectedPaymentMethod != null) {
                paymentMethodId = _selectedPaymentMethod!['paymentMethodId'];
              } else if (_metodoPago == 'Tarjeta' || _metodoPago == 'Tarjeta Nueva') {
                // Find first card payment method
                final userMethods = _paymentDb.getUserPaymentMethods(currentUserId);
                final cardMethod = userMethods.firstWhere(
                  (method) => method.paymentMethodTypeId == 1,
                  orElse: () => userMethods.first,
                );
                paymentMethodId = cardMethod.id;
              } else if (_metodoPago == 'PSE') {
                // Find first PSE payment method
                final userMethods = _paymentDb.getUserPaymentMethods(currentUserId);
                final pseMethod = userMethods.firstWhere(
                  (method) => method.paymentMethodTypeId == 2,
                  orElse: () => userMethods.first,
                );
                paymentMethodId = pseMethod.id;
              }
              
              // Create new reservation with status 1 (Pendiente)
              final newReservation = ReservationModel(
                id: _reservationDb.reservations.length + 1, // Generate new ID
                code: codigoReserva,
                userId: currentUserId,
                publicationId: 1, // Default publication ID - should come from widget
                paymentMethodId: paymentMethodId,
                periodTypeId: 1, // Default period type - should come from widget
                periodCount: widget.cantidad,
                startDate: fechaInicio,
                endDate: fechaFin,
                pickupLocation: widget.lugarRecogida,
                returnLocation: 'Punto por defecto', // Should come from widget
                totalValue: widget.total.toDouble(),
                statusId: 1, // 1 = Pendiente
                reservationDate: DateTime.now(),
              );
              
              // Add to database (this will persist to JSON)
              _reservationDb.reservations.add(newReservation);
              
              // Also add to store for UI
              ReservasStore.addActiva(
                ReservaActiva(
                  vehicleName: widget.vehiculoBrand,
                  code: codigoReserva,
                  price: '\$ ${_formatearNumero(widget.total)}',
                  startDate: _formatearFechaCorta(fechaInicio),
                  endDate: _formatearFechaCorta(fechaFin),
                  location: widget.lugarRecogida,
                  imageUrl: widget.vehiculoImage,
                ),
              );

              await _crearNotificacionReserva(
                codigoReserva: codigoReserva,
                fechaInicio: fechaInicio,
              );

              if (!mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ReservaConfirmadaPage(
                    vehiculoBrand: widget.vehiculoBrand,
                    vehiculoImage: widget.vehiculoImage,
                    periodo: widget.periodo,
                    cantidad: widget.cantidad,
                    lugarRecogida: widget.lugarRecogida,
                    totalPagado: widget.total,
                    codigoReserva: codigoReserva,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Pagar \$ $totalFormateado',
              style: GoogleFonts.poppins(
                fontSize: isSmallPhone ? 15 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _generarCodigoReserva() {
    final fecha = DateTime.now();
    final year = fecha.year;
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');
    final numero = (1000 + (9000 * (fecha.millisecond % 100) / 100)).round();
    return 'FD-$year-$month-$day-$numero';
  }

  DateTime _calcularFechaFin(DateTime fechaInicio) {
    switch (widget.periodo.toLowerCase()) {
      case 'dias':
        return fechaInicio.add(Duration(days: widget.cantidad));
      case 'semanas':
        return fechaInicio.add(Duration(days: widget.cantidad * 7));
      case 'meses':
        return fechaInicio.add(Duration(days: widget.cantidad * 30));
      default:
        return fechaInicio.add(Duration(days: widget.cantidad));
    }
  }

  String _formatearNumero(int numero) {
    final asString = numero.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < asString.length; i++) {
      final reverseIndex = asString.length - i;
      buffer.write(asString[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  String _formatearFechaCorta(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes';
  }
}

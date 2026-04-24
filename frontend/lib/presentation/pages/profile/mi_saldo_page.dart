// Flutter framework
import 'package:flutter/material.dart';
// Fuentes bonitas de Google
import 'package:google_fonts/google_fonts.dart';
// Utilidades responsive
import '../../../core/utils/responsive_utils.dart';
// Pagina principal del arrendador (para volver)
import 'principal_arrendatario_page.dart';

// Pagina "Mi Saldo" - muestra el dinero disponible del arrendador
// Para los dueños de carros que quieren retirar sus ganancias
class MiSaldoPage extends StatefulWidget {
  const MiSaldoPage({super.key});

  @override
  State<MiSaldoPage> createState() => _MiSaldoPageState();
}

// Estado de la pagina de saldo
class _MiSaldoPageState extends State<MiSaldoPage> {
  // Saldo disponible para retirar (en pesos)
  int _saldoDisponible = 1440000;
  // Saldo ya retirado
  int _saldoRetirado = 0;

  // Lista de cuentas bancarias del usuario
  final List<_CuentaBancaria> _cuentas = [
    _CuentaBancaria(
      banco: 'Bancolombia', // Nombre del banco
      tipoCuenta: 'Ahorros', // Tipo de cuenta
      numeroCuenta: '12345678', // Numero de cuenta
      titular: 'Daniel', // Nombre del titular
    ),
  ];

  // Indice de la cuenta seleccionada
  int _cuentaSeleccionadaIndex = 0;

  // Navega a la pagina principal del arrendador
  void _goToPrincipalArrendatario() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrincipalArrendatarioPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildGreenHeader(isSmallPhone, isDark),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(isSmallPhone),
                    SizedBox(height: isSmallPhone ? 16 : 20),
                    _buildStatsCards(isSmallPhone, isDark),
                    SizedBox(height: isSmallPhone ? 24 : 28),
                    _buildBankAccountsSection(isSmallPhone, isDark),
                    SizedBox(height: isSmallPhone ? 24 : 28),
                    _buildTransactionHistorySection(isSmallPhone, isDark),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreenHeader(bool isSmallPhone, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF10B981),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallPhone ? 16 : 20,
            vertical: isSmallPhone ? 16 : 20,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mi Saldo',
                    style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 20 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Gestiona tus ganancias',
                    style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 13 : 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.home_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: _goToPrincipalArrendatario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(bool isSmallPhone) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallPhone ? 20 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.attach_money,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                'Saldo disponible',
                style: GoogleFonts.inter(
                  fontSize: isSmallPhone ? 13 : 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallPhone ? 8 : 12),
          Text(
            '\$ ${_formatMoney(_saldoDisponible)}',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 36 : 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: isSmallPhone ? 16 : 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _cuentas.isEmpty
                      ? null
                      : () => _showRetirarSaldoSheet(isSmallPhone),
                  icon: const Icon(
                    Icons.arrow_circle_down,
                    size: 20,
                  ),
                  label: Text(
                    'Retirar',
                    style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 14 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallPhone ? 12 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showAgregarCuentaSheet(isSmallPhone),
                  icon: const Icon(
                    Icons.add,
                    size: 20,
                  ),
                  label: Text(
                    'Agregar cuenta',
                    style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 14 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallPhone ? 12 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isSmallPhone, bool isDark) {
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor =
        isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(isSmallPhone ? 16 : 18),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: isDark
                  ? null
                  : Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: const Color(0xFF10B981),
                      size: isSmallPhone ? 16 : 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ganado',
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 12 : 13,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallPhone ? 8 : 10),
                Text(
                  '\$ ${_formatMoney(_saldoDisponible + _saldoRetirado)}',
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(isSmallPhone ? 16 : 18),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: isDark
                  ? null
                  : Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: const Color(0xFF6366F1),
                      size: isSmallPhone ? 16 : 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Retirado',
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 12 : 13,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallPhone ? 8 : 10),
                Text(
                  '\$ ${_formatMoney(_saldoRetirado)}',
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankAccountsSection(bool isSmallPhone, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final subtextColor =
        isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuentas bancarias',
          style: GoogleFonts.inter(
            fontSize: isSmallPhone ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: isSmallPhone ? 12 : 16),
        if (_cuentas.isEmpty)
          Text(
            'No tienes cuentas registradas',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 13 : 14,
              color: subtextColor,
            ),
          )
        else
          Column(
            children: List.generate(_cuentas.length, (index) {
              final cuenta = _cuentas[index];
              return Padding(
                padding: EdgeInsets.only(
                    bottom: index == _cuentas.length - 1 ? 0 : 10),
                child: Container(
                  padding: EdgeInsets.all(isSmallPhone ? 16 : 18),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: isDark
                        ? null
                        : Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.account_balance,
                          color: Color(0xFF2563EB),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cuenta.banco,
                              style: GoogleFonts.inter(
                                fontSize: isSmallPhone ? 14 : 15,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${cuenta.tipoCuenta} •••• ${_last4(cuenta.numeroCuenta)}',
                              style: GoogleFonts.inter(
                                fontSize: isSmallPhone ? 12 : 13,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFEF4444).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => _eliminarCuenta(index),
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFFEF4444),
                            size: 19,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildTransactionHistorySection(bool isSmallPhone, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final subtextColor =
        isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial de transacciones',
          style: GoogleFonts.inter(
            fontSize: isSmallPhone ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: isSmallPhone ? 12 : 16),
        _buildTransactionCard(
          isSmallPhone: isSmallPhone,
          cardBgColor: cardBgColor,
          textColor: textColor,
          subtextColor: subtextColor,
          isDark: isDark,
          title: 'Renta completada - Mazda 3',
          date: '7 de mar de 2026',
          amount: '+\$ 900.000',
        ),
        SizedBox(height: isSmallPhone ? 10 : 12),
        _buildTransactionCard(
          isSmallPhone: isSmallPhone,
          cardBgColor: cardBgColor,
          textColor: textColor,
          subtextColor: subtextColor,
          isDark: isDark,
          title: 'Renta completada - Chevrolet Onix',
          date: '5 de mar de 2026',
          amount: '+\$ 540.000',
        ),
      ],
    );
  }

  Widget _buildTransactionCard({
    required bool isSmallPhone,
    required Color cardBgColor,
    required Color textColor,
    required Color subtextColor,
    required bool isDark,
    required String title,
    required String date,
    required String amount,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 16 : 18),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? null
            : Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.trending_up,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 12 : 13,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 15 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRetirarSaldoSheet(bool isSmallPhone) async {
    final montoController = TextEditingController(text: '0');
    int cuentaIndex = _cuentaSeleccionadaIndex;
    int monto = 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E2A44) : Colors.white;
    final dragColor =
        isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final labelColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final inputBg = isDark ? const Color(0xFF0B1736) : const Color(0xFFF8FAFC);
    final inputBorder =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final inputTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final selectedAccountBg =
        isDark ? const Color(0xFF134052) : const Color(0xFFF0FDF4);
    final selectedAccountBorder =
        isDark ? const Color(0xFF10D5A0) : const Color(0xFF10B981);
    final selectedButtonBg =
        isDark ? const Color(0xFF334766) : const Color(0xFFE2E8F0);
    final selectedButtonText =
        isDark ? const Color(0xFF7D90AC) : const Color(0xFF64748B);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final puedeRetirar =
                monto > 0 && monto <= _saldoDisponible && _cuentas.isNotEmpty;

            return Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                isSmallPhone ? 16 : 20,
                10,
                isSmallPhone ? 16 : 20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 56,
                      height: 6,
                      decoration: BoxDecoration(
                        color: dragColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      'Retirar saldo',
                      style: GoogleFonts.inter(
                        color: titleColor,
                        fontSize: isSmallPhone ? 34 : 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Monto a retirar',
                    style: GoogleFonts.inter(
                      color: labelColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: montoController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(
                      color: inputTextColor,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: inputBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFF10B981)),
                      ),
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(
                              value.replaceAll(RegExp(r'[^0-9]'), '')) ??
                          0;
                      setModalState(() {
                        monto = parsed;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Disponible: \$ ${_formatMoney(_saldoDisponible)}',
                    style: GoogleFonts.inter(
                      color: labelColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Selecciona una cuenta',
                    style: GoogleFonts.inter(
                      color: labelColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_cuentas.isNotEmpty)
                    GestureDetector(
                      onTap: () => setModalState(() {
                        cuentaIndex = 0;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedAccountBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selectedAccountBorder,
                            width: 1.4,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB)
                                    .withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.account_balance,
                                color: Color(0xFF2563EB),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _cuentas[cuentaIndex].banco,
                                    style: GoogleFonts.inter(
                                      color: titleColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_cuentas[cuentaIndex].tipoCuenta} •••• ${_last4(_cuentas[cuentaIndex].numeroCuenta)}',
                                    style: GoogleFonts.inter(
                                      color: labelColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: puedeRetirar
                          ? () {
                              setState(() {
                                _saldoDisponible -= monto;
                                _saldoRetirado += monto;
                                _cuentaSeleccionadaIndex = cuentaIndex;
                              });
                              Navigator.pop(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedButtonBg,
                        disabledBackgroundColor: selectedButtonBg,
                        foregroundColor: selectedButtonText,
                        disabledForegroundColor: selectedButtonText,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Confirmar retiro',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    montoController.dispose();
  }

  Future<void> _showAgregarCuentaSheet(bool isSmallPhone) async {
    final bancoController = TextEditingController();
    final numeroController = TextEditingController();
    final titularController = TextEditingController();
    String tipoCuenta = 'Ahorros';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E2A44) : Colors.white;
    final dragColor =
        isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final labelColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final inputBg = isDark ? const Color(0xFF0B1736) : const Color(0xFFF8FAFC);
    final inputBorder =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final hintColor =
        isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final inputTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final buttonBg = isDark ? const Color(0xFF334766) : const Color(0xFFE2E8F0);
    final buttonText =
        isDark ? const Color(0xFF7D90AC) : const Color(0xFF64748B);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final puedeAgregar = bancoController.text.trim().isNotEmpty &&
                numeroController.text.trim().isNotEmpty &&
                titularController.text.trim().isNotEmpty;

            Widget buildInput({
              required String label,
              required String hint,
              required TextEditingController controller,
              TextInputType keyboardType = TextInputType.text,
            }) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: labelColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: GoogleFonts.inter(
                      color: inputTextColor,
                      fontSize: 16,
                    ),
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.inter(
                        color: hintColor,
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: inputBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: inputBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFF2563EB)),
                      ),
                    ),
                  ),
                ],
              );
            }

            Widget buildTipoButton(String label) {
              final isActive = tipoCuenta == label;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setModalState(() {
                    tipoCuenta = label;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isActive
                          ? (isDark
                              ? const Color(0xFF22365D)
                              : const Color(0xFFE0E7FF))
                          : inputBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? const Color(0xFF2563EB) : inputBorder,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: GoogleFonts.inter(
                          color:
                              isActive ? const Color(0xFF2563EB) : labelColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                isSmallPhone ? 16 : 20,
                10,
                isSmallPhone ? 16 : 20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 56,
                        height: 6,
                        decoration: BoxDecoration(
                          color: dragColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        'Agregar cuenta bancaria',
                        style: GoogleFonts.inter(
                          color: titleColor,
                          fontSize: isSmallPhone ? 34 : 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    buildInput(
                      label: 'Banco',
                      hint: 'Ej: Bancolombia',
                      controller: bancoController,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Tipo de cuenta',
                      style: GoogleFonts.inter(
                        color: labelColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        buildTipoButton('Ahorros'),
                        const SizedBox(width: 10),
                        buildTipoButton('Corriente'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    buildInput(
                      label: 'Número de cuenta',
                      hint: 'Ej: 123456789',
                      controller: numeroController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 18),
                    buildInput(
                      label: 'Titular de la cuenta',
                      hint: 'Nombre completo',
                      controller: titularController,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: puedeAgregar
                            ? () {
                                final nuevaCuenta = _CuentaBancaria(
                                  banco: bancoController.text.trim(),
                                  tipoCuenta: tipoCuenta,
                                  numeroCuenta: numeroController.text.trim(),
                                  titular: titularController.text.trim(),
                                );

                                setState(() {
                                  _cuentas.add(nuevaCuenta);
                                  _cuentaSeleccionadaIndex =
                                      _cuentas.length - 1;
                                });
                                Navigator.pop(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonBg,
                          disabledBackgroundColor: buttonBg,
                          foregroundColor: buttonText,
                          disabledForegroundColor: buttonText,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Agregar cuenta',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
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
      },
    );

    bancoController.dispose();
    numeroController.dispose();
    titularController.dispose();
  }

  void _eliminarCuenta(int index) {
    if (_cuentas.isEmpty || index < 0 || index >= _cuentas.length) {
      return;
    }

    setState(() {
      _cuentas.removeAt(index);
      if (_cuentas.isEmpty) {
        _cuentaSeleccionadaIndex = 0;
      } else if (_cuentaSeleccionadaIndex >= _cuentas.length) {
        _cuentaSeleccionadaIndex = _cuentas.length - 1;
      }
    });
  }

  String _last4(String numeroCuenta) {
    if (numeroCuenta.length <= 4) {
      return numeroCuenta;
    }
    return numeroCuenta.substring(numeroCuenta.length - 4);
  }

  String _formatMoney(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final position = digits.length - i - 1;
      if (position > 0 && position % 3 == 0) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }
}

class _CuentaBancaria {
  final String banco;
  final String tipoCuenta;
  final String numeroCuenta;
  final String titular;

  _CuentaBancaria({
    required this.banco,
    required this.tipoCuenta,
    required this.numeroCuenta,
    required this.titular,
  });
}

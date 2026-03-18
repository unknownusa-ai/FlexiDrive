import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_utils.dart';
import '../main_page.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  
  const VerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  bool _isVerifying = false;
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendTimer = 60;
    });
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  void _onCodeChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Check if all fields are filled
    final code = _controllers.map((c) => c.text).join();
    if (code.length == 6) {
      _verifyCode();
    }
  }

  void _verifyCode() async {
    setState(() {
      _isVerifying = true;
    });
    
    // Simulate verification
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final cardColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(
                isSmallPhone ? 16 : 24,
                isSmallPhone ? 8 : 12,
                isSmallPhone ? 16 : 24,
                isSmallPhone ? 16 : 24,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: isSmallPhone ? 40 : 44,
                      height: isSmallPhone ? 40 : 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: textColor,
                        size: isSmallPhone ? 18 : 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallPhone ? 24 : 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: isSmallPhone ? 40 : 60),

                    // Icon
                    Container(
                      width: isSmallPhone ? 80 : 100,
                      height: isSmallPhone ? 80 : 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.email_outlined,
                        color: Colors.white,
                        size: isSmallPhone ? 40 : 50,
                      ),
                    ),

                    SizedBox(height: isSmallPhone ? 32 : 40),

                    // Title
                    Text(
                      'Verificación',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallPhone ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),

                    SizedBox(height: isSmallPhone ? 8 : 12),

                    // Subtitle
                    Text(
                      'Ingresa el código de 6 dígitos que enviamos a:',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 14 : 16,
                        color: secondaryTextColor,
                      ),
                    ),

                    SizedBox(height: isSmallPhone ? 4 : 6),

                    // Email
                    Text(
                      widget.email,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2563EB),
                      ),
                    ),

                    SizedBox(height: isSmallPhone ? 32 : 40),

                    // Code input fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                        (index) => _buildCodeInput(
                          index: index,
                          isSmallPhone: isSmallPhone,
                          isDark: isDark,
                          cardColor: cardColor,
                          textColor: textColor,
                        ),
                      ),
                    ),

                    SizedBox(height: isSmallPhone ? 32 : 40),

                    // Resend code
                    if (_canResend)
                      GestureDetector(
                        onTap: () {
                          _startResendTimer();
                          // TODO: Implement resend logic
                        },
                        child: Text(
                          '¿No recibiste el código? Reenviar',
                          style: GoogleFonts.inter(
                            fontSize: isSmallPhone ? 14 : 15,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      )
                    else
                      Text(
                        'Reenviar código en ${_resendTimer}s',
                        style: GoogleFonts.inter(
                          fontSize: isSmallPhone ? 14 : 15,
                          color: secondaryTextColor,
                        ),
                      ),

                    SizedBox(height: isSmallPhone ? 32 : 40),

                    // Verify button
                    GestureDetector(
                      onTap: _isVerifying ? null : _verifyCode,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallPhone ? 16 : 18,
                        ),
                        decoration: BoxDecoration(
                          gradient: _isVerifying
                              ? null
                              : const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                                ),
                          color: _isVerifying ? Colors.grey.shade300 : null,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _isVerifying
                              ? null
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: _isVerifying
                              ? SizedBox(
                                  width: isSmallPhone ? 20 : 24,
                                  height: isSmallPhone ? 20 : 24,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Verificar',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: isSmallPhone ? 16 : 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeInput({
    required int index,
    required bool isSmallPhone,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      width: isSmallPhone ? 44 : 52,
      height: isSmallPhone ? 54 : 64,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? const Color(0xFF2563EB)
              : isDark
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
          width: _focusNodes[index].hasFocus ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.inter(
          fontSize: isSmallPhone ? 20 : 24,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) => _onCodeChanged(index, value),
      ),
    );
  }
}

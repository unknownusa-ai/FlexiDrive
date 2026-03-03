import 'package:flutter/material.dart';

class OnboardingPagePayment extends StatefulWidget {
  const OnboardingPagePayment({super.key});

  @override
  State<OnboardingPagePayment> createState() => _OnboardingPagePaymentState();
}

class _OnboardingPagePaymentState extends State<OnboardingPagePayment>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _cardAnimation;
  late Animation<double> _tagAnimation;
  late Animation<double> _method1Animation;
  late Animation<double> _method2Animation;
  late Animation<double> _method3Animation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _cardAnimation = Tween<double>(begin: -200, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _tagAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _method1Animation = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.75, curve: Curves.easeOutBack),
      ),
    );

    _method2Animation = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _method3Animation = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _floatAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F3FF),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _cardAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _cardAnimation.value),
                          child: AnimatedBuilder(
                            animation: _floatAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  0,
                                  -5 + (_floatAnimation.value * 10),
                                ),
                                child: _buildCreditCard(_tagAnimation),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 75,
                      child: Row(
                        children: [
                          AnimatedBuilder(
                            animation: _method1Animation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _method1Animation.value),
                                child: _buildPaymentMethod('💳 Tarjeta'),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          AnimatedBuilder(
                            animation: _method2Animation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _method2Animation.value),
                                child: _buildPaymentMethod('🏦 PSE'),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          AnimatedBuilder(
                            animation: _method3Animation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _method3Animation.value),
                                child: _buildPaymentMethod('💵 Efectivo'),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paga fácil\ny seguro',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Múltiples métodos de pago: tarjeta, PSE o efectivo. Tus datos siempre protegidos.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 180),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCard(Animation<double> tagAnimation) {
    return Container(
      width: 260,
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -15,
            right: 20,
            child: AnimatedBuilder(
              animation: tagAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(tagAnimation.value, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF22C55E),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock,
                          size: 10,
                          color: Color(0xFF16A34A),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'SEGURO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              width: 50,
              height: 35,
              decoration: BoxDecoration(
                color: const Color(0xFFFACC15),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Text(
              'FLEXIDRIVE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 2,
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 20,
            child: Row(
              children: [
                Text(
                  '•••• •••• ••••',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '4821',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TITULAR',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Carlos R.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'VENCE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '12/28',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4B5563),
        ),
      ),
    );
  }
}

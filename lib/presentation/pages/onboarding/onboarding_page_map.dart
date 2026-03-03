import 'package:flutter/material.dart';

class OnboardingPageMap extends StatefulWidget {
  const OnboardingPageMap({super.key});

  @override
  State<OnboardingPageMap> createState() => _OnboardingPageMapState();
}

class _OnboardingPageMapState extends State<OnboardingPageMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pin1Animation;
  late Animation<double> _pin2Animation;
  late Animation<double> _pin3Animation;
  late Animation<double> _pin4Animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pin1Animation = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _pin2Animation = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.6, curve: Curves.elasticOut),
      ),
    );

    _pin3Animation = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.elasticOut),
      ),
    );

    _pin4Animation = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.65, curve: Curves.elasticOut),
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
      color: const Color(0xFFE8F5E9),
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
                    Container(
                      width: 280,
                      height: 220,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Stack(
                        children: [
                          _buildGridLines(),
                          _buildVerticalLine(),
                          _buildHorizontalLine(),
                          Positioned(
                            top: 40,
                            left: 50,
                            child: AnimatedBuilder(
                              animation: _pin1Animation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _pin1Animation.value),
                                  child: _buildPin(const Color(0xFF2563EB)),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 30,
                            right: 60,
                            child: AnimatedBuilder(
                              animation: _pin2Animation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _pin2Animation.value),
                                  child: _buildPin(const Color(0xFF7C3AED)),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 50,
                            left: 60,
                            child: AnimatedBuilder(
                              animation: _pin3Animation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _pin3Animation.value),
                                  child: _buildPin(const Color(0xFFF59E0B)),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 60,
                            right: 90,
                            child: AnimatedBuilder(
                              animation: _pin4Animation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _pin4Animation.value),
                                  child: _buildPin(const Color(0xFF10B981)),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 65,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Bogotá, Colombia',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
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
                      'Reserva desde\ncualquier lugar',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Encuentra vehículos disponibles cerca de ti en segundos. Cobertura en toda Colombia.',
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

  Widget _buildPin(Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 12,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildGridLines() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        4,
        (index) => Container(
          height: 1,
          color: const Color(0xFFD1D5DB),
        ),
      ),
    );
  }

  Widget _buildVerticalLine() {
    return Positioned(
      left: 140,
      top: 0,
      bottom: 0,
      child: Container(
        width: 6,
        color: const Color(0xFFC7D2D8),
      ),
    );
  }

  Widget _buildHorizontalLine() {
    return Positioned(
      top: 110,
      left: 0,
      right: 0,
      child: Container(
        height: 6,
        color: const Color(0xFFC7D2D8),
      ),
    );
  }
}

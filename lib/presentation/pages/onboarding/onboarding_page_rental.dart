import 'package:flutter/material.dart';

class OnboardingPageRental extends StatefulWidget {
  const OnboardingPageRental({super.key});

  @override
  State<OnboardingPageRental> createState() => _OnboardingPageRentalState();
}

class _OnboardingPageRentalState extends State<OnboardingPageRental>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _carBounceAnimation;
  late Animation<double> _tag1Animation;
  late Animation<double> _tag2Animation;
  late Animation<double> _tag3Animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _carBounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _tag1Animation = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _tag2Animation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _tag3Animation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutBack),
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
      color: const Color(0xFFF0F4FF),
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
                      animation: _tag1Animation,
                      builder: (context, child) {
                        return Positioned(
                          top: 60 + _tag1Animation.value,
                          left: 20,
                          child: _buildTag(
                            '⏱️ Por horas',
                            const Color(0xFF4F46E5),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _tag2Animation,
                      builder: (context, child) {
                        return Positioned(
                          top: 20 + _tag2Animation.value,
                          right: 10,
                          child: _buildTag(
                            '📅 Por días',
                            const Color(0xFF7C3AED),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _tag3Animation,
                      builder: (context, child) {
                        return Positioned(
                          bottom: 60 + _tag3Animation.value,
                          right: 0,
                          child: _buildTag(
                            '🗓️ Por semanas',
                            const Color(0xFF059669),
                          ),
                        );
                      },
                    ),
                    Container(
                      width: 280,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _carBounceAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.8 + (_carBounceAnimation.value * 0.2),
                          child: Transform.translate(
                            offset: Offset(0, -_carBounceAnimation.value * 10),
                            child: Container(
                              width: 180,
                              height: 100,
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
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '🚗',
                                  style: TextStyle(fontSize: 50),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
                      'Alquila por horas,\ndías o semanas',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Flexibilidad total para adaptarse a tu ritmo de vida. Sin compromisos, sin complicaciones.',
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

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

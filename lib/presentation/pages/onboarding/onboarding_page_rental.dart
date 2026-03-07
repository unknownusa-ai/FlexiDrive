import 'package:flutter/material.dart';
import '../../../core/utils/responsive_utils.dart';

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
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    
    return Container(
      color: const Color(0xFFF0F4FF),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: isSmallPhone ? 50 : 80),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallPhone ? 24 : 40),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _tag1Animation,
                      builder: (context, child) {
                        return Positioned(
                          top: isSmallPhone ? 40 : 60 + _tag1Animation.value,
                          left: isSmallPhone ? 10 : 20,
                          child: _buildTag(
                            '⏱️ Por horas',
                            const Color(0xFF4F46E5),
                            isSmallPhone: isSmallPhone,
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _tag2Animation,
                      builder: (context, child) {
                        return Positioned(
                          top: isSmallPhone ? 10 : 20 + _tag2Animation.value,
                          right: isSmallPhone ? 5 : 10,
                          child: _buildTag(
                            '📅 Por días',
                            const Color(0xFF7C3AED),
                            isSmallPhone: isSmallPhone,
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _tag3Animation,
                      builder: (context, child) {
                        return Positioned(
                          bottom: isSmallPhone ? 40 : 60 + _tag3Animation.value,
                          right: isSmallPhone ? 5 : 0,
                          child: _buildTag(
                            '🗓️ Por semanas',
                            const Color(0xFF059669),
                            isSmallPhone: isSmallPhone,
                          ),
                        );
                      },
                    ),
                    Container(
                      width: isSmallPhone ? 220 : 280,
                      height: isSmallPhone ? 80 : 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _carBounceAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: (isSmallPhone ? 0.75 : 0.8) + (_carBounceAnimation.value * 0.2),
                          child: Transform.translate(
                            offset: Offset(0, -_carBounceAnimation.value * 10),
                            child: Container(
                              width: isSmallPhone ? 150 : 180,
                              height: isSmallPhone ? 85 : 100,
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
                              child: Center(
                                child: Text(
                                  '🚗',
                                  style: TextStyle(fontSize: isSmallPhone ? 40 : 50),
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
                padding: EdgeInsets.symmetric(horizontal: isSmallPhone ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alquila por horas,\ndías o semanas',
                      style: TextStyle(
                        fontSize: isSmallPhone ? 22 : 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: isSmallPhone ? 10 : 16),
                    Text(
                      'Flexibilidad total para adaptarse a tu ritmo de vida. Sin compromisos, sin complicaciones.',
                      style: TextStyle(
                        fontSize: isSmallPhone ? 14 : 16,
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isSmallPhone ? 140 : 180),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color, {required bool isSmallPhone}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallPhone ? 10 : 16, vertical: isSmallPhone ? 6 : 10),
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
          fontSize: isSmallPhone ? 11 : 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

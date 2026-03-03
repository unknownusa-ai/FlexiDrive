import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF4D8FF5),
              Color(0xFF5566E8),
              Color(0xFF7345D6),
              Color(0xFF6B28C8),
            ],
            stops: [0.0, 0.30, 0.65, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Círculo TOP-LEFT
            Positioned(
              top: -130,
              left: -100,
              child: Container(
                width: 460,
                height: 460,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.09),
                ),
              ),
            ),

            // Círculo BOTTOM-RIGHT
            Positioned(
              bottom: -170,
              right: -140,
              child: Container(
                width: 520,
                height: 520,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.09),
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Ícono glassmorphism con carro ──
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Carro blanco base (cuerpo)
                        const Icon(
                          Icons.directions_car_filled_rounded,
                          size: 62,
                          color: Colors.white,
                        ),
                        // Techo/cabina del carro en azul cyan encima
                        Positioned(
                          top: 22,
                          child: Container(
                            width: 26,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7DD3FC),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 44),

                  // ── "FlexiDrive" ──
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Flexi',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        TextSpan(
                          text: 'Drive',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF7DD3FC),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'MOVILIDAD A TU RITMO',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      letterSpacing: 3.8,
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress bar + versión ──
            Positioned(
              bottom: 64,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SizedBox(
                    width: 88,
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: Colors.white.withOpacity(0.22),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white),
                          minHeight: 3,
                          borderRadius: BorderRadius.circular(2),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'v2.1.0 • Colombia 🇨🇴',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
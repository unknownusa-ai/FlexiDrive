// Flutter framework
import 'package:flutter/material.dart';
// Fuentes bonitas de Google
import 'package:google_fonts/google_fonts.dart';
// Paginas del onboarding
import 'onboarding_page_rental.dart';
import 'onboarding_page_map.dart';
import 'onboarding_page_payment.dart';
// Pagina de login (despues del onboarding)
import '../login/login_page.dart';

// Pagina de Onboarding - tutorial para nuevos usuarios
// Muestra 3 pantallas explicando como usar la app
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

// Estado de la pagina de onboarding
class _OnboardingPageState extends State<OnboardingPage> {
  // Controlador del PageView (para swipe entre paginas)
  final PageController _pageController = PageController();
  // Pagina actual que se muestra
  int _currentPage = 0;

  // Lista de paginas del tutorial
  final List<Widget> _pages = const [
    OnboardingPageRental(), // Pagina 1: Como rentar carros
    OnboardingPageMap(), // Pagina 2: Mapa y ubicaciones
    OnboardingPagePayment(), // Pagina 3: Metodos de pago
  ];

  @override
  void dispose() {
    // Liberamos el controlador para evitar memory leaks
    _pageController.dispose();
    super.dispose();
  }

  // Avanza a la siguiente pagina o va al login
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      // Si no es la ultima, avanza con animacion
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Si es la ultima, va al login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  // Salta el tutorial y va directo al login
  void _skip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) => _pages[index],
          ),
          Positioned(
            top: 48,
            right: 24,
            child: GestureDetector(
              onTap: _skip,
              child: Text(
                'Omitir',
                style: GoogleFonts.poppins(
                  color: _getSkipColor(),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFF4F46E5)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'Comenzar'
                                : 'Siguiente',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSkipColor() {
    switch (_currentPage) {
      case 0:
        return const Color(0xFF6B7280);
      case 1:
        return const Color(0xFF6B7280);
      case 2:
        return const Color(0xFF6B7280);
      default:
        return Colors.grey;
    }
  }
}

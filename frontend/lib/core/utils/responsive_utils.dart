// Flutter framework
import 'package:flutter/material.dart';

// Utilidades para hacer la app responsive
// Adapta la UI a diferentes tamaños de pantalla
class ResponsiveUtils {
  // Detecta si es un dispositivo movil (< 600px)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  // Detecta si es un celular pequeño (< 360px)
  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  // Detecta si es una tablet (600px - 1024px)
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  // Detecta si es escritorio (>= 1024px)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  // Obtiene el ancho de pantalla
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  // Obtiene el alto de pantalla
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Obtiene el safe area superior (notch, barra de estado)
  static double safeAreaTop(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  // Obtiene el safe area inferior (botones de navegacion)
  static double safeAreaBottom(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  // Escala un valor segun el ancho de pantalla
  // Para que se vea bien en diferentes dispositivos
  static double scale(BuildContext context, double baseValue) {
    final width = screenWidth(context);
    if (width < 360) return baseValue * 0.85; // Celular pequeño
    if (width < 600) return baseValue; // Movil normal
    if (width < 1024) return baseValue * 1.2; // Tablet
    return baseValue * 1.5; // Escritorio
  }

  // Padding horizontal adaptativo segun pantalla
  static double horizontalPadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 360) return 16; // Celular pequeño
    if (width < 600) return 20; // Movil normal
    if (width < 1024) return 40; // Tablet
    return 80; // Escritorio
  }

  // Tamaño de fuente adaptativo segun pantalla
  static double fontSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    if (width < 360) return baseSize * 0.9; // Celular pequeño
    if (width < 600) return baseSize; // Movil normal
    if (width < 1024) return baseSize * 1.1; // Tablet
    return baseSize * 1.2; // Escritorio
  }
}

// Extensiones utiles para responsive
// Facilita el acceso a las funciones de ResponsiveUtils
extension ResponsiveBuildContext on BuildContext {
  double get screenWidth => ResponsiveUtils.screenWidth(this);
  double get screenHeight => ResponsiveUtils.screenHeight(this);
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  bool get isSmallPhone => ResponsiveUtils.isSmallPhone(this);
}

// Widget para layouts adaptativos
// Muestra diferentes widgets segun el tamaño de pantalla
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile; // Widget para moviles
  final Widget? tablet; // Widget para tablets (opcional)
  final Widget? desktop; // Widget para escritorio (opcional)

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop && desktop != null) {
      return desktop!; // Escritorio
    }
    if (context.isTablet && tablet != null) {
      return tablet!; // Tablet
    }
    return mobile; // Movil (default)
  }
}

// Widget que limita el ancho maximo en pantallas grandes
// Evita que el contenido se vea demasiado ancho en escritorio
class ConstrainedContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth; // Ancho maximo (default 600px)
  final EdgeInsetsGeometry? padding; // Padding opcional

  const ConstrainedContainer({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

// Espaciado adaptativo con SizedBox
// Escala el alto y ancho segun la pantalla
class ResponsiveSizedBox extends StatelessWidget {
  final double height;
  final double? width;

  const ResponsiveSizedBox({
    super.key,
    required this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveUtils.scale(context, height),
      width: width != null ? ResponsiveUtils.scale(context, width!) : null,
    );
  }
}

// Padding adaptativo
// Aplica padding horizontal segun el tamaño de pantalla
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double horizontal; // Valor base para padding horizontal
  final double vertical; // Padding vertical (no es adaptativo)

  const ResponsivePadding({
    super.key,
    required this.child,
    this.horizontal = 20,
    this.vertical = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.horizontalPadding(context),
        vertical: vertical,
      ),
      child: child,
    );
  }
}

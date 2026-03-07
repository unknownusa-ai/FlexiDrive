import 'package:flutter/material.dart';

/// Utilidades para hacer la app responsive
class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double safeAreaTop(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  static double safeAreaBottom(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  /// Escala un valor según el ancho de pantalla
  static double scale(BuildContext context, double baseValue) {
    final width = screenWidth(context);
    if (width < 360) return baseValue * 0.85;
    if (width < 600) return baseValue;
    if (width < 1024) return baseValue * 1.2;
    return baseValue * 1.5;
  }

  /// Padding horizontal adaptativo
  static double horizontalPadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 360) return 16;
    if (width < 600) return 20;
    if (width < 1024) return 40;
    return 80;
  }

  /// Tamaño de fuente adaptativo
  static double fontSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    if (width < 360) return baseSize * 0.9;
    if (width < 600) return baseSize;
    if (width < 1024) return baseSize * 1.1;
    return baseSize * 1.2;
  }
}

/// Extensiones útiles para responsive
extension ResponsiveBuildContext on BuildContext {
  double get screenWidth => ResponsiveUtils.screenWidth(this);
  double get screenHeight => ResponsiveUtils.screenHeight(this);
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
}

/// Widget para layouts adaptativos
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop && desktop != null) {
      return desktop!;
    }
    if (context.isTablet && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/// Widget que limita el ancho máximo en pantallas grandes
class ConstrainedContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

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

/// Espaciado adaptativo
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

/// Padding adaptativo
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double horizontal;
  final double vertical;

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

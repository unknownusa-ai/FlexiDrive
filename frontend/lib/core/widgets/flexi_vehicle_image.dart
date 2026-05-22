import 'dart:io';

import 'package:flutter/material.dart';

/// Define la responsabilidad de `FlexiVehicleImage` dentro de este módulo.
class FlexiVehicleImage extends StatelessWidget {
  /// Crea una instancia y prepara el estado inicial de `FlexiVehicleImage`.
  const FlexiVehicleImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  /// Gestiona verificación de asset path dentro de esta parte del flujo.
  static bool isAssetPath(String path) => path.trim().startsWith('assets/');

  /// Gestiona verificación de network path dentro de esta parte del flujo.
  static bool isNetworkPath(String path) {
    final normalized = path.trim().toLowerCase();
    return normalized.startsWith('http://') ||
        normalized.startsWith('https://');
  }

  /// Gestiona normalize path dentro de esta parte del flujo.
  static String normalizePath(String path) {
    final trimmed = path.trim();
    if (trimmed.startsWith('file://')) {
      return Uri.parse(trimmed).toFilePath();
    }
    return trimmed;
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  @override
  Widget build(BuildContext context) {
    final fallback = placeholder ??
        Container(
          width: width,
          height: height,
          color: const Color(0xFFE5E7EB),
          alignment: Alignment.center,
          child: const Icon(
            Icons.directions_car,
            color: Color(0xFF9CA3AF),
          ),
        );

    final normalized = normalizePath(imagePath);
    if (normalized.isEmpty) return fallback;

    if (isNetworkPath(normalized)) {
      return Image.network(
        normalized,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    if (isAssetPath(normalized)) {
      return Image.asset(
        normalized,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return Image.file(
      File(normalized),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

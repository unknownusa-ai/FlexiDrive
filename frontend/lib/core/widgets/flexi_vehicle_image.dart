import 'dart:io';

import 'package:flutter/material.dart';

class FlexiVehicleImage extends StatelessWidget {
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

  static bool isAssetPath(String path) => path.trim().startsWith('assets/');
  static bool isNetworkPath(String path) {
    final normalized = path.trim().toLowerCase();
    return normalized.startsWith('http://') || normalized.startsWith('https://');
  }

  static String normalizePath(String path) {
    final trimmed = path.trim();
    if (trimmed.startsWith('file://')) {
      return Uri.parse(trimmed).toFilePath();
    }
    return trimmed;
  }

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

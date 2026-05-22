/// Define la responsabilidad de `VehicleImageResolver` dentro de este módulo.
class VehicleImageResolver {
  static const String defaultAsset = 'assets/imagenes_carros/cx5.jpg';

  static String resolveFromVehicle(
    Map<String, dynamic>? vehicle, {
    String? preferredImage,
    String fallback = defaultAsset,
  }) {
    final vehicleImage = _asCleanString(vehicle?['imagen']);
    final preferred = _asCleanString(preferredImage);

    if (_isExternalOrLocalPath(vehicleImage)) {
      return vehicleImage;
    }
    if (_isExternalOrLocalPath(preferred)) {
      return preferred;
    }

    final nameMatchedAsset = assetByVehicleMap(vehicle);
    if (nameMatchedAsset != null) {
      return nameMatchedAsset;
    }

    if (preferred.isNotEmpty) {
      return preferred;
    }
    if (vehicleImage.isNotEmpty) {
      return vehicleImage;
    }
    return fallback;
  }

  /// Gestiona asset por vehicle map dentro de esta parte del flujo.
  static String? assetByVehicleMap(Map<String, dynamic>? vehicle) {
    if (vehicle == null) {
      return null;
    }
    final name =
        '${vehicle['marca'] ?? ''} ${vehicle['linea'] ?? ''} ${vehicle['modelo'] ?? ''}';
    return assetByVehicleName(name);
  }

  /// Gestiona asset por vehicle name dentro de esta parte del flujo.
  static String? assetByVehicleName(String value) {
    final normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    if (normalized.contains('cx5')) {
      return 'assets/imagenes_carros/cx5.jpg';
    }
    if (normalized.contains('mazda3')) {
      return 'assets/imagenes_carros/mazda3.jpg';
    }
    if (normalized.contains('corolla')) {
      return 'assets/imagenes_carros/corolla.jpg';
    }
    if (normalized.contains('sandero')) {
      return 'assets/imagenes_carros/Renault-Sandero.jpg';
    }
    if (normalized.contains('onix')) {
      return 'assets/imagenes_carros/onix.jpeg';
    }
    if (normalized.contains('ranger')) {
      return 'assets/imagenes_carros/ranger.jpg';
    }
    if (normalized.contains('tesla')) {
      return 'assets/imagenes_carros/tesla.jpg';
    }
    if (normalized.contains('mercedes') || normalized.contains('benz')) {
      return 'assets/imagenes_carros/mercedes.jpg';
    }
    if (normalized.contains('porsche')) {
      return 'assets/imagenes_carros/porsche.jpg';
    }
    if (normalized.contains('audia4') ||
        (normalized.contains('audi') && normalized.contains('a4'))) {
      return 'assets/imagenes_carros/audia4.jpg';
    }
    if (normalized.contains('sentra')) {
      return 'assets/imagenes_carros/sentra.jpg';
    }
    if (normalized.contains('bmw')) {
      return 'assets/imagenes_carros/bmw.jpg';
    }
    if (normalized.contains('tucson')) {
      return 'assets/imagenes_carros/tucson.jpg';
    }
    if (normalized.contains('sportage')) {
      return 'assets/imagenes_carros/sportage.jpg';
    }
    return null;
  }

  /// Gestiona verificación de external o local path dentro de esta parte del flujo.
  static bool isExternalOrLocalPath(String? path) =>
      _isExternalOrLocalPath(_asCleanString(path));

  /// Gestiona verificación de external o local path dentro de esta parte del flujo.
  static bool _isExternalOrLocalPath(String path) {
    if (path.isEmpty) {
      return false;
    }
    final lower = path.toLowerCase();
    return lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        lower.startsWith('file://') ||
        path.startsWith('/');
  }

  /// Normaliza el texto y elimina ruido antes de usarlo.
  static String _asCleanString(dynamic value) {
    if (value is! String) {
      return '';
    }
    return value.trim();
  }
}

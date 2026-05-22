/// Define la responsabilidad de `ColombiaTime` dentro de este módulo.
class ColombiaTime {
  /// Crea una instancia y prepara el estado inicial de `ColombiaTime`.
  const ColombiaTime._();

  // Colombia opera en UTC-5 todo el año.
  static const Duration _offset = Duration(hours: -5);

  /// Gestiona now dentro de esta parte del flujo.
  static DateTime now() {
    return DateTime.now().toUtc().add(_offset);
  }

  /// Gestiona a colombia dentro de esta parte del flujo.
  static DateTime toColombia(DateTime value) {
    if (value.isUtc) return value.add(_offset);
    return value.toUtc().add(_offset);
  }
}

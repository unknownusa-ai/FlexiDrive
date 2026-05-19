class ColombiaTime {
  const ColombiaTime._();

  // Colombia opera en UTC-5 todo el año.
  static const Duration _offset = Duration(hours: -5);

  static DateTime now() {
    return DateTime.now().toUtc().add(_offset);
  }

  static DateTime toColombia(DateTime value) {
    if (value.isUtc) return value.add(_offset);
    return value.toUtc().add(_offset);
  }
}

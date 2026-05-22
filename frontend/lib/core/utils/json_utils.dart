/// Define la responsabilidad de `JsonUtils` dentro de este módulo.
class JsonUtils {
  /// Crea una instancia y prepara el estado inicial de `JsonUtils`.
  const JsonUtils._();

  /// Convierte el valor a entero de forma segura.
  static int asInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Convierte el valor a número decimal de forma segura.
  static double asDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Convierte el valor a booleano de forma segura.
  static bool asBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }
    return defaultValue;
  }

  /// Convierte el valor a texto de forma segura.
  static String asString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Convierte el valor a fecha y hora opcional de forma segura.
  static DateTime? asDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Convierte el valor a fecha y hora de forma segura.
  static DateTime asDateTime(dynamic value, {DateTime? defaultValue}) {
    return asDateTimeNullable(value) ?? defaultValue ?? DateTime(1970, 1, 1);
  }
}

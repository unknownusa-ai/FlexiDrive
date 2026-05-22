import 'package:flexidrive/features/security/domain/entities/security_models.dart';

/// Define la responsabilidad de `RepositorioSeguridadPuerto` dentro de este módulo.
abstract class RepositorioSeguridadPuerto {
  Future<void> inicializar();
  List<UserSecurityModel> obtenerSeguridadUsuarios();
  List<UserSessionModel> obtenerSesionesUsuario();
  Future<void> guardarSeguridadUsuario({
    required int userId,
    required bool twoFactorVerification,
    required bool biometricAccess,
  });
}

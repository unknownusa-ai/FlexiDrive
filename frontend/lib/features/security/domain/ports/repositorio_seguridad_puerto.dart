import 'package:flexidrive/features/security/domain/entities/security_models.dart';

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

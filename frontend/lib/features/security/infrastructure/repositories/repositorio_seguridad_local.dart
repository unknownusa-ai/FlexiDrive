import 'package:flexidrive/features/security/domain/ports/repositorio_seguridad_puerto.dart';
import 'package:flexidrive/features/security/domain/entities/security_models.dart';
import 'package:flexidrive/features/security/infrastructure/datasources/local_security_db.dart';

class RepositorioSeguridadLocal implements RepositorioSeguridadPuerto {
  RepositorioSeguridadLocal({LocalSecurityDb? origen})
      : _origen = origen ?? LocalSecurityDb.instance;

  final LocalSecurityDb _origen;

  @override
  Future<void> inicializar() async {
    await _origen.loadIfNeeded();
  }

  @override
  List<UserSecurityModel> obtenerSeguridadUsuarios() => _origen.userSecurities;

  @override
  List<UserSessionModel> obtenerSesionesUsuario() => _origen.userSessions;

  @override
  Future<void> guardarSeguridadUsuario({
    required int userId,
    required bool twoFactorVerification,
    required bool biometricAccess,
  }) {
    return _origen.upsertUserSecurity(
      userId: userId,
      twoFactorVerification: twoFactorVerification,
      biometricAccess: biometricAccess,
    );
  }

  LocalSecurityDb get origen => _origen;
}

import 'package:flexidrive/features/security/domain/entities/security_models.dart';
import 'package:flexidrive/features/security/domain/ports/repositorio_seguridad_puerto.dart';

class SecurityAccessUseCase {
  SecurityAccessUseCase(this._repository);

  final RepositorioSeguridadPuerto _repository;

  Future<void> loadIfNeeded() => _repository.inicializar();

  List<UserSecurityModel> get userSecurities {
    return _repository.obtenerSeguridadUsuarios();
  }

  List<UserSessionModel> get userSessions {
    return _repository.obtenerSesionesUsuario();
  }

  Future<void> upsertUserSecurity({
    required int userId,
    required bool twoFactorVerification,
    required bool biometricAccess,
  }) {
    return _repository.guardarSeguridadUsuario(
      userId: userId,
      twoFactorVerification: twoFactorVerification,
      biometricAccess: biometricAccess,
    );
  }
}

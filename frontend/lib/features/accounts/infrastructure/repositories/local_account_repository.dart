import 'package:flexidrive/core/api/api_client.dart';
import 'package:flexidrive/core/session/local_session_store.dart';
import 'package:flexidrive/features/accounts/domain/entities/account_models.dart';

import '../datasources/local_account_db.dart';

/// Define la responsabilidad de `LocalAccountRepository` dentro de este módulo.
class LocalAccountRepository {
  /// Crea una instancia y prepara el estado inicial de `LocalAccountRepository`.
  LocalAccountRepository({
    LocalAccountDb? db,
    LocalSessionStore? session,
  })  : _db = db ?? LocalAccountDb.instance,
        _session = session ?? LocalSessionStore.instance;

  final LocalAccountDb _db;
  final LocalSessionStore _session;

  /// Inicializa el flujo de inicialización antes de su uso.
  Future<void> init() async {
    await _db.loadIfNeeded();
    await _session.init();
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    await init();

    Map<String, dynamic> response;
    try {
      response = await ApiClient.instance.postMap('auth/login', {
        'correo': email.trim().toLowerCase(),
        'contrasena': password,
      });
    } catch (_) {
      return null;
    }

    final rawUser = response['user'];
    final userMap = rawUser is Map ? rawUser : const {};
    final userId = int.tryParse('${userMap['usuario_id'] ?? ''}');
    final userTypeId = int.tryParse('${userMap['tipo_usuario_id'] ?? ''}');
    final userTypeName = '${userMap['tipo_usuario_nombre'] ?? ''}'.trim();
    final resolvedUserTypeId = _resolveFallbackUserTypeId(
      incomingUserTypeId: userTypeId,
      incomingUserTypeName: userTypeName,
    );
    if (userId == null) return null;

    await _session.setUserId(userId);
    await _session.setLastLoggedEmail(email);

    try {
      await _db.reload();
      for (final user in _db.users) {
        if (user.id == userId) {
          return UserModel(
            id: user.id,
            identificationTypeId: user.identificationTypeId,
            identificationNumber: user.identificationNumber,
            userTypeId:
                resolvedUserTypeId > 0 ? resolvedUserTypeId : user.userTypeId,
            fullName: user.fullName,
            email: user.email,
            phone: user.phone,
            password: user.password,
            canPublish: user.canPublish,
          );
        }
      }
    } catch (_) {
      // Si falla la recarga local, mantenemos la sesion activa con datos minimos.
    }

    return UserModel(
      id: userId,
      identificationTypeId: 0,
      identificationNumber: '',
      userTypeId: resolvedUserTypeId,
      fullName: '${userMap['nombre_completo'] ?? ''}'.trim(),
      email: email.trim().toLowerCase(),
      phone: '',
      password: '',
      canPublish: false,
    );
  }

  /// Obtiene la información asociada a obtener usuarios.
  Future<List<UserModel>> getUsers() async {
    await init();
    try {
      await _db.reload();
    } catch (_) {}
    return List<UserModel>.unmodifiable(_db.users);
  }

  /// Obtiene la información asociada a obtención de ciudades de referencia.
  Future<List<String>> getReferenceCities() async {
    await _db.loadIfNeeded();
    return List<String>.unmodifiable(_db.referenceCities);
  }

  Future<UserModel> register({
    required String fullName,
    required String identificationNumber,
    String? identificationTypeName,
    String? userTypeName,
    required String email,
    required String phone,
    required String password,
    int identificationTypeId = 1,
    int? userTypeId,
    bool canPublish = false,
  }) async {
    await init();

    final normalizedEmail = email.trim().toLowerCase();
    final payload = <String, dynamic>{
      'tipo_identificacion_id': identificationTypeId,
      'tipo_identificacion_nombre': identificationTypeName?.trim() ?? '',
      'tipo_usuario_nombre': userTypeName?.trim() ?? '',
      'numero_identificacion': identificationNumber.trim(),
      'nombre_completo': fullName.trim(),
      'correo': normalizedEmail,
      'telefono': phone.trim(),
      'contrasena': password,
    };
    if (userTypeId != null) {
      payload['tipo_usuario_id'] = userTypeId;
    }
    final response = await ApiClient.instance.postMap('auth/register', payload);
    final userId = int.tryParse('${response['usuario_id'] ?? ''}');

    await _db.reload();
    for (final user in _db.users) {
      if (user.id == userId) return user;
    }

    return UserModel(
      id: userId ?? _db.nextUserId(),
      identificationTypeId: identificationTypeId,
      identificationNumber: identificationNumber.trim(),
      userTypeId: userTypeId ?? 0,
      fullName: fullName.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      password: '',
      canPublish: canPublish,
    );
  }

  /// Gestiona logout dentro de esta parte del flujo.
  Future<void> logout() async {
    await init();
    final currentUserId = _session.userId;
    if (currentUserId != null) {
      for (final user in _db.users) {
        if (user.id == currentUserId) {
          await _session.setLastLoggedEmail(user.email);
          break;
        }
      }
    }
    await _session.clear();
  }

  /// Obtiene la información asociada a obtención del usuario actual.
  Future<UserModel?> getCurrentUser() async {
    await init();

    final currentId = _session.userId;
    if (currentId == null) return null;

    for (final user in _db.users) {
      if (user.id == currentId) return user;
    }

    try {
      final response = await ApiClient.instance.getMap('users/$currentId');
      return UserModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  /// Obtiene la información asociada a obtención del usuario actual preferencia.
  Future<UserPreferenceModel?> getCurrentUserPreference() async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return null;

    for (final preference in _db.preferences) {
      if (preference.userId == currentUser.id) return preference;
    }
    return null;
  }

  /// Actualiza el estado relacionado con actualizar preferencia.
  Future<void> updatePreference(UserPreferenceModel newPreference) async {
    await init();
    final index = _db.preferences.indexWhere((p) => p.id == newPreference.id);
    final payload = newPreference.toJson();

    if (index == -1) {
      final created =
          await ApiClient.instance.postMap('user-preferences', payload);
      _db.preferences.add(UserPreferenceModel.fromJson(created));
      return;
    }

    final updated = await ApiClient.instance.patchMap(
      'user-preferences/${newPreference.id}',
      payload,
    );
    _db.preferences[index] = UserPreferenceModel.fromJson(updated);
  }

  /// Gestiona búsqueda de usuario por correo dentro de esta parte del flujo.
  Future<UserModel?> findUserByEmail(String email) async {
    await init();

    final normalizedEmail = email.trim().toLowerCase();
    for (final user in _db.users) {
      if (user.email.trim().toLowerCase() == normalizedEmail) return user;
    }
    return null;
  }

  /// Actualiza el estado relacionado con actualización de contraseña.
  Future<void> updatePassword(int userId, String newPassword) async {
    await init();

    final index = _db.users.indexWhere((u) => u.id == userId);
    if (index == -1) {
      throw Exception('Usuario no encontrado');
    }

    final user = _db.users[index];
    final updatedUser = UserModel(
      id: user.id,
      identificationTypeId: user.identificationTypeId,
      identificationNumber: user.identificationNumber,
      userTypeId: user.userTypeId,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      password: newPassword,
      canPublish: user.canPublish,
    );

    await _db.saveUserOverride(
      updatedUser,
      syncRemote: true,
      throwOnRemoteFailure: true,
    );
    await _db.reload();
  }

  int _resolveFallbackUserTypeId({
    required int? incomingUserTypeId,
    required String incomingUserTypeName,
  }) {
    final normalizedName = incomingUserTypeName
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
    if (normalizedName.contains('arrendatario')) return 2;
    if (normalizedName.contains('arrendador')) return 1;
    if (incomingUserTypeId != null && incomingUserTypeId > 0) {
      return incomingUserTypeId;
    }
    return 0;
  }
}

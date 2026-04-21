class UserSecurity {
  const UserSecurity({
    required this.id,
    required this.userId,
    required this.twoFactorVerification,
    required this.biometricAccess,
  });

  final int id;
  final int userId;
  final bool twoFactorVerification;
  final bool biometricAccess;
}

class UserSession {
  const UserSession({
    required this.id,
    required this.userId,
    required this.device,
    required this.operatingSystem,
    required this.ipAddress,
    required this.startDate,
    required this.active,
  });

  final int id;
  final int userId;
  final String device;
  final String operatingSystem;
  final String ipAddress;
  final DateTime startDate;
  final bool active;
}

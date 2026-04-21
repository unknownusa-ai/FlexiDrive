class User {
  const User({
    required this.id,
    required this.identificationTypeId,
    required this.identificationNumber,
    required this.userTypeId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.canPublish,
  });

  final int id;
  final int identificationTypeId;
  final String identificationNumber;
  final int userTypeId;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final bool canPublish;
}

class UserPreference {
  const UserPreference({
    required this.id,
    required this.userId,
    required this.darkMode,
    required this.language,
    this.profileImage,
  });

  final int id;
  final int userId;
  final bool darkMode;
  final String language;
  final String? profileImage;
}

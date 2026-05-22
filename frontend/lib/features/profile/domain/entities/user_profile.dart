/// Entidad que representa el perfil completo de un usuario
class UserProfile {
  /// Crea una instancia y prepara el estado inicial de `UserProfile`.
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.identificationNumber,
    required this.identificationTypeId,
    this.avatarUrl,
    this.bio,
    this.location,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.totalSpent = 0.0,
    this.points = 0,
    this.memberSince,
    this.isVerified = false,
    this.canPublish = false,
  });

  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String identificationNumber;
  final int identificationTypeId;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final double rating;
  final int totalTrips;
  final double totalSpent;
  final int points;
  final DateTime? memberSince;
  final bool isVerified;
  final bool canPublish;

  UserProfile copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    String? identificationNumber,
    int? identificationTypeId,
    String? avatarUrl,
    String? bio,
    String? location,
    double? rating,
    int? totalTrips,
    double? totalSpent,
    int? points,
    DateTime? memberSince,
    bool? isVerified,
    bool? canPublish,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      identificationNumber: identificationNumber ?? this.identificationNumber,
      identificationTypeId: identificationTypeId ?? this.identificationTypeId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      totalSpent: totalSpent ?? this.totalSpent,
      points: points ?? this.points,
      memberSince: memberSince ?? this.memberSince,
      isVerified: isVerified ?? this.isVerified,
      canPublish: canPublish ?? this.canPublish,
    );
  }

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'identification_number': identificationNumber,
        'identification_type_id': identificationTypeId,
        'avatar_url': avatarUrl,
        'bio': bio,
        'location': location,
        'rating': rating,
        'total_trips': totalTrips,
        'total_spent': totalSpent,
        'points': points,
        'member_since': memberSince?.toIso8601String(),
        'is_verified': isVerified,
        'can_publish': canPublish,
      };

  /// Crea una instancia y prepara el estado inicial de `UserProfile`.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      identificationNumber: json['identification_number'] as String,
      identificationTypeId: json['identification_type_id'] as int,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: json['total_trips'] as int? ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      points: json['points'] as int? ?? 0,
      memberSince: json['member_since'] != null
          ? DateTime.parse(json['member_since'] as String)
          : null,
      isVerified: json['is_verified'] as bool? ?? false,
      canPublish: json['can_publish'] as bool? ?? false,
    );
  }
}

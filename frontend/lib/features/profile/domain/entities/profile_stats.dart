/// Entidad que representa las estadísticas del perfil de usuario
class ProfileStats {
  const ProfileStats({
    this.totalRentals = 0,
    this.totalPublications = 0,
    this.totalEarnings = 0.0,
    this.averageRating = 0.0,
    this.completedTrips = 0,
    this.cancelledTrips = 0,
    this.pendingReviews = 0,
    this.memberSince,
  });

  final int totalRentals;
  final int totalPublications;
  final double totalEarnings;
  final double averageRating;
  final int completedTrips;
  final int cancelledTrips;
  final int pendingReviews;
  final DateTime? memberSince;

  double get completionRate =>
      totalRentals > 0 ? (completedTrips / totalRentals) * 100 : 0.0;

  ProfileStats copyWith({
    int? totalRentals,
    int? totalPublications,
    double? totalEarnings,
    double? averageRating,
    int? completedTrips,
    int? cancelledTrips,
    int? pendingReviews,
    DateTime? memberSince,
  }) {
    return ProfileStats(
      totalRentals: totalRentals ?? this.totalRentals,
      totalPublications: totalPublications ?? this.totalPublications,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      averageRating: averageRating ?? this.averageRating,
      completedTrips: completedTrips ?? this.completedTrips,
      cancelledTrips: cancelledTrips ?? this.cancelledTrips,
      pendingReviews: pendingReviews ?? this.pendingReviews,
      memberSince: memberSince ?? this.memberSince,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_rentals': totalRentals,
        'total_publications': totalPublications,
        'total_earnings': totalEarnings,
        'average_rating': averageRating,
        'completed_trips': completedTrips,
        'cancelled_trips': cancelledTrips,
        'pending_reviews': pendingReviews,
        'member_since': memberSince?.toIso8601String(),
      };

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      totalRentals: json['total_rentals'] as int? ?? 0,
      totalPublications: json['total_publications'] as int? ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      completedTrips: json['completed_trips'] as int? ?? 0,
      cancelledTrips: json['cancelled_trips'] as int? ?? 0,
      pendingReviews: json['pending_reviews'] as int? ?? 0,
      memberSince: json['member_since'] != null
          ? DateTime.parse(json['member_since'] as String)
          : null,
    );
  }
}

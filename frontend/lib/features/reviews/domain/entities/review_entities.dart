class Opinion {
  const Opinion({
    required this.id,
    required this.rating,
    this.description,
  });

  final int id;
  final int rating;
  final String? description;
}

class Review {
  const Review({
    required this.id,
    required this.userId,
    required this.publicationId,
    required this.opinionId,
    required this.date,
  });

  final int id;
  final int userId;
  final int publicationId;
  final int opinionId;
  final DateTime date;
}

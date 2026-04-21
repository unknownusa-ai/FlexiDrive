class Publication {
  const Publication({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.publishDate,
    required this.active,
  });

  final int id;
  final int userId;
  final int vehicleId;
  final DateTime publishDate;
  final bool active;
}

class PublicationPrice {
  const PublicationPrice({
    required this.id,
    required this.publicationId,
    required this.periodTypeId,
    required this.price,
  });

  final int id;
  final int publicationId;
  final int periodTypeId;
  final double price;
}

class PublicationImage {
  const PublicationImage({
    required this.id,
    required this.publicationId,
    required this.imageUrl,
    required this.order,
    required this.isMain,
    required this.uploadDate,
  });

  final int id;
  final int publicationId;
  final String imageUrl;
  final int order;
  final bool isMain;
  final DateTime uploadDate;
}

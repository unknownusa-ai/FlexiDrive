class LandlordDocument {
  const LandlordDocument({
    required this.id,
    required this.userId,
    required this.documentTypeId,
    required this.verificationStatusId,
    required this.documentUrl,
    required this.uploadDate,
    this.verificationDate,
    this.observations,
  });

  final int id;
  final int userId;
  final int documentTypeId;
  final int verificationStatusId;
  final String documentUrl;
  final DateTime uploadDate;
  final DateTime? verificationDate;
  final String? observations;
}

class Notification {
  const Notification({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.subject,
    required this.description,
    required this.status,
    required this.sentAt,
  });

  final int id;
  final int userId;
  final int categoryId;
  final String subject;
  final String description;
  final String status;
  final DateTime sentAt;
}

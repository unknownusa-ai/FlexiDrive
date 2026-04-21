class Reservation {
  const Reservation({
    required this.id,
    required this.code,
    required this.userId,
    required this.publicationId,
    required this.paymentMethodId,
    required this.periodTypeId,
    required this.periodCount,
    required this.startDate,
    required this.endDate,
    required this.pickupLocation,
    required this.returnLocation,
    required this.totalValue,
    required this.statusId,
    required this.reservationDate,
  });

  final int id;
  final String code;
  final int userId;
  final int publicationId;
  final int paymentMethodId;
  final int periodTypeId;
  final int periodCount;
  final DateTime startDate;
  final DateTime endDate;
  final String pickupLocation;
  final String returnLocation;
  final double totalValue;
  final int statusId;
  final DateTime reservationDate;
}

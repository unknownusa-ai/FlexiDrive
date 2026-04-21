class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.userId,
    required this.paymentMethodTypeId,
    required this.isDefault,
  });

  final int id;
  final int userId;
  final int paymentMethodTypeId;
  final bool isDefault;
}

class Card {
  const Card({
    required this.id,
    required this.paymentMethodId,
    required this.cardNumber,
    required this.cardBrandId,
    required this.expirationMonth,
    required this.expirationYear,
    required this.cvc,
  });

  final int id;
  final int paymentMethodId;
  final String cardNumber;
  final int cardBrandId;
  final int expirationMonth;
  final int expirationYear;
  final int cvc;
}

class Pse {
  const Pse({
    required this.id,
    required this.paymentMethodId,
    required this.bankId,
    required this.personTypeId,
  });

  final int id;
  final int paymentMethodId;
  final int bankId;
  final int personTypeId;
}

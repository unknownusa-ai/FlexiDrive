import 'package:flexidrive/features/payments/domain/entities/payment_models.dart';

abstract class RepositorioPagosPuerto {
  Future<void> inicializar();
  List<PaymentMethodModel> obtenerMetodosPagoUsuario(int userId);
  List<CardModel> obtenerTarjetasUsuario(int userId);
  List<PseModel> obtenerPseUsuario(int userId);
  PaymentMethodModel? obtenerMetodoPagoPredeterminado(int userId);
  PaymentMethodModel? obtenerMetodoPagoPorId(int paymentMethodId);
  CardModel? obtenerTarjetaPorMetodoPagoId(int paymentMethodId);
  PseModel? obtenerPsePorMetodoPagoId(int paymentMethodId);
}

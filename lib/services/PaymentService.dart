import 'package:e_commerces/dto/PaymentDto.dart';
import 'package:e_commerces/models/PaymentModel.dart';

abstract class PaymentService {
  Future<Map<String, dynamic>> createPayment(CreatePaymentDto dto);
  Future<PaymentModel> syncStatus(String paymentId);
}
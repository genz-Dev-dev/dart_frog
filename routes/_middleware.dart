import 'package:dart_frog/dart_frog.dart';
import 'package:e_commerces/config/Dependencies.dart';
import 'package:e_commerces/controllers/PaymentController.dart';

Handler middleware(Handler handler) {
  return (context) async {
    final deps = await Dependencies.instance();
    return handler
        .use(provider<PaymentController>((_) => deps.paymentController))
        .call(context);
  };
}
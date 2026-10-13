import 'package:dart_frog/dart_frog.dart';
import '../../lib/controllers/PaymentController.dart';

/// POST /payments/callback  — ABA PayWay server-to-server notification
/// PayWay will POST here after every payment status change.
/// Must return 200 + {"status":"success"} to stop PayWay retrying.
Future<Response> onRequest(RequestContext context) async {
  return context.read<PaymentController>().callback(context);
}
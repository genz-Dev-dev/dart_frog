import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../errors/PaymentException.dart';

/// ABA PayWay API client.
/// Sandbox: https://checkout-sandbox.payway.com.kh/
/// Production: https://checkout.payway.com.kh/
///
/// Docs: https://developer.payway.com.kh/
class PayWayClient {
  PayWayClient({
    required this.merchantId,
    required this.apiKey,
    String? baseUrl,
  }) : baseUrl = (baseUrl ?? 'https://checkout-sandbox.payway.com.kh')
            .replaceAll(RegExp(r'/$'), '');

  final String merchantId;
  final String apiKey;
  final String baseUrl;

  // ---------------------------------------------------------------------------
  // Create a KHQR / ABA Pay checkout session
  // POST /api/payment-gateway/v1/payments/purchase
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> createKhqrPayment({
    required String tranId,       // your unique payment ID ≤ 20 chars
    required double amount,       // total in USD or KHR
    required String currency,     // USD | KHR
    required String callbackUrl,  // your /payments/callback endpoint
    String firstname = '',
    String lastname = '',
    String email = '',
    String phone = '',
    List<Map<String, dynamic>> items = const [],
    String returnUrl = '',        // browser redirect after payment (web only)
    String cancelUrl = '',
  }) async {
    final reqTime = _reqTime();
    final amountStr = amount.toStringAsFixed(2);

    final params = {
      'req_time': reqTime,
      'merchant_id': merchantId,
      'tran_id': tranId,
      'amount': amountStr,
      'items': jsonEncode(items),
      'shipping': '0',
      'discount': '0',
      'ctry_code': 'KH',
      'currency': currency,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'email': email,
      'payment_option': 'abapay_khqr',
      'callback_url': callbackUrl,
      'return_url': returnUrl,
      'cancel_url': cancelUrl,
    };

    params['hash'] = _sign(params);

    return _post('/api/payment-gateway/v1/payments/purchase', params);
  }

  // ---------------------------------------------------------------------------
  // Check transaction status
  // POST /api/payment-gateway/v1/payments/check-transaction-2
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> checkTransaction(String tranId) async {
    final reqTime = _reqTime();

    final params = {
      'req_time': reqTime,
      'merchant_id': merchantId,
      'tran_id': tranId,
    };
    params['hash'] = _sign(params);

    return _post(
        '/api/payment-gateway/v1/payments/check-transaction-2', params);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// ISO-8601 timestamp in UTC that PayWay uses as part of the signed payload.
  String _reqTime() =>
      DateTime.now().toUtc().toIso8601String().replaceAll(RegExp(r'\.\d+Z$'), 'Z');

  /// HMAC-SHA512 of the sorted key=value pairs, Base64-encoded.
  /// PayWay signs: alphabetically sorted keys joined by \n, then HMAC with apiKey.
  String _sign(Map<String, String> params) {
    final sorted = (params.keys.toList()..sort())
        .map((k) => params[k]!)
        .join('');
    final key = utf8.encode(apiKey);
    final msg = utf8.encode(sorted);
    final digest = Hmac(sha512, key).convert(msg);
    return base64.encode(digest.bytes);
  }

  Future<Map<String, dynamic>> _post(
      String path, Map<String, String> params) async {
    final uri = Uri.parse('$baseUrl$path');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: params,
    );

    if (response.statusCode >= 500) {
      throw PaymentException(
        'PayWay server error ${response.statusCode}',
        statusCode: 502,
        details: response.body,
      );
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw PaymentException(
        'Invalid JSON from PayWay',
        statusCode: 502,
        details: response.body,
      );
    }
  }
}


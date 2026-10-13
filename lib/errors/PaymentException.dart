class PaymentException implements Exception {
  PaymentException(this.message, {this.statusCode = 400, this.details});

  final String message;
  final int statusCode;
  final dynamic details;

  @override
  String toString() => 'PaymentException($statusCode): $message';
}


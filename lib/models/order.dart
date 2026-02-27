class Order {
  final int orderId;
  final String status;
  final String? paymentUrl;

  const Order({
    required this.orderId,
    required this.status,
    this.paymentUrl,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final orderId = json['order_id'];
    final status = json['status'];

    if (orderId is! int) {
      throw FormatException('Expected int for order_id, got ${orderId.runtimeType}');
    }
    if (status is! String) {
      throw FormatException('Expected String for status, got ${status.runtimeType}');
    }

    return Order(
      orderId: orderId,
      status: status,
      paymentUrl: json['payment_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'status': status,
        'payment_url': paymentUrl,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order &&
          runtimeType == other.runtimeType &&
          orderId == other.orderId &&
          status == other.status &&
          paymentUrl == other.paymentUrl;

  @override
  int get hashCode => Object.hash(orderId, status, paymentUrl);

  @override
  String toString() => 'Order(id: $orderId, status: $status, paymentUrl: $paymentUrl)';
}

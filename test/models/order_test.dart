import 'package:flutter_test/flutter_test.dart';
import 'package:order_project/models/order.dart';

void main() {
  group('Order', () {
    test('fromJson parses valid response', () {
      final json = {
        'order_id': 42,
        'status': 'pending',
        'payment_url': 'https://pay.example.com/42',
      };

      final order = Order.fromJson(json);

      expect(order.orderId, 42);
      expect(order.status, 'pending');
      expect(order.paymentUrl, 'https://pay.example.com/42');
    });

    test('fromJson handles null payment_url', () {
      final json = {
        'order_id': 1,
        'status': 'created',
        'payment_url': null,
      };

      final order = Order.fromJson(json);

      expect(order.paymentUrl, isNull);
    });

    test('fromJson handles missing payment_url', () {
      final json = {
        'order_id': 1,
        'status': 'created',
      };

      final order = Order.fromJson(json);

      expect(order.paymentUrl, isNull);
    });

    test('fromJson throws on missing order_id', () {
      final json = {'status': 'created'};

      expect(() => Order.fromJson(json), throwsFormatException);
    });

    test('fromJson throws on missing status', () {
      final json = {'order_id': 1};

      expect(() => Order.fromJson(json), throwsFormatException);
    });

    test('toJson produces correct map', () {
      const order = Order(orderId: 5, status: 'paid', paymentUrl: 'https://pay.example.com');

      expect(order.toJson(), {
        'order_id': 5,
        'status': 'paid',
        'payment_url': 'https://pay.example.com',
      });
    });

    test('equality works correctly', () {
      const a = Order(orderId: 1, status: 'pending');
      const b = Order(orderId: 1, status: 'pending');
      const c = Order(orderId: 2, status: 'pending');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });
  });
}

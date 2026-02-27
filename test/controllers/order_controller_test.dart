import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:order_project/controllers/order_controller.dart';
import 'package:order_project/services/api_service.dart';

void main() {
  group('OrderController', () {
    test('initial state is correct', () {
      final service = ApiService(
        client: MockClient((_) async => http.Response('', 200)),
      );
      final controller = OrderController(service);

      expect(controller.state, OrderState.initial);
      expect(controller.errorMessage, isNull);
      expect(controller.order, isNull);
    });

    test('transitions to loading then success', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'order_id': 1, 'status': 'created'}),
            200,
          ));
      final service = ApiService(client: client, baseUrl: 'https://test.com');
      final controller = OrderController(service);

      final states = <OrderState>[];
      controller.addListener(() => states.add(controller.state));

      await controller.submitOrder(1, 100);

      expect(states, [OrderState.loading, OrderState.success]);
      expect(controller.order, isNotNull);
      expect(controller.order!.orderId, 1);
      expect(controller.errorMessage, isNull);
    });

    test('transitions to loading then error on failure', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'message': 'Bad request'}),
            400,
          ));
      final service = ApiService(client: client, baseUrl: 'https://test.com');
      final controller = OrderController(service);

      final states = <OrderState>[];
      controller.addListener(() => states.add(controller.state));

      await controller.submitOrder(1, 100);

      expect(states, [OrderState.loading, OrderState.error]);
      expect(controller.errorMessage, isNotNull);
      expect(controller.order, isNull);
    });

    test('reset returns to initial state', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'order_id': 1, 'status': 'created'}),
            200,
          ));
      final service = ApiService(client: client, baseUrl: 'https://test.com');
      final controller = OrderController(service);

      await controller.submitOrder(1, 100);
      expect(controller.state, OrderState.success);

      controller.reset();

      expect(controller.state, OrderState.initial);
      expect(controller.order, isNull);
      expect(controller.errorMessage, isNull);
    });
  });
}

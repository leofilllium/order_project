import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:order_project/core/api_exception.dart';
import 'package:order_project/services/api_service.dart';

void main() {
  group('ApiService.createOrder', () {
    test('returns Order on 200 with valid JSON', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({
              'order_id': 1,
              'status': 'created',
              'payment_url': 'https://pay.example.com/1',
            }),
            200,
          ));

      final service = ApiService(client: client, baseUrl: 'https://test.com');
      final order = await service.createOrder(10, 20);

      expect(order.orderId, 1);
      expect(order.status, 'created');
      expect(order.paymentUrl, 'https://pay.example.com/1');
    });

    test('throws ApiException on 400 with error message', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'message': 'Invalid service ID'}),
            400,
          ));

      final service = ApiService(client: client, baseUrl: 'https://test.com');

      expect(
        () => service.createOrder(10, 999),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', 'Invalid service ID')
            .having((e) => e.statusCode, 'statusCode', 400)),
      );
    });

    test('throws ApiException on 500 with "error" field', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'error': 'Internal server error'}),
            500,
          ));

      final service = ApiService(client: client, baseUrl: 'https://test.com');

      expect(
        () => service.createOrder(10, 20),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', 'Internal server error')
            .having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('throws ApiException on invalid JSON response for 200', () async {
      final client = MockClient((_) async => http.Response('not json', 200));

      final service = ApiService(client: client, baseUrl: 'https://test.com');

      expect(
        () => service.createOrder(10, 20),
        throwsA(isA<ApiException>()),
      );
    });

    test('sends correct request body', () async {
      late http.Request capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({'order_id': 1, 'status': 'created'}),
          200,
        );
      });

      final service = ApiService(client: client, baseUrl: 'https://test.com');
      await service.createOrder(42, 99);

      expect(capturedRequest.url.toString(), 'https://test.com/api/orders');
      expect(capturedRequest.headers['Content-Type'], 'application/json');

      final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
      expect(body['userId'], 42);
      expect(body['serviceId'], 99);
    });
  });
}

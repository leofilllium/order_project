import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:order_project/services/api_service.dart';
import 'package:order_project/ui/order_screen.dart';

void main() {
  group('OrderScreen', () {
    Widget buildApp(http.Client client) {
      return MaterialApp(
        home: OrderScreen(
          apiService: ApiService(client: client, baseUrl: 'https://test.com'),
        ),
      );
    }

    testWidgets('shows create order button initially', (tester) async {
      final client = MockClient((_) async => http.Response('', 200));
      await tester.pumpWidget(buildApp(client));

      expect(find.text('Создать заказ'), findsOneWidget);
    });

    testWidgets('shows success message after order creation', (tester) async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'order_id': 42, 'status': 'created'}),
            200,
          ));
      await tester.pumpWidget(buildApp(client));

      await tester.tap(find.text('Создать заказ'));
      await tester.pumpAndSettle();

      expect(find.text('Заказ успешно создан!'), findsOneWidget);
      expect(find.textContaining('ID заказа: 42'), findsOneWidget);
    });

    testWidgets('shows error message and retry button on failure', (tester) async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'message': 'Service unavailable'}),
            503,
          ));
      await tester.pumpWidget(buildApp(client));

      await tester.tap(find.text('Создать заказ'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Service unavailable'), findsOneWidget);
      expect(find.text('Повторить попытку'), findsOneWidget);
    });

    testWidgets('button is disabled during loading', (tester) async {
      final completer = Completer<http.Response>();
      final client = MockClient((_) => completer.future);
      await tester.pumpWidget(buildApp(client));

      await tester.tap(find.text('Создать заказ'));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to avoid pending timers.
      completer.complete(http.Response(
        jsonEncode({'order_id': 1, 'status': 'created'}),
        200,
      ));
      await tester.pumpAndSettle();
    });
  });
}

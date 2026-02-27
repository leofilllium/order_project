import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../core/api_exception.dart';

class ApiService {
  final http.Client _client;
  final String _baseUrl;

  static const _timeout = Duration(seconds: 10);

  ApiService({
    http.Client? client,
    String baseUrl = 'https://example.com',
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl;

  Future<Order> createOrder(int userId, int serviceId) async {
    final uri = Uri.parse('$_baseUrl/api/orders');
    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'userId': userId, 'serviceId': serviceId}),
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }

      throw ApiException(
        _extractErrorMessage(response.body),
        response.statusCode,
      );
    } on TimeoutException {
      throw const ApiException('Превышено время ожидания запроса.');
    } on SocketException {
      throw const ApiException('Нет подключения к интернету.');
    } on FormatException {
      throw const ApiException('Некорректный формат ответа сервера.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Непредвиденная ошибка: $e');
    }
  }

  String _extractErrorMessage(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return (data['message'] ?? data['error'] ?? 'Неизвестная ошибка.') as String;
    } catch (_) {
      return 'Неизвестная ошибка.';
    }
  }
}

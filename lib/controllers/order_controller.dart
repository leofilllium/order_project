import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/api_service.dart';

enum OrderState { initial, loading, success, error }

class OrderController extends ChangeNotifier {
  final ApiService _apiService;

  OrderState _state = OrderState.initial;
  OrderState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Order? _order;
  Order? get order => _order;

  OrderController(this._apiService);

  Future<void> submitOrder(int userId, int serviceId) async {
    _state = OrderState.loading;
    _errorMessage = null;
    _order = null;
    notifyListeners();

    try {
      _order = await _apiService.createOrder(userId, serviceId);
      _state = OrderState.success;
    } catch (e) {
      _state = OrderState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void reset() {
    _state = OrderState.initial;
    _errorMessage = null;
    _order = null;
    notifyListeners();
  }
}

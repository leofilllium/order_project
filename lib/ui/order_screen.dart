import 'package:flutter/material.dart';
import '../controllers/order_controller.dart';
import '../services/api_service.dart';

class OrderScreen extends StatefulWidget {
  final ApiService apiService;

  const OrderScreen({super.key, required this.apiService});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late final OrderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OrderController(widget.apiService);
    _controller.addListener(_onStateChanged);
  }

  void _onStateChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onCreateOrderTap() {
    _controller.submitOrder(1, 100);
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final isLoading = state == OrderState.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Создание заказа')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (state == OrderState.error && _controller.errorMessage != null)
                _StatusBanner(
                  message: _controller.errorMessage!,
                  color: Colors.red,
                  icon: Icons.error_outline,
                ),
              if (state == OrderState.success) ...[
                const _StatusBanner(
                  message: 'Заказ успешно создан!',
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                ),
                if (_controller.order != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'ID заказа: ${_controller.order!.orderId}\n'
                      'Статус: ${_controller.order!.status}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _onCreateOrderTap,
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Text(
                          state == OrderState.error
                              ? 'Повторить попытку'
                              : 'Создать заказ',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;

  const _StatusBanner({
    required this.message,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

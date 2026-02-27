class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  bool get isNetworkError => statusCode == null && message == 'Нет подключения к интернету.';

  bool get isTimeout => statusCode == null && message == 'Превышено время ожидания запроса.';

  @override
  String toString() => statusCode != null ? 'ApiException($statusCode): $message' : 'ApiException: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          statusCode == other.statusCode;

  @override
  int get hashCode => Object.hash(message, statusCode);
}

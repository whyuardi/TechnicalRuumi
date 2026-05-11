// lib/core/error/app_exception.dart

/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

/// Network / connectivity errors
class NetworkException extends AppException {
  const NetworkException({super.message = 'Tidak ada koneksi internet. Periksa jaringan Anda.'});
}

/// Timeout errors
class TimeoutException extends AppException {
  const TimeoutException({super.message = 'Koneksi timeout. Coba lagi.'});
}

/// Server returned 4xx / 5xx
class ServerException extends AppException {
  final dynamic rawData;
  const ServerException({
    required super.message,
    super.statusCode,
    this.rawData,
  });
}

/// 422 Unprocessable Entity (validation errors from backend)
class ValidationException extends AppException {
  final dynamic detail;
  const ValidationException({
    required super.message,
    this.detail,
  }) : super(statusCode: 422);
}

/// Local / unknown errors
class UnknownException extends AppException {
  const UnknownException({super.message = 'Terjadi kesalahan. Coba lagi.'});
}

// lib/core/network/dio_client.dart
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../error/app_exception.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(_LoggingInterceptor());
    dio.interceptors.add(_ErrorInterceptor());

    return dio;
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[DIO] → ${options.method} ${options.uri}');
    if (options.data != null) {
      debugPrint('[DIO] Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[DIO] ← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[DIO] ✗ ${err.type} - ${err.message}');
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException appException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        appException = const TimeoutException();
        break;
      case DioExceptionType.connectionError:
        appException = const NetworkException();
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        final data = err.response?.data;

        if (statusCode == 422) {
          String message = 'Data tidak valid.';
          if (data is Map && data.containsKey('detail')) {
            message = data['detail'].toString();
          }
          appException = ValidationException(message: message, detail: data);
        } else if (statusCode == 404) {
          appException = const ServerException(
            message: 'Data tidak ditemukan.',
            statusCode: 404,
          );
        } else if (statusCode >= 500) {
          appException = ServerException(
            message: 'Server error. Coba lagi nanti.',
            statusCode: statusCode,
          );
        } else {
          appException = ServerException(
            message: 'Terjadi kesalahan ($statusCode).',
            statusCode: statusCode,
            rawData: data,
          );
        }
        break;
      default:
        appException = const UnknownException();
    }

    // Wrap the original error with our custom exception
    final newErr = err.copyWith(
      error: appException,
      message: appException.message,
    );
    handler.next(newErr);
  }
}

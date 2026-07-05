import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_exceptions.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('--> [REQUEST] ${options.method.toUpperCase()} ${options.uri}');
      if (options.queryParameters.isNotEmpty) {
        debugPrint('    Query: ${options.queryParameters}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- [RESPONSE ${response.statusCode}] ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- [ERROR ${err.response?.statusCode}] ${err.requestOptions.uri}');
      debugPrint('    Message: ${err.message}');
    }

    final exception = _handleDioError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException(message: 'Connection timed out. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String message = 'Server error occurred.';
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          message = data['data'].toString();
        } else if (data is Map<String, dynamic> && data.containsKey('message')) {
          message = data['message'].toString();
        }
        if (statusCode == 401) return UnauthorizedException(message: message);
        if (statusCode == 404) return NotFoundException(message: message);
        return ServerException(message: message, statusCode: statusCode);
      case DioExceptionType.cancel:
        return const UnknownException(message: 'Request was cancelled.');
      default:
        return const NetworkException();
    }
  }
}

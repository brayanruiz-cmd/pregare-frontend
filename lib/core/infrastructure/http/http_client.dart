import 'package:dio/dio.dart';
import '../errors/app_exception.dart';

class PregareHttpClient {
  PregareHttpClient({required String baseUrl, String? token})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )) {
    _dio.interceptors.add(_RetryInterceptor());
  }

  final Dio _dio;

  void updateToken(String? token) {
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return parser != null ? parser(response.data) : response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return parser != null ? parser(response.data) : response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return parser != null ? parser(response.data) : response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timeout');
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Server error';
        if (statusCode == 401) return UnauthorizedException(message);
        if (statusCode == 404) return NotFoundException(message);
        if (statusCode == 400) return BadRequestException(message);
        return ServerException(message, statusCode);
      default:
        return ServerException(e.message ?? 'Unknown error');
    }
  }
}

class _RetryInterceptor extends Interceptor {
  int _retryCount = 0;
  static const _maxRetries = 3;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_retryCount < _maxRetries &&
        err.type == DioExceptionType.connectionError) {
      _retryCount++;
      Future.delayed(Duration(seconds: _retryCount), () async {
        try {
          final dio = Dio();
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
        } catch (e) {
          handler.next(err);
        }
      });
    } else {
      _retryCount = 0;
      handler.next(err);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _retryCount = 0;
    handler.next(response);
  }
}

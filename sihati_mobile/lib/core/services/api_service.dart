// lib/core/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData;
import '../../app/constants/api_constants.dart';
import 'storage_service.dart';

typedef QueuedInterceptorCallback = void Function(String? token);

class ApiService extends GetxService {
  late final Dio _dio;
  late final StorageService _storageService;

  @override
  void onInit() {
    super.onInit();
    _storageService = Get.find<StorageService>();
    _initDio();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.BASE_URL,
      connectTimeout: ApiConstants.CONNECT_TIMEOUT,
      receiveTimeout: ApiConstants.RECEIVE_TIMEOUT,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor(_storageService, _dio));
    _dio.interceptors.add(_LoggingInterceptor());
  }

  Dio get dio => _dio;

  // ─── HTTP METHODS ─────────────────────────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(path,
          queryParameters: queryParameters, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(path,
          data: data, queryParameters: queryParameters, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(path,
          data: data, queryParameters: queryParameters, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(path,
          queryParameters: queryParameters, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(path,
          data: data, queryParameters: queryParameters, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> upload(
    String path,
    FormData formData, {
    Options? options,
  }) async {
    try {
      return await _dio.post(path, data: formData, options: options);
    } catch (e) {
      rethrow;
    }
  }
}

// ============================================
// AUTH INTERCEPTOR - Auto refresh token
// ============================================
class _AuthInterceptor extends Interceptor {
  final StorageService _storageService;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<QueuedInterceptorCallback> _failedRequests = [];

  _AuthInterceptor(this._storageService, this._dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;

      // Don't try to refresh if already refreshing
      if (_isRefreshing) {
        _failedRequests.add((token) {
          requestOptions.headers['Authorization'] = 'Bearer $token';
          _dio
              .fetch(requestOptions)
              .then((response) => handler.resolve(response))
              .catchError((e) => handler.reject(e));
        });
        return;
      }

      _isRefreshing = true;

      try {
        final newToken = await _refreshToken();
        if (newToken != null) {
          // Retry all failed requests
          for (final callback in _failedRequests) {
            callback(newToken);
          }

          // Retry current request
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final response = await _dio.fetch(requestOptions);
          handler.resolve(response);
        } else {
          // Refresh failed - logout
          await _storageService.clearAuth();
          Get.offAllNamed('/login');
          handler.reject(err);
        }
      } catch (e) {
        handler.reject(err);
      } finally {
        _isRefreshing = false;
        _failedRequests.clear();
      }
    } else {
      handler.next(err);
    }
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        print('No refresh token available');
        return null;
      }

      final response = await _dio.post(
        '${ApiConstants.BASE_URL}${ApiConstants.REFRESH_TOKEN}',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final newToken = data['accessToken'] ?? data['token'];

        if (newToken != null) {
          await _storageService.saveToken(newToken);
          return newToken;
        }
      }
      return null;
    } catch (e) {
      print('Refresh token error: $e');
      return null;
    }
  }
}

// ============================================
// LOGGING INTERCEPTOR (Debug only)
// ============================================
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🌐 REQUEST: ${options.method} ${options.uri}');
    print('📦 HEADERS: ${options.headers}');
    if (options.data != null) {
      print('📝 DATA: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR: ${err.message}');
    print('🔍 RESPONSE: ${err.response?.data}');
    handler.next(err);
  }
}

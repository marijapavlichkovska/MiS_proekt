import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;
  final String? apiKey;

  ApiService(String baseUrl, {this.apiKey})
      : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) {
    final queryWithKey = Map<String, dynamic>.from(query ?? {});
    if (apiKey != null) {
      queryWithKey['key'] = apiKey;
    }
    return _dio.get<T>(path, queryParameters: queryWithKey);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) =>
      _dio.delete<T>(path);
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

/// Reusable API service for all HTTP requests to the backend.
///
/// Handles authorization headers, error parsing, and response decoding.
class ApiService {
  final String baseUrl;
  String? _authToken;

  ApiService({this.baseUrl = AppConstants.apiBaseUrl});

  /// Set the auth token for subsequent requests.
  void setToken(String? token) {
    _authToken = token;
  }

  /// Standard headers including auth token if available.
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// GET request.
  Future<ApiResponse> get(String endpoint,
      {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Koneksi gagal: ${e.toString()}');
    }
  }

  /// POST request.
  Future<ApiResponse> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Koneksi gagal: ${e.toString()}');
    }
  }

  /// PUT request.
  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Koneksi gagal: ${e.toString()}');
    }
  }

  /// DELETE request.
  Future<ApiResponse> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Koneksi gagal: ${e.toString()}');
    }
  }

  /// Handle HTTP response and return ApiResponse.
  ApiResponse _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.success(body);
    }

    final message = body is Map && body.containsKey('message')
        ? body['message'] as String
        : 'Terjadi kesalahan (${response.statusCode})';

    return ApiResponse.error(message, statusCode: response.statusCode);
  }
}

/// Wrapper for API responses.
class ApiResponse {
  final bool isSuccess;
  final dynamic data;
  final String? errorMessage;
  final int? statusCode;

  const ApiResponse._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
    this.statusCode,
  });

  factory ApiResponse.success(dynamic data) {
    return ApiResponse._(isSuccess: true, data: data);
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse._(
      isSuccess: false,
      errorMessage: message,
      statusCode: statusCode,
    );
  }
}

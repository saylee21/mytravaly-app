import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// import '../app_export.dart';
import '../utils/pref_utils.dart';
import 'network_info.dart';

/// ApiClientV2: Enhanced HTTP client with better error handling and response processing
class ApiClientV2 {
  final Duration timeout;

  ApiClientV2({
    this.timeout = const Duration(seconds: 120),
  });

  /// GET method with enhanced error handling
  Future<Either<FailureV2, T>> get<T>({
    required String url,
    Map<String, String>? queryParams,
    required T Function(dynamic json) converter,
    bool requiresAuth = true,
  }) async {
    try {
      // Check network connectivity
      if (!await NetworkInfo().isConnected()) {
        return Left(NetworkFailure('No internet connection available'));
      }

      final uri = Uri.parse(url).replace(queryParameters: queryParams);

      // Log request details
      _logRequest('GET', uri);

      final response = await http
          .get(
            uri,
            headers: populateHeaders(contentType: 'application/json'),
          )
          .timeout(
            timeout,
            onTimeout: () => throw APIExceptionV2(
              message: 'Request timeout',
              statusCode: 408,
            ),
          );

      // Log response
      _logResponse(response);

      return _handleResponse(response, converter);
    } on TimeoutException {
      return Left(APIFailureV2(
        message: 'Request timed out',
        statusCode: 408,
      ));
    } on FormatException catch (e, stackTrace) {
      _logError('Format Exception', e, stackTrace);
      return Left(APIFailureV2(
        message: 'Error processing data',
        statusCode: 422,
        errorData: {'error': e.toString()},
      ));
    } on APIExceptionV2 catch (e) {
      return Left(APIFailureV2(
        message: e.message,
        statusCode: e.statusCode,
        errorData: e.data,
      ));
    } catch (e, stackTrace) {
      log('Catch error', error: e, stackTrace: stackTrace);
      return _handleError(e, stackTrace);
    }
  }

  /// POST method with enhanced error handling
  Future<Either<FailureV2, T>> post<T>({
    required String url,
    required dynamic body,
    required T Function(dynamic json) converter,
    String contentType = 'application/json',
  }) async {
    try {
      if (!await NetworkInfo().isConnected()) {
        return Left(NetworkFailure('No internet connection available'));
      }

      final uri = Uri.parse(url);
      final jsonBody = jsonEncode(body);

      _logRequest('POST', uri, body: jsonBody);

      final response = await http
          .post(
            uri,
            headers: populateHeaders(contentType: contentType),
            body: jsonBody,
          )
          .timeout(timeout);

      _logResponse(response);

      return _handleResponse(response, converter);
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  /// PUT method with enhanced error handling
  Future<Either<FailureV2, T>> put<T>({
    required String url,
    required dynamic body,
    required T Function(dynamic json) converter,
  }) async {
    try {
      if (!await NetworkInfo().isConnected()) {
        return Left(NetworkFailure('No internet connection available'));
      }

      final uri = Uri.parse(url);
      final jsonBody = jsonEncode(body);

      _logRequest('PUT', uri, body: jsonBody);

      final response = await http
          .put(
            uri,
            headers: populateHeaders(),
            body: jsonBody,
          )
          .timeout(timeout);

      _logResponse(response);

      return _handleResponse(response, converter);
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  /// DELETE method with enhanced error handling
  Future<Either<FailureV2, T>> delete<T>({
    required String url,
    dynamic body,
    required T Function(dynamic json) converter,
  }) async {
    try {
      if (!await NetworkInfo().isConnected()) {
        return Left(NetworkFailure('No internet connection available'));
      }

      final uri = Uri.parse(url);
      final jsonBody = body != null ? jsonEncode(body) : null;

      _logRequest('DELETE', uri, body: jsonBody);

      final response = await http
          .delete(
            uri,
            headers: populateHeaders(),
            body: jsonBody,
          )
          .timeout(timeout);

      _logResponse(response);

      return _handleResponse(response, converter);
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  /* Future<Either<FailureV2, T>> postMultipart<T>({
    required String url,
    required Map<String, String> fields,
    required Map<String, dynamic> files,
    required T Function(dynamic json) converter,
  }) async {
    try {
      if (!await NetworkInfo().isConnected()) {
        return Left(NetworkFailure('No internet connection available'));
      }

      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers
          .addAll(populateHeaders(contentType: 'multipart/form-data'));

      // Add text fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add files
      for (var entry in files.entries) {
        if (entry.value is html.File) {
          final file = entry.value as html.File;
          final bytes = await _readFileAsBytes(file);
          request.files.add(
            http.MultipartFile.fromBytes(
              entry.key,
              bytes,
              filename: file.name,
              contentType: _getContentType(file.type),
            ),
          );
        }
      }

      _logRequest('POST', uri, body: fields.toString());

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse(response);

      return _handleResponse(response, converter);
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<Either<FailureV2, T>> putMultipart<T>({
    required String url,
    required Map<String, String> fields,
    Map<String, dynamic>? files, // Made files parameter optional
    required T Function(dynamic json) converter,
  }) async {
    try {
      if (!await NetworkInfo().isConnected()) {
        return Left(NetworkFailure('No internet connection available'));
      }

      final uri = Uri.parse(url);
      final request = http.MultipartRequest('PUT', uri);

      // Add headers
      request.headers
          .addAll(populateHeaders(contentType: 'multipart/form-data'));

      // Add text fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add files only if files map is provided
      if (files != null) {
        for (var entry in files.entries) {
          if (entry.value is html.File) {
            final file = entry.value as html.File;
            if (await _hasFileContent(file)) {
              final bytes = await _readFileAsBytes(file);
              request.files.add(
                http.MultipartFile.fromBytes(
                  entry.key,
                  bytes,
                  filename: file.name,
                  contentType: _getContentType(file.type),
                ),
              );
            }
          }
        }
      }

      _logRequest('PUT', uri, body: fields.toString());

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse(response);

      return _handleResponse(response, converter);
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<bool> _hasFileContent(html.File file) async {
    return file.size > 0;
  }

  Future<List<int>> _readFileAsBytes(html.File file) async {
    final completer = Completer<List<int>>();
    final reader = html.FileReader();

    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      if (result is List<int>) {
        completer.complete(result);
      } else {
        completer.completeError('Failed to read file as bytes');
      }
    });

    reader.onError.listen((error) {
      completer.completeError(error);
    });

    reader.readAsArrayBuffer(file);
    return completer.future;
  }

  MediaType _getContentType(String mimeType) {
    final parts = mimeType.split('/');
    if (parts.length == 2) {
      return MediaType(parts[0], parts[1]);
    }
    return MediaType('application', 'octet-stream');
  }*/

/*  /// Handle API response
  Either<FailureV2, T> _handleResponse1<T>(
    http.Response response,
    T Function(dynamic json) converter,
  ) {
    try {
      final utf8Body = utf8.decode(response.bodyBytes);
      final dynamic parsedJson = jsonDecode(utf8Body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final T model = converter(parsedJson);
          return Right(model);
        } catch (e, stackTrace) {
          _logError('Conversion Error', e, stackTrace);
          return Left(APIFailureV2(
            message: 'Error processing response data',
            statusCode: 422,
            errorData: {'error': e.toString(), 'data': parsedJson},
          ));
        }
      }

      if (response.statusCode == 401) {
        // Clear preferences and navigate to splash screen
        _handleAuthorizationError();
      }
      // For error responses, create APIFailure with the actual status code
      final errorMessage = _getErrorMessage(response);
      final errorData = _extractErrorData(response);

      log(
        'Error Response Details:\n'
        'Status Code: ${response.statusCode}\n'
        'Error Message: $errorMessage\n'
        'Error Data: $errorData',
      );

      return Left(APIFailureV2(
        message: errorMessage,
        statusCode: response.statusCode,
        errorData: errorData,
      ));
    } catch (e, stackTrace) {
      _logError('Response Handling Error', e, stackTrace);
      return Left(APIFailureV2(
        message: 'Error processing response',
        statusCode: 422,
        errorData: {'error': e.toString()},
      ));
    }
  }*/

  /// Handle API response with business logic validation
  Either<FailureV2, T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic json) converter,
  ) {
    try {
      final utf8Body = utf8.decode(response.bodyBytes);
      final dynamic parsedJson = jsonDecode(utf8Body);

      // First check HTTP status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Then check business logic success flag if available
        if (parsedJson is Map<String, dynamic> &&
            parsedJson.containsKey('success') &&
            parsedJson.containsKey('has_errors')) {
          final bool success = parsedJson['success'] as bool;
          final bool hasErrors = parsedJson['has_errors'] as bool;

          if (!success || hasErrors) {
            // Handle business logic error
            final errorMessage = _getBusinessErrorMessage(parsedJson);
            final errorData = _extractBusinessErrorData(parsedJson);

            log(
              'Business Logic Error:\n'
              'Success: $success\n'
              'Has Errors: $hasErrors\n'
              'Error Message: $errorMessage\n'
              'Error Data: $errorData',
            );

            return Left(APIFailureV2(
              message: errorMessage,
              statusCode: parsedJson['r_code'] as int? ?? response.statusCode,
              errorData: errorData,
            ));
          }
        }

        // If we get here, it's a valid successful response
        try {
          final T model = converter(parsedJson);
          return Right(model);
        } catch (e, stackTrace) {
          _logError('Conversion Error', e, stackTrace);
          return Left(APIFailureV2(
            message: 'Error processing response data',
            statusCode: 422,
            errorData: {'error': e.toString(), 'data': parsedJson},
          ));
        }
      }

      if (response.statusCode == 401) {
        // Clear preferences and navigate to splash screen
        _handleAuthorizationError();
      }

      // HTTP error responses
      final errorMessage = _getErrorMessage(response);
      final errorData = _extractErrorData(response);

      log(
        'Error Response Details:\n'
        'Status Code: ${response.statusCode}\n'
        'Error Message: $errorMessage\n'
        'Error Data: $errorData',
      );

      return Left(APIFailureV2(
        message: errorMessage,
        statusCode: response.statusCode,
        errorData: errorData,
      ));
    } catch (e, stackTrace) {
      _logError('Response Handling Error', e, stackTrace);
      return Left(APIFailureV2(
        message: 'Error processing response',
        statusCode: 422,
        errorData: {'error': e.toString()},
      ));
    }
  }

  /// Extract error message from business logic error
  String _getBusinessErrorMessage(Map<String, dynamic> parsedJson) {
    // First try to get error message from the errors array
    if (parsedJson.containsKey('errors') &&
        parsedJson['errors'] is List &&
        (parsedJson['errors'] as List).isNotEmpty) {
      final errors = parsedJson['errors'] as List;
      if (errors.first is Map<String, dynamic>) {
        final firstError = errors.first as Map<String, dynamic>;
        if (firstError.containsKey('e_msg')) {
          return firstError['e_msg'].toString();
        }
      }
    }

    // Fall back to the general message
    if (parsedJson.containsKey('msg') && parsedJson['msg'] != null) {
      return parsedJson['msg'].toString();
    }

    // Default message
    return 'An error occurred in the operation';
  }

  /// Extract business error data
  Map<String, dynamic> _extractBusinessErrorData(
      Map<String, dynamic> parsedJson) {
    final Map<String, dynamic> errorData = {
      'success': parsedJson['success'],
      'has_errors': parsedJson['has_errors'],
    };

    if (parsedJson.containsKey('r_code')) {
      errorData['status_code'] = parsedJson['r_code'];
    }

    if (parsedJson.containsKey('errors') &&
        parsedJson['errors'] is List &&
        (parsedJson['errors'] as List).isNotEmpty) {
      errorData['errors'] = parsedJson['errors'];
    }

    if (parsedJson.containsKey('msg')) {
      errorData['message'] = parsedJson['msg'];
    }

    return errorData;
  }

  /// Handle different types of errors
  Either<FailureV2, T> _handleError<T>(dynamic error, StackTrace stackTrace) {
    _logError('Error in API call', error, stackTrace);

    if (error is TimeoutException) {
      return Left(APIFailureV2(
        message: 'Request timed out',
        statusCode: 408,
      ));
    }

    if (error is FormatException) {
      return Left(APIFailureV2(
        message: 'Error processing data',
        statusCode: 422,
        errorData: {'error': error.toString()},
      ));
    }

    if (error is APIExceptionV2) {
      return Left(APIFailureV2(
        message: error.message,
        statusCode: error.statusCode,
        errorData: error.data,
      ));
    }

    if (error.toString().contains('SocketException')) {
      return Left(
          NetworkFailure('Connection failed. Please check your internet.'));
    }

    return Left(APIFailureV2(
      message: 'An unexpected error occurred',
      statusCode: 500,
      errorData: {'error': error.toString()},
    ));
  }

  /// Extract error message from response
  String _getErrorMessage(http.Response response) {
    try {
      final body = utf8.decode(response.bodyBytes);
      final dynamic parsedJson = jsonDecode(body);

      if (parsedJson is Map<String, dynamic>) {
        final message = parsedJson['message'] ??
            parsedJson['error'] ??
            parsedJson['errorMessage'];

        if (message != null && message.toString().isNotEmpty) {
          return message.toString();
        }
      }
    } catch (e) {
      _logError('Error Parsing Error Response', e, StackTrace.current);
    }

    if (kDebugMode) {
      print("response.statusCode:- ${response.statusCode}");
    }

    // Create a temporary APIFailureV2 to use our extension
    final failure = APIFailureV2(
      message: '',
      statusCode: response.statusCode,
    );

    return failure._getAPIErrorMessage(
        failure); //_getStatusCodeMessage(response.statusCode);
  }

  /// Extract structured error data from response
  Map<String, dynamic> _extractErrorData(http.Response response) {
    try {
      final body = utf8.decode(response.bodyBytes);
      final dynamic parsedJson = jsonDecode(body);

      return {
        'statusCode': response.statusCode,
        'message': parsedJson is Map<String, dynamic>
            ? (parsedJson['message'] ?? parsedJson['error'] ?? 'Unknown error')
            : 'Unknown error',
        'rawResponse': response.body,
      };
    } catch (e) {
      return {
        'statusCode': response.statusCode,
        'message': 'Error parsing response',
        'rawResponse': response.body,
      };
    }
  }

  /// Populate request headers
  Map<String, String> populateHeaders({String? contentType}) {
    final headers = <String, String>{
      'Content-Type': contentType ?? 'application/json',
      'authtoken': '71523fdd8d26f585315b4233e39d9263',
    };

    final visitorToken = PrefUtils().getVisitorToken();
    if (visitorToken.isNotEmpty) {
      headers['visitortoken'] = visitorToken;
    }

    return headers;
  }

  /// Log request details
  void _logRequest(String method, Uri uri, {String? body}) {
    log(
      'API Request:\n'
      'Method: $method\n'
      'URL: $uri\n'
      'Headers: ${populateHeaders()}\n'
      '${body != null ? 'Body: $body' : ''}',
      name: 'ApiClientV2',
    );
  }

  /// Log response details
  void _logResponse(http.Response response) {
    log(
      'API Response:\n'
      'Status Code: ${response.statusCode}\n'
      'Headers: ${response.headers}\n'
      'Body: ${response.body}',
      name: 'ApiClientV2',
    );
  }

  /// Log error details
  void _logError(String type, dynamic error, StackTrace stackTrace) {
    log(
      'Error Type: $type\n'
      'Error: $error\n'
      'Stack Trace: $stackTrace',
      name: 'ApiClientV2',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _handleAuthorizationError() {
    // Clear preferences
  }

}


/// Extension for user-friendly error messages
extension FailureMessages on FailureV2 {
  String get userFriendlyMessage {
    switch (runtimeType) {
      case NetworkFailure:
        return 'Please check your internet connection';
      case APIFailureV2:
        final apiFailure = this as APIFailureV2;
        return _getAPIErrorMessage(apiFailure);
      case ServerFailure:
        return 'Server error occurred. Please try again later';
      default:
        return 'Something went wrong. Please try again';
    }
  }

  String _getAPIErrorMessage(APIFailureV2 failure) {
    switch (failure.statusCode) {
      case 400:
        return failure.message.isNotEmpty
            ? failure.message
            : 'Invalid request. Please check your input';
      case 401:
        return 'Your session has expired. Please login again';
      case 403:
        return 'You don\'t have permission to perform this action';
      case 404:
        return 'The requested resource was not found';
      case 408:
        return 'Request timed out. Please try again';
      case 422:
        return 'Unable to process your request. Please try again';
      case 429:
        return 'Too many requests. Please try again later';
      case 500:
        return 'A server error occurred. Please try again later';
      default:
        return failure.message.isNotEmpty
            ? failure.message
            : 'An error occurred while processing your request';
    }
  }

  bool get isAuthError =>
      this is APIFailureV2 && (this as APIFailureV2).statusCode == 401;

  bool get isNetworkError => this is NetworkFailure;

  bool get isServerError => this is ServerFailure;


}

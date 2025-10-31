import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

// For checking internet connectivity
abstract class NetworkInfoI {
  Future<bool> isConnected();

  Future<ConnectivityResult> get connectivityResult;

  Stream<ConnectivityResult> get onConnectivityChanged;
}

class NetworkInfo implements NetworkInfoI {
  Connectivity connectivity;

  static final NetworkInfo _networkInfo = NetworkInfo._internal(Connectivity());

  factory NetworkInfo() {
    return _networkInfo;
  }

  NetworkInfo._internal(this.connectivity) {
    connectivity = this.connectivity;
  }

  ///checks internet is connected or not
  ///returns [true] if internet is connected
  ///else it will return [false]
  @override
  Future<bool> isConnected() async {
    final result = await connectivity.checkConnectivity();
    if (result != ConnectivityResult.none) {
      return true;
    }
    return false;
  }

  @override
  Future<ConnectivityResult> get connectivityResult =>
      throw UnimplementedError();

  @override
  Stream<ConnectivityResult> get onConnectivityChanged =>
      throw UnimplementedError();
}

abstract class FailureV2 {
  final String message;

  FailureV2(this.message);

  @override
  String toString() {
    return '{message: $message}';
  }
}

// General failures
class ServerFailure extends FailureV2 {
  ServerFailure(String message) : super(message);
}

class CacheFailure extends FailureV2 {
  CacheFailure(super.message);
}

class NetworkFailure extends FailureV2 {
  NetworkFailure(super.message);
}

class ServerException implements Exception {
  final String message;

  ServerException([this.message = 'Server error occurred']);

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {}

class NetworkException implements Exception {}

///can be used for throwing [NoInternetException]
class NoInternetException implements Exception {
  final String message;

  NoInternetException([this.message = 'No internet connection']);

  @override
  String toString() => 'NoInternetException: $message';
}

/// Custom exception for API related errors
class APIExceptionV2 implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;

  APIExceptionV2({
    required this.message,
    required this.statusCode,
    this.data,
  });

  @override
  String toString() => 'APIException: $message (Status Code: $statusCode)';
}

/// API Failure class with enhanced error information
class APIFailureV2 extends FailureV2 {
  final int statusCode;
  final Map<String, dynamic>? errorData;

  APIFailureV2({
    required String message,
    required this.statusCode,
    this.errorData,
  }) : super(message);

  @override
  String toString() => 'APIFailure: $message (Status Code: $statusCode)';
}

/// API Response wrapper for consistent response handling
class APIResponse<T> {
  final T data;
  final int statusCode;
  final Map<String, dynamic>? headers;

  APIResponse({
    required this.data,
    required this.statusCode,
    this.headers,
  });
}

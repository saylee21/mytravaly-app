

class ServerException implements Exception {}

class CacheException implements Exception {}

class NetworkException implements Exception {}

///can be used for throwing [NoInternetException]
class NoInternetException implements Exception {
  late String _message;

  NoInternetException([String message = 'NoInternetException Occurred']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

// class ApiException implements Exception {
//   final String message;
//
//   ApiException(this.message);
// }

//
// class APIException extends Equatable implements Exception {
//   const APIException({required this.message, required this.statusCode});
//
//   final String message;
//   final int statusCode;
//
//   @override
//   List<Object?> get props => [message, statusCode];
// }

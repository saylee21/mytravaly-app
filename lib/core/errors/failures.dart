import 'package:equatable/equatable.dart';

// Assuming APIException is defined somewhere in your code
class APIException {
  final String message;
  final int statusCode;

  APIException({required this.message, required this.statusCode});
}

abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    required this.statusCode,
    this.errorData,
  });

  final String message;
  final int statusCode;
  final dynamic errorData; // Changed to dynamic

  String get errorMessage => '$statusCode Error: $message';

  @override
  List<Object> get props => [message, statusCode, if (errorData != null) errorData!];
}

class APIFailure extends Failure {
  const APIFailure({required super.message, required super.statusCode});

  factory APIFailure.fromException(APIException exception) {
    return APIFailure(
      message: exception.message,
      statusCode: exception.statusCode,
    );
  }
}

class ApiFailure extends Failure {
  final String message;
  final int statusCode;
  final dynamic errorData; // Change to dynamic to handle unexpected structures

  ApiFailure({
    required this.message,
    required this.statusCode,
    this.errorData,
  }) : super(message: message, statusCode: statusCode, errorData: errorData);

  @override
  String toString() => "$message (Status Code: $statusCode)";
}

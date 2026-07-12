class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class AuthException extends AppException {
  AuthException(super.message, {super.code});
}

class ServerException extends AppException {
  ServerException(super.message, {super.code});
}

class LocationException extends AppException {
  LocationException(super.message, {super.code});
}

class SensorException extends AppException {
  SensorException(super.message, {super.code});
}

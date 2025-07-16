class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, code: 'NETWORK_ERROR');
}

class FileUploadException extends AppException {
  FileUploadException(String message)
      : super(message, code: 'FILE_UPLOAD_ERROR');
}

class ValidationException extends AppException {
  ValidationException(String message)
      : super(message, code: 'VALIDATION_ERROR');
}

class FirestoreException extends AppException {
  FirestoreException(String message) : super(message, code: 'FIRESTORE_ERROR');
}

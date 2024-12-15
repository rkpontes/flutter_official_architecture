abstract class AppGenericException implements Exception {
  final String message;
  final String? code;

  AppGenericException([this.message = "Generic Exception", this.code]);
}

class AppException extends AppGenericException {
  AppException([super.message = "App Exception", super.code]);
}

class LocalStorageException extends AppGenericException {
  LocalStorageException(
      [super.message = "Local Storage Exception", super.code]);
}

class ApiClientException extends AppGenericException {
  ApiClientException([super.message = "Api Client Exception", super.code]);
}

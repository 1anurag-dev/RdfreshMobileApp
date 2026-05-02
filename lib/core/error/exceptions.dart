class AuthException implements Exception {
  final String message;
  final String code;

  AuthException({required this.message, required this.code});
}

class UserUnapprovedException implements Exception {
  final String message;

  UserUnapprovedException({this.message = 'Your account is not approved. Please contact support.'});
}

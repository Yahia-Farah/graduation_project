abstract class AuthRepo {
  Future<AuthResult> login({required String email, required String password});

  Future<String> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String nationalId,
    required String password,
    required String confirmPassword,
  });

  Future<void> verifyOtp({required String email, required String otpCode});
}

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String role;
  final String userName;

  AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.role,
    required this.userName,
  });
}

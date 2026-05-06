import 'package:dio/dio.dart';

class AuthRemoteDs {
  AuthRemoteDs(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      '/auth/login',
      data: {"email": email, "password": password},
    );

    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String nationalId,
    required String password,
    required String confirmPassword,
  }) async {
    final res = await _dio.post(
      '/auth/register',
      data: {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "nationalId": nationalId,
        "password": password,
        "confirmPassword": confirmPassword,
      },
    );

    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final res = await _dio.post(
      '/auth/verify-otp',
      data: {"email": email, "otpCode": otpCode},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Fetch user profile using the correct endpoint based on role.
  /// Called right after login since the session token isn't set on Dio yet.
  Future<Map<String, dynamic>> getUserProfile({
    required String userId,
    required String role,
    required String accessToken,
  }) async {
    // Pick the right profile endpoint based on role
    String path;
    switch (role.toUpperCase()) {
      case 'ADMIN':
        path = '/v1/admin/users/users/$userId';
        break;
      case 'LAWYER':
        path = '/v1/lawyer/profile';
        break;
      case 'JUDGE':
        path = '/v1/judges/profile';
        break;
      default:
        throw Exception('Unknown role: $role');
    }

    final res = await _dio.get(
      path,
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );
    return Map<String, dynamic>.from(res.data as Map);
  }
}

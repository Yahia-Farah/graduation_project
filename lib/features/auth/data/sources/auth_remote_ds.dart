import 'package:dio/dio.dart';

class AuthRemoteDs {
  AuthRemoteDs(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/auth/login', data: {"email": email, "password": password});

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
}
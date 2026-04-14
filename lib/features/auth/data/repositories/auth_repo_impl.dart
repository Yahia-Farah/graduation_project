import 'package:dio/dio.dart';
import '../sources/auth_remote_ds.dart';
import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  AuthRepoImpl(this._remote);
  final AuthRemoteDs _remote;

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    try {
      final root = await _remote.login(email: email, password: password);

      if (root['success'] != true) {
        throw Exception((root['message'] ?? 'Login failed').toString());
      }

      final data = root['data'];
      if (data is! Map) throw Exception('Invalid response');

      final access = (data['access_token'] ?? '').toString();
      final refresh = (data['refresh_token'] ?? '').toString();
      final id = (data['id'] ?? '').toString();
      final role = (data['role'] ?? '').toString();

      if (access.isEmpty || refresh.isEmpty) {
        throw Exception('Missing token');
      }

      return AuthResult(
        accessToken: access,
        refreshToken: refresh,
        userId: id,
        role: role,
      );
    } on DioException catch (e) {
      throw Exception(_mapDioError(e));
    }
  }

  @override
  Future<String> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String nationalId,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final root = await _remote.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        nationalId: nationalId,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (root['success'] != true) {
        throw Exception((root['message'] ?? 'Signup failed').toString());
      }

      final data = root['data'];
      if (data is! Map) throw Exception('Invalid response');

      final returnedEmail = (data['email'] ?? '').toString();

      if (returnedEmail.isEmpty) throw Exception('Email missing in response');

      return returnedEmail;
    } on DioException catch (e) {
      throw Exception(_mapDioError(e));
    }
  }

  @override
  Future<void> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final root = await _remote.verifyOtp(email: email, otpCode: otpCode);

      if (root['success'] != true) {
        throw Exception((root['message'] ?? 'OTP Verification failed').toString());
      }
    } on DioException catch (e) {
      throw Exception(_mapDioError(e));
    }
  }

  String _mapDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    final code = e.response?.statusCode;
    if (code == 401) return 'بيانات الدخول غير صحيحة';
    if (code == 409) return 'الحساب موجود بالفعل';
    if (code != null && code >= 500) return 'مشكلة في السيرفر، حاول لاحقًا';
    return 'تعذر الاتصال، تأكد من الإنترنت';
  }
}
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../auth/domain/user_role.dart';
import 'profile_model.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(dioProvider));
});

class SettingsRepository {
  final Dio _dio;

  SettingsRepository(this._dio);

  Future<ProfileData?> getProfile(UserRole role) async {
    try {
      String endpoint;
      if (role == UserRole.judge) {
        endpoint = '/v1/judges/profile';
      } else if (role == UserRole.lawyer) {
        endpoint = '/v1/lawyer/profile';
      } else {
        return null; // For admin or unknown
      }

      final response = await _dio.get(endpoint);
      if (response.data != null && response.data['success'] == true) {
        return ProfileData.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

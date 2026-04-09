import 'package:dio/dio.dart';
import '../../domain/user_entity.dart';

abstract class UsersRemoteDs {
  Future<List<UserEntity>> getUsers();
  Future<UserEntity> createUser(UserEntity user);
  Future<void> toggleUserStatus(String userId, bool activate);
  Future<void> deleteUser(String userId);
}

class UsersRemoteDsImpl implements UsersRemoteDs {
  final Dio dio;

  UsersRemoteDsImpl(this.dio);

  @override
  Future<List<UserEntity>> getUsers() async {
    // API Path: /api/v1/admin/users/users
    // Note: User mentioned /api/v1/admin/users/users/{userId} for response format, ignoring {userId} for fetch all.
    final res = await dio.get('/v1/admin/users/users');

    // Check if data is wrapped in the standard response format
    final responseData = res.data;
    if (responseData is Map && responseData.containsKey('data')) {
      final rawData = responseData['data'];
      if (rawData is List) {
        return rawData.map((e) => UserEntity.fromJson(e)).toList();
      } else if (rawData is Map) {
        // Just in case it returned a single object dictionary instead of list
        return [UserEntity.fromJson(rawData.cast<String, dynamic>())];
      }
    }

    // Fallback if data is returned directly as list
    if (responseData is List) {
      return responseData.map((e) => UserEntity.fromJson(e)).toList();
    }

    throw Exception('Invalid response format getting users');
  }

  @override
  Future<UserEntity> createUser(UserEntity user) async {
    final res = await dio.post(
      '/v1/admin/users/users',
      data: user.toJsonForCreate(),
    );

    // Some APIs might not return the created user or wrap it differently.
    // Try to parse if they returned it in `data`
    if (res.data is Map && res.data.containsKey('data')) {
      return UserEntity.fromJson(res.data['data']);
    }

    return user;
  }

  @override
  Future<void> toggleUserStatus(String userId, bool activate) async {
    // 4- PUT
    // /api/v1/admin/users/{userId}/activate
    // /api/v1/admin/users/{userId}/deactivate
    final action = activate ? 'activate' : 'deactivate';
    await dio.put('/api/v1/admin/users/$userId/$action');
  }

  @override
  Future<void> deleteUser(String userId) async {
    await dio.delete('/api/v1/admin/users/$userId');
  }
}

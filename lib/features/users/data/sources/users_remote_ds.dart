import 'package:dio/dio.dart';
import '../../domain/user_entity.dart';

abstract class UsersRemoteDs {
  Future<List<UserEntity>> getUsers();
  Future<List<UserEntity>> getLawyers();
  Future<List<UserEntity>> getJudges();
  Future<UserEntity> createUser(UserEntity user);
  Future<void> toggleUserStatus(String userId, bool activate);
  Future<void> deleteUser(String userId);
  Future<void> reviewLawyer(String lawyerId, bool isApproved);
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
    List<dynamic> rawList = [];

    if (responseData is List) {
      rawList = responseData;
    } else if (responseData is Map) {
      // Direct array checking
      for (final key in ['data', 'content', 'users', 'items']) {
        if (responseData[key] is List) {
          rawList = responseData[key] as List;
          break;
        }
      }

      // If still empty, check for Java Spring nested page structures: { "data": { "content": [...] } }
      if (rawList.isEmpty && responseData.containsKey('data')) {
        final nestedData = responseData['data'];
        if (nestedData is Map) {
          if (nestedData.containsKey('content') &&
              nestedData['content'] is List) {
            rawList = nestedData['content'] as List;
          } else if (nestedData.containsKey('items') &&
              nestedData['items'] is List) {
            rawList = nestedData['items'] as List;
          } else {
            // Just in case the backend actually returned a single object dictionary inside data
            // We ensure we don't throw cast errors if keys like "totalElements" indicate it's empty pagination
            if (!nestedData.containsKey('totalElements') &&
                !nestedData.containsKey('totalPages')) {
              return [UserEntity.fromJson(nestedData.cast<String, dynamic>())];
            }
          }
        }
      }
    }

    if (rawList.isNotEmpty) {
      return rawList.map((e) {
        try {
          return UserEntity.fromJson(e as Map<String, dynamic>);
        } catch (err) {
          // ignore: avoid_print
          print('Error parsing UserEntity: $err');
          return UserEntity(
            id: e['id']?.toString() ?? '',
            firstName: e['firstName']?.toString() ?? 'Error',
            lastName: e['lastName']?.toString() ?? '',
            email: e['email']?.toString() ?? '',
            age: 0,
            role: 'UNKNOWN',
            isActive: false,
            assignedCasesCount: 0,
            court: '',
            isApproved: false,
          );
        }
      }).toList();
    }

    return [];
  }

  @override
  Future<List<UserEntity>> getLawyers() async {
    // Fetch specifically lawyers with a large size to get all
    final res = await dio.get('/v1/admin/users/lawyers?size=1000');
    final responseData = res.data;
    List<dynamic> rawList = [];

    if (responseData is List) {
      rawList = responseData;
    } else if (responseData is Map) {
      for (final key in ['data', 'content', 'users', 'items']) {
        if (responseData[key] is List) {
          rawList = responseData[key] as List;
          break;
        }
      }
      if (rawList.isEmpty && responseData.containsKey('data')) {
        final nestedData = responseData['data'];
        if (nestedData is Map) {
          if (nestedData.containsKey('content') &&
              nestedData['content'] is List) {
            rawList = nestedData['content'] as List;
          } else if (nestedData.containsKey('items') &&
              nestedData['items'] is List) {
            rawList = nestedData['items'] as List;
          } else if (!nestedData.containsKey('totalElements') &&
              !nestedData.containsKey('totalPages')) {
            return [UserEntity.fromJson(nestedData.cast<String, dynamic>())];
          }
        }
      }
    }

    if (rawList.isNotEmpty) {
      return rawList.map((e) {
        try {
          return UserEntity.fromJson(e as Map<String, dynamic>);
        } catch (err) {
          // ignore: avoid_print
          print('Error parsing UserEntity in getLawyers: $err');
          return UserEntity(
            id: e['id']?.toString() ?? '',
            firstName: e['firstName']?.toString() ?? 'Error',
            lastName: e['lastName']?.toString() ?? '',
            email: e['email']?.toString() ?? '',
            age: 0,
            role: 'LAWYER',
            isActive: false,
            assignedCasesCount: 0,
            court: '',
            isApproved: false,
          );
        }
      }).toList();
    }

    return [];
  }

  @override
  Future<List<UserEntity>> getJudges() async {
    final res = await dio.get('/v1/admin/users/judges?size=1000');
    final responseData = res.data;
    List<dynamic> rawList = [];

    if (responseData is List) {
      rawList = responseData;
    } else if (responseData is Map) {
      for (final key in ['data', 'content', 'users', 'items']) {
        if (responseData[key] is List) {
          rawList = responseData[key] as List;
          break;
        }
      }
      if (rawList.isEmpty && responseData.containsKey('data')) {
        final nestedData = responseData['data'];
        if (nestedData is Map) {
          if (nestedData.containsKey('content') &&
              nestedData['content'] is List) {
            rawList = nestedData['content'] as List;
          } else if (nestedData.containsKey('items') &&
              nestedData['items'] is List) {
            rawList = nestedData['items'] as List;
          } else if (!nestedData.containsKey('totalElements') &&
              !nestedData.containsKey('totalPages')) {
            return [UserEntity.fromJson(nestedData.cast<String, dynamic>())];
          }
        }
      }
    }

    if (rawList.isNotEmpty) {
      return rawList.map((e) {
        try {
          return UserEntity.fromJson(e as Map<String, dynamic>);
        } catch (err) {
          // ignore: avoid_print
          print('Error parsing UserEntity in getJudges: $err');
          return UserEntity(
            id: e['id']?.toString() ?? '',
            firstName: e['firstName']?.toString() ?? 'Error',
            lastName: e['lastName']?.toString() ?? '',
            email: e['email']?.toString() ?? '',
            age: 0,
            role: 'JUDGE',
            isActive: false,
            assignedCasesCount: 0,
            court: '',
            isApproved: false,
          );
        }
      }).toList();
    }

    return [];
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
    await dio.put('/v1/admin/users/$userId/$action');
  }

  @override
  Future<void> deleteUser(String userId) async {
    await dio.delete('/v1/admin/users/$userId');
  }

  @override
  Future<void> reviewLawyer(String lawyerId, bool isApproved) async {
    // Assuming 'reject' for 'رفض' because using 'approve' for both is likely a typo in the prompt.
    final action = isApproved ? 'approve' : 'reject';
    await dio.put('/v1/admin/users/lawyers/$lawyerId/$action');
  }
}

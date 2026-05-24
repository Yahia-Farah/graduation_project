import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/user_entity.dart';
import '../../users_providers.dart';

class JudgesViewModel extends AsyncNotifier<List<UserEntity>> {
  @override
  Future<List<UserEntity>> build() async {
    return _fetchJudges();
  }

  Future<List<UserEntity>> _fetchJudges() async {
    final repo = ref.read(usersRepoProvider);
    return await repo.getJudges();
  }

  Future<void> deleteUser(String userId) async {
    final previousUsers = state.valueOrNull ?? [];
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(usersRepoProvider);
      await repo.deleteUser(userId);
      ref.invalidateSelf();
    } catch (e) {
      state = AsyncValue.data(previousUsers);
    }
  }

  Future<void> toggleUserStatus(UserEntity user) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(usersRepoProvider);
      await repo.toggleUserStatus(user.id, !user.isActive);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final judgesViewModelProvider =
    AsyncNotifierProvider<JudgesViewModel, List<UserEntity>>(JudgesViewModel.new);

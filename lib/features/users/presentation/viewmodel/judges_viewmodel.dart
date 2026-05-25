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

  Future<void> addUser(UserEntity newUser) async {
    state = const AsyncValue.loading();
    final repo = ref.read(usersRepoProvider);
    await repo.createUser(newUser);
    state = AsyncValue.data(await _fetchJudges());
  }

  Future<void> deleteUser(String userId) async {
    final previousList = state.valueOrNull ?? [];
    state = const AsyncValue.loading();
    final repo = ref.read(usersRepoProvider);
    await repo.deleteUser(userId);
    // Optimistically update the list because the backend GET might return stale data immediately after delete
    final updatedList = previousList.where((u) => u.id != userId).toList();
    state = AsyncValue.data(updatedList);
  }

  Future<void> toggleUserStatus(UserEntity user) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(usersRepoProvider);
      await repo.toggleUserStatus(user.id, !user.isActive);
      state = AsyncValue.data(await _fetchJudges());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final judgesViewModelProvider =
    AsyncNotifierProvider<JudgesViewModel, List<UserEntity>>(JudgesViewModel.new);

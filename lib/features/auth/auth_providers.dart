import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_provider.dart';
import 'data/repositories/auth_repo.dart';
import 'data/repositories/auth_repo_impl.dart';
import 'data/sources/auth_remote_ds.dart';

final authRepoProvider = Provider<AuthRepo>((ref) {
  final dio = ref.watch(dioProvider);
  final remote = AuthRemoteDs(dio);
  return AuthRepoImpl(remote);
});
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_provider.dart';
import 'data/sources/notifications_remote_ds.dart';
import 'data/repositories/notifications_repo.dart';
import 'data/repositories/notifications_repo_impl.dart';

final notificationsRemoteDsProvider = Provider<NotificationsRemoteDs>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationsRemoteDsImpl(dio);
});

final notificationsRepoProvider = Provider<NotificationsRepo>((ref) {
  final remoteDs = ref.watch(notificationsRemoteDsProvider);
  return NotificationsRepoImpl(remoteDs);
});

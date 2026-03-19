import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_session.dart';
import '../../domain/user_role.dart';

final userRoleProvider = Provider<UserRole>((ref) {
  final session = ref.watch(authSessionProvider);
  return parseRole(session.role);
});
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/viewmodel/auth_session.dart';
import '../features/auth/presentation/view/auth_shell.dart';
import 'shell/home_shell.dart';

class RootDecider extends ConsumerWidget {
  const RootDecider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);

    debugPrint('Auth Initialized. isLoggedIn: ${session.isAuthed}, role: ${session.role}');

    if (session.isAuthed) {
      return const HomeShell();
    } else {
      return const AuthShell();
    }
  }
}

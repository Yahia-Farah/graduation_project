import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/access_requests/presentation/view/access_requests_page.dart';
import '../../features/auth/domain/user_role.dart';
import '../../features/auth/presentation/viewmodel/auth_session.dart';
import '../../features/cases/presentation/view/cases_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/dashboard/presentation/judge_dashboard_page.dart';
import '../../features/users/presentation/view/users_management_page.dart';
import '../home_nav_provider.dart';
import '../theme/design_tokens.dart';
import 'menu_items.dart';
import 'side_menu.dart';
import 'top_bar.dart';

import '../../features/auth/presentation/viewmodel/user_role_provider.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    // ignore: avoid_print
    print('CURRENT ROLE: $role');
    final session = ref.watch(authSessionProvider);
    // ignore: avoid_print
    print('RAW ROLE FROM SESSION: ${session.role}');
    final visibleItems = appMenuItems
        .where((item) => item.canAccess(role))
        .toList();

    final selectedIndex = ref.watch(homeNavIndexProvider);

    final safeIndex = selectedIndex.clamp(
      0,
      visibleItems.isEmpty ? 0 : visibleItems.length - 1,
    );

    final currentItem = visibleItems[safeIndex];

    return Directionality(
      textDirection: TextDirection.ltr,
      child: ScaffoldPage(
        padding: EdgeInsets.zero,
        content: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  TopBar(pageTitle: currentItem.title),
                  Expanded(
                    child: Container(
                      color: DesignTokens.beige,
                      padding: const EdgeInsets.all(18),
                      child: buildPage(currentItem.keyName, role),
                    ),
                  ),
                ],
              ),
            ),
            SideMenu(
              items: visibleItems,
              selectedIndex: safeIndex,
              onChanged: (i) {
                ref.read(homeNavIndexProvider.notifier).state = i;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPage(String key, UserRole role) {
    switch (key) {
      case 'dashboard':
        return role == UserRole.judge
            ? const JudgeDashboardPage()
            : const DashboardPage();

      case 'cases':
        return const CasesPage();

      case 'access_requests':
        return const AccessRequestsPage();

      // case 'hearings':
      //   return const HearingsPage();

      case 'users':
        return const UsersManagementPage();

      case 'profile':
        return const Center(
          child: Text('الحساب الشخصي', style: TextStyle(fontSize: 24)),
        );

      case 'settings':
        return const Center(
          child: Text('الإعدادات', style: TextStyle(fontSize: 24)),
        );

      default:
        return const Center(child: Text('Unknown'));
    }
  }
}

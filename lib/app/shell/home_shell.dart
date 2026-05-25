import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/access_requests/presentation/view/access_requests_page.dart';
import '../../features/auth/domain/user_role.dart';
import '../../features/auth/presentation/viewmodel/auth_session.dart';
import '../../features/cases/presentation/view/cases_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/dashboard/presentation/judge_dashboard_page.dart';
import '../../features/users/presentation/view/users_management_page.dart';
import '../../features/users/presentation/view/lawyers_management_page.dart';
import '../../features/users/presentation/view/judges_management_page.dart';
import '../home_nav_provider.dart';
import '../theme/design_tokens.dart';
import 'menu_items.dart';
import 'side_menu.dart';
import 'top_bar.dart';

import '../../features/auth/presentation/viewmodel/user_role_provider.dart';
import '../../features/users/presentation/viewmodel/judges_viewmodel.dart';
import '../../features/users/presentation/viewmodel/lawyers_viewmodel.dart';
import '../../features/cases/presentation/viewmodel/cases_vm.dart';

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

    // Build a flat list of navigable items (same logic as SideMenu).
    final flatItems = _flattenItems(visibleItems);

    final selectedIndex = ref.watch(homeNavIndexProvider);

    final safeIndex = selectedIndex.clamp(
      0,
      flatItems.isEmpty ? 0 : flatItems.length - 1,
    );

    final currentItem = flatItems[safeIndex];

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
                // Refresh data when navigating to a tab
                final targetItem = flatItems[i];
                switch (targetItem.keyName) {
                  case 'users_judges':
                    ref.invalidate(judgesViewModelProvider);
                    break;
                  case 'users_lawyers':
                    ref.invalidate(lawyersViewModelProvider);
                    break;
                  case 'cases':
                    ref.invalidate(casesVmProvider);
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Flattens the menu tree into a list of navigable items.
  /// Parent items with children are replaced by their children.
  List<AppMenuItem> _flattenItems(List<AppMenuItem> items) {
    final flat = <AppMenuItem>[];
    for (final item in items) {
      if (item.hasChildren) {
        flat.addAll(item.children);
      } else {
        flat.add(item);
      }
    }
    return flat;
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

      case 'users_judges':
        return const JudgesManagementPage();

      case 'users_lawyers':
        return const LawyersManagementPage();

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

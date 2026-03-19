import 'package:fluent_ui/fluent_ui.dart';
import '../../features/auth/domain/user_role.dart';

class AppMenuItem {
  final String keyName;
  final String title;
  final IconData icon;
  final List<UserRole> allowedRoles;

  const AppMenuItem({
    required this.keyName,
    required this.title,
    required this.icon,
    required this.allowedRoles,
  });

  bool canAccess(UserRole role) {
    return allowedRoles.contains(role);
  }
}

const appMenuItems = [

  AppMenuItem(
    keyName: 'dashboard',
    title: 'لوحة التحكم',
    icon: FluentIcons.home,
    allowedRoles: [UserRole.admin, UserRole.lawyer, UserRole.judge],
  ),

  AppMenuItem(
    keyName: 'cases',
    title: 'القضايا',
    icon: FluentIcons.branch_search,
    allowedRoles: [UserRole.admin, UserRole.lawyer],
  ),

  AppMenuItem(
    keyName: 'hearings',
    title: 'الجلسات',
    icon: FluentIcons.calendar,
    allowedRoles: [UserRole.judge],
  ),

  AppMenuItem(
    keyName: 'users',
    title: 'إدارة المستخدمين',
    icon: FluentIcons.people,
    allowedRoles: [UserRole.admin],
  ),
];
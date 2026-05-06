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
    title: 'لوحة التحكم الرئيسية',
    icon: FluentIcons.home,
    allowedRoles: [UserRole.admin, UserRole.lawyer, UserRole.judge],
  ),

  AppMenuItem(
    keyName: 'cases',
    title: 'إدارة القضايا',
    icon: FluentIcons.branch_search,
    allowedRoles: [UserRole.admin, UserRole.lawyer],
  ),

  AppMenuItem(
    keyName: 'access_requests',
    title: 'إدارة طلبات الوصول',
    icon: FluentIcons.access_logo,
    allowedRoles: [UserRole.admin],
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

  AppMenuItem(
    keyName: 'profile',
    title: 'الحساب الشخصي',
    icon: FluentIcons.contact,
    allowedRoles: [UserRole.admin, UserRole.lawyer, UserRole.judge],
  ),

  AppMenuItem(
    keyName: 'settings',
    title: 'الإعدادات',
    icon: FluentIcons.settings,
    allowedRoles: [UserRole.admin, UserRole.lawyer, UserRole.judge],
  ),
];

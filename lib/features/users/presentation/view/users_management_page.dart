import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/design_tokens.dart';
import '../../domain/user_entity.dart';
import '../viewmodel/users_viewmodel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'add_user_dialog.dart';

class UsersManagementPage extends ConsumerWidget {
  const UsersManagementPage({super.key, this.roleFilter});

  /// If set, only users whose role matches this value are shown.
  /// Expected values: 'JUDGE', 'LAWYER', or null (show all).
  final String? roleFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(usersViewModelProvider);

    return ScaffoldPage(
      header: PageHeader(
        title: Text(
          textAlign: TextAlign.end,
          _pageTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 8.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Toolbar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _subtitleText,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (roleFilter != 'LAWYER')
                    FilledButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FluentIcons.add, size: 14.sp),
                          SizedBox(width: 8.w),
                          const Text('إضافة مستخدم جديد'),
                        ],
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const AddUserDialog(),
                        );
                      },
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              // Data View
              Expanded(
                child: state.when(
                  data: (users) {
                    final filtered = _applyFilter(users);
                    if (filtered.isEmpty) {
                      return const Center(child: Text('لا يوجد مستخدمين'));
                    }
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _buildUserCard(context, ref, filtered[index]);
                      },
                    );
                  },
                  loading: () => const Center(child: ProgressRing()),
                  error: (e, st) => Center(
                    child: ContentDialog(
                      title: const Text('تنبيه'),
                      content: Text('حدث خطأ: $e'),
                      actions: [
                        FilledButton(
                          onPressed: () {
                            ref.invalidate(usersViewModelProvider);
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the page header title based on the active role filter.
  String get _pageTitle {
    switch (roleFilter) {
      case 'JUDGE':
        return 'إدارة المستخدمين - قضاة';
      case 'LAWYER':
        return 'إدارة المستخدمين - محامين';
      default:
        return 'إدارة المستخدمين';
    }
  }

  /// Returns a contextual subtitle based on the active role filter.
  String get _subtitleText {
    switch (roleFilter) {
      case 'JUDGE':
        return 'قائمة القضاة في النظام';
      case 'LAWYER':
        return 'قائمة المحامين في النظام';
      default:
        return 'قائمة المستخدمين في النظام';
    }
  }

  /// Filters users by [roleFilter] if provided.
  List<UserEntity> _applyFilter(List<UserEntity> users) {
    if (roleFilter == null) return users;
    return users.where((u) => u.role.toUpperCase() == roleFilter).toList();
  }

  Widget _buildUserCard(BuildContext context, WidgetRef ref, UserEntity user) {
    final bool isAdmin = user.role.toUpperCase() == 'ADMIN';
    final Color roleColor = isAdmin ? DesignTokens.green : DesignTokens.brown;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.0.h),
      child: Card(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: DesignTokens.beige,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                FluentIcons.contact,
                size: 24.sp,
                color: DesignTokens.brown,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(FluentIcons.mail, size: 12.sp),
                      SizedBox(width: 4.w),
                      Text(user.email, style: TextStyle(fontSize: 12.sp)),
                      SizedBox(width: 16.w),
                      Icon(FluentIcons.entitlement_policy, size: 12.sp),
                      SizedBox(width: 4.w),
                      Text(
                        user.court.isEmpty ? 'غير محدد' : user.court,
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: roleColor),
              ),
              child: Text(
                user.role,
                style: TextStyle(
                  color: roleColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            ToggleSwitch(
              checked: user.isActive,
              content: const Text('نشط'),
              onChanged: (v) {
                ref
                    .read(usersViewModelProvider.notifier)
                    .toggleUserStatus(user);
              },
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(FluentIcons.delete, color: Colors.red),
              onPressed: () {
                _confirmDelete(context, ref, user);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, UserEntity user) {
    showDialog(
      context: context,
      builder: (ctx) {
        return ContentDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف المستخدم ${user.fullName}؟'),
          actions: [
            Button(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(ctx),
            ),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(Colors.red),
              ),
              onPressed: () {
                ref.read(usersViewModelProvider.notifier).deleteUser(user.id);
                Navigator.pop(ctx);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }
}

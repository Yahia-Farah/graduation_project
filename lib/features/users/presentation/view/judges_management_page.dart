import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../domain/user_entity.dart';
import '../viewmodel/judges_viewmodel.dart';
import 'add_user_dialog.dart';

class JudgesManagementPage extends ConsumerStatefulWidget {
  const JudgesManagementPage({super.key});

  @override
  ConsumerState<JudgesManagementPage> createState() =>
      _JudgesManagementPageState();
}

class _JudgesManagementPageState extends ConsumerState<JudgesManagementPage> {
  int _selectedTabIndex = 0; // 0: المستخدمين الحاليين, 1: اخرى
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Tabs ───────────────────────────────────────────────
          Row(
            children: [
              _buildTab('المستخدمين الحاليين', 0),
              const SizedBox(width: 32),
              _buildTab('اخرى', 1),
            ],
          ),
          Container(
            height: 1,
            color: DesignTokens.brown.withValues(alpha: 0.2),
            margin: const EdgeInsets.only(bottom: 16),
          ),

          // ─── Search Bar and Add Button ────────────────────────────────────────
          Row(
            children: [
              FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color(0xFF8F5E41),
                  ),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
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
              const Spacer(),
              SizedBox(
                width: 300,
                child: TextBox(
                  placeholder: _searchPlaceholder,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  suffix: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(FluentIcons.search, size: 14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: DesignTokens.brown.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(
                      FluentIcons.calendar,
                      size: 14,
                      color: DesignTokens.gray,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Content ───────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DesignTokens.brown.withValues(alpha: 0.2),
                ),
              ),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab Button ──────────────────────────────────────────────────

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? DesignTokens.brown : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? DesignTokens.brown : DesignTokens.gray,
          ),
        ),
      ),
    );
  }

  String get _searchPlaceholder {
    switch (_selectedTabIndex) {
      case 0:
        return 'ابحث في القضايا';
      case 1:
        return 'ابحث في قائمة القضاة غير النشطين';
      default:
        return 'ابحث';
    }
  }

  Widget _buildContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildCurrentUsersTab();
      case 1:
        return _buildOtherTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCurrentUsersTab() {
    final state = ref.watch(judgesViewModelProvider);

    return state.when(
      data: (users) {
        final judges = users.where((u) {
          if (u.isActive == false) return false;
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return u.fullName.toLowerCase().contains(q) ||
              (u.id.toLowerCase().contains(q) ?? false);
        }).toList();
        if (judges.isEmpty) {
          return const Center(child: Text('لا يوجد قضاة حاليين'));
        }
        return ListView.builder(
          itemCount: judges.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final user = judges[index];
            return GestureDetector(
              onTap: () => _showUserDetailsDialog(user),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: DesignTokens.brown.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
                child: Row(
                  children: [
                    Icon(
                      FluentIcons.contact,
                      size: 18,
                      color: DesignTokens.brown,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'القاضي/${user.fullName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: user.isActive
                            ? DesignTokens.green.withValues(alpha: 0.1)
                            : DesignTokens.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: user.isActive
                              ? DesignTokens.green
                              : DesignTokens.red,
                        ),
                      ),
                      child: Text(
                        user.isActive ? 'نشط' : 'غير نشط',
                        style: TextStyle(
                          color: user.isActive
                              ? DesignTokens.green
                              : DesignTokens.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: ProgressRing()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('حدث خطأ: $e'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => ref.invalidate(judgesViewModelProvider),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetailsDialog(UserEntity user) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: ContentDialog(
            constraints: const BoxConstraints(maxWidth: 600),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'بيانات القاضي',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: DesignTokens.brown,
                  ),
                ),
                IconButton(
                  icon: const Icon(FluentIcons.chrome_close, size: 14),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 1,
                  color: DesignTokens.brown.withValues(alpha: 0.3),
                  margin: const EdgeInsets.only(bottom: 20),
                ),
                Row(
                  children: [
                    Expanded(child: _fieldBox('الأسم', user.fullName)),
                    const SizedBox(width: 12),
                    Expanded(child: _fieldBox('البريد الالكتروني', user.email)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _fieldBox('الرقم التعريفي', user.id ?? 'غير محدد'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _fieldBox(
                        'الحالة',
                        user.isActive ? 'حساب نشط' : 'حساب غير نشط',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _fieldBox('السن', '${user.age}')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _fieldBox(
                        'عدد القضايا المعينة',
                        '${user.assignedCasesCount}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            const Color(0xFF6C6C6C),
                          ),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 14),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(judgesViewModelProvider.notifier)
                              .toggleUserStatus(user);
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          user.isActive ? 'الغاء تفعيل الحساب' : 'تفعيل الحساب',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            const Color(0xFF9E4226),
                          ),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 14),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _confirmDelete(user);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'حذف الحساب',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              FluentIcons.delete,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: const [],
          ),
        );
      },
    );
  }

  Widget _fieldBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2C485)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: '),
            TextSpan(text: value),
          ],
        ),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8F5E41),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _confirmDelete(UserEntity user) {
    showDialog(
      context: context,
      builder: (ctx) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return ContentDialog(
              title: const Text('تأكيد الحذف'),
              content: Text('هل أنت متأكد من حذف القاضي ${user.fullName}؟'),
              actions: [
                Button(
                  onPressed: isDeleting ? null : () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(Colors.red),
                  ),
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() => isDeleting = true);
                          try {
                            await ref
                                .read(judgesViewModelProvider.notifier)
                                .deleteUser(user.id);
                            if (ctx.mounted) Navigator.pop(ctx);
                          } catch (e) {
                            if (ctx.mounted) {
                              setDialogState(() => isDeleting = false);
                              displayInfoBar(
                                ctx,
                                builder: (context, close) => InfoBar(
                                  title: const Text('خطأ'),
                                  content: Text(
                                    e.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                  ),
                                  severity: InfoBarSeverity.error,
                                  action: IconButton(
                                    icon: const Icon(FluentIcons.clear),
                                    onPressed: close,
                                  ),
                                ),
                                duration: const Duration(seconds: 5),
                              );
                            }
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: ProgressRing(strokeWidth: 2),
                        )
                      : const Text('حذف'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildOtherTab() {
    final state = ref.watch(judgesViewModelProvider);

    return state.when(
      data: (users) {
        final judges = users.where((u) {
          if (u.isActive == true) return false;
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return u.fullName.toLowerCase().contains(q) ||
              (u.id.toLowerCase().contains(q) ?? false);
        }).toList();
        if (judges.isEmpty) {
          return const Center(child: Text('لا يوجد قضاة غير نشطين'));
        }
        return ListView.builder(
          itemCount: judges.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final user = judges[index];
            return GestureDetector(
              onTap: () => _showUserDetailsDialog(user),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: DesignTokens.brown.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
                child: Row(
                  children: [
                    Icon(
                      FluentIcons.contact,
                      size: 18,
                      color: DesignTokens.brown,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'القاضي/${user.fullName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: DesignTokens.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DesignTokens.red),
                      ),
                      child: const Text(
                        'غير نشط',
                        style: TextStyle(
                          color: DesignTokens.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: ProgressRing()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('حدث خطأ: $e'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => ref.invalidate(judgesViewModelProvider),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

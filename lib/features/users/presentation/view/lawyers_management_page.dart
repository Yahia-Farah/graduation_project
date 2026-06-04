import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../domain/user_entity.dart';
import '../viewmodel/lawyers_viewmodel.dart';

class LawyersManagementPage extends ConsumerStatefulWidget {
  const LawyersManagementPage({super.key});

  @override
  ConsumerState<LawyersManagementPage> createState() =>
      _LawyersManagementPageState();
}

class _LawyersManagementPageState
    extends ConsumerState<LawyersManagementPage> {
  int _selectedTabIndex = 0; // 0: الطلبات, 1: المستخدمين الحاليين, 2: اخرى
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
              _buildTab('الطلبات', 0),
              const SizedBox(width: 32),
              _buildTab('المستخدمين الحاليين', 1),
              const SizedBox(width: 32),
              _buildTab('اخرى', 2),
            ],
          ),
          Container(
            height: 1,
            color: DesignTokens.brown.withValues(alpha: 0.2),
            margin: const EdgeInsets.only(bottom: 16),
          ),

          // ─── Search Bar ────────────────────────────────────────
          Row(
            children: [
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
              const Spacer(),
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

  // ─── Search Placeholder ──────────────────────────────────────────

  String get _searchPlaceholder {
    switch (_selectedTabIndex) {
      case 0:
        return 'ابحث في قائمة الطلبات';
      case 1:
        return 'ابحث في قائمة المستخدمين';
      default:
        return 'ابحث';
    }
  }

  // ─── Content Switcher ────────────────────────────────────────────

  Widget _buildContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildRequestsTab();
      case 1:
        return _buildCurrentUsersTab();
      case 2:
        return _buildOtherTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Tab 0: الطلبات (Pending Requests)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildRequestsTab() {
    final state = ref.watch(lawyersViewModelProvider);

    return state.when(
      data: (users) {
        final requests = users.where((u) {
          if (u.isApproved == true) return false;
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return u.fullName.toLowerCase().contains(q) || u.id.toLowerCase().contains(q);
        }).toList();
        if (requests.isEmpty) {
          return const Center(child: Text('لا توجد طلبات معلقة'));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Table Header
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE2C485),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'رقم الطلب',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'اسم المحامي',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'الرقم القومي',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'الاجراء',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Table Rows
            Expanded(
              child: ListView.builder(
                itemCount: requests.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: DesignTokens.brown.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            // Extract first 5 chars of ID or something similar since we don't have requestNumber
                            '#${req.id.length >= 5 ? req.id.substring(0, 5).toUpperCase() : req.id}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            req.fullName,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            req.nationalId ?? 'غير محدد',
                            textAlign: TextAlign.center,
                          ),
                        ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Accept
                          FilledButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                const Color(0xFF4A6B3A),
                              ),
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                              ),
                            ),
                            onPressed: () {
                              ref
                                  .read(lawyersViewModelProvider.notifier)
                                  .reviewLawyer(req.id, true);
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(FluentIcons.check_mark, size: 12),
                                SizedBox(width: 6),
                                Text('قبول'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Reject
                          FilledButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                const Color(0xFF9E4226),
                              ),
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                              ),
                            ),
                            onPressed: () {
                              ref
                                  .read(lawyersViewModelProvider.notifier)
                                  .reviewLawyer(req.id, false);
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(FluentIcons.cancel, size: 12),
                                SizedBox(width: 6),
                                Text('رفض'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
              onPressed: () => ref.invalidate(lawyersViewModelProvider),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Tab 1: المستخدمين الحاليين (Current Lawyer Users)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildCurrentUsersTab() {
    final state = ref.watch(lawyersViewModelProvider);

    return state.when(
      data: (users) {
        final lawyers = users.where((u) {
          if (!(u.isApproved == true && u.isActive == true)) return false;
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return u.fullName.toLowerCase().contains(q) || u.id.toLowerCase().contains(q);
        }).toList();
        if (lawyers.isEmpty) {
          return const Center(child: Text('لا يوجد محامين حاليين'));
        }
        return ListView.builder(
          itemCount: lawyers.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final user = lawyers[index];
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
                    // Person icon
                    Icon(
                      FluentIcons.contact,
                      size: 18,
                      color: DesignTokens.brown,
                    ),
                    const SizedBox(width: 12),
                    // Lawyer name
                    Text(
                      'المحامي/${user.fullName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    // Status badge
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
              onPressed: () => ref.invalidate(lawyersViewModelProvider),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── User Details Popup ──────────────────────────────────────────

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
                  'بيانات المحامي',
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
                // Divider under title
                Container(
                  height: 1,
                  color: DesignTokens.brown.withValues(alpha: 0.3),
                  margin: const EdgeInsets.only(bottom: 20),
                ),

                // Row 1: الأسم | البريد الالكتروني
                Row(
                  children: [
                    Expanded(
                      child: _fieldBox(
                        'الأسم',
                        user.fullName,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _fieldBox(
                        'البريد الالكتروني',
                        user.email,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 2: الرقم القومي | الحالة
                Row(
                  children: [
                    Expanded(
                      child: _fieldBox(
                        'الرقم التعريفي',
                        user.id,
                      ),
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

                // Row 3: السن | عدد القضايا المعينة
                Row(
                  children: [
                    Expanded(
                      child: _fieldBox(
                        'السن',
                        '${user.age}',
                      ),
                    ),
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

                // Action buttons
                Row(
                  mainAxisAlignment: .end,
                  children: [
                    // الغاء تفعيل الحساب / تفعيل الحساب
                    Expanded(
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            const Color(0xFF6C6C6C), // Gray color matching screenshot
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
                              .read(lawyersViewModelProvider.notifier)
                              .toggleUserStatus(user);
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          user.isActive
                              ? 'الغاء تفعيل الحساب'
                              : 'تفعيل الحساب',
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // حذف الحساب
                    Expanded(
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            const Color(0xFF9E4226), // Brown/red color matching screenshot
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
                              style: TextStyle(fontSize: 14, color: Colors.white),
                            ),
                            SizedBox(width: 8),
                            Icon(FluentIcons.delete, size: 16, color: Colors.white),
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

  /// Builds a bordered field box matching the screenshot design.
  Widget _fieldBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2C485), // Light brown/gold border
        ),
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
          color: Color(0xFF8F5E41), // Brown text color
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _confirmDelete(UserEntity user) {
    showDialog(
      context: context,
      builder: (ctx) {
        return ContentDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف المحامي ${user.fullName}؟'),
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
                ref
                    .read(lawyersViewModelProvider.notifier)
                    .deleteUser(user.id);
                Navigator.pop(ctx);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Tab 2: اخرى (Other — activity log of resolved requests)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildOtherTab() {
    final state = ref.watch(lawyersViewModelProvider);

    return state.when(
      data: (users) {
        final lawyers = users.where((u) {
          if (!(u.isApproved == true && u.isActive == false)) return false;
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return u.fullName.toLowerCase().contains(q) || u.id.toLowerCase().contains(q);
        }).toList();
        if (lawyers.isEmpty) {
          return const Center(child: Text('لا يوجد محامين غير نشطين'));
        }
        return ListView.builder(
          itemCount: lawyers.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final user = lawyers[index];
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
                    // Person icon
                    Icon(
                      FluentIcons.contact,
                      size: 18,
                      color: DesignTokens.brown,
                    ),
                    const SizedBox(width: 12),
                    // Lawyer name
                    Text(
                      'المحامي/${user.fullName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    // Status badge
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
              onPressed: () => ref.invalidate(lawyersViewModelProvider),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

}



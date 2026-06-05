import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/design_tokens.dart';
import '../../cases/domain/case_model.dart';
import '../../cases/presentation/viewmodel/cases_vm.dart';
import '../../cases/presentation/view/widgets/add_case_dialog.dart';
import '../../cases/presentation/view/widgets/case_details_dialog.dart';
import 'viewmodel/dashboard_vm.dart';
import '../../../app/shell/menu_items.dart';
import '../../../app/home_nav_provider.dart';
import '../../auth/presentation/viewmodel/user_role_provider.dart';
import '../../users/presentation/viewmodel/judges_viewmodel.dart';
import '../../users/presentation/viewmodel/lawyers_viewmodel.dart';
import '../../access_requests/presentation/viewmodel/access_requests_viewmodel.dart';
import '../../access_requests/domain/access_request_entity.dart';
import '../../users/presentation/viewmodel/users_viewmodel.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  void _navigateTo(WidgetRef ref, String keyName) {
    final role = ref.read(userRoleProvider);
    final visibleItems = appMenuItems.where((item) => item.canAccess(role)).toList();
    final flatItems = <AppMenuItem>[];
    for (final item in visibleItems) {
      if (item.hasChildren) {
        flatItems.addAll(item.children);
      } else {
        flatItems.add(item);
      }
    }
    
    final index = flatItems.indexWhere((item) => item.keyName == keyName);
    if (index != -1) {
      ref.read(homeNavIndexProvider.notifier).state = index;
      switch (keyName) {
        case 'dashboard':
          ref.invalidate(dashboardVmProvider);
          break;
        case 'users':
          ref.invalidate(usersViewModelProvider);
          break;
        case 'users_judges':
          ref.invalidate(judgesViewModelProvider);
          break;
        case 'users_lawyers':
          ref.invalidate(lawyersViewModelProvider);
          break;
        case 'cases':
          ref.invalidate(casesVmProvider);
          break;
        case 'access_requests':
          ref.invalidate(accessRequestsViewModelProvider);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(casesVmProvider);
    final dashSt = ref.watch(dashboardVmProvider);
    final accessReqsSt = ref.watch(accessRequestsViewModelProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stat Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'طلبات الوصول الي القضايا',
                  value: dashSt.valueOrNull?.accessRequests.toString().toArabicNumbers() ?? (dashSt.isLoading ? '...' : '-'),
                  subtitle: 'طلب جديد',
                  buttonLabel: 'مراجعة الطلبات',
                  icon: FluentIcons.clipboard_list,
                  onPressed: () => _navigateTo(ref, 'access_requests'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _StatCard(
                  title: 'طلبات انضمام المحامون',
                  value: dashSt.valueOrNull?.lawyerRequests.toString().toArabicNumbers() ?? (dashSt.isLoading ? '...' : '-'),
                  subtitle: 'طلب جديد',
                  buttonLabel: 'مراجعة الحسابات',
                  icon: FluentIcons.people,
                  onPressed: () => _navigateTo(ref, 'users_lawyers'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _StatCard(
                  title: 'القضايا الغير موكلة',
                  value: dashSt.valueOrNull?.unassignedCases.toString().toArabicNumbers() ?? (dashSt.isLoading ? '...' : '-'),
                  subtitle: 'قضية غير موكلة',
                  buttonLabel: 'بدء التعيين',
                  icon: FluentIcons.info,
                  onPressed: () => _navigateTo(ref, 'cases'),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Error handling
          if (st.error != null) ...[
            Text(
              st.error!,
              textAlign: TextAlign.right,
              style: TextStyle(color: DesignTokens.red, fontSize: 14.sp),
            ),
            SizedBox(height: 12.h),
          ],

          // Section title + action buttons
          Row(
            children: [
              // Title (right in RTL)
              Text(
                'أحدث القضايا المضافة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.brown,
                ),
              ),
              const Spacer(),
              // Buttons (left in RTL)
              Button(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(color: DesignTokens.brown),
                    ),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddCaseDialog(),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FluentIcons.add,
                      size: 12.sp,
                      color: DesignTokens.brown,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'اضف قضية',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: DesignTokens.brown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Button(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(color: DesignTokens.brown),
                    ),
                  ),
                ),
                onPressed: () => _navigateTo(ref, 'cases'),
                child: Text(
                  'عرض الجميع',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: DesignTokens.brown,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Cases Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DesignTokens.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: DesignTokens.lightGray),
              ),
              child: st.loading && st.items.isEmpty
                  ? const Center(child: ProgressRing())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TableHeader(),
                        Expanded(
                          child: ListView.separated(
                            itemCount: st.items.length,
                            separatorBuilder: (_, _) => Container(
                              height: 1.h,
                              color: DesignTokens.brown.withValues(alpha: 0.2),
                            ),
                            itemBuilder: (context, i) {
                              final c = st.items[i];
                              return _CaseRow(
                                c: c,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => CaseDetailsDialog(c: c),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 24.h),

          // Second Table Title Row
          Row(
            children: [
              Text(
                'أحدث طلبات الوصول الي القضايا',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.brown,
                ),
              ),
              const Spacer(),
              Button(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(DesignTokens.beige),
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(color: DesignTokens.brown),
                    ),
                  ),
                ),
                onPressed: () => _navigateTo(ref, 'access_requests'),
                child: Text(
                  'عرض الجميع',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: DesignTokens.brown,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Second Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DesignTokens.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: DesignTokens.lightGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AccessRequestsTableHeader(),
                  Expanded(
                    child: accessReqsSt.isLoading && accessReqsSt.valueOrNull == null
                        ? const Center(child: ProgressRing())
                        : ListView.separated(
                            itemCount: (accessReqsSt.valueOrNull?.length ?? 0).clamp(0, 4),
                            separatorBuilder: (_, _) => Container(
                              height: 1.h,
                              color: DesignTokens.brown.withValues(alpha: 0.2),
                            ),
                            itemBuilder: (context, i) {
                              final req = accessReqsSt.valueOrNull![i];
                              return _AccessRequestRow(
                                request: req,
                                onApprove: () => ref.read(accessRequestsViewModelProvider.notifier).approveRequest(req.requestId),
                                onReject: () => ref.read(accessRequestsViewModelProvider.notifier).rejectRequest(req.requestId),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String buttonLabel;
  final IconData icon;
  final VoidCallback onPressed;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.buttonLabel,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: DesignTokens.brown.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row: icon + title (right), info icon (left)
          Row(
            children: [
              Icon(icon, size: 16.sp, color: DesignTokens.brown),
              SizedBox(width: 6.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.brown,
                ),
              ),
              const Spacer(),
              Icon(FluentIcons.info, size: 14.sp, color: DesignTokens.gray),
            ],
          ),
          SizedBox(height: 12.h),
          // Bottom row: value (right), button (left)
          Row(
            children: [
              // Value + subtitle
              Text(
                value,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.brown,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12.sp, color: DesignTokens.gray),
              ),
              const Spacer(),
              // Action button
              Button(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(color: DesignTokens.brown),
                    ),
                  ),
                ),
                onPressed: onPressed,
                child: Text(
                  buttonLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: DesignTokens.brown,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.beige,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'رقم القضية',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'نوع القضية',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'تاريخ التسجيل',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'الاجراء',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseRow extends StatelessWidget {
  const _CaseRow({required this.c, required this.onTap});

  final CaseModel c;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "#${c.caseNumber}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              c.courtRuling.isNotEmpty ? c.courtRuling : 'غير محدد',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(c.createdAt),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (c.judgeName == null || c.judgeName!.isEmpty) ...[
                  // تعيين button
                  Button(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        DesignTokens.brown,
                      ),
                      padding: WidgetStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                    onPressed: onTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FluentIcons.add_friend,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'تعيين',
                          style: TextStyle(color: Colors.white, fontSize: 11.sp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
                // عرض button
                Button(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      DesignTokens.brown,
                    ),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  onPressed: onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FluentIcons.view, size: 12.sp, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        'عرض',
                        style: TextStyle(color: Colors.white, fontSize: 11.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => "${d.day}-${d.month}-${d.year}";
}




class _AccessRequestsTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.beige,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'رقم الطلب',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'اسم المحامي',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'رقم القضية المطلوبة',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'الاجراء',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessRequestRow extends StatelessWidget {
  final AccessRequestEntity request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _AccessRequestRow({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "#${request.requestId.length > 5 ? request.requestId.substring(0, 5) : request.requestId}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              request.lawyerName,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "#${request.caseNumber}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: request.status == 'PENDING'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Accept button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green),
                        ),
                        child: IconButton(
                          icon: Icon(
                            FluentIcons.check_mark,
                            color: Colors.green,
                            size: 12.sp,
                          ),
                          onPressed: onApprove,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Reject button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: DesignTokens.red),
                        ),
                        child: IconButton(
                          icon: Icon(
                            FluentIcons.cancel,
                            color: DesignTokens.red,
                            size: 12.sp,
                          ),
                          onPressed: onReject,
                        ),
                      ),
                    ],
                  )
                : Text(
                    request.status == 'APPROVED' ? 'تمت الموافقة' : 'مرفوض',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: request.status == 'APPROVED'
                          ? Colors.green
                          : DesignTokens.red,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

extension ArabicNumbers on String {
  String toArabicNumbers() {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = this;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }
}

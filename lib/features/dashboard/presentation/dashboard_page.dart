import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/design_tokens.dart';
import '../../cases/domain/case_model.dart';
import '../../cases/presentation/viewmodel/cases_vm.dart';
import '../../cases/presentation/view/case_details_page.dart';
import '../../cases/presentation/view/widgets/add_case_dialog.dart';
import 'viewmodel/dashboard_vm.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(casesVmProvider);
    final dashSt = ref.watch(dashboardVmProvider);

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
                  value: dashSt.valueOrNull?.accessRequests.toString() ?? (dashSt.isLoading ? '...' : '-'),
                  subtitle: 'طلب جديد',
                  buttonLabel: 'مراجعة الطلبات',
                  icon: FluentIcons.clipboard_list,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _StatCard(
                  title: 'طلبات انضمام المحامون',
                  value: dashSt.valueOrNull?.lawyerRequests.toString() ?? (dashSt.isLoading ? '...' : '-'),
                  subtitle: 'طلب جديد',
                  buttonLabel: 'مراجعة الحسابات',
                  icon: FluentIcons.people,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _StatCard(
                  title: 'القضايا الغير موكلة',
                  value: dashSt.valueOrNull?.unassignedCases.toString() ?? (dashSt.isLoading ? '...' : '-'),
                  subtitle: 'قضية غير موكلة',
                  buttonLabel: 'بدء التعيين',
                  icon: FluentIcons.info,
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
                onPressed: () {},
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
                                    builder: (_) => _CaseDetailsDialog(c: c),
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
                onPressed: () {},
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
                    child: ListView.separated(
                      itemCount: 4, // placeholder items
                      separatorBuilder: (_, _) => Container(
                        height: 1.h,
                        color: DesignTokens.brown.withValues(alpha: 0.2),
                      ),
                      itemBuilder: (context, i) {
                        return _AccessRequestRow();
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

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.buttonLabel,
    required this.icon,
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
                onPressed: () {},
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
              'جنايات',
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
                  onPressed: () {
                    // TODO: Assign case
                  },
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

class _CaseDetailsDialog extends StatelessWidget {
  final CaseModel c;
  const _CaseDetailsDialog({required this.c});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 600.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F6F0), // match the beige background in image
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: DesignTokens.brown),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                children: [
                  // Close button (Left)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: DesignTokens.brown),
                    ),
                    child: IconButton(
                      icon: Icon(
                        FluentIcons.cancel,
                        size: 12.sp,
                        color: DesignTokens.brown,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Spacer(),
                  // Title (Right)
                  Text(
                    'تفاصيل القضية',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.brown,
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Container(height: 1, color: DesignTokens.brown),

            // Content
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column: الاطراف المعينة
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'الاطراف المعينة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: DesignTokens.brown,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildInfoBox('المحامي: عبد العزيز محمد'),
                        SizedBox(height: 12.h),
                        _buildInfoBox('القاضي: حمادة عباس'),
                      ],
                    ),
                  ),
                  SizedBox(width: 32.w),
                  // Right column: بيانات القضية
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'بيانات القضية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: DesignTokens.brown,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildInfoBox('رقم القضية: #${c.caseNumber}'),
                        SizedBox(height: 12.h),
                        _buildInfoBox('نوع القضية: جنايات'),
                        SizedBox(height: 12.h),
                        _buildInfoBox(
                          'تاريخ تسجيل القضية: ${_formatDate(c.createdAt)}',
                          icon: FluentIcons.calendar,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Divider
            Container(height: 1, color: DesignTokens.brown),

            // Action Button
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      DesignTokens.brown,
                    ),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 48.w, vertical: 10.h),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      FluentPageRoute(
                        builder: (_) => CaseDetailsPage(caseId: c.id),
                      ),
                    );
                  },
                  child: Text(
                    'عرض الملفات',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String text, {IconData? icon}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9F6),
        border: Border.all(color: DesignTokens.brown.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (icon != null)
            Icon(icon, size: 16.sp, color: DesignTokens.brown)
          else
            const SizedBox.shrink(),
          Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 14.sp, color: DesignTokens.brown),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => "${d.year}-${d.month}-${d.day}";
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
              "#34627",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "رمضان ابراهيم",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "#34627",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
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
                    onPressed: () {},
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
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

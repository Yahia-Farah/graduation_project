import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/design_tokens.dart';

class JudgeDashboardPage extends ConsumerWidget {
  const JudgeDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'معالي المستشار/ حمادة عباس',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.brown,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'الخميس, 29 يناير 2026',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: DesignTokens.brown.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Stat Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'القضايا الجديدة',
                  value: '130 قضية',
                  icon: FluentIcons.folder, // Using folder as mock
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _StatCard(
                  title: 'القضايا الجاري تحليلها',
                  value: '57 قضية',
                  icon: FluentIcons.clock,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _StatCard(
                  title: 'القضايا المكتملة',
                  value: '90 قضية',
                  icon: FluentIcons.check_mark, // Using checkmark
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Controls Row
          Row(
            children: [
              // Search Box with Calendar Prefix
              Expanded(
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: DesignTokens.brown.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: TextBox(
                    placeholder: 'ابحث في القضايا',
                    textAlign: TextAlign.right,
                    highlightColor: Colors.transparent,
                    unfocusedColor: Colors.transparent,
                    prefix: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Icon(FluentIcons.calendar, size: 16.sp, color: DesignTokens.gray),
                    ),
                    suffix: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Icon(FluentIcons.search, size: 16.sp, color: DesignTokens.gray),
                    ),
                    decoration: WidgetStateProperty.all(
                      const BoxDecoration(
                        color: Colors.transparent,
                        border: Border.fromBorderSide(BorderSide.none),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              // Analyze Now Button
              FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(DesignTokens.brown),
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 32.w, vertical: 10.h),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  children: [
                    Icon(FluentIcons.branch_fork, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'حلل الآن',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Table Header
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE2C485),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
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
                    'تاريخ القضية',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'حالة القضية',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                ),
              ],
            ),
          ),

          // Table Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r)),
                border: Border.all(color: DesignTokens.brown.withValues(alpha: 0.2)),
              ),
              child: ListView.builder(
                itemCount: 8,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  // Mock data variation
                  final statuses = ['لم يبدأ التحليل', 'جاري التحليل', 'لم يبدأ التحليل', 'جاري التحليل', 'مكتمل', 'لم يبدأ التحليل', 'جاري التحليل', 'مكتمل'];
                  final types = ['جنايات', 'جنح', 'جنايات', 'جنايات', 'جنح', 'جنح', 'جنايات', 'جنايات'];

                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: index == 7 ? Colors.transparent : DesignTokens.brown.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                index % 2 == 0 ? '#3287' : '#34627',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              SizedBox(width: 8.w),
                              Checkbox(
                                checked: false,
                                onChanged: (v) {},
                                style: CheckboxThemeData(
                                  checkedDecoration: WidgetStateProperty.all(
                                    BoxDecoration(
                                      color: DesignTokens.brown,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            types[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '25-1-2026',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            statuses[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(FluentIcons.chevron_right, size: 12),
                onPressed: () {},
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: DesignTokens.brown,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '1',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp),
                ),
              ),
              SizedBox(width: 12.w),
              Text('2', style: TextStyle(fontSize: 12.sp, color: DesignTokens.gray)),
              SizedBox(width: 12.w),
              Text('3', style: TextStyle(fontSize: 12.sp, color: DesignTokens.gray)),
              SizedBox(width: 12.w),
              Text('4', style: TextStyle(fontSize: 12.sp, color: DesignTokens.gray)),
              SizedBox(width: 12.w),
              Text('...', style: TextStyle(fontSize: 12.sp, color: DesignTokens.gray)),
              SizedBox(width: 12.w),
              Text('10', style: TextStyle(fontSize: 12.sp, color: DesignTokens.gray)),
              SizedBox(width: 12.w),
              IconButton(
                icon: const Icon(FluentIcons.chevron_left, size: 12),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20.sp, color: DesignTokens.brown),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.brown,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: DesignTokens.brown,
            ),
          ),
        ],
      ),
    );
  }
}

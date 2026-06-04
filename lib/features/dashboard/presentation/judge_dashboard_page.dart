import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/design_tokens.dart';
import '../../ai_analysis/presentation/viewmodel/ai_analysis_vm.dart';
import '../../cases/domain/case_model.dart';
import 'viewmodel/judge_dashboard_vm.dart';
import '../../cases/presentation/view/widgets/case_details_dialog.dart';

class JudgeDashboardPage extends ConsumerWidget {
  const JudgeDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(judgeDashboardVmProvider);
    final vm = ref.read(judgeDashboardVmProvider.notifier);
    final aiState = ref.watch(aiAnalysisVmProvider);
    final aiVm = ref.read(aiAnalysisVmProvider.notifier);

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
                  title: 'القضايا الجديدة',
                  value: '${st.newCount}',
                  subtitle: 'قضية جديد',
                  icon: FluentIcons.folder,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _StatCard(
                  title: 'القضايا الجاري تحليلها',
                  value: '${st.inProgressCount}',
                  subtitle: 'قضية',
                  icon: FluentIcons.clock,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _StatCard(
                  title: 'القضايا المكتملة',
                  value: '${st.completedCount}',
                  subtitle: 'قضية مكتملة',
                  icon: FluentIcons.check_mark,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // AI Analysis InfoBar
          if (aiState.hasRunningTasks)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: InfoBar(
                title: Text(
                  'جاري تحليل ${aiState.runningTasks.length} قضية...',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: aiState.runningTasks
                      .map((t) => Text('القضية #${t.caseNumber}'))
                      .toList(),
                ),
                severity: InfoBarSeverity.info,
                isLong: true,
              ),
            ),

          // Completed Analysis Results
          ...aiState.completedTasks.map((task) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: InfoBar(
                  title: Text(
                    'اكتمل تحليل القضية #${task.caseNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  severity: InfoBarSeverity.success,
                  action: FilledButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(DesignTokens.brown),
                    ),
                    onPressed: () {
                      aiVm.viewResult(task.result!);
                      // Navigate to results page via setting nav index
                      // This will be handled in home_shell.dart
                    },
                    child: const Text('عرض النتائج'),
                  ),
                  onClose: () => aiVm.dismissTask(task.caseId),
                ),
              )),

          // Failed Analysis
          ...aiState.tasks.values
              .where((t) => t.status == AnalysisTaskStatus.failed)
              .map((task) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: InfoBar(
                      title: Text(
                        'فشل تحليل القضية #${task.caseNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: Text(task.error ?? 'خطأ غير معروف'),
                      severity: InfoBarSeverity.error,
                      onClose: () => aiVm.dismissTask(task.caseId),
                    ),
                  )),

          // Controls Row
          Row(
            children: [
              // Search Box
              Expanded(
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: DesignTokens.brown.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: TextBox(
                    placeholder: 'ابحث في القضايا',
                    textAlign: TextAlign.right,
                    highlightColor: Colors.transparent,
                    unfocusedColor: Colors.transparent,
                    prefix: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Icon(
                        FluentIcons.calendar,
                        size: 16.sp,
                        color: DesignTokens.gray,
                      ),
                    ),
                    suffix: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Icon(
                        FluentIcons.search,
                        size: 16.sp,
                        color: DesignTokens.gray,
                      ),
                    ),
                    decoration: WidgetStateProperty.all(
                      const BoxDecoration(
                        color: Colors.transparent,
                        border: Border.fromBorderSide(BorderSide.none),
                      ),
                    ),
                    onChanged: vm.setQuery,
                    onSubmitted: (_) => vm.search(),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              // Analyze Now Button
              FilledButton(
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(DesignTokens.brown),
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 32.w, vertical: 10.h),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                onPressed: st.selectedCaseIds.isEmpty
                    ? null
                    : () {
                        for (final caseId in st.selectedCaseIds) {
                          final caseModel = st.allItems
                              .where((c) => c.id == caseId)
                              .firstOrNull;
                          if (caseModel != null) {
                            aiVm.startAnalysis(
                                caseId, caseModel.caseNumber);
                          }
                        }
                        vm.clearSelection();
                      },
                child: Row(
                  children: [
                    Icon(FluentIcons.branch_fork, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      st.selectedCaseIds.isEmpty
                          ? 'حلل الآن'
                          : 'حلل الآن (${st.selectedCaseIds.length})',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
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
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            padding:
                EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'رقم القضية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'نوع القضية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'تاريخ القضية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'حالة القضية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
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
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12.r),
                ),
                border: Border.all(
                  color: DesignTokens.brown.withValues(alpha: 0.2),
                ),
              ),
              child: st.loading && st.items.isEmpty
                  ? const Center(child: ProgressRing())
                  : st.items.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد قضايا',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: DesignTokens.gray,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: st.items.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final c = st.items[index];
                            final isSelected =
                                st.selectedCaseIds.contains(c.id);
                            final isAnalyzing =
                                aiState.isAnalyzing(c.id);

                            return _DashboardRow(
                              c: c,
                              isLast: index == st.items.length - 1,
                              isSelected: isSelected,
                              isAnalyzing: isAnalyzing,
                              onToggle: () =>
                                  vm.toggleCaseSelection(c.id),
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
          ),
          SizedBox(height: 12.h),

          // Pagination
          if (st.pageInfo.totalPages > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon:
                      const Icon(FluentIcons.chevron_right, size: 12),
                  onPressed: st.pageInfo.hasPrevious
                      ? vm.prevPage
                      : null,
                ),
                SizedBox(width: 12.w),
                ...List.generate(
                  st.pageInfo.totalPages > 5
                      ? 5
                      : st.pageInfo.totalPages,
                  (i) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: i == st.pageInfo.currentPage
                              ? DesignTokens.brown
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: i == st.pageInfo.currentPage
                                ? Colors.white
                                : DesignTokens.gray,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (st.pageInfo.totalPages > 5) ...[
                  SizedBox(width: 4.w),
                  Text('...',
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: DesignTokens.gray)),
                  SizedBox(width: 4.w),
                  Text('${st.pageInfo.totalPages}',
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: DesignTokens.gray)),
                ],
                SizedBox(width: 12.w),
                IconButton(
                  icon:
                      const Icon(FluentIcons.chevron_left, size: 12),
                  onPressed:
                      st.pageInfo.hasNext ? vm.nextPage : null,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Stat Card ───────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
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
            '$value $subtitle',
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

// ─── Dashboard Row ──────────────────────────────────────────────────

class _DashboardRow extends StatelessWidget {
  final CaseModel c;
  final bool isLast;
  final bool isSelected;
  final bool isAnalyzing;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  const _DashboardRow({
    required this.c,
    required this.isLast,
    required this.isSelected,
    required this.isAnalyzing,
    required this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast
                  ? Colors.transparent
                  : DesignTokens.brown.withValues(alpha: 0.2),
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
                Text('#${c.caseNumber}',
                    style: TextStyle(fontSize: 14.sp)),
                SizedBox(width: 8.w),
                if (isAnalyzing)
                  SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const ProgressRing(strokeWidth: 2),
                  )
                else
                  Checkbox(
                    checked: isSelected,
                    onChanged: (_) => onToggle(),
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
              c.courtRuling.isNotEmpty ? c.courtRuling : 'غير محدد',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${c.createdAt.day}-${c.createdAt.month}-${c.createdAt.year}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _statusLabel(c.status),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    ),
    );
  }

  String _statusLabel(String s) {
    switch (s.toUpperCase()) {
      case 'PENDING':
        return 'لم يبدأ التحليل';
      case 'IN_PROGRESS':
        return 'جاري التحليل';
      case 'COMPLETED':
        return 'مكتمل';
      default:
        return s.isNotEmpty ? s : 'غير محدد';
    }
  }
}

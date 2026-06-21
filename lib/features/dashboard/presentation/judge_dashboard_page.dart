import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/design_tokens.dart';
import '../../ai_analysis/presentation/viewmodel/ai_analysis_vm.dart';
import '../../ai_analysis/presentation/view/ai_analysis_result_page.dart';
import '../../cases/domain/case_model.dart';
import 'viewmodel/judge_dashboard_vm.dart';
import '../../cases/presentation/view/widgets/case_details_dialog.dart';
import '../../../../app/shared_widgets/custom_search_bar.dart';
import '../../../../app/shared_widgets/custom_date_picker.dart';
import '../../../../core/utils/arabic_numbers_extension.dart';

class JudgeDashboardPage extends ConsumerStatefulWidget {
  const JudgeDashboardPage({super.key});

  @override
  ConsumerState<JudgeDashboardPage> createState() => _JudgeDashboardPageState();
}

class _JudgeDashboardPageState extends ConsumerState<JudgeDashboardPage> {
  DateTime? _dateFilter;

  @override
  void initState() {
    super.initState();
    _dateFilter = ref.read(judgeDashboardVmProvider).dateFilter;
  }

  @override
  Widget build(BuildContext context) {
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
                  value: '${st.newCount}'.toArabicNumbers(),
                  subtitle: 'قضية جديدة',
                  buttonLabel: 'عرض القضايا',
                  icon: FluentIcons.folder,
                  onPressed: () {},
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _StatCard(
                  title: 'القضايا الجاري تحليلها',
                  value: '${st.inProgressCount}'.toArabicNumbers(),
                  subtitle: 'قضية',
                  buttonLabel: 'عرض القضايا',
                  icon: FluentIcons.clock,
                  onPressed: () {},
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _StatCard(
                  title: 'القضايا المكتملة',
                  value: '${st.completedCount}'.toArabicNumbers(),
                  subtitle: 'قضية مكتملة',
                  buttonLabel: 'عرض القضايا',
                  icon: FluentIcons.check_mark,
                  onPressed: () {},
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
                      .map((t) => Text(('القضية #${t.caseNumber}').toArabicNumbers()))
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
                      aiVm.viewResult(task.result!, caseId: task.caseId);
                      Navigator.of(context).push(FluentPageRoute(
                        builder: (context) => const AiAnalysisResultPage(),
                      ));
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
                child: SizedBox(
                  height: 48.h,
                  child: CustomSearchBar(
                    placeholder: 'ابحث في القضايا',
                    prefix: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: CustomDatePicker(
                        borderless: true,
                        iconSize: 16.sp,
                        selectedDate: _dateFilter,
                        onDateChanged: (v) {
                          setState(() {
                            _dateFilter = v;
                            vm.setDateFilter(v);
                          });
                        },
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
                    onChanged: vm.setQuery,
                    onSubmitted: (_) => vm.search(),
                  ),
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
                Expanded(
                  flex: 2,
                  child: Text(
                    'الإجراء',
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
                            final isAnalyzing =
                                aiState.isAnalyzing(c.id);

                            return _DashboardRow(
                              c: c,
                              isLast: index == st.items.length - 1,
                              isAnalyzing: isAnalyzing,
                              onAnalyze: () {
                                aiVm.startAnalysis(c.id, c.caseNumber);
                              },
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
                          '${i + 1}'.toArabicNumbers(),
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
                  Text('${st.pageInfo.totalPages}'.toArabicNumbers(),
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
                  fontSize: 20.sp,
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
                  fontSize: 42.sp,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.brown,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                subtitle,
                style: TextStyle(fontSize: 16.sp, color: DesignTokens.gray),
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
                    fontSize: 14.sp,
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

// ─── Dashboard Row ──────────────────────────────────────────────────

class _DashboardRow extends StatelessWidget {
  final CaseModel c;
  final bool isLast;
  final bool isAnalyzing;
  final VoidCallback onAnalyze;
  final VoidCallback onTap;

  const _DashboardRow({
    required this.c,
    required this.isLast,
    required this.isAnalyzing,
    required this.onAnalyze,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = c.status.toUpperCase() == 'COMPLETED';
    final bool canAnalyze = !isCompleted && !isAnalyzing;

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
                Text('#${c.caseNumber}'.toArabicNumbers(),
                    style: TextStyle(fontSize: 14.sp)),
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
              '${c.createdAt.day}-${c.createdAt.month}-${c.createdAt.year}'.toArabicNumbers(),
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
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Analyze Button
                Button(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      canAnalyze ? DesignTokens.brown : const Color(0xffDFDFDF),
                    ),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  onPressed: canAnalyze ? onAnalyze : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isAnalyzing)
                        SizedBox(
                          width: 12.sp,
                          height: 12.sp,
                          child: const ProgressRing(strokeWidth: 2),
                        )
                      else
                        Icon(FluentIcons.branch_fork, size: 12.sp, color: canAnalyze ? Colors.white : DesignTokens.gray),
                      SizedBox(width: 4.w),
                      Text(
                        'حلل الآن',
                        style: TextStyle(
                          color: canAnalyze ? Colors.white : DesignTokens.gray,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // View Button
                Button(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      DesignTokens.brown,
                    ),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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

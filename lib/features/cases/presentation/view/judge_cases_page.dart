import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../domain/case_model.dart';
import '../viewmodel/judge_cases_vm.dart';
import 'widgets/case_details_dialog.dart';

class JudgeCasesPage extends ConsumerWidget {
  const JudgeCasesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(judgeCasesVmProvider);
    final vm = ref.read(judgeCasesVmProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TabButton(
                  label: 'الجميع',
                  isActive: st.activeTab == 'ALL',
                  onTap: () => vm.setActiveTab('ALL'),
                ),
                SizedBox(width: 24.w),
                _TabButton(
                  label: 'الجديدة',
                  isActive: st.activeTab == 'PENDING',
                  onTap: () => vm.setActiveTab('PENDING'),
                ),
                SizedBox(width: 24.w),
                _TabButton(
                  label: 'قيد التحليل',
                  isActive: st.activeTab == 'IN_PROGRESS',
                  onTap: () => vm.setActiveTab('IN_PROGRESS'),
                ),
                SizedBox(width: 24.w),
                _TabButton(
                  label: 'مكتملة',
                  isActive: st.activeTab == 'COMPLETED',
                  onTap: () => vm.setActiveTab('COMPLETED'),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Search Box
          Row(
            children: [
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
                    placeholder: 'ابحث في القضايا المقيدة',
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
            ],
          ),
          SizedBox(height: 16.h),

          if (st.error != null) ...[
            Text(
              st.error!,
              textAlign: TextAlign.right,
              style: const TextStyle(color: DesignTokens.red),
            ),
            SizedBox(height: 12.h),
          ],

          // Table Header
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE2C485),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            child: Row(
              children: [
                _HeaderCell('رقم القضية'),
                _HeaderCell('نوع القضية'),
                _HeaderCell('تاريخ القضية'),
                _HeaderCell('حالة القضية'),
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
                                fontSize: 16.sp, color: DesignTokens.gray),
                          ),
                        )
                      : ListView.builder(
                          itemCount: st.items.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final c = st.items[index];
                            return _CaseRow(
                              c: c,
                              isLast: index == st.items.length - 1,
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
          _Pagination(
            currentPage: st.pageInfo.currentPage,
            totalPages: st.pageInfo.totalPages,
            onNext: st.pageInfo.hasNext ? vm.nextPage : null,
            onPrev: st.pageInfo.hasPrevious ? vm.prevPage : null,
          ),
        ],
      ),
    );
  }
}

// ─── Tab Button ───────────────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? DesignTokens.brown : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? DesignTokens.brown : DesignTokens.gray,
          ),
        ),
      ),
    );
  }
}

// ─── Table Cells ──────────────────────────────────────────────────────

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
      ),
    );
  }
}

class _CaseRow extends StatelessWidget {
  final CaseModel c;
  final bool isLast;
  final VoidCallback? onTap;
  const _CaseRow({required this.c, required this.isLast, this.onTap});

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
            child: Text(
              '#${c.caseNumber}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
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

// ─── Pagination ──────────────────────────────────────────────────────

class _Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;

  const _Pagination({
    required this.currentPage,
    required this.totalPages,
    this.onNext,
    this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(FluentIcons.chevron_right, size: 12),
          onPressed: onPrev,
        ),
        SizedBox(width: 12.w),
        ...List.generate(
          totalPages > 5 ? 5 : totalPages,
          (i) {
            final page = i;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: page == currentPage
                        ? DesignTokens.brown
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    '${page + 1}',
                    style: TextStyle(
                      color: page == currentPage
                          ? Colors.white
                          : DesignTokens.gray,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (totalPages > 5) ...[
          SizedBox(width: 4.w),
          Text('...',
              style: TextStyle(fontSize: 12.sp, color: DesignTokens.gray)),
          SizedBox(width: 4.w),
          Text('$totalPages',
              style: TextStyle(fontSize: 12.sp, color: DesignTokens.gray)),
        ],
        SizedBox(width: 12.w),
        IconButton(
          icon: const Icon(FluentIcons.chevron_left, size: 12),
          onPressed: onNext,
        ),
      ],
    );
  }
}

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../domain/case_model.dart';
import '../viewmodel/judge_archive_vm.dart';
import 'widgets/case_details_dialog.dart';

class JudgeArchivePage extends ConsumerWidget {
  const JudgeArchivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(judgeArchiveVmProvider);
    final vm = ref.read(judgeArchiveVmProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                    placeholder: 'ابحث في الأرشيف',
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
                            'لا توجد قضايا في الأرشيف',
                            style: TextStyle(
                                fontSize: 16.sp, color: DesignTokens.gray),
                          ),
                        )
                      : ListView.builder(
                          itemCount: st.items.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final c = st.items[index];
                            return _ArchiveRow(
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
          if (st.pageInfo.totalPages > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(FluentIcons.chevron_right, size: 12),
                  onPressed:
                      st.pageInfo.hasPrevious ? vm.prevPage : null,
                ),
                SizedBox(width: 12.w),
                Text(
                  "${st.pageInfo.currentPage + 1} / ${st.pageInfo.totalPages}",
                  style: TextStyle(fontSize: 12.sp),
                ),
                SizedBox(width: 12.w),
                IconButton(
                  icon: const Icon(FluentIcons.chevron_left, size: 12),
                  onPressed: st.pageInfo.hasNext ? vm.nextPage : null,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

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

class _ArchiveRow extends StatelessWidget {
  final CaseModel c;
  final bool isLast;
  final VoidCallback? onTap;
  const _ArchiveRow({required this.c, required this.isLast, this.onTap});

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
            child: Text('#${c.caseNumber}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp)),
          ),
          Expanded(
            flex: 2,
            child: Text(
                c.courtRuling.isNotEmpty ? c.courtRuling : 'غير محدد',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp)),
          ),
          Expanded(
            flex: 2,
            child: Text(
                '${c.createdAt.day}-${c.createdAt.month}-${c.createdAt.year}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp)),
          ),
          Expanded(
            flex: 2,
            child: Text('مكتمل',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    ),
    );
  }
}

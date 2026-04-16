import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/design_tokens.dart';
import '../../cases/domain/case_model.dart';
import '../../cases/presentation/viewmodel/cases_vm.dart';
import '../../cases/presentation/view/case_details_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(casesVmProvider);
    final vm = ref.read(casesVmProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stat Cards
          Wrap(
            spacing: 24.w,
            runSpacing: 16.h,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _StatCard(title: "القضايا المكتملة", value: "90", icon: FluentIcons.check_mark),
              _StatCard(title: "القضايا الجاري تحليلها", value: "57", icon: FluentIcons.time_sheet),
              _StatCard(title: "القضايا الجديدة", value: "130", icon: FluentIcons.new_folder),
            ],
          ),
          SizedBox(height: 24.h),

          // Search Row
          Row(
            children: [
              FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(DesignTokens.brown),
                  padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h)),
                ),
                onPressed: () {},
                child: Row(
                  children: [
                    Text('حلل الآن', style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, fontSize: 16.sp)),
                    SizedBox(width: 8.w),
                    Icon(FluentIcons.share, size: 16.sp),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: TextBox(
                  placeholder: 'ابحث في القضايا',
                  textAlign: TextAlign.right,
                  suffix: Padding(padding: EdgeInsets.only(right: 8.w), child: Icon(FluentIcons.search, size: 20.sp)),
                  prefix: Padding(padding: EdgeInsets.only(left: 8.w), child: Icon(FluentIcons.calendar, size: 20.sp)),
                  onChanged: vm.setQuery,
                  onSubmitted: (_) => vm.search(),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Error handling
          if (st.error != null) ...[
            Text(st.error!, textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Amiri', color: DesignTokens.red, fontSize: 14.sp)),
            SizedBox(height: 12.h),
          ],

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
                            separatorBuilder: (_, __) => Container(height: 1.h, color: DesignTokens.brown.withValues(alpha: 0.2)),
                            itemBuilder: (context, i) {
                              final c = st.items[i];
                              return _CaseRow(
                                c: c,
                                onTap: () {
                                  Navigator.of(context).push(
                                    FluentPageRoute(builder: (_) => CaseDetailsPage(caseId: c.id)),
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
          SizedBox(height: 16.h),

          // Pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(FluentIcons.chevron_right), onPressed: st.pageInfo.hasPrevious ? vm.prevPage : null),
              const SizedBox(width: 16),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: DesignTokens.brown, borderRadius: BorderRadius.circular(4)), child: Text("\${st.pageInfo.currentPage + 1}", style: const TextStyle(color: Colors.white))),
              const SizedBox(width: 8),
              if (st.pageInfo.totalPages > 1) ...[
                Text("2", style: TextStyle(color: DesignTokens.gray)),
                const SizedBox(width: 8),
                Text("3", style: TextStyle(color: DesignTokens.gray)),
                const SizedBox(width: 8),
                Text("...", style: TextStyle(color: DesignTokens.gray)),
                const SizedBox(width: 8),
                Text("\${st.pageInfo.totalPages}", style: TextStyle(color: DesignTokens.gray)),
              ],
              const SizedBox(width: 16),
              IconButton(icon: const Icon(FluentIcons.chevron_left), onPressed: st.pageInfo.hasNext ? vm.nextPage : null),
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

  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.w,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontFamily: "Amiri", fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8.w),
              Icon(icon, size: 16.sp, color: DesignTokens.gray),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            "$value قضية",
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: "Amiri", fontSize: 24.sp, fontWeight: FontWeight.bold, color: DesignTokens.brown),
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
          Expanded(flex: 1, child: Text('رقم القضية', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, fontSize: 14.sp))),
          Expanded(flex: 2, child: Text('نوع القضية', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, fontSize: 14.sp))),
          Expanded(flex: 2, child: Text('تاريخ القضية', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, fontSize: 14.sp))),
          Expanded(flex: 2, child: Text('حالة القضية', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, fontSize: 14.sp))),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // for hit testing
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text("#${c.caseNumber}", textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Amiri', fontSize: 14.sp)), SizedBox(width: 8.w), Container(width: 14.w, height: 14.w, decoration: BoxDecoration(border: Border.all(color: DesignTokens.gray), borderRadius: BorderRadius.circular(4.r)))],
              ),
            ),
            Expanded(flex: 2, child: Text("جنايات", textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, fontSize: 14.sp))),
            Expanded(flex: 2, child: Text(_formatDate(c.createdAt), textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Amiri', fontSize: 14.sp))),
            Expanded(flex: 2, child: Text(_statusLabel(c.status), textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Amiri', fontSize: 14.sp))),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => "${d.day}-${d.month}-${d.year}";

  String _statusLabel(String s) {
    switch (s) {
      case 'PENDING': return "لم يبدأ التحليل";
      case 'IN_PROGRESS': return "جاري التحليل";
      case 'COMPLETED': return "مكتمل";
      default: return s;
    }
  }
}

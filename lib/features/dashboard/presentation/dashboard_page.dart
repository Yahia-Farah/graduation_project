import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            spacing: 24,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _StatCard(title: "القضايا المكتملة", value: "90", icon: FluentIcons.check_mark),
              _StatCard(title: "القضايا الجاري تحليلها", value: "57", icon: FluentIcons.time_sheet),
              _StatCard(title: "القضايا الجديدة", value: "130", icon: FluentIcons.new_folder),
            ],
          ),
          const SizedBox(height: 24),

          // Search Row
          Row(
            children: [
              FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(DesignTokens.brown),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 10)),
                ),
                onPressed: () {},
                child: const Row(
                  children: [
                    Text('حلل الآن', style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(width: 8),
                    Icon(FluentIcons.share, size: 16),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextBox(
                  placeholder: 'ابحث في القضايا',
                  textAlign: TextAlign.right,
                  suffix: const Padding(padding: EdgeInsets.only(right: 8), child: Icon(FluentIcons.search)),
                  prefix: const Padding(padding: EdgeInsets.only(left: 8), child: Icon(FluentIcons.calendar)),
                  onChanged: vm.setQuery,
                  onSubmitted: (_) => vm.search(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Error handling
          if (st.error != null) ...[
            Text(st.error!, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Amiri', color: DesignTokens.red)),
            const SizedBox(height: 12),
          ],

          // Cases Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DesignTokens.white,
                borderRadius: BorderRadius.circular(16),
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
                            separatorBuilder: (_, __) => Container(height: 1, color: DesignTokens.brown.withValues(alpha: 0.2)),
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
          const SizedBox(height: 16),

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
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(fontFamily: "Amiri", fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 16, color: DesignTokens.gray),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "$value قضية",
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontFamily: "Amiri", fontSize: 24, fontWeight: FontWeight.bold, color: DesignTokens.brown),
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
      decoration: const BoxDecoration(
        color: DesignTokens.beige,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: const Row(
        children: [
          Expanded(flex: 1, child: Text('رقم القضية', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('نوع القضية', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('تاريخ القضية', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('حالة القضية', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold))),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text("#${c.caseNumber}", textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Amiri')), const SizedBox(width: 8), Container(width: 14, height: 14, decoration: BoxDecoration(border: Border.all(color: DesignTokens.gray), borderRadius: BorderRadius.circular(4)))],
              ),
            ),
            Expanded(flex: 2, child: Text("جنايات", textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold))),
            Expanded(flex: 2, child: Text(_formatDate(c.createdAt), textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Amiri'))),
            Expanded(flex: 2, child: Text(_statusLabel(c.status), textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Amiri'))),
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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../domain/case_model.dart';
import '../viewmodel/cases_vm.dart';
import 'case_details_page.dart';

class CasesPage extends ConsumerWidget {
  const CasesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(casesVmProvider);
    final vm = ref.read(casesVmProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            const Text(
              'القضايا',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: DesignTokens.brown,
              ),
            ),
            const Spacer(),

            SizedBox(
              width: 360,
              child: TextBox(
                placeholder: 'ابحث في القضايا',
                textAlign: TextAlign.right,
                onChanged: vm.setQuery,
                onSubmitted: (_) => vm.search(),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(DesignTokens.brown),
              ),
              onPressed: st.loading ? null : vm.search,
              child: st.loading ? const ProgressRing() : const Text('بحث'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        if (st.error != null) ...[
          Text(
            st.error!,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Amiri',
              color: DesignTokens.red,
            ),
          ),
          const SizedBox(height: 12),
        ],

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: DesignTokens.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DesignTokens.lightGray),
            ),
            child: st.loading && st.items.isEmpty
                ? const Center(child: ProgressRing())
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: st.items.length + 1,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      if (i == 0) return _TableHeader();
                      final c = st.items[i - 1];
                      return _CaseRow(
                        c: c,
                        onTap: () {
                          Navigator.of(context).push(
                            FluentPageRoute(
                              builder: (_) => CaseDetailsPage(caseId: c.id)
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ),

        const SizedBox(height: 12),

        // Pagination (مبدئي)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(FluentIcons.chevron_left),
              onPressed: st.pageInfo.hasPrevious ? vm.prevPage : null,
            ),
            const SizedBox(width: 12),
            Text(
              "${st.pageInfo.currentPage + 1} / ${st.pageInfo.totalPages}",
              style: const TextStyle(fontFamily: 'Amiri'),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(FluentIcons.chevron_right),
              onPressed: st.pageInfo.hasNext ? vm.nextPage : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.beige,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: const [
          Expanded(child: Text('رقم القضية', textAlign: TextAlign.right)),
          Expanded(child: Text('نوع القضية', textAlign: TextAlign.right)),
          Expanded(child: Text('تاريخ القضية', textAlign: TextAlign.right)),
          Expanded(child: Text('حالة القضية', textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _CaseRow extends StatelessWidget {
  const _CaseRow({
    required this.c,
    required this.onTap,
  });

  final CaseModel c;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: DesignTokens.brown, width: 0.3),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Expanded(child: Text("#${c.caseNumber}", textAlign: TextAlign.right)),
            Expanded(child: Text(c.title, textAlign: TextAlign.right)),
            Expanded(child: Text(_formatDate(c.createdAt), textAlign: TextAlign.right)),
            Expanded(child: Text(_statusLabel(c.status), textAlign: TextAlign.right)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => "${d.day}-${d.month}-${d.year}";

  String _statusLabel(String s) {
    switch (s) {
      case 'PENDING':
        return "لم يبدأ التحليل";
      case 'IN_PROGRESS':
        return "جاري التحليل";
      case 'COMPLETED':
        return "مكتمل";
      default:
        return s;
    }
  }
}

Widget _StatusTabs(CasesState st, CasesVm vm) {
  Widget tab(String label, String value) {
    final selected = st.statusFilter == value;

    return GestureDetector(
      onTap: () => vm.setStatusFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? DesignTokens.brown : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: DesignTokens.brown,
          ),
        ),
      ),
    );
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      tab("الجميع", "ALL"),
      const SizedBox(width: 24),
      tab("الجديدة", "PENDING"),
      const SizedBox(width: 24),
      tab("قيد التحليل", "IN_PROGRESS"),
      const SizedBox(width: 24),
      tab("مكتملة", "COMPLETED"),
    ],
  );
}

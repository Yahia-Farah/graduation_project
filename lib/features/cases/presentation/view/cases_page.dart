import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../domain/case_model.dart';
import '../viewmodel/cases_vm.dart';
import 'case_details_page.dart';
import 'widgets/add_case_dialog.dart';

class CasesPage extends ConsumerWidget {
  const CasesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(casesVmProvider);
    final vm = ref.read(casesVmProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Controls Row
          Row(
            children: [
              // Search Box
              SizedBox(
                width: 300,
                child: TextBox(
                  placeholder: 'ابحث في القضايا',
                  suffix: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(FluentIcons.search, size: 14),
                  ),
                  onChanged: vm.setQuery,
                  onSubmitted: (_) => vm.search(),
                ),
              ),
              const SizedBox(width: 12),
              // Date Picker (Mock)
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: DesignTokens.brown.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: const [
                    Icon(
                      FluentIcons.calendar,
                      size: 14,
                      color: DesignTokens.brown,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Status Dropdown
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: DesignTokens.brown.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: const [
                    Text(
                      "الحالة: الكل",
                      style: TextStyle(color: DesignTokens.brown, fontSize: 13),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      FluentIcons.chevron_down,
                      size: 10,
                      color: DesignTokens.brown,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Add Case Button
              FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(DesignTokens.brown),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddCaseDialog(),
                  );
                },
                child: Row(
                  children: const [
                    Icon(FluentIcons.add, size: 12),
                    SizedBox(width: 8),
                    Text('إضافة قضية جديدة'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (st.error != null) ...[
            Text(
              st.error!,
              textAlign: TextAlign.right,
              style: const TextStyle(color: DesignTokens.red),
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
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, i) {
                        if (i == 0) return _TableHeader();
                        final c = st.items[i - 1];
                        return _CaseRow(
                          c: c,
                          onTap: () {
                            Navigator.of(context).push(
                              FluentPageRoute(
                                builder: (_) => CaseDetailsPage(caseId: c.id),
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
                style: const TextStyle(),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(FluentIcons.chevron_right),
                onPressed: st.pageInfo.hasNext ? vm.nextPage : null,
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
      decoration: const BoxDecoration(
        color: Color(0xFFE2C485), // beige matching the design
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: const [
          Expanded(
            flex: 2,
            child: Text(
              'رقم القضية',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'نوع القضية',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'تاريخ القضية',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'حالة القضية',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: DesignTokens.brown, width: 0.3),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text("#${c.caseNumber}", textAlign: TextAlign.center),
            ),
            Expanded(
              flex: 2,
              child: Text('جنايات', textAlign: TextAlign.center),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _formatDate(c.createdAt),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(_statusLabel(c.status), textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => "${d.day}-${d.month}-${d.year}";

  String _statusLabel(String s) {
    if (s == 'ASSIGNED' || s == 'COMPLETED') return 'تم التعيين';
    return 'لم يتم التعيين'; // Default to match mock
  }
}

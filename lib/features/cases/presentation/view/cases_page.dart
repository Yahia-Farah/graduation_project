import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../domain/case_model.dart';
import '../viewmodel/cases_vm.dart';
import 'widgets/add_case_dialog.dart';
import 'widgets/case_details_dialog.dart';
import '../../../../app/shared_widgets/custom_search_bar.dart';
import '../../../../app/shared_widgets/custom_date_picker.dart';
import '../../../../core/utils/arabic_numbers_extension.dart';

class CasesPage extends ConsumerStatefulWidget {
  const CasesPage({super.key});

  @override
  ConsumerState<CasesPage> createState() => _CasesPageState();
}

class _CasesPageState extends ConsumerState<CasesPage> {
  DateTime? _dateFilter;

  @override
  void initState() {
    super.initState();
    _dateFilter = ref.read(casesVmProvider).dateFilter;
  }

  @override
  Widget build(BuildContext context) {
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
                width: 600,
                child: CustomSearchBar(
                  placeholder: 'ابحث في القضايا',
                  prefix: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconButton(
                      icon: const Icon(FluentIcons.search, size: 14),
                      onPressed: () => vm.search(),
                    ),
                  ),
                  suffix: CustomDatePicker(
                    borderless: true,
                    iconSize: 18,
                    selectedDate: _dateFilter,
                    onDateChanged: (v) {
                      setState(() {
                        _dateFilter = v;
                        vm.setDateFilter(v);
                      });
                    },
                  ),
                  onChanged: vm.setQuery,
                  onSubmitted: (_) => vm.search(),
                ),
              ),
              const Spacer(),

              // Status Dropdown
              ComboBox<String>(
                value: st.statusFilter,
                items: const [
                  ComboBoxItem(value: 'ALL', child: Text('الحالة: الكل')),
                  ComboBoxItem(value: 'PENDING', child: Text('قيد الانتظار')),
                  ComboBoxItem(value: 'ASSIGNED', child: Text('تم التعيين')),
                  ComboBoxItem(
                    value: 'IN_PROGRESS',
                    child: Text('قيد التنفيذ'),
                  ),
                  ComboBoxItem(value: 'COMPLETED', child: Text('مكتملة')),
                ],
                onChanged: (v) {
                  if (v != null) vm.setStatusFilter(v);
                },
              ),
              const SizedBox(width: 12),
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

          const SizedBox(height: 12),

          // Pagination (مبدئي)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(FluentIcons.chevron_right),
                onPressed: st.pageInfo.hasPrevious ? vm.prevPage : null,
              ),
              const SizedBox(width: 12),
              Text(
                "${st.pageInfo.currentPage + 1} / ${st.pageInfo.totalPages}".toArabicNumbers(),
                style: const TextStyle(),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(FluentIcons.chevron_left),
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
              child: Text("#${c.caseNumber}".toArabicNumbers(), textAlign: TextAlign.center),
            ),
            Expanded(
              flex: 2,
              child: Text(
                c.courtRuling.isNotEmpty ? c.courtRuling : 'غير محدد',
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _formatDate(c.createdAt).toArabicNumbers(),
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
    switch (s.toUpperCase()) {
      case 'PENDING':
        return 'قيد الانتظار';
      case 'ASSIGNED':
        return 'تم التعيين';
      case 'IN_PROGRESS':
        return 'قيد التنفيذ';
      case 'COMPLETED':
        return 'مكتملة';
      case 'CLOSED':
        return 'مغلقة';
      case 'REJECTED':
        return 'مرفوضة';
      case 'ACCEPTED':
        return 'مقبولة';
      default:
        return s.isNotEmpty ? s : 'غير محدد';
    }
  }
}


import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../domain/case_model.dart';
import '../viewmodel/cases_vm.dart';
import 'widgets/add_case_dialog.dart';
import 'widgets/case_details_dialog.dart';

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
                width: 600,
                child: TextBox(
                  decoration: WidgetStateProperty.all(BoxDecoration(
                    border:BoxBorder.all(color: DesignTokens.brown)
                  )),
                  suffix: _CustomDatePicker(
                    selectedDate: st.dateFilter,
                    onDateChanged: vm.setDateFilter,
                  ),

                  placeholder: 'ابحث في القضايا',
                  prefix: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconButton(
                      icon: const Icon(FluentIcons.search, size: 14),
                      onPressed: () => vm.search(),
                    ),
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
                "${st.pageInfo.currentPage + 1} / ${st.pageInfo.totalPages}",
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
              child: Text("#${c.caseNumber}", textAlign: TextAlign.center),
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

class _CustomDatePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateChanged;

  const _CustomDatePicker({
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<_CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<_CustomDatePicker> {
  final _flyoutController = FlyoutController();

  @override
  void dispose() {
    _flyoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FlyoutTarget(
          controller: _flyoutController,
          child: Button(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(
                    color: DesignTokens.brown,
                  ),
                ),
              ),
            ),
            onPressed: () {
              _flyoutController.showFlyout(
                builder: (context) {
                  return FlyoutContent(
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      width: 320,
                      height: 350,
                      child: SfDateRangePicker(
                        view: DateRangePickerView.month,
                        selectionMode: DateRangePickerSelectionMode.single,
                        initialSelectedDate: widget.selectedDate,
                        todayHighlightColor: DesignTokens.brown,
                        selectionColor: DesignTokens.brown,
                        monthCellStyle: DateRangePickerMonthCellStyle(
                          todayTextStyle: const TextStyle(
                            color: DesignTokens.brown,
                            fontWeight: FontWeight.bold,
                          ),
                          textStyle: TextStyle(
                            color: DesignTokens.brown.withValues(alpha: 0.8),
                          ),
                        ),
                        headerStyle: const DateRangePickerHeaderStyle(
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(
                            color: DesignTokens.brown,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onSelectionChanged: (args) {
                          if (args.value is DateTime) {
                            widget.onDateChanged(args.value);
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
            child: const Icon(
              FluentIcons.calendar,
              size: 18,
              color: DesignTokens.brown,
            ),
          ),
        ),
        if (widget.selectedDate != null) ...[
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(FluentIcons.clear, size: 12),
            onPressed: () => widget.onDateChanged(null),
          ),
        ],
      ],
    );
  }
}

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../domain/access_request_entity.dart';
import '../viewmodel/access_requests_viewmodel.dart';
import '../../../../app/shared_widgets/custom_search_bar.dart';
import '../../../../app/shared_widgets/custom_date_picker.dart';
import 'package:graduation_project/core/utils/arabic_numbers_extension.dart';

class AccessRequestsPage extends ConsumerStatefulWidget {
  const AccessRequestsPage({super.key});

  @override
  ConsumerState<AccessRequestsPage> createState() => _AccessRequestsPageState();
}

class _AccessRequestsPageState extends ConsumerState<AccessRequestsPage> {
  int _selectedTabIndex = 0; // 0: Pending, 1: Accepted, 2: Rejected
  String _searchQuery = '';
  DateTime? _dateFilter;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tabs
          Row(
            children: [
              _buildTab('قيد الانتظار', 0),
              const SizedBox(width: 32),
              _buildTab('الطلبات المقبولة', 1),
              const SizedBox(width: 32),
              _buildTab('الطلبات المرفوضة', 2),
            ],
          ),
          Container(
            height: 1,
            color: DesignTokens.brown.withValues(alpha: 0.2),
            margin: const EdgeInsets.only(bottom: 16),
          ),

          // Controls Row
          Row(
            children: [
              // Search Box
              Expanded(
                child: CustomSearchBar(
                  placeholder: _selectedTabIndex == 0
                      ? 'ابحث في الطلبات'
                      : (_selectedTabIndex == 1
                            ? 'ابحث في الطلبات المقبولة'
                            : 'ابحث في الطلبات المرفوضة'),
                  prefix: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(FluentIcons.search, size: 14),
                  ),
                  suffix: CustomDatePicker(
                    borderless: true,
                    selectedDate: _dateFilter,
                    onDateChanged: (v) {
                      setState(() {
                        _dateFilter = v;
                      });
                    },
                  ),
                  onChanged: (v) {
                    setState(() {
                      _searchQuery = v;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DesignTokens.brown.withValues(alpha: 0.2),
                ),
              ),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedTabIndex == index) return;
        setState(() => _selectedTabIndex = index);

        String newStatus;
        if (index == 0) {
          newStatus = 'PENDING';
        } else if (index == 1) {
          newStatus = 'APPROVED';
        } else {
          newStatus = 'REJECTED';
        }
        ref.read(accessRequestsViewModelProvider.notifier).changeTab(newStatus);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? DesignTokens.brown : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? DesignTokens.brown : DesignTokens.gray,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final asyncRequests = ref.watch(accessRequestsViewModelProvider);

    return asyncRequests.when(
      data: (requests) {
        var filteredRequests = requests;
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          filteredRequests = filteredRequests
              .where(
                (r) =>
                    r.lawyerName.toLowerCase().contains(q) ||
                    r.caseNumber.toLowerCase().contains(q) ||
                    r.requestId.toLowerCase().contains(q),
              )
              .toList();
        }

        if (_dateFilter != null) {
          final d = _dateFilter!;
          filteredRequests = filteredRequests.where((r) {
            if (r.requestedAt == null) return false;
            return r.requestedAt!.year == d.year &&
                r.requestedAt!.month == d.month &&
                r.requestedAt!.day == d.day;
          }).toList();
        }

        if (filteredRequests.isEmpty) {
          return const Center(child: Text('لا توجد طلبات تطابق البحث'));
        }

        if (_selectedTabIndex == 0) {
          return _buildPendingRequests(filteredRequests);
        } else if (_selectedTabIndex == 1) {
          return _buildResolvedRequests(filteredRequests, isAccepted: true);
        } else {
          return _buildResolvedRequests(filteredRequests, isAccepted: false);
        }
      },
      loading: () => const Center(child: ProgressRing()),
      error: (e, st) => Center(child: Text(('خطأ: $e').toArabicNumbers())),
    );
  }

  Widget _buildPendingRequests(List<AccessRequestEntity> requests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table Header
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFE2C485), // Beige matching the design
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: const [
              Expanded(
                flex: 2,
                child: Text(
                  'رقم الطلب',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'اسم المحامي',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
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
                  'تاريخ الطلب',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'الاجراء',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        // Table Rows
        Expanded(
          child: ListView.builder(
            itemCount: requests.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final request = requests[index];
              final dateStr = request.requestedAt != null
                  ? DateFormat('yyyy-MM-dd').format(request.requestedAt!)
                  : '-';

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: DesignTokens.brown.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        request.requestId.length > 8 ? request.requestId.substring(0, 8) : request.requestId,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        request.lawyerName.isNotEmpty
                            ? request.lawyerName
                            : 'غير معروف',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        request.caseNumber,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(dateStr, textAlign: TextAlign.center),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Accept Button
                          FilledButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                const Color(0xFF4A6B3A), // Greenish
                              ),
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                              ),
                            ),
                            onPressed: () {
                              ref
                                  .read(
                                    accessRequestsViewModelProvider.notifier,
                                  )
                                  .approveRequest(request.requestId);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(FluentIcons.check_mark, size: 12),
                                SizedBox(width: 6),
                                Text('قبول'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Reject Button
                          FilledButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                const Color(0xFF9E4226), // Reddish brown
                              ),
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                              ),
                            ),
                            onPressed: () {
                              ref
                                  .read(
                                    accessRequestsViewModelProvider.notifier,
                                  )
                                  .rejectRequest(request.requestId);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(FluentIcons.cancel, size: 12),
                                SizedBox(width: 6),
                                Text('رفض'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResolvedRequests(
    List<AccessRequestEntity> requests, {
    required bool isAccepted,
  }) {
    return ListView.builder(
      itemCount: requests.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final request = requests[index];
        final dateStr = request.requestedAt != null
            ? DateFormat('yyyy-MM-dd').format(request.requestedAt!)
            : '-';
        final reqId = request.requestId.length > 8
            ? request.requestId.substring(0, 8)
            : request.requestId;

        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: DesignTokens.brown.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Row(
            children: [
              // Icon
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isAccepted ? Colors.green : Colors.red,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: Icon(
                  isAccepted ? FluentIcons.check_mark : FluentIcons.cancel,
                  size: 14,
                  color: isAccepted ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              // Text
              Text(
                isAccepted
                    ? 'تم قبول طلب رقم $reqId - المحامي/${request.lawyerName} - القضية رقم ${request.caseNumber}'
                    : 'تم رفض طلب رقم $reqId - المحامي/${request.lawyerName} - القضية رقم ${request.caseNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Date
              Text(dateStr, style: const TextStyle(color: DesignTokens.gray)),
            ],
          ),
        );
      },
    );
  }
}


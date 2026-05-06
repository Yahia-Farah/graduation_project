import 'package:fluent_ui/fluent_ui.dart';

import '../../../../app/theme/design_tokens.dart';

class AccessRequestsPage extends StatefulWidget {
  const AccessRequestsPage({super.key});

  @override
  State<AccessRequestsPage> createState() => _AccessRequestsPageState();
}

class _AccessRequestsPageState extends State<AccessRequestsPage> {
  int _selectedTabIndex = 0; // 0: Pending, 1: Accepted, 2: Rejected

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
              SizedBox(
                width: 300,
                child: TextBox(
                  placeholder: _selectedTabIndex == 0
                      ? 'ابحث في الطلبات'
                      : (_selectedTabIndex == 1
                            ? 'ابحث في الطلبات المقبولة'
                            : 'ابحث في الطلبات المرفوضة'),
                  suffix: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(FluentIcons.search, size: 14),
                  ),
                ),
              ),
              const Spacer(),
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
                      color: DesignTokens.gray,
                    ),
                  ],
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
        setState(() {
          _selectedTabIndex = index;
        });
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
    if (_selectedTabIndex == 0) {
      return _buildPendingRequests();
    } else if (_selectedTabIndex == 1) {
      return _buildResolvedRequests(isAccepted: true);
    } else {
      return _buildResolvedRequests(isAccepted: false);
    }
  }

  Widget _buildPendingRequests() {
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
            itemCount: 8,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
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
                    const Expanded(
                      flex: 2,
                      child: Text('#3287', textAlign: TextAlign.center),
                    ),
                    const Expanded(
                      flex: 2,
                      child: Text(
                        'برعي عبدالحميد',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: Text('#34627', textAlign: TextAlign.center),
                    ),
                    const Expanded(
                      flex: 2,
                      child: Text('25-1-2026', textAlign: TextAlign.center),
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
                            onPressed: () {},
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
                            onPressed: () {},
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

  Widget _buildResolvedRequests({required bool isAccepted}) {
    return ListView.builder(
      itemCount: 8,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
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
                    ? 'تم قبول طلب رقم 3476 - المحامي/برعي عبدالحميد - القضية رقم 26483'
                    : 'تم رفض طلب رقم 3476 - المحامي/برعي عبدالحميد - القضية رقم 26483',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Date
              const Text(
                '22-1-2026',
                style: TextStyle(color: DesignTokens.gray),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/design_tokens.dart';
import '../../cases/domain/case_model.dart';
import '../../cases/presentation/viewmodel/cases_vm.dart';
import '../../cases/presentation/view/widgets/case_details_dialog.dart';
import 'viewmodel/lawyer_dashboard_vm.dart';

class LawyerDashboardPage extends ConsumerStatefulWidget {
  const LawyerDashboardPage({super.key});

  @override
  ConsumerState<LawyerDashboardPage> createState() => _LawyerDashboardPageState();
}

class _LawyerDashboardPageState extends ConsumerState<LawyerDashboardPage> {
  final TextEditingController _caseNumberController = TextEditingController();

  @override
  void dispose() {
    _caseNumberController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    final caseNumber = _caseNumberController.text.trim();
    ref.read(lawyerDashboardVmProvider.notifier).requestAccess(caseNumber);
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(casesVmProvider);
    final vmState = ref.watch(lawyerDashboardVmProvider);

    ref.listen<LawyerDashboardState>(lawyerDashboardVmProvider, (previous, next) {
      if (next.requestSuccessMessage != null && (previous?.requestSuccessMessage != next.requestSuccessMessage)) {
        _showSuccessDialog(next.requestSuccessMessage!);
        _caseNumberController.clear();
      }
      if (next.requestError != null && (previous?.requestError != next.requestError)) {
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: const Text('خطأ'),
            content: Text(next.requestError!),
            severity: InfoBarSeverity.error,
            onClose: close,
          ),
        );
        ref.read(lawyerDashboardVmProvider.notifier).clearMessages();
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section: Send Access Request
          Container(
            decoration: BoxDecoration(
              color: DesignTokens.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: DesignTokens.brown.withValues(alpha: 0.3)),
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(FluentIcons.send, size: 16.sp, color: DesignTokens.brown),
                    SizedBox(width: 8.w),
                    Text(
                      'ارسال طلب وصول إلى قضية',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.brown,
                      ),
                    ),
                    const Spacer(),
                    Icon(FluentIcons.info, size: 14.sp, color: DesignTokens.gray),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: TextBox(
                        controller: _caseNumberController,
                        placeholder: 'ادخل رقم القضية',
                        suffixMode: OverlayVisibilityMode.always,
                        suffix: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Icon(FluentIcons.search, size: 14.sp, color: DesignTokens.gray),
                        ),
                        decoration: WidgetStateProperty.all(BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: DesignTokens.brown.withValues(alpha: 0.3)),
                          color: Colors.white,
                        )),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Button(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(DesignTokens.brown),
                        padding: WidgetStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 32.w, vertical: 8.h),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                      onPressed: vmState.isRequestingAccess ? null : _submitRequest,
                      child: vmState.isRequestingAccess
                          ? const ProgressRing(strokeWidth: 2)
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'ارسال الطلب',
                                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                                ),
                                SizedBox(width: 8.w),
                                Icon(FluentIcons.send, size: 14.sp, color: Colors.white),
                              ],
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),

          // Section: Current Cases
          if (st.items.isNotEmpty || st.loading) ...[
            Text(
              'القضايا الحالية',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: DesignTokens.brown,
              ),
            ),
            SizedBox(height: 12.h),
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
                          _CasesTableHeader(),
                          Expanded(
                            child: ListView.separated(
                              itemCount: st.items.length,
                              separatorBuilder: (_, _) => Container(
                                height: 1.h,
                                color: DesignTokens.brown.withValues(alpha: 0.2),
                              ),
                              itemBuilder: (context, i) {
                                final c = st.items[i];
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
                        ],
                      ),
              ),
            ),
            SizedBox(height: 24.h),
          ],

          // Section: Sent Requests (Empty state since no GET API exists)
          Text(
            'الطلبات المرسلة',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: DesignTokens.brown,
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DesignTokens.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: DesignTokens.lightGray),
              ),
              child: Center(
                child: Text(
                  'لم يتم إرسال طلبات وصول من هذا المستخدم بعد',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: DesignTokens.brown,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تأكيد طلب القضية',
                style: TextStyle(color: DesignTokens.brown, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(FluentIcons.cancel, color: DesignTokens.brown),
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(lawyerDashboardVmProvider.notifier).clearMessages();
                },
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: 16.sp, color: DesignTokens.brown),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

class _CasesTableHeader extends StatelessWidget {
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
          Expanded(
            flex: 2,
            child: Text(
              'رقم القضية',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'نوع القضية',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'تاريخ الحصول على القضية',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'الاجراء',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
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
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "#${c.caseNumber}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              c.courtRuling.isNotEmpty ? c.courtRuling : 'جنايات', // Mocking case type for visual
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(c.createdAt),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Button(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(DesignTokens.brown),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  onPressed: onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FluentIcons.view, size: 12.sp, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        'عرض',
                        style: TextStyle(color: Colors.white, fontSize: 11.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => "${d.day}-${d.month}-${d.year}";
}

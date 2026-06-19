import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/design_tokens.dart';
import '../../../../users/presentation/viewmodel/judges_viewmodel.dart';
import '../../../../users/presentation/viewmodel/lawyers_viewmodel.dart';
import '../../../cases_providers.dart';
import '../../viewmodel/cases_vm.dart';
import 'package:graduation_project/core/utils/arabic_numbers_extension.dart';


class AddCaseDialog extends ConsumerStatefulWidget {
  const AddCaseDialog({super.key});

  @override
  ConsumerState<AddCaseDialog> createState() => _AddCaseDialogState();
}

class _AddCaseDialogState extends ConsumerState<AddCaseDialog> {
  final _caseNumberCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _selectedJudgeId;
  String? _selectedLawyerId;
  String? _selectedCourtRuling;

  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _caseNumberCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_caseNumberCtrl.text.trim().isEmpty ||
        _titleCtrl.text.trim().isEmpty ||
        _selectedCourtRuling == null) {
      setState(() {
        _errorMsg = 'يرجى تعبئة الحقول الأساسية المطلوبة.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final repo = ref.read(casesRepoProvider);
      await repo.createCase({
        "caseNumber": _caseNumberCtrl.text.trim(),
        "title": _titleCtrl.text.trim(),
        "description": _descCtrl.text.trim(),
        "status": "PENDING",
        "judgeId": (_selectedJudgeId == null || _selectedJudgeId!.isEmpty) ? null : _selectedJudgeId,
        "lawyerId": (_selectedLawyerId == null || _selectedLawyerId!.isEmpty) ? null : _selectedLawyerId,
        "courtRuling": _selectedCourtRuling,
      });

      if (!mounted) return;
      ref.invalidate(casesVmProvider);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMsg = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final judgesState = ref.watch(judgesViewModelProvider);
    final lawyersState = ref.watch(lawyersViewModelProvider);

    return Center(
      child: Container(
        width: 700.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F6F0), // beige background
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: DesignTokens.brown),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close button (Left)
                  Container(
                    margin: EdgeInsets.only(top: 8.h),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: DesignTokens.brown),
                    ),
                    child: IconButton(
                      icon: Icon(
                        FluentIcons.cancel,
                        size: 12.sp,
                        color: DesignTokens.brown,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Spacer(),
                  // Title (Right)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'نموذج إضافة قضية جديدة',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.brown,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'يرجى ملء جميع التفاصيل التالية لإنشاء قضية جديدة',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: DesignTokens.gray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Divider
            Container(height: 1, color: DesignTokens.brown),

            if (_errorMsg != null)
              Padding(
                padding: EdgeInsets.all(16.w),
                child: InfoBar(
                  title: const Text('خطأ'),
                  content: Text(_errorMsg!),
                  severity: InfoBarSeverity.error,
                  onClose: () => setState(() => _errorMsg = null),
                ),
              ),

            // Content
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column: تعيين الأطراف
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'تعيين الأطراف',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: DesignTokens.brown,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // Judge
                        _buildDropdown<String>(
                          placeholder: 'اسم القاضي المعين له القضية',
                          value: _selectedJudgeId,
                          items: [
                            const ComboBoxItem<String>(value: '', child: Text('بدون')),
                            ...?(judgesState.valueOrNull?.map((j) => ComboBoxItem<String>(
                                  value: j.id,
                                  child: Text(('${j.firstName} ${j.lastName}').toArabicNumbers()),
                                ))),
                          ],
                          onChanged: (v) => setState(() => _selectedJudgeId = v),
                          isLoading: judgesState.isLoading,
                        ),
                        SizedBox(height: 16.h),
                        // Lawyer
                        _buildDropdown<String>(
                          placeholder: 'المحامي',
                          value: _selectedLawyerId,
                          items: [
                            const ComboBoxItem<String>(value: '', child: Text('بدون')),
                            ...?(lawyersState.valueOrNull?.map((l) => ComboBoxItem<String>(
                                  value: l.id,
                                  child: Text(('${l.firstName} ${l.lastName}').toArabicNumbers()),
                                ))),
                          ],
                          onChanged: (v) => setState(() => _selectedLawyerId = v),
                          isLoading: lawyersState.isLoading,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 32.w),
                  // Right column: بيانات القضية
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'بيانات القضية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: DesignTokens.brown,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildInputField('رقم القضية', _caseNumberCtrl),
                        SizedBox(height: 16.h),
                        _buildInputField('عنوان القضية', _titleCtrl),
                        SizedBox(height: 16.h),
                        _buildDropdown<String>(
                          placeholder: 'نوع القضية',
                          value: _selectedCourtRuling,
                          items: ['المخالفات', 'الجنح', 'الجنايات']
                              .map((r) => ComboBoxItem<String>(value: r, child: Text(r)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedCourtRuling = v),
                          isLoading: false,
                        ),
                        SizedBox(height: 16.h),
                        _buildInputField('وصف القضية', _descCtrl, maxLines: 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Divider
            Container(height: 1, color: DesignTokens.brown),

            // Action Button
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(DesignTokens.brown),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 48.w, vertical: 12.h),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const ProgressRing(activeColor: Colors.white)
                      : Text(
                          'إضافة القضية',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String placeholder, TextEditingController controller, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9F6),
        border: Border.all(color: DesignTokens.brown.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextBox(
        controller: controller,
        placeholder: placeholder,
        textAlign: TextAlign.right,
        maxLines: maxLines,
        highlightColor: Colors.transparent,
        unfocusedColor: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        style: TextStyle(fontSize: 14.sp, color: DesignTokens.brown),
        placeholderStyle: TextStyle(fontSize: 14.sp, color: DesignTokens.gray),
        decoration: WidgetStateProperty.all(
          const BoxDecoration(
            color: Colors.transparent,
            border: Border.fromBorderSide(
              BorderSide(color: Colors.transparent, width: 0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String placeholder,
    required T? value,
    required List<ComboBoxItem<T>> items,
    required ValueChanged<T?> onChanged,
    required bool isLoading,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9F6),
        border: Border.all(color: DesignTokens.brown.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: ProgressRing(value: 20),
            )
          : ComboBox<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              placeholder: Text(
                placeholder,
                style: TextStyle(fontSize: 14.sp, color: DesignTokens.gray),
              ),
              isExpanded: true,
            ),
    );
  }
}

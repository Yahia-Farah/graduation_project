import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/design_tokens.dart';
import '../../../../../core/utils/arabic_numbers_extension.dart';
import '../../../../ai_analysis/presentation/view/ai_analysis_result_page.dart';
import '../../../../ai_analysis/presentation/viewmodel/ai_analysis_vm.dart';
import '../../../domain/case_model.dart';
import '../../viewmodel/cases_vm.dart';
import '../../viewmodel/judge_cases_vm.dart';
import '../../../cases_providers.dart';
import '../../../../users/presentation/viewmodel/judges_viewmodel.dart';
import '../../../../auth/presentation/viewmodel/auth_session.dart';

import '../case_files_page.dart';class CaseDetailsDialog extends ConsumerStatefulWidget {
  final CaseModel c;
  const CaseDetailsDialog({super.key, required this.c});

  @override
  ConsumerState<CaseDetailsDialog> createState() => _CaseDetailsDialogState();
}

class _CaseDetailsDialogState extends ConsumerState<CaseDetailsDialog> {
  String? _selectedJudgeId;
  bool _isSaving = false;
  bool _isFetchingAnalysis = false;

  String _formatDate(DateTime d) => "${d.day}-${d.month}-${d.year}";

  Future<void> _saveAssignments() async {
    if (_selectedJudgeId == null) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(casesRepoProvider);
      if (_selectedJudgeId != null && _selectedJudgeId!.isNotEmpty) {
        await repo.assignUser(widget.c.id, _selectedJudgeId!);
      }
      ref.invalidate(casesVmProvider);
      ref.invalidate(judgeCasesVmProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: const Text('خطأ'),
            content: Text(('حدث خطأ أثناء التحديث: $e').toArabicNumbers()),
            severity: InfoBarSeverity.error,
            action: IconButton(
              icon: const Icon(FluentIcons.clear),
              onPressed: close,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnassignedJudge = widget.c.judgeName == null;
    final authState = ref.watch(authSessionProvider);
    final isJudge = authState.role?.toUpperCase() == 'JUDGE';

    return Center(
      child: Container(
        width: 600.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F6F0), // match the beige background in image
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
                children: [
                  // Close button (Left)
                  Container(
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
                  Text(
                    'تفاصيل القضية',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.brown,
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Container(height: 1, color: DesignTokens.brown),

            // Content
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column: الاطراف المعينة
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'الاطراف المعينة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: DesignTokens.brown,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildInfoBox('المحامي: ${widget.c.lawyerName ?? 'غير معين'}'),
                        SizedBox(height: 12.h),
                        if (!isJudge) _buildJudgeSelection(),
                        if (isJudge) _buildInfoBox('القاضي: ${widget.c.judgeName ?? 'غير معين'}'),
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
                        _buildInfoBox('رقم القضية: #${widget.c.caseNumber}'),
                        SizedBox(height: 12.h),
                        _buildInfoBox('نوع القضية: ${widget.c.courtRuling.isNotEmpty ? widget.c.courtRuling : 'غير محدد'}'),
                        SizedBox(height: 12.h),
                        _buildInfoBox(
                          'تاريخ تسجيل القضية: ${_formatDate(widget.c.createdAt)}',
                          icon: FluentIcons.calendar,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Divider
            Container(height: 1, color: DesignTokens.brown),

            // Action Buttons
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasUnassignedJudge && !isJudge)
                      Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: FilledButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(DesignTokens.brown),
                            padding: WidgetStateProperty.all(
                              EdgeInsets.symmetric(horizontal: 48.w, vertical: 10.h),
                            ),
                          ),
                          onPressed: _isSaving ? null : _saveAssignments,
                          child: _isSaving
                              ? const ProgressRing(strokeWidth: 3)
                              : Text(
                                  'حفظ التعيينات',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    if (!hasUnassignedJudge || isJudge)
                      Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: FilledButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(DesignTokens.brown),
                            padding: WidgetStateProperty.all(
                              EdgeInsets.symmetric(horizontal: 48.w, vertical: 10.h),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              FluentPageRoute(
                                builder: (context) => CaseFilesPage(caseModel: widget.c),
                              ),
                            );
                          },
                          child: Text(
                            'عرض الملفات',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (isJudge)
                      Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: FilledButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(const Color(0xFFE2C485)),
                            padding: WidgetStateProperty.all(
                              EdgeInsets.symmetric(horizontal: 48.w, vertical: 10.h),
                            ),
                          ),
                          onPressed: _isFetchingAnalysis ? null : () async {
                            if (widget.c.status.toUpperCase() == 'COMPLETED') {
                               setState(() => _isFetchingAnalysis = true);
                               try {
                                 await ref.read(aiAnalysisVmProvider.notifier).fetchSavedResult(widget.c.id);
                                 if (!context.mounted) return;
                                 Navigator.of(context).pop();
                                 Navigator.of(context).push(FluentPageRoute(
                                   builder: (context) => const AiAnalysisResultPage(),
                                 ));
                               } catch (e) {
                                 if (!context.mounted) return;
                                 setState(() => _isFetchingAnalysis = false);
                                 displayInfoBar(
                                   context,
                                   builder: (context, close) => InfoBar(
                                     title: const Text('خطأ'),
                                     content: Text(('تعذر تحميل نتيجة التحليل: ${e.toString().replaceFirst('Exception: ', '')}').toArabicNumbers()),
                                     severity: InfoBarSeverity.error,
                                     onClose: close,
                                   ),
                                 );
                               }
                            } else {
                               Navigator.of(context).pop();
                               ref.read(aiAnalysisVmProvider.notifier).startAnalysis(widget.c.id, widget.c.caseNumber);
                            }
                          },
                          child: _isFetchingAnalysis 
                              ? const SizedBox(width: 16, height: 16, child: ProgressRing(strokeWidth: 2))
                              : Text(
                                  widget.c.status.toUpperCase() == 'COMPLETED' ? 'عرض التحليل' : 'حلل الآن',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: DesignTokens.brown,
                                  ),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJudgeSelection() {
    if (widget.c.judgeName != null) {
      return _buildInfoBox('القاضي: ${widget.c.judgeName}');
    }

    final judgesState = ref.watch(judgesViewModelProvider);
    if (judgesState.isLoading) {
      return const ProgressRing();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9F6),
        border: Border.all(color: DesignTokens.brown.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ComboBox<String>(
        placeholder: Text(
          'اختر قاضياً',
          style: TextStyle(color: DesignTokens.brown, fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        value: _selectedJudgeId,
        items: judgesState.valueOrNull?.map((j) => ComboBoxItem<String>(
              value: j.id,
              child: Text('${j.firstName} ${j.lastName}', style: TextStyle(color: DesignTokens.brown)),
            )).toList() ?? [],
        onChanged: (v) => setState(() => _selectedJudgeId = v),
        isExpanded: true,
      ),
    );
  }

  Widget _buildInfoBox(String text, {IconData? icon}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9F6),
        border: Border.all(color: DesignTokens.brown.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (icon != null)
            Icon(icon, size: 14.sp, color: DesignTokens.brown),
          if (icon == null) const SizedBox(),
          Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14.sp,
              color: DesignTokens.brown,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../domain/ai_analysis_model.dart';
import '../viewmodel/ai_analysis_vm.dart';

class AiAnalysisResultPage extends ConsumerWidget {
  const AiAnalysisResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiAnalysisVmProvider);
    final result = aiState.viewingResult;

    if (result == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Text(
            'لا توجد نتائج تحليل للعرض',
            style: TextStyle(fontSize: 18.sp, color: DesignTokens.gray),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Header
          Row(
            children: [
              Icon(FluentIcons.branch_fork, size: 24.sp, color: DesignTokens.brown),
              SizedBox(width: 12.w),
              Text(
                'نتائج تحليل القضية #${result.caseNumber}',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.brown,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (result.processedAt != null)
            Text(
              'تم التحليل في: ${result.processedAt}',
              style: TextStyle(fontSize: 12.sp, color: DesignTokens.gray),
            ),
          SizedBox(height: 24.h),

          // Case Summary
          if (result.caseSummary != null)
            _buildSection(
              title: 'ملخص القضية',
              icon: FluentIcons.info,
              child: _CaseSummarySection(summary: result.caseSummary!),
            ),

          // Suggested Verdict
          if (result.caseSummary?.suggestedVerdict != null)
            _buildSection(
              title: 'الحكم المقترح',
              icon: FluentIcons.decision_solid,
              child: _SuggestedVerdictSection(
                  verdict: result.caseSummary!.suggestedVerdict!),
            ),

          // Defendants
          if (result.defendants.isNotEmpty)
            _buildSection(
              title: 'المتهمون (${result.defendants.length})',
              icon: FluentIcons.people,
              child: _DefendantsSection(defendants: result.defendants),
            ),

          // Charges
          if (result.charges.isNotEmpty)
            _buildSection(
              title: 'التهم (${result.charges.length})',
              icon: FluentIcons.list,
              child: _ChargesSection(charges: result.charges),
            ),

          // Incidents
          if (result.incidents.isNotEmpty)
            _buildSection(
              title: 'الوقائع (${result.incidents.length})',
              icon: FluentIcons.event_date,
              child: _IncidentsSection(incidents: result.incidents),
            ),

          // Evidence
          if (result.evidences.isNotEmpty)
            _buildSection(
              title: 'الأدلة (${result.evidences.length})',
              icon: FluentIcons.search,
              child: _EvidenceSection(evidences: result.evidences),
            ),

          // Witness Statements
          if (result.witnessStatements.isNotEmpty)
            _buildSection(
              title: 'شهادات الشهود (${result.witnessStatements.length})',
              icon: FluentIcons.contact,
              child: _WitnessSection(statements: result.witnessStatements),
            ),

          // Confessions
          if (result.confessions.isNotEmpty)
            _buildSection(
              title: 'الاعترافات (${result.confessions.length})',
              icon: FluentIcons.chat,
              child: _ConfessionsSection(confessions: result.confessions),
            ),

          // Lab Reports
          if (result.labReports.isNotEmpty)
            _buildSection(
              title: 'تقارير المعمل (${result.labReports.length})',
              icon: FluentIcons.test_case,
              child: _LabReportsSection(reports: result.labReports),
            ),

          // Criminal Proceedings
          if (result.criminalProceedings.isNotEmpty)
            _buildSection(
              title: 'الإجراءات الجنائية (${result.criminalProceedings.length})',
              icon: FluentIcons.processing,
              child: _ProceedingsSection(proceedings: result.criminalProceedings),
            ),

          // Defense Documents
          if (result.defenseDocuments.isNotEmpty)
            _buildSection(
              title: 'مستندات الدفاع (${result.defenseDocuments.length})',
              icon: FluentIcons.document_set,
              child: _DefenseSection(documents: result.defenseDocuments),
            ),

          // Procedural Audit
          if (result.proceduralAudit != null)
            _buildSection(
              title: 'المراجعة الإجرائية',
              icon: FluentIcons.shield,
              child: _ProceduralAuditSection(audit: result.proceduralAudit!),
            ),

          // Processing Errors
          if (result.processingErrors.isNotEmpty)
            _buildSection(
              title: 'أخطاء المعالجة',
              icon: FluentIcons.warning,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: result.processingErrors
                    .map((e) => Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: Text('• $e',
                              style: const TextStyle(color: DesignTokens.red)),
                        ))
                    .toList(),
              ),
            ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Expander(
        initiallyExpanded: true,
        header: Row(
          children: [
            Icon(icon, size: 18.sp, color: DesignTokens.brown),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: DesignTokens.brown,
              ),
            ),
          ],
        ),
        content: child,
      ),
    );
  }
}

// ─── Section Widgets ──────────────────────────────────────────────────

class _CaseSummarySection extends StatelessWidget {
  final CaseSummary summary;
  const _CaseSummarySection({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow('المحكمة', summary.court),
        _InfoRow('درجة المحكمة', summary.courtLevel),
        _InfoRow('الاختصاص', summary.jurisdiction),
        _InfoRow('تاريخ الإيداع', summary.filingDate),
        _InfoRow('اسم النيابة', summary.prosecutorName),
        _InfoRow('عدد المتهمين', summary.defendantCount.toString()),
        _InfoRow('عدد التهم', summary.chargeCount.toString()),
        _InfoRow('مخالفات إجرائية',
            summary.hasProceduralViolations ? 'نعم' : 'لا'),
      ],
    );
  }
}

class _SuggestedVerdictSection extends StatelessWidget {
  final SuggestedVerdict verdict;
  const _SuggestedVerdictSection({required this.verdict});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow('الحكم', verdict.verdict),
        _InfoRow('العقوبة المقترحة', verdict.recommendedPenalty),
        _InfoRow('نسبة الثقة', '${(verdict.confidenceScore * 100).toStringAsFixed(1)}%'),
        if (verdict.operativeText.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text('النص التنفيذي:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
          SizedBox(height: 4.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: DesignTokens.beige.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(verdict.operativeText, style: TextStyle(fontSize: 13.sp)),
          ),
        ],
        if (verdict.perChargeRulings.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Text('أحكام التهم:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
          ...verdict.perChargeRulings.map((r) => Container(
                margin: EdgeInsets.only(top: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  border: Border.all(color: DesignTokens.lightGray),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow('التهمة', r.chargeDescription),
                    _InfoRow('الحكم', r.verdict),
                    _InfoRow('العقوبة', r.penalty),
                    _InfoRow('التسبيب', r.reasoning),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}

class _DefendantsSection extends StatelessWidget {
  final List<Defendant> defendants;
  const _DefendantsSection({required this.defendants});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: defendants.map((d) => Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: DesignTokens.lightGray),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(children: [
              _InfoRow('الاسم', d.name),
              if (d.alias.isNotEmpty) _InfoRow('الشهرة', d.alias),
              _InfoRow('الجنس', d.gender),
              _InfoRow('العمر', d.age.toString()),
              _InfoRow('المهنة', d.occupation),
              _InfoRow('الجنسية', d.nationality),
              if (d.address.isNotEmpty) _InfoRow('العنوان', d.address),
              if (d.nationalId.isNotEmpty) _InfoRow('الرقم القومي', d.nationalId),
              if (d.complicityRole.isNotEmpty) _InfoRow('الدور', d.complicityRole),
            ]),
          )).toList(),
    );
  }
}

class _ChargesSection extends StatelessWidget {
  final List<Charge> charges;
  const _ChargesSection({required this.charges});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: charges.asMap().entries.map((e) {
        final i = e.key + 1;
        final c = e.value;
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            border: Border.all(color: DesignTokens.lightGray),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(children: [
            _InfoRow('التهمة $i', c.description),
            _InfoRow('القانون', c.lawCode),
            _InfoRow('رقم المادة', c.articleNumber),
            _InfoRow('نوع الجريمة', c.incidentType),
            _InfoRow('التصنيف', c.chargeClassification),
            _InfoRow('شروع', c.attemptFlag ? 'نعم' : 'لا'),
            if (c.chargeDate.isNotEmpty) _InfoRow('التاريخ', c.chargeDate),
            if (c.chargeLocation.isNotEmpty) _InfoRow('المكان', c.chargeLocation),
            if (c.linkedDefendantNames.isNotEmpty)
              _InfoRow('المتهمون', c.linkedDefendantNames.join('، ')),
          ]),
        );
      }).toList(),
    );
  }
}

class _IncidentsSection extends StatelessWidget {
  final List<Incident> incidents;
  const _IncidentsSection({required this.incidents});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: incidents.map((i) => Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: DesignTokens.lightGray),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(children: [
              _InfoRow('النوع', i.incidentType),
              _InfoRow('التاريخ', i.incidentDate),
              _InfoRow('المكان', i.incidentLocation),
              _InfoRow('الوصف', i.incidentDescription),
              if (i.perpetratorNames.isNotEmpty)
                _InfoRow('الجناة', i.perpetratorNames.join('، ')),
              if (i.victimNames.isNotEmpty)
                _InfoRow('الضحايا', i.victimNames.join('، ')),
            ]),
          )).toList(),
    );
  }
}

class _EvidenceSection extends StatelessWidget {
  final List<Evidence> evidences;
  const _EvidenceSection({required this.evidences});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: evidences.map((e) => Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: DesignTokens.lightGray),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(children: [
              _InfoRow('الوصف', e.description),
              _InfoRow('النوع', e.evidenceType),
              if (e.detailedText.isNotEmpty) _InfoRow('التفاصيل', e.detailedText),
              if (e.seizureDate.isNotEmpty) _InfoRow('تاريخ الضبط', e.seizureDate),
              if (e.seizureLocation.isNotEmpty) _InfoRow('مكان الضبط', e.seizureLocation),
              if (e.seizedBy.isNotEmpty) _InfoRow('بواسطة', e.seizedBy),
              _InfoRow('أمر ضبط', e.seizureWarrantPresent ? 'نعم' : 'لا'),
              if (e.linkedDefendantName.isNotEmpty)
                _InfoRow('المتهم المرتبط', e.linkedDefendantName),
            ]),
          )).toList(),
    );
  }
}

class _WitnessSection extends StatelessWidget {
  final List<WitnessStatement> statements;
  const _WitnessSection({required this.statements});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: statements.map((w) => Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: DesignTokens.lightGray),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(children: [
              _InfoRow('الاسم', w.witnessName),
              _InfoRow('النوع', w.witnessType),
              _InfoRow('المهنة', w.occupation),
              if (w.relationToDefendant.isNotEmpty)
                _InfoRow('العلاقة بالمتهم', w.relationToDefendant),
              _InfoRow('ملخص الشهادة', w.statementSummary),
              _InfoRow('أدى اليمين', w.wasSwornIn ? 'نعم' : 'لا'),
              _InfoRow('حاضر في المشهد', w.presenceAtScene ? 'نعم' : 'لا'),
            ]),
          )).toList(),
    );
  }
}

class _ConfessionsSection extends StatelessWidget {
  final List<Confession> confessions;
  const _ConfessionsSection({required this.confessions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: confessions.map((c) => Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: DesignTokens.lightGray),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _InfoRow('المتهم', c.defendantName),
              _InfoRow('المرحلة', c.confessionStage),
              _InfoRow('التاريخ', c.confessionDate),
              _InfoRow('حضور محامي', c.legalCounselPresent ? 'نعم' : 'لا'),
              _InfoRow('إكراه مدعى', c.coercionClaimed ? 'نعم' : 'لا'),
              _InfoRow('النص', c.text),
              if (c.keyAdmissions.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text('الاعترافات الرئيسية:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                ...c.keyAdmissions.map((a) => Text('  • $a', style: TextStyle(fontSize: 12.sp))),
              ],
            ]),
          )).toList(),
    );
  }
}

class _LabReportsSection extends StatelessWidget {
  final List<LabReport> reports;
  const _LabReportsSection({required this.reports});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: reports.map((r) => Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: DesignTokens.lightGray),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(children: [
              _InfoRow('نوع التقرير', r.reportType),
              _InfoRow('رقم التقرير', r.reportNumber),
              _InfoRow('النتيجة', r.result),
              _InfoRow('تاريخ الفحص', r.examinationDate),
              _InfoRow('الفاحص', r.examinerName),
              if (r.linkedDefendantName.isNotEmpty)
                _InfoRow('المتهم المرتبط', r.linkedDefendantName),
            ]),
          )).toList(),
    );
  }
}

class _ProceedingsSection extends StatelessWidget {
  final List<CriminalProceeding> proceedings;
  const _ProceedingsSection({required this.proceedings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: proceedings.map((p) => Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: DesignTokens.lightGray),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(children: [
              _InfoRow('نوع الإجراء', p.procedureType),
              _InfoRow('الوصف', p.description),
              _InfoRow('أمر قضائي', p.warrantPresent ? 'نعم' : 'لا'),
              _InfoRow('الضابط المنفذ', p.conductingOfficer),
            ]),
          )).toList(),
    );
  }
}

class _DefenseSection extends StatelessWidget {
  final List<DefenseDocument> documents;
  const _DefenseSection({required this.documents});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: documents.map((d) => Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: DesignTokens.lightGray),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _InfoRow('مقدم من', d.submittedBy),
              _InfoRow('المتهم', d.defendantName),
              _InfoRow('دفع بوجود أليبي', d.alibiClaimed ? 'نعم' : 'لا'),
              if (d.alibiDescription.isNotEmpty) _InfoRow('وصف الأليبي', d.alibiDescription),
              if (d.formalDefenses.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text('الدفوع الشكلية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                ...d.formalDefenses.map((f) => Text('  • $f', style: TextStyle(fontSize: 12.sp))),
              ],
              if (d.substantiveDefenses.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text('الدفوع الموضوعية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                ...d.substantiveDefenses.map((s) => Text('  • $s', style: TextStyle(fontSize: 12.sp))),
              ],
            ]),
          )).toList(),
    );
  }
}

class _ProceduralAuditSection extends StatelessWidget {
  final ProceduralAudit audit;
  const _ProceduralAuditSection({required this.audit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow('التقييم العام', audit.overallAssessment),
        if (audit.criticalNullities.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text('بطلان جوهري:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: DesignTokens.red)),
          ...audit.criticalNullities.map((n) => Text('  • $n', style: TextStyle(fontSize: 12.sp, color: DesignTokens.red))),
        ],
        if (audit.violations.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Text('المخالفات:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
          ...audit.violations.map((v) => Container(
                margin: EdgeInsets.only(top: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  border: Border.all(color: DesignTokens.red.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(children: [
                  _InfoRow('نوع الإجراء', v.procedureType),
                  _InfoRow('المشكلة', v.issueDescription),
                  _InfoRow('نوع البطلان', v.nullityType),
                  _InfoRow('أثر البطلان', v.nullityEffect),
                  _InfoRow('المادة', v.articleBasis),
                  _InfoRow('الضابط', v.conductingOfficer),
                ]),
              )),
        ],
        if (audit.kgArticlesUsed.isNotEmpty) ...[
          SizedBox(height: 8.h),
          _InfoRow('مواد قانونية مستخدمة', audit.kgArticlesUsed.join('، ')),
        ],
      ],
    );
  }
}

// ─── Shared Helper ────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: DesignTokens.brown,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, color: DesignTokens.black),
            ),
          ),
        ],
      ),
    );
  }
}

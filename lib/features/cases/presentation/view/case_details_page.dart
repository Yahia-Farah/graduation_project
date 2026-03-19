import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../../auth/presentation/viewmodel/auth_session.dart';
import '../../domain/case_details_model.dart';
import '../../domain/case_status.dart';
import '../viewmodel/case_details_vm.dart';

class CaseDetailsPage extends ConsumerStatefulWidget {
  const CaseDetailsPage({super.key, required this.caseId});

  final String caseId;

  @override
  ConsumerState<CaseDetailsPage> createState() => _CaseDetailsPageState();
}

class _CaseDetailsPageState extends ConsumerState<CaseDetailsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(caseDetailsVmProvider.notifier).load(widget.caseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    final role = (session.role ?? '').toUpperCase();
    final canEditStatus = role == 'ADMIN' || role == 'JUDGE';
    final st = ref.watch(caseDetailsVmProvider);

    if (st.loading) {
      return const Center(child: ProgressRing());
    }

    if (st.error != null) {
      return Center(child: Text(st.error!));
    }

    final data = st.data!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ScaffoldPage(
        padding: EdgeInsets.zero,
        content: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoCard(caseItem: data),

              const SizedBox(height: 16),

              // ✅ هنا مكان الجزء بتاع تغيير الحالة
              if (canEditStatus) ...[
                _StatusEditor(
                  currentStatus: data.status,
                  loading: st.updatingStatus,
                  error: st.updateError,
                  success: st.updateSuccess,
                  onChanged: (newStatus) {
                    ref
                        .read(caseDetailsVmProvider.notifier)
                        .changeStatus(
                          caseId: widget.caseId,
                          newStatus: newStatus,
                        );
                  },
                ),
                const SizedBox(height: 16),
              ],

              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _FilesCard(
                        title: 'ملفات القضية',
                        files: data.caseFiles,
                        emptyText: 'لا توجد ملفات بعد',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _FilesCard(
                        title: 'ملفات الدفاع',
                        files: data.defenseFiles,
                        emptyText: 'لا توجد ملفات بعد',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.caseItem});

  final CaseDetailsModel caseItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DesignTokens.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل القضية #${caseItem.caseNumber}',
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: DesignTokens.brown,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            caseItem.title,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: DesignTokens.brown,
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              _KV('الحالة', _statusLabel(caseItem.status)),
              _KV('القاضي', caseItem.judgeName ?? '—'),
              _KV('المحامي', caseItem.lawyerName ?? '—'),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            caseItem.description.isEmpty ? '—' : caseItem.description,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Amiri',
              color: DesignTokens.black,
              height: 1.4,
            ),
          ),

          if ((caseItem.courtRuling ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'حكم المحكمة:',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontWeight: FontWeight.w700,
                color: DesignTokens.gray,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              caseItem.courtRuling!.trim(),
              style: const TextStyle(fontFamily: 'Amiri'),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'PENDING':
        return "لم يبدأ التحليل";
      case 'IN_PROGRESS':
        return "قيد التحليل";
      case 'COMPLETED':
        return "مكتمل";
      default:
        return s;
    }
  }
}

class _KV extends StatelessWidget {
  const _KV(this.k, this.v);

  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Row(
        children: [
          Text(
            '$k: ',
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontWeight: FontWeight.w700,
              color: DesignTokens.gray,
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                fontFamily: 'Amiri',
                color: DesignTokens.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilesCard extends StatelessWidget {
  const _FilesCard({
    required this.title,
    required this.emptyText,
    required this.files,
  });

  final String title;
  final String emptyText;
  final List<CaseFile> files;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DesignTokens.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: DesignTokens.brown,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: files.isEmpty
                ? Center(
                    child: Text(
                      emptyText,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        color: DesignTokens.gray,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: files.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      final f = files[i];
                      return ListTile(
                        title: Text(
                          f.fileName,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontFamily: 'Amiri'),
                        ),
                        subtitle: Text(f.fileType, textAlign: TextAlign.right),
                        onPressed: () {
                          // TODO: فتح الرابط (هنعملها بعدين بـ url_launcher)
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusEditor extends StatelessWidget {
  const _StatusEditor({
    required this.currentStatus,
    required this.loading,
    required this.error,
    required this.success,
    required this.onChanged,
  });

  final String currentStatus; // "PENDING" ...
  final bool loading;
  final String? error;
  final bool success;
  final ValueChanged<CaseStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = parseCaseStatus(currentStatus);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignTokens.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'تغيير الحالة:',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),

              ComboBox<CaseStatus>(
                value: current,
                items: CaseStatus.values
                    .map(
                      (s) => ComboBoxItem(
                        value: s,
                        child: Text(
                          caseStatusLabel(s),
                          style: const TextStyle(fontFamily: 'Amiri'),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: loading
                    ? null
                    : (v) {
                        if (v != null) onChanged(v);
                      },
              ),

              const SizedBox(width: 10),
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: ProgressRing(strokeWidth: 2),
                ),
            ],
          ),

          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error!,
              style: const TextStyle(
                fontFamily: 'Amiri',
                color: DesignTokens.red,
              ),
            ),
          ],

          if (success) ...[
            const SizedBox(height: 8),
            const Text(
              'تم تحديث الحالة بنجاح',
              style: TextStyle(fontFamily: 'Amiri', color: DesignTokens.green),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../domain/case_details_model.dart';
import '../viewmodel/case_details_vm.dart';

class CaseDetailsPage extends ConsumerStatefulWidget {
  const CaseDetailsPage({super.key, required this.caseId});

  final String caseId;

  @override
  ConsumerState<CaseDetailsPage> createState() => _CaseDetailsPageState();
}

class _CaseDetailsPageState extends ConsumerState<CaseDetailsPage> {
  int _aiTabIndex = 0; // 0 for Summary (الملخص), 1 for Analysis (التحليل)
  bool _isAnalyzing = false;
  bool _isAnalyzed = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(caseDetailsVmProvider.notifier).load(widget.caseId);
    });
  }

  void _startAnalysis() {
    setState(() => _isAnalyzing = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _isAnalyzed = true;
          _aiTabIndex = 1; // Auto switch to analysis
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(caseDetailsVmProvider);

    if (st.loading) {
      return const ScaffoldPage(content: Center(child: ProgressRing()));
    }
    if (st.error != null) {
      return ScaffoldPage(content: Center(child: Text(st.error!)));
    }
    final data = st.data!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ScaffoldPage(
        padding: EdgeInsets.zero,
        content: Column(
          children: [
            // Top Bar
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              color: DesignTokens
                  .beige, // using beige as placeholder for yellow top bar
              child: Row(
                children: [
                  Text(
                    'قضية رقم #\${data.caseNumber} - جنايات',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.brown,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      FluentIcons.chevron_right,
                      size: 20,
                      color: DesignTokens.brown,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Layout (3 columns)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Right Column (AI Assistant) - 25% width
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: DesignTokens.beige, width: 2),
                        ),
                      ),
                      child: _buildAIAssistantColumn(),
                    ),
                  ),

                  // Middle Column (PDF Viewer) - 50% width
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: DesignTokens.beige, width: 2),
                        ),
                      ),
                      child: _buildPDFViewerColumn(),
                    ),
                  ),

                  // Left (actually Right in RTL) Column (Files Explorer) - 25% width
                  Expanded(flex: 2, child: _buildFilesColumn(data)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAssistantColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: DesignTokens.brown,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: const Text(
            'مساعد الذكاء الاصطناعي',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        // Tabs
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _aiTabIndex = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _aiTabIndex == 0
                            ? DesignTokens.brown
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.read, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        'الملخص',
                        style: TextStyle(
                          fontWeight: _aiTabIndex == 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _aiTabIndex == 0
                              ? DesignTokens.brown
                              : DesignTokens.gray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _aiTabIndex = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _aiTabIndex == 1
                            ? DesignTokens.brown
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.set_action, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        'التحليل',
                        style: TextStyle(
                          fontWeight: _aiTabIndex == 1
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _aiTabIndex == 1
                              ? DesignTokens.brown
                              : DesignTokens.gray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Content Area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildAIAssistantContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildAIAssistantContent() {
    if (_isAnalyzing) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProgressRing(),
          SizedBox(height: 16),
          Text(
            'جاري تحليل القضية ©',
            style: TextStyle(color: DesignTokens.brown),
          ),
        ],
      );
    }

    if (!_isAnalyzed) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'لم يتم إجراء تحليل لهذه القضية بعد، اضغط على الزر لبدء التحليل',
            textAlign: TextAlign.center,
            style: TextStyle(color: DesignTokens.brown),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(DesignTokens.brown),
            ),
            onPressed: _startAnalysis,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('حلل الآن', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(FluentIcons.share, size: 14),
              ],
            ),
          ),
        ],
      );
    }

    if (_aiTabIndex == 0) {
      return ListView(
        children: [
          _buildAISection('٠١. أطراف الدعوى:', [
            'المدعي: النيابة العامة المصرية.',
            'المدعى عليه: (م. أ. ح) - طبيب بشري.',
            'التهمة: التزوير في محررات رسمية واستعمالها.',
          ]),
          _buildAISection('٠٢. ملخص الوقائع:', [
            'تتلخص الواقعة في قيام المتهم باستغلال وظيفته العمومية بإحدى المستشفيات الحكومية...',
            'وذلك على خلاف الحقيقة، بقصد استخدام هذه التقارير...',
          ]),
          _buildAISection('٠٣. الأسانيد القانونية (مواد القانون):', [
            'المادة ٢١١ من قانون العقوبات: بشأن تزوير المحررات...',
            'المادة ٢١٤ من قانون العقوبات: بشأن استعمال المحرر المزور...',
          ]),
        ],
      );
    } else {
      return ListView(
        children: [
          _buildAISection('القرار المقترح: [إدانة]', []),
          _buildAISection(
            'العقوبة المقترحة: السجن المشدد لمدة 5 سنوات + العزل من الوظيفة',
            [],
          ),
          _buildAISection('٠١. الحيثيات: اتساق الأدلة المادية', [
            'استنتاج الذكاء الاصطناعي: كشف التحليل الجنائي الرقمي...',
            'السند القانوني: هذا الاستنتاج يستوفي الركن المادي...',
          ]),
          _buildAISection('٠٢. الحيثيات: تحليل القصد الجنائي', [
            'استنتاج الذكاء الاصطناعي: أظهر تحليل السجلات...',
          ]),
        ],
      );
    }
  }

  Widget _buildAISection(String title, List<String> bulletPoints) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: DesignTokens.brown,
            ),
          ),
          const SizedBox(height: 8),
          ...bulletPoints.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0, right: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: DesignTokens.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 14,
                        color: DesignTokens.brown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPDFViewerColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: DesignTokens.brown,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              const Icon(FluentIcons.remove, size: 12, color: Colors.white),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                color: DesignTokens.beige,
                child: const Text(
                  '100%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.brown,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(FluentIcons.add, size: 12, color: Colors.white),
              const Spacer(),
              const Text(
                '2',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '/',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                color: DesignTokens.beige,
                child: const Text(
                  '1',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.brown,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'اسم الملف',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(FluentIcons.document, size: 14, color: Colors.white),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: DesignTokens.lightGray,
            alignment: Alignment.center,
            // Placeholder for PDF Viewer Map
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    FluentIcons.pdf,
                    size: 64,
                    color: DesignTokens.gray,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PDF Viewer Placeholder',
                    style: TextStyle(color: DesignTokens.gray, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilesColumn(CaseDetailsModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: DesignTokens.brown,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'جميع الملفات',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 8),
              Icon(FluentIcons.fabric_folder, color: Colors.white, size: 14),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildFolder(
                'ملفات القضية',
                data.caseFiles.map((e) => e.fileName).toList(),
              ),
              const SizedBox(height: 16),
              _buildFolder(
                'ملفات الدفاع',
                data.defenseFiles.map((e) => e.fileName).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFolder(String folderName, List<String> files) {
    // Basic tree view mock
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              FluentIcons.chevron_down,
              size: 10,
              color: DesignTokens.brown,
            ),
            const SizedBox(width: 8),
            Text(
              folderName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: DesignTokens.brown,
              ),
            ),
            const Spacer(),
            const Icon(
              FluentIcons.fabric_folder,
              size: 16,
              color: DesignTokens.brown,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...files.map(
          (file) => Padding(
            padding: const EdgeInsets.only(right: 24, bottom: 8),
            child: Row(
              children: [
                Text(file, style: const TextStyle(color: DesignTokens.brown)),
                const Spacer(),
                const Icon(
                  FluentIcons.page,
                  size: 14,
                  color: DesignTokens.brown,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

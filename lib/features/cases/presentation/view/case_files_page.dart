import 'package:file_picker/file_picker.dart' as fp;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../../../app/theme/design_tokens.dart';
import '../../../auth/presentation/viewmodel/auth_session.dart';
import '../../cases_providers.dart';
import '../../domain/case_model.dart';
import '../viewmodel/case_files_vm.dart';

class CaseFilesPage extends ConsumerStatefulWidget {
  final CaseModel caseModel;
  const CaseFilesPage({super.key, required this.caseModel});

  @override
  ConsumerState<CaseFilesPage> createState() => _CaseFilesPageState();
}

class _CaseFilesPageState extends ConsumerState<CaseFilesPage> {
  String? previewingFileName;
  Uint8List? previewingFileBytes;
  bool isPreviewLoading = false;
  bool openedExternally = false;

  void _triggerUpload() async {
    final vm = ref.read(
      caseFilesViewModelProvider(widget.caseModel.id).notifier,
    );
    final result = await fp.FilePicker.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      vm.uploadFiles(result.files);
      if (previewingFileName != null) {
        _closePreview();
      }
    }
  }

  void _showPreview(String fileName) async {
    setState(() {
      previewingFileName = fileName;
      previewingFileBytes = null;
      isPreviewLoading = true;
      openedExternally = false;
    });

    try {
      final repo = ref.read(casesRepoProvider);
      final bytes = await repo.getFileBytes(widget.caseModel.id, fileName);
      if (mounted && previewingFileName == fileName) {
        final lowerName = fileName.toLowerCase();
        final isRenderable =
            lowerName.endsWith('.pdf') ||
            lowerName.endsWith('.png') ||
            lowerName.endsWith('.jpg') ||
            lowerName.endsWith('.jpeg');

        if (isRenderable) {
          setState(() {
            previewingFileBytes = Uint8List.fromList(bytes);
            isPreviewLoading = false;
          });
        } else {
          setState(() {
            previewingFileBytes = Uint8List.fromList(bytes);
            isPreviewLoading = false;
            openedExternally = true;
          });
          _saveToTempAndOpen(fileName, bytes);
        }
      }
    } catch (e) {
      if (mounted && previewingFileName == fileName) {
        setState(() {
          isPreviewLoading = false;
        });
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: const Text('خطأ'),
            content: Text('تعذر جلب الملف للمعاينة: $e'),
            severity: InfoBarSeverity.error,
            onClose: close,
          ),
        );
      }
    }
  }

  void _closePreview() {
    setState(() {
      previewingFileName = null;
      previewingFileBytes = null;
      isPreviewLoading = false;
    });
  }

  void _saveToTempAndOpen(String fileName, List<int> bytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) {
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: const Text('خطأ'),
            content: Text('تعذر فتح الملف الخارجي: $e'),
            severity: InfoBarSeverity.error,
            onClose: close,
          ),
        );
      }
    }
  }

  void _downloadCurrentPreview() async {
    if (previewingFileBytes == null || previewingFileName == null) return;

    try {
      final savedPath = await fp.FilePicker.saveFile(
        dialogTitle: 'حفظ الملف',
        fileName: previewingFileName,
        bytes: previewingFileBytes,
      );

      if (savedPath != null && mounted) {
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: const Text('نجاح'),
            content: Text('تم حفظ الملف بنجاح: $savedPath'),
            severity: InfoBarSeverity.success,
            onClose: close,
          ),
        );
        // Automatically open the file
        final url = Uri.file(savedPath);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      }
    } catch (e) {
      if (mounted) {
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: const Text('خطأ'),
            content: Text('تعذر تحميل الملف: $e'),
            severity: InfoBarSeverity.error,
            onClose: close,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(caseFilesViewModelProvider(widget.caseModel.id));
    final authState = ref.watch(authSessionProvider);
    final isJudge = authState.role?.toUpperCase() == 'JUDGE';

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: Container(
        height: 60.h,
        color: const Color(0xFFDEB878), // Golden color from design
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Row(
          children: [
            // Upload button on far left
            if (!isJudge)
              FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                  ),
                ),
                onPressed: _triggerUpload,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FluentIcons.cloud_upload,
                      color: DesignTokens.brown,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'رفع ملفات',
                      style: TextStyle(
                        color: DesignTokens.brown,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            if (!isJudge) const Spacer(),
            if (isJudge) const Spacer(),
            Text(
              'قضية رقم #${widget.caseModel.caseNumber} - ${widget.caseModel.courtRuling.isNotEmpty ? widget.caseModel.courtRuling : "غير محدد"}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: DesignTokens.brown,
              ),
            ),
            SizedBox(width: 16.w),
            IconButton(
              icon: Icon(
                FluentIcons.chevron_right,
                size: 20.sp,
                color: DesignTokens.brown,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      content: Container(
        color: const Color(0xFFF7F5F0), // Light beige background
        padding: EdgeInsets.all(24.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left main section (Upload or Preview)
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: DesignTokens.brown.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: previewingFileName == null
                    ? EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w)
                    : EdgeInsets.zero,
                child: previewingFileName != null
                    ? _buildPreviewSection()
                    : (isJudge ? _buildEmptyPreviewSection() : _buildUploadSection(state)),
              ),
            ),
            SizedBox(width: 24.w),
            // Right Sidebar (Files List)
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: DesignTokens.brown.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 16.w,
                      ),
                      decoration: BoxDecoration(
                        color: DesignTokens.brown,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(7.r),
                          topRight: Radius.circular(7.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'الملفات',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            FluentIcons.list,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: state.isLoading && state.files.isEmpty
                          ? const Center(child: ProgressRing())
                          : ListView.builder(
                              padding: EdgeInsets.all(16.w),
                              itemCount: state.files.length,
                              itemBuilder: (context, index) {
                                return _buildFileItem(state.files[index]);
                              },
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

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Preview Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F6F0),
            border: Border(
              bottom: BorderSide(
                color: DesignTokens.brown.withValues(alpha: 0.2),
              ),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(7.r),
              topRight: Radius.circular(7.r),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(FluentIcons.cancel, color: Colors.red),
                onPressed: _closePreview,
              ),
              const Spacer(),
              Text(
                previewingFileName ?? '',
                style: TextStyle(
                  color: DesignTokens.brown,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(FluentIcons.red_eye, color: DesignTokens.brown, size: 16.sp),
            ],
          ),
        ),
        // Preview Body
        Expanded(
          child: isPreviewLoading
              ? const Center(child: ProgressRing())
              : _buildFileViewer(),
        ),
      ],
    );
  }

  Widget _buildFileViewer() {
    if (previewingFileBytes == null) {
      return const Center(child: Text('لا يوجد محتوى لعرضه'));
    }

    if (openedExternally) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FluentIcons.open_in_new_window,
              size: 64.sp,
              color: DesignTokens.brown.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'تم فتح الملف في البرنامج الخارجي المناسب',
              style: TextStyle(fontSize: 16.sp, color: DesignTokens.brown),
            ),
            SizedBox(height: 8.h),
            Text(
              'إذا لم يفتح الملف، يمكنك تحميله يدوياً',
              style: TextStyle(
                fontSize: 12.sp,
                color: DesignTokens.brown.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      DesignTokens.brown,
                    ),
                  ),
                  onPressed: () => _saveToTempAndOpen(
                    previewingFileName!,
                    previewingFileBytes!,
                  ),
                  child: Text('إعادة الفتح'),
                ),
                SizedBox(width: 16.w),
                Button(
                  onPressed: _downloadCurrentPreview,
                  child: Text('حفظ الملف'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final lowerName = previewingFileName!.toLowerCase();

    if (lowerName.endsWith('.pdf')) {
      return SfPdfViewer.memory(previewingFileBytes!);
    } else if (lowerName.endsWith('.png') ||
        lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg')) {
      return InteractiveViewer(child: Image.memory(previewingFileBytes!));
    } else {
      // This case shouldn't be reached now, but kept as a fallback
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FluentIcons.page,
              size: 64.sp,
              color: DesignTokens.brown.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'لا يمكن معاينة هذا النوع من الملفات داخل التطبيق',
              style: TextStyle(fontSize: 16.sp, color: DesignTokens.brown),
            ),
            SizedBox(height: 8.h),
            Text(
              'يرجى تحميل الملف لفتحه بالبرنامج المناسب (مثل Word أو Excel)',
              style: TextStyle(
                fontSize: 12.sp,
                color: DesignTokens.brown.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 24.h),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(DesignTokens.brown),
              ),
              onPressed: _downloadCurrentPreview,
              child: Text('تحميل وفتح الملف'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildEmptyPreviewSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FluentIcons.document_search,
            size: 64.sp,
            color: DesignTokens.brown.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'اختر ملفاً من القائمة الجانبية للمعاينة',
            style: TextStyle(
              fontSize: 18.sp,
              color: DesignTokens.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(CaseFilesState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 40.h),
        Text(
          'رفع ملفات',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: DesignTokens.brown,
          ),
        ),
        SizedBox(height: 24.h),

        // Upload Box
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _triggerUpload,
            child: Container(
              width: 400.w,
              height: 100.h,
              decoration: BoxDecoration(
                border: Border.all(
                  color: DesignTokens.brown.withValues(alpha: 0.5),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'اسحب الملفات هنا',
                    style: TextStyle(
                      color: DesignTokens.brown.withValues(alpha: 0.7),
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    FluentIcons.cloud_upload,
                    color: DesignTokens.brown,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        FilledButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color(0xFFDEB878)),
            padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
            ),
          ),
          onPressed: _triggerUpload,
          child: Text(
            'اختر ملف',
            style: TextStyle(
              color: DesignTokens.brown,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),

        SizedBox(height: 40.h),
        // Upload Progress List
        if (state.uploadProgress.isNotEmpty)
          SizedBox(
            width: 400.w,
            child: Column(
              children: state.uploadProgress.entries.map((entry) {
                return _buildProgressItem(entry.key, entry.value);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressItem(String fileName, double progress) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(FluentIcons.delete, color: Colors.red.lightest),
            onPressed: () {},
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    color: DesignTokens.brown,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                ProgressBar(
                  value: progress * 100,
                  strokeWidth: 4.h,
                  backgroundColor: DesignTokens.brown.withValues(alpha: 0.2),
                  activeColor: DesignTokens.brown,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Icon(FluentIcons.page, color: DesignTokens.brown, size: 24.sp),
        ],
      ),
    );
  }

  Widget _buildFileItem(String fileName) {
    final isSelected = fileName == previewingFileName;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _showPreview(fileName);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF9F6F0) : Colors.transparent,
            borderRadius: BorderRadius.circular(6.r),
            border: isSelected
                ? Border.all(color: DesignTokens.brown.withValues(alpha: 0.2))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isSelected)
                Icon(
                  FluentIcons.red_eye,
                  color: DesignTokens.brown,
                  size: 16.sp,
                )
              else
                Icon(FluentIcons.check_mark, color: Colors.green, size: 16.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  fileName,
                  style: TextStyle(
                    color: DesignTokens.brown,
                    fontSize: 14.sp,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(FluentIcons.page, color: DesignTokens.brown, size: 16.sp),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../core/widgets/app_toast.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage>
    with SingleTickerProviderStateMixin {
  static const _allowedDomains = [
    'firebasestorage.googleapis.com',
    'storage.googleapis.com',
  ];

  static bool _isAllowedDomain(String host) {
    return _allowedDomains.any((d) => host == d || host.endsWith('.$d'));
  }

  TabController? _tabController;
  List<Map<String, dynamic>> _sections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDocumentsFromFirestore();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchDocumentsFromFirestore() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('document_library')
          .doc('customer_resources')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data['sections'] != null) {
          final sectionsList = data['sections'] as List<dynamic>;

          if (mounted) {
            setState(() {
              _sections = sectionsList
                  .map((e) => e as Map<String, dynamic>)
                  .toList();
              _tabController = TabController(
                length: _sections.length,
                vsync: this,
              );
              _isLoading = false;
            });
          }
          return;
        }
      }
    } catch (_) {
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openRemoteFile(Map<String, dynamic> docData) async {
    final fileName = docData['fileName'] as String? ?? 'document';
    final url = docData['url'] as String?;

    if (url == null || url.isEmpty) {
      if (mounted) {
        AppToast.show(context, message: 'Document link is missing', type: ToastType.error);
      }
      return;
    }

    // Validate URL scheme and domain allowlist
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || !_isAllowedDomain(uri.host)) {
      if (mounted) {
        AppToast.show(context, message: 'Invalid document URL', type: ToastType.error);
      }
      return;
    }

    AppToast.show(context, message: 'Downloading $fileName...', type: ToastType.info);

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<int> bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(bytes, flush: true);

        final result = await OpenFilex.open(tempFile.path);
        if (result.type != ResultType.done && mounted) {
          AppToast.show(context, message: 'Could not open file: ${result.message}', type: ToastType.error);
        }
      } else {
        if (mounted) {
          AppToast.show(context, message: 'Failed to download file', type: ToastType.error);
        }
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(context, message: 'Error occurred while opening the document', type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Downloads Center',
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: _sections.isEmpty
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
              indicatorColor: AppColors.primaryGreen,
              indicatorWeight: 2,
              labelColor: AppColors.primaryGreen,
              unselectedLabelColor: context.textSecondary,
              labelStyle: AppTypography.labelLarge,
                tabs: _sections.map((section) {
                  return Tab(text: section['title'] ?? 'Section');
                }).toList(),
              ),
      ),
      body: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.base),
              child: ShimmerList(itemCount: 5, itemHeight: 72),
            )
          : _sections.isEmpty
              ? const AppEmptyState(
                  icon: Icons.folder_open_rounded,
                  title: 'No documents available',
                  subtitle: 'Documents will appear here when uploaded.',
                )
              : TabBarView(
                  controller: _tabController,
                  children: _sections.map((section) {
                    final docs =
                        (section['documents'] as List<dynamic>?) ?? [];
                    return _buildRemoteFileList(
                      docs.map((e) => e as Map<String, dynamic>).toList(),
                    );
                  }).toList(),
                ),
    );
  }

  Widget _buildRemoteFileList(List<Map<String, dynamic>> docs) {
    if (docs.isEmpty) {
      return const AppEmptyState(
        icon: Icons.folder_open_rounded,
        title: 'No documents found',
        subtitle: 'No documents found in this section',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: docs.length,
      itemBuilder: (context, index) => _buildRemoteFileTile(docs[index]),
    );
  }

  Widget _buildRemoteFileTile(Map<String, dynamic> docData) {
    final fileName = docData['fileName'] as String? ?? 'document';
    final title = docData['title'] as String?;
    final fileSize = docData['fileSize'] as String?;

    if (fileName.isEmpty) return const SizedBox.shrink();

    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    final isWord = fileName.toLowerCase().endsWith('.docx') ||
        fileName.toLowerCase().endsWith('.doc');

    final Color fileColor =
        isPdf ? AppColors.error : (isWord ? AppColors.info : AppColors.accent);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.baseBr,
        border: Border.all(color: context.borderColor),
        boxShadow: context.cardShadow,
      ),
      child: ListTile(
        onTap: () => _openRemoteFile(docData),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: fileColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPdf
                ? Icons.picture_as_pdf_rounded
                : (isWord
                    ? Icons.description_rounded
                    : Icons.insert_drive_file_rounded),
            color: fileColor,
            size: 24,
          ),
        ),
        title: Text(
          title ?? fileName,
          style: AppTypography.titleSmall.copyWith(
            color: context.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              isPdf ? 'PDF' : (isWord ? 'Word' : 'File'),
              style: AppTypography.caption.copyWith(
                color: context.textTertiary,
              ),
            ),
            if (fileSize != null && fileSize.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: context.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                fileSize,
                style: AppTypography.caption.copyWith(
                  color: context.textTertiary,
                ),
              ),
            ],
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: context.textTertiary,
        ),
      ),
    );
  }
}

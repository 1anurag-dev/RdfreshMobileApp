import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
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
  TabController? _tabController;

  // -- COMMENTED OUT LOCAL LOGIC --
  /*
  late TabController _tabController;
  final Map<String, List<String>> _categories = {
    'Company Literature': [],
    'Expert Training': [],
    'Marketing Reviews': [],
    'Scientific Evidence': [],
  };
  */

  // New logic:
  List<Map<String, dynamic>> _sections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // -- COMMENTED OUT LOCAL LOGIC --
    // _tabController = TabController(length: 4, vsync: this);
    // _loadAssetManifest();

    // Trigger remote fetch
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
    } catch (e) {
      debugPrint('Error fetching documents from Firestore: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // -- COMMENTED OUT LOCAL LOGIC --
  /*
  Future<void> _loadAssetManifest() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final List<String> docPaths = manifest.listAssets();

      debugPrint('DEBUG: Total assets in manifest: ${docPaths.length}');

      for (var key in _categories.keys) {
        _categories[key]!.clear();
      }

      for (var path in docPaths) {
        if (!path.startsWith('assets/documents/')) continue;

        final lowerPath = path.toLowerCase();
        if (lowerPath.contains('rd_fresh_literature')) {
          _categories['Company Literature']!.add(path);
        } else if (lowerPath.contains('quiz')) {
          _categories['Expert Training']!.add(path);
        } else if (lowerPath.contains('google_review')) {
          _categories['Marketing Reviews']!.add(path);
        } else if (lowerPath.contains('scientific') ||
            lowerPath.contains('test_docs') ||
            lowerPath.contains('evidence')) {
          _categories['Scientific Evidence']!.add(path);
        }
      }
    } catch (e) {
      debugPrint('Error loading asset manifest: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  */

  // -- COMMENTED OUT LOCAL LOGIC --
  /*
  Future<void> _openFile(String assetPath) async {
    final fileName = assetPath.split('/').last;

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(child: Text('Opening $fileName...')),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      // 1. Get the bytes from assets
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List();

      // 2. Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');

      // 3. Write bytes to the temporary file
      await tempFile.writeAsBytes(bytes, flush: true);

      // 4. Open the file using the system's default app
      final result = await OpenFilex.open(tempFile.path);

      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open file: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error occurred while opening the file'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  */

  Future<void> _openRemoteFile(Map<String, dynamic> docData) async {
    final fileName = docData['fileName'] as String? ?? 'document';
    final url = docData['url'] as String?;

    if (url == null || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document link is missing'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(child: Text('Downloading $fileName...')),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 4),
      ),
    );

    try {
      // Download remote file to local temp dir before launching it
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<int> bytes = response.bodyBytes;

        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName');

        await tempFile.writeAsBytes(bytes, flush: true);

        // Open file explicitly
        final result = await OpenFilex.open(tempFile.path);

        if (result.type != ResultType.done) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open file: ${result.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to download file. Error code: ${response.statusCode}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening remote file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error occurred while opening the document'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          'Downloads Center',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: _sections.isEmpty
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primaryGreen,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primaryGreen,
                tabs: _sections.map((section) {
                  return Tab(text: section['title'] ?? 'Section');
                }).toList(),
              ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          : _sections.isEmpty
          ? const Center(
              child: Text(
                'No documents available',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: _sections.map((section) {
                final docs = (section['documents'] as List<dynamic>?) ?? [];
                return _buildRemoteFileList(
                  docs.map((e) => e as Map<String, dynamic>).toList(),
                );
              }).toList(),
            ),
    );
  }

  // -- COMMENTED OUT LOCAL LOGIC --
  /*
  Widget _buildFileList(List<String> files) {
    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No documents found in this section',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: files.length,
      itemBuilder: (context, index) => _buildFileTile(files[index]),
    );
  }

  Widget _buildFileTile(String path) {
    final fileName = path.split('/').last.replaceAll('%20', ' ');
    if (fileName.isEmpty) return const SizedBox.shrink();

    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    final isWord =
        fileName.toLowerCase().endsWith('.docx') ||
        fileName.toLowerCase().endsWith('.doc');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _openFile(path),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isPdf ? Colors.red : (isWord ? Colors.blue : Colors.orange))
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isPdf
                ? Icons.picture_as_pdf
                : (isWord ? Icons.description : Icons.insert_drive_file),
            color: isPdf ? Colors.red : (isWord ? Colors.blue : Colors.orange),
            size: 24,
          ),
        ),
        title: Text(
          fileName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          isPdf ? 'PDF Document' : (isWord ? 'Word Document' : 'File'),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
  */

  Widget _buildRemoteFileList(List<Map<String, dynamic>> docs) {
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No documents found in this section',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
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
    final isWord =
        fileName.toLowerCase().endsWith('.docx') ||
        fileName.toLowerCase().endsWith('.doc');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _openRemoteFile(docData),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isPdf ? Colors.red : (isWord ? Colors.blue : Colors.orange))
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isPdf
                ? Icons.picture_as_pdf
                : (isWord ? Icons.description : Icons.insert_drive_file),
            color: isPdf ? Colors.red : (isWord ? Colors.blue : Colors.orange),
            size: 24,
          ),
        ),
        title: Text(
          title ?? fileName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              isPdf ? 'PDF' : (isWord ? 'Word' : 'File'),
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            if (fileSize != null && fileSize.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                fileSize,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
}

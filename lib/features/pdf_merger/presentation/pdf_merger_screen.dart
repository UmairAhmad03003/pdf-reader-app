import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdftest/core/services/file_service.dart';
import 'package:pdftest/core/services/injection_container.dart';
import 'package:pdftest/presentation/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';
import 'package:pdftest/presentation/viewmodels/home_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class PdfMergerScreen extends ConsumerStatefulWidget {
  const PdfMergerScreen({super.key});

  @override
  ConsumerState<PdfMergerScreen> createState() => _PdfMergerScreenState();
}

class _PdfMergerScreenState extends ConsumerState<PdfMergerScreen> {
  final List<String> _selectedFiles = [];
  bool _isProcessing = false;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.paths.whereType<String>());
      });
    }
  }

  Future<void> _mergeFiles() async {
    if (_selectedFiles.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 2 PDF files')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final fileService = sl<FileService>();
      final mergedPath = await fileService.mergePdfs(_selectedFiles);
      ref.read(homeViewModelProvider.notifier).addRecentFile(mergedPath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDFs merged successfully!')),
        );
        context.pushReplacement('/reader', extra: mergedPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error merging PDFs: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Merge PDFs')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            PrimaryButton(
              text: 'Select PDF Files',
              onPressed: _pickFiles,
              icon: Icons.add,
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: _selectedFiles.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _selectedFiles.removeAt(oldIndex);
                    _selectedFiles.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final path = _selectedFiles[index];
                  return ListTile(
                    key: ValueKey(path),
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(p.basename(path)),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                      onPressed: () => setState(() => _selectedFiles.removeAt(index)),
                    ),
                  );
                },
              ),
            ),
            if (_isProcessing)
              const CircularProgressIndicator()
            else
              PrimaryButton(
                text: 'Merge Files',
                onPressed: _mergeFiles,
                icon: Icons.merge_type,
              ),
          ],
        ),
      ),
    );
  }
}

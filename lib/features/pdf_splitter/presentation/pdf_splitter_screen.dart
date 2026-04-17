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

class PdfSplitterScreen extends ConsumerStatefulWidget {
  const PdfSplitterScreen({super.key});

  @override
  ConsumerState<PdfSplitterScreen> createState() => _PdfSplitterScreenState();
}

class _PdfSplitterScreenState extends ConsumerState<PdfSplitterScreen> {
  String? _selectedPath;
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedPath = result.files.single.path;
      });
    }
  }

  Future<void> _splitPdf() async {
    if (_selectedPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file')),
      );
      return;
    }

    final start = int.tryParse(_startController.text);
    final end = int.tryParse(_endController.text);

    if (start == null || end == null || start <= 0 || end < start) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid page range')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final fileService = sl<FileService>();
      final splitPath = await fileService.splitPdf(_selectedPath!, start, end);
      ref.read(homeViewModelProvider.notifier).addRecentFile(splitPath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF split successfully!')),
        );
        context.pushReplacement('/reader', extra: splitPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error splitting PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Split PDF')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            PrimaryButton(
              text: _selectedPath == null ? 'Select PDF' : 'Change PDF',
              onPressed: _pickFile,
              icon: Icons.file_open,
            ),
            if (_selectedPath != null) ...[
              SizedBox(height: 16.h),
              Text('Selected: ${p.basename(_selectedPath!)}'),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startController,
                      decoration: const InputDecoration(labelText: 'Start Page'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextField(
                      controller: _endController,
                      decoration: const InputDecoration(labelText: 'End Page'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              if (_isProcessing)
                const CircularProgressIndicator()
              else
                PrimaryButton(
                  text: 'Split PDF',
                  onPressed: _splitPdf,
                  icon: Icons.call_split,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

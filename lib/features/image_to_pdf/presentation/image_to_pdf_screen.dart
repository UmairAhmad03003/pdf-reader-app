import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdftest/core/services/file_service.dart';
import 'package:pdftest/core/services/injection_container.dart';
import 'package:pdftest/presentation/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';
import 'package:pdftest/presentation/viewmodels/home_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class ImageToPdfScreen extends ConsumerStatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  ConsumerState<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends ConsumerState<ImageToPdfScreen> {
  final List<String> _selectedImages = [];
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages.addAll(images.map((e) => e.path));
      });
    }
  }

  Future<void> _convertToPdf() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final fileService = sl<FileService>();
      final pdfPath = await fileService.imagesToPdf(_selectedImages);
      ref.read(homeViewModelProvider.notifier).addRecentFile(pdfPath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF created successfully from images!')),
        );
        context.pushReplacement('/reader', extra: pdfPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Images to PDF')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            PrimaryButton(
              text: 'Select Images',
              onPressed: _pickImages,
              icon: Icons.add_a_photo,
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(File(_selectedImages[index]), fit: BoxFit.cover),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => setState(() => _selectedImages.removeAt(index)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (_isProcessing)
              const CircularProgressIndicator()
            else
              PrimaryButton(
                text: 'Convert to PDF',
                onPressed: _convertToPdf,
                icon: Icons.picture_as_pdf,
              ),
          ],
        ),
      ),
    );
  }
}

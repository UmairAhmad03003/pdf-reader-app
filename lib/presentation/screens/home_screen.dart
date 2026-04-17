import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdftest/core/services/file_service.dart';
import 'package:pdftest/core/services/injection_container.dart';
import 'package:pdftest/presentation/viewmodels/home_viewmodel.dart';
import 'package:pdftest/presentation/widgets/feature_tile.dart';
import 'package:pdftest/presentation/widgets/pdf_card.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentFiles = ref.watch(homeViewModelProvider);
    final fileService = sl<FileService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Master'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.2,
              children: [
                FeatureTile(
                  title: 'Open PDF',
                  icon: Icons.picture_as_pdf,
                  color: Colors.red,
                  onTap: () async {
                    if (await fileService.requestPermissions()) {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );
                      if (result != null) {
                        final path = result.files.single.path!;
                        ref.read(homeViewModelProvider.notifier).addRecentFile(path);
                        context.push('/reader', extra: path);
                      }
                    }
                  },
                ),
                FeatureTile(
                  title: 'Merge PDF',
                  icon: Icons.merge_type,
                  color: Colors.blue,
                  onTap: () => context.push('/merger'),
                ),
                FeatureTile(
                  title: 'Image to PDF',
                  icon: Icons.image,
                  color: Colors.green,
                  onTap: () => context.push('/image-to-pdf'),
                ),
                FeatureTile(
                  title: 'Split PDF',
                  icon: Icons.call_split,
                  color: Colors.orange,
                  onTap: () => context.push('/splitter'),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              'Recent Files',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            if (recentFiles.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40.h),
                  child: Text(
                    'No recent files found',
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentFiles.length,
                itemBuilder: (context, index) {
                  final path = recentFiles[index];
                  return PDFCard(
                    path: path,
                    onTap: () => context.push('/reader', extra: path),
                    onMorePressed: () => _showFileOptions(context, ref, path),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showFileOptions(BuildContext context, WidgetRef ref, String path) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Rename'),
            onTap: () {
              Navigator.pop(context);
              _showRenameDialog(context, ref, path);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteDialog(context, ref, path);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              Share.shareXFiles([XFile(path)]);
            },
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, String oldPath) {
    final controller = TextEditingController(text: p.basenameWithoutExtension(oldPath));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename PDF'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'File Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final newPath = await sl<FileService>().renameFile(oldPath, controller.text);
              ref.read(homeViewModelProvider.notifier).renameRecentFile(oldPath, newPath);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete PDF'),
        content: const Text('Are you sure you want to delete this file?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await sl<FileService>().deleteFile(path);
              ref.read(homeViewModelProvider.notifier).removeRecentFile(path);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

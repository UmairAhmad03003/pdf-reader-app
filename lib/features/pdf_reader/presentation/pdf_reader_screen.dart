import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdftest/core/services/file_service.dart';
import 'package:pdftest/core/services/injection_container.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:pdftest/presentation/viewmodels/home_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PdfReaderScreen extends ConsumerStatefulWidget {
  final String path;

  const PdfReaderScreen({super.key, required this.path});

  @override
  ConsumerState<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends ConsumerState<PdfReaderScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  PdfTextSearchResult? _searchResult;
  
  bool _isEditing = false;
  bool _isSearching = false;
  Uint8List? _pendingImage;
  String? _pendingText;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _showAddTextDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Text'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter text here'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _pendingText = controller.text;
                _pendingImage = null;
                _isEditing = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tap on PDF to place text')),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Search...', border: InputBorder.none),
              onSubmitted: (text) {
                setState(() {
                  _searchResult = _pdfViewerController.searchText(text);
                });
              },
            )
          : Text(widget.path.split('/').last),
        actions: [
          if (_isSearching) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => _searchResult?.previousInstance(),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => _searchResult?.nextInstance(),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchResult?.clear();
                  _pdfViewerController.clearSelection();
                });
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _isSearching = true),
            ),
            IconButton(
              icon: Icon(_isEditing ? Icons.edit_off : Icons.edit),
              onPressed: () => setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _pendingImage = null;
                  _pendingText = null;
                }
              }),
            ),
            if (_isEditing) ...[
              IconButton(
                icon: const Icon(Icons.text_fields),
                onPressed: _showAddTextDialog,
              ),
              IconButton(
                icon: const Icon(Icons.gesture),
                onPressed: () async {
                  final result = await context.push('/signature', extra: widget.path);
                  if (result != null && result is Uint8List) {
                    setState(() {
                      _pendingImage = result;
                      _pendingText = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tap on PDF to place signature')),
                    );
                  }
                },
              ),
            ],
            PopupMenuButton(
              onSelected: (value) {
                if (value == 'print') {
                  sl<FileService>().printPdf(widget.path);
                } else if (value == 'share') {
                  Share.shareXFiles([XFile(widget.path)]);
                } else if (value == 'bookmarks') {
                  _pdfViewerKey.currentState?.openBookmarkView();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'bookmarks', child: Text('Bookmarks')),
                const PopupMenuItem(value: 'print', child: Text('Print')),
                const PopupMenuItem(value: 'share', child: Text('Share')),
              ],
            ),
          ],
        ],
      ),
      body: GestureDetector(
        onTapUp: (details) async {
          if (_isEditing) {
            final fileService = sl<FileService>();
            String? editedPath;
            try {
              // Note: Converting global/local position to PDF coordinates
              // requires knowledge of the PDF page size and zoom. 
              // For now, we use a simplified approach as a placeholder.
              if (_pendingImage != null) {
                editedPath = await fileService.addImageToPdf(
                  widget.path,
                  _pendingImage!,
                  _pdfViewerController.pageNumber - 1,
                  details.localPosition,
                  const Size(100, 50),
                );
              } else if (_pendingText != null) {
                editedPath = await fileService.addTextToPdf(
                  widget.path,
                  _pendingText!,
                  _pdfViewerController.pageNumber - 1,
                  details.localPosition,
                );
              }

              if (editedPath != null) {
                ref.read(homeViewModelProvider.notifier).addRecentFile(editedPath);
                if (mounted) {
                  context.pushReplacement('/reader', extra: editedPath);
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error editing PDF: $e')),
                );
              }
            }
          }
        },
        child: SfPdfViewer.file(
          File(widget.path),
          key: _pdfViewerKey,
          controller: _pdfViewerController,
        ),
      ),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path/path.dart' as p;
import 'package:pdftest/core/constants/app_constants.dart';
import 'package:printing/printing.dart';

class FileService {
  Future<String> getAppDirectory() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Documents/${AppConstants.appFolder}');
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      return statuses[Permission.storage]!.isGranted;
    }
    return true;
  }

  Future<File> savePdf(Uint8List bytes, String fileName) async {
    final path = await getAppDirectory();
    final file = File(p.join(path, fileName));
    return await file.writeAsBytes(bytes);
  }

  Future<String> mergePdfs(List<String> paths) async {
    final PdfDocument document = PdfDocument();
    for (final path in paths) {
      final PdfDocument sourceDocument = PdfDocument(inputBytes: File(path).readAsBytesSync());
      for (int i = 0; i < sourceDocument.pages.count; i++) {
        document.pages.add().graphics.drawPdfTemplate(
          sourceDocument.pages[i].createTemplate(),
          const Offset(0, 0),
        );
      }
      sourceDocument.dispose();
    }
    
    final List<int> bytes = await document.save();
    document.dispose();
    
    final fileName = 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final savedFile = await savePdf(Uint8List.fromList(bytes), fileName);
    return savedFile.path;
  }

  Future<String> splitPdf(String path, int start, int end) async {
    final PdfDocument sourceDocument = PdfDocument(inputBytes: File(path).readAsBytesSync());
    final PdfDocument document = PdfDocument();
    
    for (int i = start - 1; i < end; i++) {
      document.pages.add().graphics.drawPdfTemplate(
        sourceDocument.pages[i].createTemplate(),
        const Offset(0, 0),
      );
    }
    
    final List<int> bytes = await document.save();
    document.dispose();
    sourceDocument.dispose();
    
    final fileName = 'split_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final savedFile = await savePdf(Uint8List.fromList(bytes), fileName);
    return savedFile.path;
  }

  Future<String> imagesToPdf(List<String> imagePaths) async {
    final PdfDocument document = PdfDocument();
    
    for (final path in imagePaths) {
      final PdfPage page = document.pages.add();
      final PdfBitmap image = PdfBitmap(File(path).readAsBytesSync());
      page.graphics.drawImage(image, Rect.fromLTWH(0, 0, page.getClientSize().width, page.getClientSize().height));
    }
    
    final List<int> bytes = await document.save();
    document.dispose();
    
    final fileName = 'images_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final savedFile = await savePdf(Uint8List.fromList(bytes), fileName);
    return savedFile.path;
  }

  Future<String> addImageToPdf(String pdfPath, Uint8List imageBytes, int pageIndex, Offset position, Size size) async {
    final PdfDocument document = PdfDocument(inputBytes: File(pdfPath).readAsBytesSync());
    final PdfPage page = document.pages[pageIndex];
    
    final PdfBitmap image = PdfBitmap(imageBytes);
    page.graphics.drawImage(
      image,
      Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
    );
    
    final List<int> bytes = await document.save();
    document.dispose();
    
    final fileName = 'edited_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final savedFile = await savePdf(Uint8List.fromList(bytes), fileName);
    return savedFile.path;
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<String> renameFile(String path, String newName) async {
    final file = File(path);
    final extension = p.extension(path);
    final newPath = p.join(p.dirname(path), '$newName$extension');
    final renamedFile = await file.rename(newPath);
    return renamedFile.path;
  }

  Future<String> addTextToPdf(String pdfPath, String text, int pageIndex, Offset position, {double fontSize = 12, Color color = Colors.black}) async {
    final PdfDocument document = PdfDocument(inputBytes: File(pdfPath).readAsBytesSync());
    final PdfPage page = document.pages[pageIndex];
    
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, fontSize);
    page.graphics.drawString(
      text,
      font,
      brush: PdfSolidBrush(PdfColor(color.red, color.green, color.blue)),
      bounds: Rect.fromLTWH(position.dx, position.dy, 0, 0),
    );
    
    final List<int> bytes = await document.save();
    document.dispose();
    
    final fileName = 'edited_text_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final savedFile = await savePdf(Uint8List.fromList(bytes), fileName);
    return savedFile.path;
  }

  Future<void> printPdf(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    await Printing.layoutPdf(onLayout: (format) => bytes);
  }
}

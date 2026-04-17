import 'dart:typed_data';
import 'package:flutter/material.dart';

abstract class PdfRepository {
  Future<String> mergePdfs(List<String> paths);
  Future<String> splitPdf(String path, int start, int end);
  Future<String> imagesToPdf(List<String> imagePaths);
  Future<String> addImageToPdf(String pdfPath, Uint8List imageBytes, int pageIndex, Offset position, Size size);
  Future<String> addTextToPdf(String pdfPath, String text, int pageIndex, Offset position);
  Future<void> printPdf(String path);
  Future<void> deleteFile(String path);
  Future<String> renameFile(String path, String newName);
  Future<bool> requestPermissions();
}

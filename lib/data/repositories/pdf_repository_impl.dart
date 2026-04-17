import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdftest/core/services/file_service.dart';
import 'package:pdftest/domain/repositories/pdf_repository.dart';

class PdfRepositoryImpl implements PdfRepository {
  final FileService _fileService;

  PdfRepositoryImpl(this._fileService);

  @override
  Future<String> mergePdfs(List<String> paths) => _fileService.mergePdfs(paths);

  @override
  Future<String> splitPdf(String path, int start, int end) => _fileService.splitPdf(path, start, end);

  @override
  Future<String> imagesToPdf(List<String> imagePaths) => _fileService.imagesToPdf(imagePaths);

  @override
  Future<String> addImageToPdf(String pdfPath, Uint8List imageBytes, int pageIndex, Offset position, Size size) =>
      _fileService.addImageToPdf(pdfPath, imageBytes, pageIndex, position, size);

  @override
  Future<String> addTextToPdf(String pdfPath, String text, int pageIndex, Offset position) =>
      _fileService.addTextToPdf(pdfPath, text, pageIndex, position);

  @override
  Future<void> printPdf(String path) => _fileService.printPdf(path);

  @override
  Future<void> deleteFile(String path) => _fileService.deleteFile(path);

  @override
  Future<String> renameFile(String path, String newName) => _fileService.renameFile(path, newName);

  @override
  Future<bool> requestPermissions() => _fileService.requestPermissions();
}

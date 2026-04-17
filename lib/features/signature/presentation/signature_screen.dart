import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signature/signature.dart';
import 'package:pdftest/presentation/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';

class SignatureScreen extends StatefulWidget {
  final String pdfPath;
  const SignatureScreen({super.key, required this.pdfPath});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Draw Signature')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _controller.clear(),
                    child: const Text('Clear'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: PrimaryButton(
                    text: 'Save & Use',
                    onPressed: () async {
                      if (_controller.isNotEmpty) {
                        final Uint8List? data = await _controller.toPngBytes();
                        if (data != null && mounted) {
                          context.pop(data);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as p;

class PDFCard extends StatelessWidget {
  final String path;
  final VoidCallback onTap;
  final VoidCallback? onMorePressed;

  const PDFCard({
    super.key,
    required this.path,
    required this.onTap,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = p.basename(path);
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: const Icon(Icons.picture_as_pdf, color: Colors.red),
        ),
        title: Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp),
        ),
        subtitle: Text(
          path,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
        ),
        trailing: onMorePressed != null
            ? IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: onMorePressed,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

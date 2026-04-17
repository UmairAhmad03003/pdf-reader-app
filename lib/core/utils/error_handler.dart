import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, dynamic error) {
    String message = 'An unexpected error occurred';
    
    if (error is Exception) {
      message = error.toString().replaceAll('Exception: ', '');
    } else if (error is String) {
      message = error;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SnackBarUtil {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        duration: duration,
        action: action,
      ),
    );
  }

  static void showSuccessSnackBar({
    required BuildContext context,
    required String message,
  }) {
    showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  static void showErrorSnackBar({
    required BuildContext context,
    required String message,
  }) {
    showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  static void showWarningSnackBar({
    required BuildContext context,
    required String message,
  }) {
    showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }
}

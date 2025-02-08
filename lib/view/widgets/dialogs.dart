import 'package:flutter/material.dart';

void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text("خطأ"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("حسناً"),
            ),
          ],
        ),
      ),
    );
  }
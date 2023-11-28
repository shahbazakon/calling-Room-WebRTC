import 'package:calling_room/utils/Utils.dart';
import 'package:flutter/material.dart';

void showSnackBar({required String title, Duration? duration}) {
  final snackBar = SnackBar(
    backgroundColor: Colors.black,
    duration: duration ?? const Duration(seconds: 3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    behavior: SnackBarBehavior.floating,
    content: Text(
      title,
    ),
  );
  ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
  ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(snackBar);
}

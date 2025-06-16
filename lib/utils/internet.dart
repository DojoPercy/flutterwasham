import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SafeOnTap {
  final Duration timeout;
  final String testUrl;

  SafeOnTap({
    this.timeout = const Duration(seconds: 3),
    this.testUrl = 'https://www.google.com',
  });

  Future<void> execute({
    required BuildContext context,
    required VoidCallback onSafeTap,
    VoidCallback? onNoInternet,
  }) async {
    final hasInternet = await _hasRealInternet();

    if (hasInternet) {
      onSafeTap();
    } else {
      if (onNoInternet != null) {
        onNoInternet();
      } else {
        _defaultNoInternetHandler(context);
      }
    }
  }

  Future<bool> _hasRealInternet() async {
    try {
      final result =
          await InternetAddress.lookup('google.com').timeout(timeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _defaultNoInternetHandler(BuildContext context) {
    Fluttertoast.showToast(
      msg: "No Internet Connection, check your Network",
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}

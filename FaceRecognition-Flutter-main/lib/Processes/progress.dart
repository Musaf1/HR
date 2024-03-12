
import 'package:flutter/material.dart';

class Progress {
  progress(context) async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: SingleChildScrollView(
              child: PopScope(canPop: false,
                child: AlertDialog(
                  elevation: 24,
                  title: Text(
                    'Loading...',
                  ),
                  content: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
          );
        });
  }
}

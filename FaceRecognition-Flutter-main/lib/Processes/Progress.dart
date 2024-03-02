import 'package:flutter/material.dart';

class Progress {
  progress(context) async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: SingleChildScrollView(
              child: WillPopScope(
                onWillPop: () async => false,
                child: const AlertDialog(
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

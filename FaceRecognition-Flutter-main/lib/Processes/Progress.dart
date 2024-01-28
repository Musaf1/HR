import 'package:flutter/material.dart';

class Progress {
  progress2(text, progress, context) async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: SingleChildScrollView(
              child: WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  //  backgroundColor: color,
                  elevation: 24,
                  title: Text(
                    text,
                    //style: textStyle
                  ),
                  content: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 10.0,
                      value: progress,
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  progress(context) async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: SingleChildScrollView(
              child: WillPopScope(
                onWillPop: () async => false,
                child: const AlertDialog(
                  //  backgroundColor: color,
                  elevation: 24,
                  title: Text(
                    'Loading...',
                    //style: textStyle
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

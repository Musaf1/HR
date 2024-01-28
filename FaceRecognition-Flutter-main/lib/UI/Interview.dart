
import 'package:flutter/material.dart';

import '../Processes/Init.dart';

class InterviewPage extends StatefulWidget {
  const InterviewPage({super.key});

  @override
  InterviewPageState createState() => InterviewPageState();
}

class InterviewPageState extends State<InterviewPage> {
  @override
  void initState() {
    super.initState();
    Init().initShowDialog(context, this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: const Column(
        children: <Widget>[
          SizedBox(height: 10),
          Text('Interview')
        ],
      ),
    );
  }
}


import 'package:facerecognition_flutter/UI/Employed.dart';
import 'package:flutter/material.dart';
import '../Processes/Init.dart';



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Init().initShowDialog(context, this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: const EmployedPage(),
      // child: FutureBuilder(
      //   future: Process().personStatusPage(),
      //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      //     return snapshot.data ?? Container();
      //   },
      // ),
    );
  }
}

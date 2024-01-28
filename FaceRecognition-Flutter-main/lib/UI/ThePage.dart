
import 'package:facerecognition_flutter/UI/Setting.dart';
import 'package:flutter/material.dart';
import '../Processes/Init.dart';
import 'Home.dart';

class ThePage extends StatefulWidget {
  const ThePage({super.key});

  @override
  PageState createState() => PageState();
}

class PageState extends State<ThePage> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    Init().initShowDialog(context, this);
  }

  @override
  Widget build(BuildContext context) {
    //initShowDialog();
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
        body: [const MyHomePage(), const Setting()][currentPageIndex],
      ),
    );
  }
}

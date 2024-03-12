
import 'package:flutter/material.dart';
import '../Processes/init.dart';
import '../Processes/process.dart';
import '../Processes/progress.dart';
import 'Dialogs.dart';

class EmployedPage extends StatefulWidget {
  const EmployedPage({super.key});

  @override
  EmployedPageState createState() => EmployedPageState();
}

class EmployedPageState extends State<EmployedPage> {
  @override
  initState() {
    super.initState();
    Init().initShowDialog(context, this);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Process().notDeparture(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot1) {
        return snapshot1.hasData
            ? Scaffold(
                body: SafeArea(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            FutureBuilder(
                              future: Process().canAttendance(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<dynamic> snapshot3) {
                                return snapshot3.hasData
                                    ? Visibility(
                                        visible: snapshot3.data,
                                        child: Expanded(
                                          flex: 1,
                                          child: FutureBuilder(
                                            future: Process().attStatus(),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<dynamic>
                                                    snapshot2) {
                                              return snapshot2.hasData
                                                  ? ElevatedButton.icon(
                                                      label: Text(
                                                        snapshot2.data,
                                                      ),
                                                      icon: const Icon(
                                                        Icons
                                                            .person_search_outlined,
                                                        size: 32,
                                                      ),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 20,
                                                                      bottom:
                                                                          20),
                                                              shape:
                                                                  const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            12.0)),
                                                              ),
                                                              textStyle:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          24)),
                                                      onPressed: () async {
                                                        Progress()
                                                            .progress(context);
                                                        if (await Init()
                                                            .initShowDialog(
                                                                context,
                                                                this)) {
                                                          setState(() {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            if (snapshot2
                                                                    .data ==
                                                                'Attendance') {
                                                              Init().buildShowDialog(context, this);
                                                            } else {
                                                              Dialogs()
                                                                  .confirmDeparture(
                                                                      context,
                                                                      this);
                                                            }
                                                          });
                                                        }
                                                      })
                                                  : const Center(
                                                      child:
                                                          CircularProgressIndicator());
                                            },
                                          ),
                                        ),
                                      )
                                    : const CircularProgressIndicator();
                              },
                            ),
                            FutureBuilder(
                              future: Process().canAttendance(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<dynamic> snapshot3) {
                                return snapshot3.hasData
                                    ? Visibility(
                                        visible: snapshot3.data,
                                        child: const SizedBox(
                                          width: 20,
                                        ),
                                      )
                                    : Container();
                              },
                            ),
                            Expanded(
                              child: ElevatedButton.icon(
                                  label: const Text(
                                    'Sign out',
                                  ),
                                  icon: const Icon(
                                    Icons.logout_outlined,
                                    size: 32,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.only(
                                          top: 20, bottom: 20),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0)),
                                      ),
                                      textStyle: const TextStyle(fontSize: 24)),
                                  onPressed: () async {
                                    Init().initShowDialog(context, this);
                                    await Process().signOutUser(context);
                                  }),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }
}

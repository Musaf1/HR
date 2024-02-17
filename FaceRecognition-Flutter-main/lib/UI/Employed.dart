
import 'package:flutter/material.dart';

import '../Processes/Init.dart';
import '../Processes/Process.dart';
import '../Processes/Progress.dart';
import 'Dialogs.dart';
import 'facedetectionview.dart';

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
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return snapshot.hasData
            ? Container(
                margin: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        // Visibility(
                        //   child: Expanded(
                        //     flex: 1,
                        //     child: ElevatedButton.icon(
                        //         label: const Text(
                        //           'Add CV',
                        //           // style: textStyle
                        //         ),
                        //         icon: const Icon(
                        //           //  color: textColor,
                        //           Icons.person_add_outlined,
                        //           // color: Colors.white70,
                        //         ),
                        //         style: ElevatedButton.styleFrom(
                        //             padding:
                        //                 const EdgeInsets.only(top: 10, bottom: 10),
                        //             // foregroundColor: Colors.white70,
                        //             //  backgroundColor: color,
                        //             shape: const RoundedRectangleBorder(
                        //               borderRadius:
                        //                   BorderRadius.all(Radius.circular(12.0)),
                        //             )),
                        //         onPressed: () {
                        //           // initShowDialog();
                        //           // enrollPerson(context);
                        //         }),
                        //   ),
                        // ),
                        // const Visibility(child: SizedBox(width: 20)),
                        Visibility(
                          visible: snapshot.data,
                          child: Expanded(
                            flex: 1,
                            child: FutureBuilder(
                              future: Process().attStatus(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<dynamic> snapshot) {
                                return snapshot.hasData
                                    ? ElevatedButton.icon(
                                        label: Text(
                                          snapshot.data,
                                          //style: textStyle
                                        ),
                                        icon: const Icon(
                                          // color: textColor,
                                          Icons.person_search_outlined,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            // backgroundColor: color,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12.0)),
                                            )),
                                        onPressed: () async {
                                          Init().initShowDialog(context, this);
                                          Progress().progress(context);
                                             // await LoadPerson().loadPerson();
                                          Navigator.of(context).pop();
                                          setState(() {
                                            if (snapshot.data == 'Attendance') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FaceRecognitionView(
                                                          // personList:
                                                          //     personList,
                                                          employedPageState:
                                                              this,
                                                        )),
                                              );
                                            } else {
                                              Dialogs().confirmDeparture(context,this);
                                            }
                                          });
                                        })
                                    : const Center(
                                        child: CircularProgressIndicator());
                              },
                            ),
                          ),
                        ),
                        // Visibility(
                        //     visible: snapshot.data,
                        //     child: const SizedBox(width: 20)),
                        // Expanded(
                        //   child: ElevatedButton.icon(
                        //       label: const Text(
                        //         'Leave request',
                        //         // style: textStyle
                        //       ),
                        //       icon: const Icon(
                        //         //  color: textColor,
                        //         Icons.logout_outlined,
                        //         // color: Colors.white70,
                        //       ),
                        //       style: ElevatedButton.styleFrom(
                        //           padding: const EdgeInsets.only(
                        //               top: 10, bottom: 10),
                        //           // foregroundColor: Colors.white70,
                        //           //  backgroundColor: color,
                        //           shape: const RoundedRectangleBorder(
                        //             borderRadius:
                        //                 BorderRadius.all(Radius.circular(12.0)),
                        //           )),
                        //       onPressed: () {
                        //         Init().initShowDialog(context, this);
                        //         //Process().enrollLeave(context, this);
                        //       }),
                        // ),
                      ],
                    ),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }
}

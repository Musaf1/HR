import 'package:face_recognition_admin/View/CV.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Prosses/Prosses.dart';

class Dialogs {
  static const color3 = Color.fromRGBO(0, 150, 150, 1);
  static const textStyle =
      TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: color3);
  TextStyle textStyle2 = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: Colors.amberAccent[100]);

  // Future<List> showDialogTextField(
  //     name, job, startWorkTime, endWorkTime, context) async {
  //   await showDialog(
  //       context: context,
  //       builder: (context) {
  //         return WillPopScope(
  //           onWillPop: () async => false,
  //           child: SingleChildScrollView(
  //             child: AlertDialog(
  //               //  backgroundColor: color,
  //               elevation: 24,
  //               title: const Text(
  //                 'Info',
  //                 //style: textStyle
  //               ),
  //               content: Column(
  //                 children: [
  //                   TextField(
  //                     inputFormatters: [
  //                       FilteringTextInputFormatter.allow(
  //                           RegExp("[A-Za-z0-9 ]"))
  //                     ],
  //                     controller: TextEditingController(text: name),
  //                     onChanged: (value) {
  //                       name = value;
  //                     },
  //                     //controller: _textFieldController,
  //                     decoration: const InputDecoration(
  //                       labelText: 'Name',
  //                       focusedBorder: UnderlineInputBorder(
  //                           // borderSide: BorderSide(color: textColor2),
  //                           ),
  //                     ),
  //                     // cursorColor: textColor,
  //                   ),
  //                   const SizedBox(height: 10),
  //                   TextField(
  //                     controller: TextEditingController(text: job),
  //                     onChanged: (value) {
  //                       job = value;
  //                     },
  //                     //controller: _textFieldController,
  //                     decoration: const InputDecoration(
  //                         labelText: "Job",
  //                         focusedBorder: UnderlineInputBorder(
  //                             //  borderSide: BorderSide(color: textColor2),
  //                             )),
  //                     // cursorColor: textColor,
  //                   ),
  //                   const SizedBox(height: 10),
  //                   ElevatedButton.icon(
  //                     icon: const Icon(
  //                       //  color: textColor,
  //                       Icons.check_circle_outline,
  //                       color: Colors.green,
  //                     ),
  //                     style: ElevatedButton.styleFrom(
  //                         // padding: const EdgeInsets.only(top: 10, bottom: 10),
  //                         // foregroundColor: Colors.white70,
  //                         //  backgroundColor: color,
  //                         shape: const RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.all(Radius.circular(12.0)),
  //                     )),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     label: const Text('OK'),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       });
  //   TimeOfDay? startWork =
  //       await Prosses().timePicker('Start Work', startWorkTime, context);
  //   String startWorkString = Prosses().timeOfDateFormat(startWork, context);
  //   TimeOfDay? endWork =
  //       await Prosses().timePicker('End Work', endWorkTime, context);
  //   String endWorkString = Prosses().timeOfDateFormat(endWork, context);
  //
  //   return [name, job, startWorkString, endWorkString];
  // }

  Future<String> showDialogEmailBody(context) async {
    String body='Hello\nWe are honored to have you attend the personal interview for the position in the Al-Raisi branch\nall the best';
    await showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: SingleChildScrollView(
              child: AlertDialog(
                //  backgroundColor: color,
                elevation: 24,
                title: const Text(
                  'Email Body',
                  //style: textStyle
                ),
                content: Column(
                  children: [
                    TextField(
                      maxLines: 5,
                      minLines: 1,
                      controller: TextEditingController(text: body),
                      onChanged: (value) {
                        body = value;
                      },
                      //controller: _textFieldController,
                      decoration: const InputDecoration(
                        labelText: 'Body',
                        focusedBorder: UnderlineInputBorder(
                          // borderSide: BorderSide(color: textColor2),
                        ),
                      ),
                      // cursorColor: textColor,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(
                        //  color: textColor,
                        Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                      style: ElevatedButton.styleFrom(
                        // padding: const EdgeInsets.only(top: 10, bottom: 10),
                        // foregroundColor: Colors.white70,
                        //  backgroundColor: color,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          )),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      label: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ),
          );
        });


    return body;
  }

  void showDialogFun(text, funNumber, context) {
    showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          //backgroundColor: color,
          elevation: 24,
          title: Text(
            text,
            //style: textStyle,
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(
                  //  color: textColor,
                  Icons.check_circle_outline,
                  color: Colors.green,
                ),
                style: ElevatedButton.styleFrom(
                    // padding: const EdgeInsets.only(top: 10, bottom: 10),
                    // foregroundColor: Colors.white70,
                    //  backgroundColor: color,
                    shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                )),
                onPressed: () async {
                  bool boolFun;
                  if (funNumber == 0) {
                    boolFun = await Prosses().sqlConnection();
                  } else {
                    boolFun = await Prosses().connectivityResult();
                  }
                  if (boolFun) {
                    Navigator.pop(context, 'OK');
                    CVsViewState().initShowDialog(text);
                  }
                },
                label: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDialogAttendanceTime(attendanceList, context) {
    showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Scaffold(
              body: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: attendanceList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 16,
                        ),
                        Center(
                            child: Card(
                                child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${attendanceList[index]}',
                            style: textStyle,
                          ),
                        )))
                      ],
                    );
                  }),
            ));
  }

  void showDialogInfo(id, name, gender, dob, email, phone, job, faceJpg,
      description, startWork, endWork, attendanceList, context) {
    showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.memory(
                      faceJpg,
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Text(
                      'Id: ',
                      style: textStyle,
                    ),
                    Text(
                      '$id',
                      style: textStyle2,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Text(
                      'Name: ',
                      style: textStyle,
                    ),
                    Text(
                      '$name',
                      style: textStyle2,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Text(
                      'Gender: ',
                      style: textStyle,
                    ),
                    Text(
                      '$gender',
                      style: textStyle2,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Text(
                      'Date of birth: ',
                      style: textStyle,
                    ),
                    Text(
                      '$dob',
                      style: textStyle2,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Text(
                      'Email: ',
                      style: textStyle,
                    ),
                    Text(
                      '$email',
                      style: textStyle2,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Text(
                      'Phone: ',
                      style: textStyle,
                    ),
                    Text(
                      '$phone',
                      style: textStyle2,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Text(
                      'Job: ',
                      style: textStyle,
                    ),
                    Text(
                      '$job',
                      style: textStyle2,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Text(
                      'Description: ',
                      style: textStyle,
                    ),
                    Text(
                      '$description',
                      style: textStyle2,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Text(
                      'StartWork: ',
                      style: textStyle,
                    ),
                    Text(
                      '$startWork',
                      style: textStyle2,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Text(
                      'EndWork: ',
                      style: textStyle,
                    ),
                    Text(
                      '$endWork',
                      style: textStyle2,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 36,
                ),
                Center(
                  child: Column(
                    children: [
                      Visibility(
                        visible: (attendanceList.length >= 1),
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            //  color: textColor,
                            Icons.format_list_numbered_outlined,
                            color: Colors.teal,
                          ),
                          style: ElevatedButton.styleFrom(
                              // padding: const EdgeInsets.only(top: 10, bottom: 10),
                              // foregroundColor: Colors.white70,
                              //  backgroundColor: color,
                              shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          )),
                          onPressed: () {
                            showDialogAttendanceTime(attendanceList, context);
                            //Navigator.pop(context, 'OK');
                          },
                          label: const Text('Attendance Time'),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(
                          //  color: textColor,
                          Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        style: ElevatedButton.styleFrom(
                            // padding: const EdgeInsets.only(top: 10, bottom: 10),
                            // foregroundColor: Colors.white70,
                            //  backgroundColor: color,
                            shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        )),
                        onPressed: () {
                          Navigator.pop(context, 'OK');
                        },
                        label: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<TimeOfDay?> timePicker(text, time, context) {
    return showTimePicker(
      helpText: text,
      initialTime: time,
      context: context,
    );
  }

  Future<DateTime?> datePicker(text, context) {
    return showDatePicker(
        helpText: text,
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1970),
        lastDate: DateTime(2030)
    );
  }

}

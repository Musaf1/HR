import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facerecognition_flutter/Processes/Process.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show File;
import '../Processes/Init.dart';
import '../Processes/Progress.dart';

class Dialogs {
  final _formKey = GlobalKey<FormState>();
  static const color3 = Color.fromRGBO(0, 150, 150, 1);

  Future<List<Object>> showDialogLeaveTextField(context, state) async {
    Timestamp start, end;
    String reason = '', description = '';
    List<String> reasonList = ['Vacation', 'Sick leave'];
    String dropdownValue = reasonList.first;
    reason = dropdownValue;
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
                  'Leave request',
                  //style: textStyle
                ),
                content: Column(
                  children: [
                    const SizedBox(height: 10),
                    DropdownMenu<String>(
                      label: const Text("Reason"),
                      initialSelection: dropdownValue,
                      onSelected: (String? value) {
                        // This is called when the user selects an item.
                        state.setState(() {
                          dropdownValue = value!;
                          reason = dropdownValue;
                        });
                      },
                      dropdownMenuEntries: reasonList
                          .map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(
                          value: value,
                          label: value,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      maxLines: 5,
                      minLines: 1,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(500),
                        FilteringTextInputFormatter.allow(
                            RegExp("[A-Za-z0-9 @.]"))
                      ],
                      controller: TextEditingController(text: description),
                      onChanged: (value) {
                        description = value;
                      },
                      //controller: _textFieldController,
                      decoration: const InputDecoration(
                          labelText: "Description",
                          focusedBorder: UnderlineInputBorder(
                              //  borderSide: BorderSide(color: textColor2),
                              )),
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
                      onPressed: () async {
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

    DateTimeRange? dateRange = await dateRangePicker(context, 'Leave Range');
    start = Timestamp.fromDate(dateRange!.start);
    end = Timestamp.fromDate(dateRange.end);
    if (reason == 'Sick leave') {
      return [
        reason,
        start,
        end,
        description,
        await pickSickLeave(context, state)
      ];
    }
    return [reason, start, end, description, ''];
  }

  Future<List> showDialogTextField(context, state) async {
    String gender = '', job = '', description = '', phoneNumber = '', name = '';
    List<String> genderList = ['male', 'female'];
    String dropdownValue = genderList.first;
    gender = dropdownValue;
    List<String> jobList = await Process().loadJobs();
    String dropdownValue2 = jobList.first;
    job = dropdownValue2;
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
                  'Info',
                  //style: textStyle
                ),
                content: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Full Name';
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp("[A-Za-z0-9 @.]"))
                        ],
                        controller: TextEditingController(text: name),
                        onChanged: (value) {
                          name = value;
                        },
                        //controller: _textFieldController,
                        decoration: const InputDecoration(
                            labelText: "Full Name",
                            focusedBorder: UnderlineInputBorder(
                                //  borderSide: BorderSide(color: textColor2),
                                )),
                        // cursorColor: textColor,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length != 10) {
                            return 'Please enter Phone number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                        ],
                        controller: TextEditingController(text: phoneNumber),
                        onChanged: (value) {
                          phoneNumber = value;
                        },
                        //controller: _textFieldController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          focusedBorder: UnderlineInputBorder(
                              // borderSide: BorderSide(color: textColor2),
                              ),
                        ),
                        // cursorColor: textColor,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        maxLines: 5,
                        minLines: 1,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(500),
                          FilteringTextInputFormatter.allow(
                              RegExp("[A-Za-z0-9 @.]"))
                        ],
                        controller: TextEditingController(text: description),
                        onChanged: (value) {
                          description = value;
                        },
                        //controller: _textFieldController,
                        decoration: const InputDecoration(hintText: '(Optional)',
                            labelText: "Description",
                            focusedBorder: UnderlineInputBorder(
                                //  borderSide: BorderSide(color: textColor2),
                                )),
                        // cursorColor: textColor,
                      ),
                      const SizedBox(height: 20),
                      DropdownMenu<String>(
                        label: const Text("Job"),
                        initialSelection: dropdownValue2,
                        onSelected: (String? value) {
                          // This is called when the user selects an item.
                          state.setState(() {
                            dropdownValue2 = value!;
                            job = dropdownValue2;
                          });
                        },
                        dropdownMenuEntries: jobList
                            .map<DropdownMenuEntry<String>>((String value) {
                          return DropdownMenuEntry<String>(
                            value: value,
                            label: value,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      DropdownMenu<String>(
                        label: const Text("Gender"),
                        initialSelection: dropdownValue,
                        onSelected: (String? value) {
                          // This is called when the user selects an item.
                          state.setState(() {
                            dropdownValue = value!;
                            gender = dropdownValue;
                          });
                        },
                        dropdownMenuEntries: genderList
                            .map<DropdownMenuEntry<String>>((String value) {
                          return DropdownMenuEntry<String>(
                            value: value,
                            label: value,
                          );
                        }).toList(),
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
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop();
                          }
                        },
                        label: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
    Timestamp dob = Timestamp.fromDate(
        await datePicker(context, 'Date of birth') as DateTime);

    return [
      gender,
      dob,
      phoneNumber,
      job,
      description,
      name
    ];
  }

  Future<void> verifyEmail(context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: WillPopScope(
              onWillPop: () async => false,
              child: SingleChildScrollView(
                child: AlertDialog(
                  //  backgroundColor: color,
                  elevation: 24,
                  title: const Text('Please verify your email'),
                  content: Column(
                    children: [
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
                          GoRouter.of(context).go('/');
                        },
                        label: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<void> confirmDeparture(context, personList) async {
    var att_id = personList[0].id_att;
    await showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: WillPopScope(
              onWillPop: () async => false,
              child: SingleChildScrollView(
                child: AlertDialog(
                  //  backgroundColor: color,
                  elevation: 24,
                  title: const Text('Confirm Departure'),
                  content: Column(
                    children: [
                      Row(
                        children: [
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            )),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await Process().timeId(att_id, context);
                            },
                            label: const Text('Confirm'),
                          ),
                          const SizedBox(width: 10,),
                          ElevatedButton.icon(
                            icon: const Icon(
                              //  color: textColor,
                              Icons.cancel_outlined,
                              color: Colors.redAccent,
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
                              Navigator.of(context).pop();
                            },
                            label: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<String> showDialogChangePhoneNumber(
      context, String phoneNumber) async {
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
                  'Change phone number',
                  //style: textStyle
                ),
                content: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length != 10) {
                            return 'Please enter Phone number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                        ],
                        controller: TextEditingController(text: phoneNumber),
                        onChanged: (value) {
                          phoneNumber = value;
                        },
                        //controller: _textFieldController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
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
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop();
                          }
                        },
                        label: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });

    return phoneNumber;
  }

  Future<DateTime?> datePicker(context, text) {
    return showDatePicker(
        helpText: text,
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1970),
        lastDate: DateTime.now());
  }

  Future<DateTimeRange?> dateRangePicker(context, text) {
    return showDateRangePicker(
        helpText: text,
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
  }

  Future<String> pickSickLeave(context, state) async {
    final ref = FirebaseDatabase.instance.ref('Number').child('Leave');
    final sickLeaveNumber = await ref.get();
    Fluttertoast.showToast(
        msg: "Pick Sick Leave Reports!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        //backgroundColor: color,
        textColor: color3,
        fontSize: 16.0);
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();
    File file = File(resultFile!.files.single.path.toString());
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final mountainsRef =
          storageRef.child("Sick Leave Reports${sickLeaveNumber.value}");
      var uploadTask = mountainsRef.putFile(file);
      Progress().progress(context);
      uploadTask.snapshotEvents.listen((event) {
        state.setState(() {
          Navigator.of(context).pop();
          var progress =
              event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
          Progress().progress2('Uploading...', progress, context);
          if (event.state == TaskState.success) {
            Navigator.of(context).pop();
            Fluttertoast.showToast(
                msg: "Leave enrolled!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                // backgroundColor: color,
                textColor: color3,
                fontSize: 16.0);
          }
        });
      });
      //navigatorKey.currentState?.pop();
      return "Sick Leave Reports${sickLeaveNumber.value}";
    } catch (e) {
      return '';
    }
  }

  void showDialogFun(context, state, text) {
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
                  //if (await connectivityResult()) {
                  Navigator.pop(context, 'OK');
                  await Init().initShowDialog(context, state);
                  // }
                },
                label: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

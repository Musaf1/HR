import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:facesdk_plugin/facesdk_plugin.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show File, Platform;
import 'person.dart';
import 'facedetectionview.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Color color = const Color.fromRGBO(0, 100, 100, 1);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: color,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  double? _progress;
  final _formKey = GlobalKey<FormState>();
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  // List<Person> currentPersonList = <Person>[];
  static const textStyle =
      TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: color3);
  TextStyle textStyle2 = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: Colors.amberAccent[100]);
  static const color3 = Color.fromRGBO(0, 150, 150, 1);
  final _facesdkPlugin = FacesdkPlugin();

  Future<bool> connectivityResult() async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  void showDialogFun(text) {
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
                  if (await connectivityResult()) {
                    Navigator.pop(context, 'OK');
                    await initShowDialog();
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

  @override
  void initState() {
    super.initState();
    initShowDialog();
  }

  Future<void> initShowDialog() async {
    if (await connectivityResult()) {
      init();
    } else {
      showDialogFun('connect to internet');
    }
  }

  Future<void> init() async {
    //currentPersonList = await loadAllPersons();
    int facepluginState = -1;
    try {
      if (Platform.isAndroid) {
        await _facesdkPlugin
            .setActivation(
                "Os8QQO1k4+7MpzJ00bVHLv3UENK8YEB04ohoJsU29wwW1u4fBzrpF6MYoqxpxXw9m5LGd0fKsuiK"
                "fETuwulmSR/gzdSndn8M/XrEMXnOtUs1W+XmB1SfKlNUkjUApax82KztTASiMsRyJ635xj8C6oE1"
                "gzCe9fN0CT1ysqCQuD3fA66HPZ/Dhpae2GdKIZtZVOK8mXzuWvhnNOPb1lRLg4K1IL95djy0PKTh"
                "BNPKNpI6nfDMnzcbpw0612xwHO3YKKvR7B9iqRbalL0jLblDsmnOqV7u1glLvAfSCL7F5G1grwxL"
                "Yo1VrNPVGDWA/Qj6Z2tPC0ENQaB4u/vXAS0ipg==")
            .then((value) => facepluginState = value ?? -1);
      } else {
        await _facesdkPlugin
            .setActivation(
                "nWsdDhTp12Ay5yAm4cHGqx2rfEv0U+Wyq/tDPopH2yz6RqyKmRU+eovPeDcAp3T3IJJYm2LbPSEz"
                "+e+YlQ4hz+1n8BNlh2gHo+UTVll40OEWkZ0VyxkhszsKN+3UIdNXGaQ6QL0lQunTwfamWuDNx7Ss"
                "efK/3IojqJAF0Bv7spdll3sfhE1IO/m7OyDcrbl5hkT9pFhFA/iCGARcCuCLk4A6r3mLkK57be4r"
                "T52DKtyutnu0PDTzPeaOVZRJdF0eifYXNvhE41CLGiAWwfjqOQOHfKdunXMDqF17s+LFLWwkeNAD"
                "PKMT+F/kRCjnTcC8WPX3bgNzyUBGsFw9fcneKA==")
            .then((value) => facepluginState = value ?? -1);
      }
      if (facepluginState == 0) {
        await _facesdkPlugin
            .init()
            .then((value) => facepluginState = value ?? -1);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    final prefs = await SharedPreferences.getInstance();
    int? livenessLevel = prefs.getInt("liveness_level");

    try {
      await _facesdkPlugin
          .setParam({'check_liveness_level': livenessLevel ?? 0});
    } catch (e) {
      debugPrint(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  //A method that retrieves all the dogs from the dogs table.
  Future<List<Person>> loadAllPersons() async {
    List personList = [];
    //await db.collection("person").doc("1").delete();
    await db.collection("person").get().then((querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        personList.add({
          'id': int.parse(docSnapshot.id),
          'name': docSnapshot.data()['name'],
          'faceJpg': docSnapshot.data()['faceJpg'],
          'templates': docSnapshot.data()['templates'],
          'id_att': docSnapshot.data()['id_att'],
        });
      }
    });

    return List.generate(personList.length, (i) {
      return Person.fromMap(personList[i]);
    });
  }

  // bool workHours(startWork, endWork, timeNow) {
  //   if (startWork <= timeNow && timeNow <= endWork) {
  //     return true;
  //   } else if ((startWork - endWork >= const Duration(microseconds: 1)) &&
  //       (startWork >= timeNow && timeNow <= endWork)) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  // String dateFormat(date) {
  //   return DateFormat('yyyy-MM-dd kk:mm:ss').format(date);
  // }
  //
  // String dateFormatOnly(date) {
  //   return DateFormat('yyyy-MM-dd').format(date);
  // }

  Future<int> timeId(id) async {
    var data;
    progress();
    await db
        .collection("attendance")
        .doc(id)
        .update({"serverTimestamp": FieldValue.serverTimestamp()});
    await db.collection("attendance").doc(id).get().then((d) {
      data = d.data()!['serverTimestamp'];
    });
    await db.collection("attendance").doc(id).update({
      "List": FieldValue.arrayUnion([data])
    });

    // bool booL = false;
    // DateTime DateTimeNow = DateTime.now();
    // Duration timeNow = const Duration();
    // Duration startWork = const Duration();
    // Duration endWork = const Duration();
    // var conn = await MySqlConnection.connect(settings);
    // var timeNowGet = await conn.query('select CURRENT_TIME()');
    // var DateTimeNowGet = await conn.query('select now()');
    // var timeWork = await conn
    //     .query('select startWork, endWork from person where id=?', [id]);
    //
    // for (var i in timeWork) {
    //   startWork = i[0];
    //   endWork = i[1];
    // }
    // for (var i in timeNowGet) {
    //   timeNow = i[0];
    // }
    // for (var i in DateTimeNowGet) {
    //   DateTimeNow = i[0];
    // }
    //
    // if (workHours(startWork, endWork, timeNow)) {
    //   String formattedDate = dateFormat(DateTimeNow);
    //   var time = await conn.query(
    //       'select time from attendance where id=? order by time desc limit 1',
    //       [id]);
    //   if (time.isEmpty) {
    //     await conn.query('insert into attendance (id, time) values (?, ?)',
    //         [id, formattedDate]);
    //     return 1;
    //   }
    //   for (var i in time) {
    //     booL = DateTimeNow.isAfter(i[0].add(const Duration(days: 1)));
    //   }
    //   if (booL) {
    //     await conn.query('insert into attendance (id, time) values (?, ?)',
    //         [id, formattedDate]);
    //     return 1;
    //   } else {
    //     return 2;
    //   }
    // }
    Navigator.of(context).pop();
    return 0;
  }

  void progress2({text}) async {
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
                      value: _progress,
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  void progress() async {
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

  Future<List<Object>> showDialogLeaveTextField() async {
    Timestamp start, end;
    String reason = '', description = '', sickLeavePatch = '';
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
                        setState(() {
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
                        if (reason == 'Sick leave') {
                          sickLeavePatch = await pickSickLeave();
                        }
                      },
                      label: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ),
          );
        });

    DateTimeRange? dateRange = await dateRangePicker('Leave Range');
    start = Timestamp.fromDate(dateRange!.start);
    end = Timestamp.fromDate(dateRange.end);
    return [reason, start, end, description, sickLeavePatch];
  }

  Future<List> showDialogTextField() async {
    String name = '',
        gender = '',
        email = '',
        phone = '',
        job = '',
        description = '';
    List<String> genderList = ['male', 'female'];
    String dropdownValue = genderList.first;
    gender = dropdownValue;
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
                            return 'Please enter Name';
                          }
                          return null;
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(20),
                          FilteringTextInputFormatter.allow(
                              RegExp("[A-Za-z0-9 ]"))
                        ],
                        controller: TextEditingController(text: name),
                        onChanged: (value) {
                          name = value;
                        },
                        //controller: _textFieldController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          focusedBorder: UnderlineInputBorder(
                              // borderSide: BorderSide(color: textColor2),
                              ),
                        ),
                        // cursorColor: textColor,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30),
                        ],
                        controller: TextEditingController(text: email),
                        onChanged: (value) {
                          email = value;
                        },
                        //controller: _textFieldController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          focusedBorder: UnderlineInputBorder(
                              // borderSide: BorderSide(color: textColor2),
                              ),
                        ),
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
                        controller: TextEditingController(text: phone),
                        onChanged: (value) {
                          phone = value;
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Job';
                          }
                          return null;
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(20),
                          FilteringTextInputFormatter.allow(
                              RegExp("[A-Za-z0-9 ]"))
                        ],
                        controller: TextEditingController(text: job),
                        onChanged: (value) {
                          job = value;
                        },
                        //controller: _textFieldController,
                        decoration: const InputDecoration(
                            labelText: "Job",
                            focusedBorder: UnderlineInputBorder(
                                //  borderSide: BorderSide(color: textColor2),
                                )),
                        // cursorColor: textColor,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Description';
                          }
                          return null;
                        },
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
                      const SizedBox(height: 20),
                      DropdownMenu<String>(
                        label: const Text("Gender"),
                        initialSelection: dropdownValue,
                        onSelected: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
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
    Timestamp dob =
        Timestamp.fromDate(await datePicker('Date of birth') as DateTime);

    return [
      name,
      gender,
      dob,
      email,
      phone,
      job,
      description,
    ];
  }

  Future<DateTime?> datePicker(text) {
    return showDatePicker(
        helpText: text,
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1970),
        lastDate: DateTime.now());
  }

  Future<DateTimeRange?> dateRangePicker(text) {
    return showDateRangePicker(
        helpText: text,
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
  }

  Future<String> pickSickLeave() async {
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
      progress2();
      uploadTask.snapshotEvents.listen((event) {
        setState(() {
          Navigator.of(context).pop();
          _progress =
              event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
          progress2(text: 'Uploading...');
          if (event.state == TaskState.success) Navigator.of(context).pop();
        });
      });
      //Navigator.of(context).pop();
      return "Sick Leave Reports${sickLeaveNumber.value}";
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Sick Leave Reports Error!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          //backgroundColor: color,
          textColor: color3,
          fontSize: 16.0);
      return '';
    }
  }

  Future enrollPerson(BuildContext context) async {
    progress();
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      String cvpath = '', idAtt = '', idBank = '', idDep = '', idShift = '';
      final ref = FirebaseDatabase.instance.ref('Number').child('person');
      final personNumber = await ref.get();
      await ref.set(ServerValue.increment(1));

      try {
        Fluttertoast.showToast(
            msg: "Pick CV file!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: color,
            textColor: color3,
            fontSize: 16.0);
        FilePickerResult? resultFile = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['docx', 'pdf'],
        );
        File file = File(resultFile!.files.single.path.toString());
        try {
          final storageRef = FirebaseStorage.instance.ref();
          final mountainsRef = storageRef.child("${personNumber.value}");
          await mountainsRef.putFile(file);
        } catch (e) {
          Fluttertoast.showToast(
              msg: "CV file Error!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              //backgroundColor: color,
              textColor: color3,
              fontSize: 16.0);
        }

        Fluttertoast.showToast(
            msg: "Add your face photo!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: color,
            textColor: color3,
            fontSize: 16.0);
        final image =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (image == null) {
          return;
        }
        var rotatedImage =
            await FlutterExifRotation.rotateImage(path: image.path);
        final faces = await _facesdkPlugin.extractFaces(rotatedImage.path);
        for (var face in faces) {
          // ignore: use_build_context_synchronously
          List info = await showDialogTextField();

          await db.collection("attendance").add({"List": []}).then(
              (documentSnapshot) => idAtt = documentSnapshot.id);
          await db
              .collection("bank_info")
              .add({}).then((documentSnapshot) => idBank = documentSnapshot.id);
          await db
              .collection("department")
              .add({}).then((documentSnapshot) => idDep = documentSnapshot.id);
          await db.collection("shift").add({}).then(
              (documentSnapshot) => idShift = documentSnapshot.id);
          await db.collection("person").doc("${personNumber.value}").set({
            "name": "${info[0]}",
            "gender": "${info[1]}",
            "dob": info[2],
            "email": "${info[3]}",
            "phone": "${info[4]}",
            "job": "${info[5]}",
            "status": "cv",
            "templates": face['templates'],
            "faceJpg": face['faceJpg'],
            "id_att": idAtt,
            "id_bank": idBank,
            "id_dep": idDep,
            "id_shift": idShift,
            "LeaveId": [],
            "cv_path": cvpath
          });

          await Fluttertoast.showToast(
              msg: "CV enrolled!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              // backgroundColor: color,
              textColor: color3,
              fontSize: 16.0);
        }

        if (faces.length == 0) {
          await Fluttertoast.showToast(
              msg: "No face detected!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              //backgroundColor: color,
              textColor: color3,
              fontSize: 16.0);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
      Navigator.of(context).pop();
    }
  }

  Future enrollLeave(BuildContext context) async {
    progress();
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      final ref = FirebaseDatabase.instance.ref('Number').child('Leave');
      final leaveNumber = await ref.get();
      await ref.set(ServerValue.increment(1));

      try {
        List info = await showDialogLeaveTextField();
        await db.collection("Leave").doc("${leaveNumber.value}").set({
          "reason": "${info[0]}",
          "start": info[1],
          "end": info[2],
          "description": "${info[3]}",
          "sickLeavePatch": info[4],
        });

        await Fluttertoast.showToast(
            msg: "Leave enrolled!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            // backgroundColor: color,
            textColor: color3,
            fontSize: 16.0);
      } catch (e) {
        await Fluttertoast.showToast(
            msg: "Leave Error!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: color,
            textColor: color3,
            fontSize: 16.0);
        debugPrint(e.toString());
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    initShowDialog();
    return SafeArea(
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                        label: const Text(
                          'Add CV',
                          // style: textStyle
                        ),
                        icon: const Icon(
                          //  color: textColor,
                          Icons.person_add_outlined,
                          // color: Colors.white70,
                        ),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            // foregroundColor: Colors.white70,
                            //  backgroundColor: color,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            )),
                        onPressed: () {
                          initShowDialog();
                          enrollPerson(context);
                        }),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                        label: const Text(
                          'Attendance',
                          //style: textStyle
                        ),
                        icon: const Icon(
                          // color: textColor,
                          Icons.person_search_outlined,
                        ),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            // backgroundColor: color,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            )),
                        onPressed: () async {
                          progress();
                          initShowDialog();
                          List<Person> personList = await loadAllPersons();
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FaceRecognitionView(
                                      personList: personList,
                                      homePageState: this,
                                    )),
                          );
                        }),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton.icon(
                        label: const Text(
                          'Leave request',
                          // style: textStyle
                        ),
                        icon: const Icon(
                          //  color: textColor,
                          Icons.logout_outlined,
                          // color: Colors.white70,
                        ),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            // foregroundColor: Colors.white70,
                            //  backgroundColor: color,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            )),
                        onPressed: () {
                          initShowDialog();
                          enrollLeave(context);
                        }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

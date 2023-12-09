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
import 'package:mysql1/mysql1.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ssh2/ssh2.dart';

void main() async {
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
  List<Person> currentPersonList = <Person>[];
  static const textStyle =
      TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: color3);
  TextStyle textStyle2 = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: Colors.amberAccent[100]);
  static const color3 = Color.fromRGBO(0, 150, 150, 1);
  var settings = ConnectionSettings(
      host: '192.168.8.231',
      port: 3306,
      user: 'musa',
      password: '2002',
      db: 'dbm');
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

  Future<bool> sqlConnection() async {
    try {
      await MySqlConnection.connect(settings);
      return true;
    } catch (e) {
      return false;
    }
  }

  void showDialogFun(text, funNumber) {
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
                    boolFun = await sqlConnection();
                  } else {
                    boolFun = await connectivityResult();
                  }
                  if (boolFun) {
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
      if (await sqlConnection()) {
        init();
      } else {
        showDialogFun('server offline', 0);
      }
    } else {
      showDialogFun('connect to internet', 1);
    }
  }

  Future<void> init() async {
    currentPersonList = await loadAllPersons();
    const Duration(seconds: 1);
    setState(() {
      currentPersonList=currentPersonList;
    });

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
    var conn = await MySqlConnection.connect(settings);
    var maps = await conn.query('select * from person');
    for (var row in maps) {
      personList.add({
        'id': row[0],
        'name': row[1],
        'gender': row[2],
        'dob': dateFormatOnly(row[3]),
        'email': row[4],
        'phone': row[5],
        'job': row[6],
        'faceJpg': row[7],
        'templates': row[8],
        'description': row[9],
        'startWork': row[10],
        'endWork': row[11]
      });
    }

    return List.generate(personList.length, (i) {
      return Person.fromMap(personList[i]);
    });
  }

  bool workHours(startWork, endWork, timeNow) {
    if (startWork <= timeNow && timeNow <= endWork) {
      return true;
    } else if ((startWork - endWork >= const Duration(microseconds: 1)) &&
        (startWork >= timeNow && timeNow <= endWork)) {
      return true;
    } else {
      return false;
    }
  }

  String dateFormat(date) {
    return DateFormat('yyyy-MM-dd kk:mm:ss').format(date);
  }

  String dateFormatOnly(date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<int> timeId(id) async {
    bool booL = false;
    DateTime DateTimeNow = DateTime.now();
    Duration timeNow = const Duration();
    Duration startWork = const Duration();
    Duration endWork = const Duration();
    var conn = await MySqlConnection.connect(settings);
    var timeNowGet = await conn.query('select CURRENT_TIME()');
    var DateTimeNowGet = await conn.query('select now()');
    var timeWork = await conn
        .query('select startWork, endWork from person where id=?', [id]);

    for (var i in timeWork) {
      startWork = i[0];
      endWork = i[1];
    }
    for (var i in timeNowGet) {
      timeNow = i[0];
    }
    for (var i in DateTimeNowGet) {
      DateTimeNow = i[0];
    }

    if (workHours(startWork, endWork, timeNow)) {
      String formattedDate = dateFormat(DateTimeNow);
      var time = await conn.query(
          'select time from attendance where id=? order by time desc limit 1',
          [id]);
      if (time.isEmpty) {
        await conn.query('insert into attendance (id, time) values (?, ?)',
            [id, formattedDate]);
        return 1;
      }
      for (var i in time) {
        booL = DateTimeNow.isAfter(i[0].add(const Duration(days: 1)));
      }
      if (booL) {
        await conn.query('insert into attendance (id, time) values (?, ?)',
            [id, formattedDate]);
        return 1;
      } else {
        return 2;
      }
    }
    return 0;
  }

  Future<List> showDialogTextField(
      name, gender, dob, email, phone, job, description) async {
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
                content: Column(
                  children: [
                    TextField(
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
                    TextField(
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
                    TextField(
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
                    TextField(
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
                    const SizedBox(height: 20),
                    DropdownMenu<String>(
                      label: const Text("gender"),
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
    String dob = dateFormatOnly(await datePicker('Date of birth'));

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

  Future enrollPerson(BuildContext context) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      String name = '';
      String gender = '';
      String dob = '';
      String email = '';
      String phone = '';
      String job = '';
      String description = '';
      String cvpath = '';

      try {
        var client = SSHClient(
          host: '192.168.8.231',
          port: 22,
          username: 'musa',
          passwordOrKey: '2002',
        );
        await client.connect();
        await client.connectSFTP();
        var conn = await MySqlConnection.connect(settings);
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
          allowedExtensions: ['docx'],
        );
        File file = File(resultFile!.files.single.path.toString());
        cvpath = resultFile.files.single.name.toString();
        Fluttertoast.showToast(
            msg: "Pick your photo!",
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
          List info = await showDialogTextField(
              name, gender, dob, email, phone, job, description);
          await conn.query(
              'insert into cv (name, gender, dob, email, phone, job, faceJpg, template, description, startWork, endWork, cvpath) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
              [
                info[0],
                info[1],
                info[2],
                info[3],
                info[4],
                info[5],
                face['faceJpg'],
                face['templates'],
                info[6],
                '00:00',
                '00:00',
                cvpath
              ]);
          await Fluttertoast.showToast(
              msg: "CV enrolled!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              // backgroundColor: color,
              textColor: color3,
              fontSize: 16.0);
          await client.sftpUpload(
            path: file.path,
            toPath: ".",
          );
          await client.disconnectSFTP();
          await client.disconnect();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    initShowDialog();
    return SafeArea(
      child: Scaffold(
        body: FaceRecognitionView(
          personList: currentPersonList,
          homePageState: this,
        ),
        // Container(
        //   margin: const EdgeInsets.only(left: 16.0, right: 16.0),
        //   child: Column(
        //     children: <Widget>[
        //       const SizedBox(height: 10),
        //       Row(
        //         children: <Widget>[
        //           Expanded(
        //             flex: 1,
        //             child: ElevatedButton.icon(
        //                 label: const Text(
        //                   'Add CV',
        //                   // style: textStyle
        //                 ),
        //                 icon: const Icon(
        //                   //  color: textColor,
        //                   Icons.person_add_outlined,
        //                   // color: Colors.white70,
        //                 ),
        //                 style: ElevatedButton.styleFrom(
        //                     padding: const EdgeInsets.only(top: 10, bottom: 10),
        //                     // foregroundColor: Colors.white70,
        //                     //  backgroundColor: color,
        //                     shape: const RoundedRectangleBorder(
        //                       borderRadius:
        //                           BorderRadius.all(Radius.circular(12.0)),
        //                     )),
        //                 onPressed: () {
        //                   initShowDialog();
        //                   enrollPerson(context);
        //                 }),
        //           ),
        //           const SizedBox(width: 20),
        //           Expanded(
        //             flex: 1,
        //             child: ElevatedButton.icon(
        //                 label: const Text(
        //                   'Attendance',
        //                   //style: textStyle
        //                 ),
        //                 icon: const Icon(
        //                   // color: textColor,
        //                   Icons.person_search_outlined,
        //                 ),
        //                 style: ElevatedButton.styleFrom(
        //                     padding: const EdgeInsets.only(top: 10, bottom: 10),
        //                     // backgroundColor: color,
        //                     shape: const RoundedRectangleBorder(
        //                       borderRadius:
        //                           BorderRadius.all(Radius.circular(12.0)),
        //                     )),
        //                 onPressed: () async {
        //                   initShowDialog();
        //                   List<Person> personList = await loadAllPersons();
        //                   Navigator.push(
        //                     context,
        //                     MaterialPageRoute(
        //                         builder: (context) => FaceRecognitionView(
        //                               personList: personList,
        //                               homePageState: this,
        //                             )),
        //                   );
        //                 }),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}

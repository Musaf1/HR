//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_database/firebase_database.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:intl/intl.dart';

// import 'package:file_picker/file_picker.dart';
// import 'dart:io' show File, HttpHeaders;

import 'dart:convert';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../UI/Dialogs.dart';
import 'Init.dart';
import 'Progress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

class Process {
  //final db = FirebaseFirestore.instance;
  static const color3 = Color.fromRGBO(0, 150, 150, 1);

  String baseUrl = "http://192.168.8.48:8000/api/";

  Future getData(s, {t}) async {
    try {
      var response = await http.get(
        Uri.parse(baseUrl + s),
        headers: {
          'Authorization': 'TOKEN $t',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return Future.error('Server Error');
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  Future setData(s, data, {t}) async {
    try {
      var response = await http.post(
        Uri.parse(baseUrl + s),
        body: jsonEncode(data),
        headers: t != null
            ? <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'TOKEN $t',
              }
            : <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return Future.error('Server Error');
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  Future updateData(s, data, t) async {
    try {
      var response = await http.put(
        Uri.parse(baseUrl + s),
        body: jsonEncode(data),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'TOKEN $t',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return Future.error('Server Error');
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  Future deleteData(s, t) async {
    try {
      var response = await http.delete(
        Uri.parse(baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'TOKEN $t',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return Future.error('Server Error');
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  Future addFace() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'mydb.db');
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE Face(templates BLOB , faceJpg BLOB )');
    });
    final facesdkPlugin = Init().facesdkPlugin;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getInt('id');
    var t = prefs.getString('token');
    var data = await getData('linkUser/', t: t);
    for (var d in data) {
      if (d['name'] == id) {
        if (d['image'] == 'http://192.168.8.48:8000/media/default.png') {
          await Fluttertoast.showToast(
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
          final faces = await facesdkPlugin.extractFaces(rotatedImage.path);
          if (faces.length == 1) {
            for (var face in faces) {
              await database.transaction((txn) async {
                await txn.rawInsert(
                    'INSERT INTO Face(templates, faceJpg) VALUES(?, ?)',
                    [face['templates'], face['faceJpg']]);
              });
              d['image'] = await MultipartFile.fromFile(image.path,
                  filename: "${d['id']}");
              FormData formData = FormData.fromMap(d);
              await Dio()
                  .put("http://192.168.8.48:8000/api/linkUser/${d['id']}/",
                      data: formData,
                      options: Options(
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                          'Authorization': 'TOKEN $t',
                        },
                      ));
              await Fluttertoast.showToast(
                  msg: "Your face added!",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  //backgroundColor: color,
                  textColor: color3,
                  fontSize: 16.0);
            }
          }
          if (faces.length > 1) {
            await Fluttertoast.showToast(
                msg: "More than face detected!",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                //backgroundColor: color,
                textColor: color3,
                fontSize: 16.0);
            await addFace();
          }
          if (faces.length == 0) {
            await Fluttertoast.showToast(
                msg: "No face detected!",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                //backgroundColor: color,
                textColor: color3,
                fontSize: 16.0);
            await addFace();
          }
        } else {
          http.Response response = await http.get(
            Uri.parse(d['image']),
          );
          Directory documentDirectory =
              await getApplicationDocumentsDirectory();
          File file = File(join(documentDirectory.path, 'face.png'));
          file.writeAsBytesSync(response.bodyBytes);
          final faces = await facesdkPlugin.extractFaces(file.path);
          for (var face in faces) {
            await database.transaction((txn) async {
              await txn.rawInsert(
                  'INSERT INTO Face(templates, faceJpg) VALUES(?, ?)',
                  [face['templates'], face['faceJpg']]);
            });
          }
        }
      }
    }
  }

  Future userAccess(context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var p = prefs.getString('token');
      // if (
      // FirebaseAuth.instance.currentUser!.emailVerified
      // ) {
      // var user = FirebaseAuth.instance.currentUser;
      if (p != null
          //await Process().haveCV(context, user?.email)
          ) {
        GoRouter.of(context).go('/ThePage');
      }
      // }
    } catch (e) {}
  }

  Future signUser(username, password, context, state) async {
    Progress().progress(context);
    // try {
    // await FirebaseAuth.instance
    //     .signInWithEmailAndPassword(email: emailAddress, password: password);
    var data = {
      "username": username.toString(),
      "password": password.toString()
    };
    var token = await setData('api-token-auth/', data);
    if (token['token'] != null) {
      var users = await getData('user/', t: token['token']);
      for (var user in users) {
        if (user['username'] == username) {
          var linIds = await getData('linkUser/', t: token['token']);
          for (var linId in linIds) {
            if (linId['user'] == user['id']) {
              var userInfo = await getData('employees_info/${linId['name']}/',
                  t: token['token']);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('id', userInfo['id']);
              await prefs.setString('name', userInfo['name']);
              await prefs.setString('phone', userInfo['contact'].toString());
              await prefs.setString('shift', userInfo['shift'].toString());
              await prefs.setString(
                  'department', userInfo['department'].toString());
              await prefs.setString('token', token['token'].toString());
              await userAccess(context);
              await addFace();
            }
          }
        }
      }

      //   var user = FirebaseAuth.instance.currentUser;
      //   if (!await Process().haveCV(context, user?.email)) {
      //     //print(_auth.currentUser?.displayName);
      //     await Process().enrollPerson(context, state, user?.email);
      //   }
      //   await userAccess(context);
      //   //GoRouter.of(context).go('/ThePage');
      // } else {
      //   Dialogs().verifyEmail(context);
      // }
      // await db.collection("person").get().then((querySnapshot) async {
      //   for (var docSnapshot in querySnapshot.docs) {
      //     if (docSnapshot.data()['email'] == emailAddress) {
      //       final prefs = await SharedPreferences.getInstance();
      //       await prefs.setString('personId', docSnapshot.id);
      //       Navigator.of(context).pop();
      //       await userAccess(context);
      //     }
    }
    // });
    // } else {
    //   await Dialogs().verifyEmail(context);
    // }
    // } on FirebaseAuthException catch (e) {
    //   if (e.code == 'invalid-credential') {
    //     Fluttertoast.showToast(
    //         msg: "Check your email and password",
    //         toastLength: Toast.LENGTH_LONG,
    //         gravity: ToastGravity.BOTTOM,
    //         timeInSecForIosWeb: 1,
    //         //backgroundColor: color,
    //         textColor: color3,
    //         fontSize: 16.0);
    //   }
    // }
    //Navigator.of(context).pop();
  }

  Future signOutUser(context) async {
    //await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    prefs.getString('att_time') != null ? await timeRecord() : null;
    await prefs.remove('id');
    await prefs.remove('name');
    await prefs.remove('phone');
    await prefs.remove('token');
    await prefs.remove('shift');
    await prefs.remove('department');
    await databaseFactory
        .deleteDatabase(join(await getDatabasesPath(), 'mydb.db'));
    GoRouter.of(context).go('/');
  }

  changePhoneNumber(context) async {
    String? phoneNum;
    Progress().progress(context);
    final prefs = await SharedPreferences.getInstance();
    var p = prefs.getInt('id');
    var t = prefs.getString('token');
    phoneNum = prefs.getString('phone');
    // await db.collection("person").doc(p).get().then((d) {
    //   phoneNum = d.data()!['phone'];
    // });
    phoneNum = await Dialogs().showDialogChangePhoneNumber(context, phoneNum!);
    var d = await getData('employees_info/$p/', t: t);
    d['contact'] = phoneNum;
    await prefs.setString('phone', phoneNum);
    await updateData('employees_info/$p/', d, t);
    // await db.collection("person").doc(p).update({"phone": phoneNum});

    Navigator.of(context).pop();
  }

  Future userShift() async {
    final prefs = await SharedPreferences.getInstance();
    var s = prefs.getString('shift');
    var t = prefs.getString('token');
    return await getData('shift/$s/', t: t);
    // var querySnapshot = db.collection("person").doc(id);
    // return await querySnapshot.get().then((docSnapshot) async {
    //var querySnapshot2 = db.collection("shift").doc('0');
    // return await querySnapshot2.get().then((docSnapshot2) {
    //   return docSnapshot2.data()![docSnapshot.data()!['id_shift']];
    //    });
    //  });
  }

  seconds(x) {
    var splited = x.split(':');
    return (int.parse(splited[0]) * 3600) + (int.parse(splited[1]) * 60);
  }

  Future<bool> canAttendance() async {
    var shift = await userShift();
    var getTime = await getData('time/');
    int time = seconds(getTime['time']);
    int start = seconds(shift['start']);
    int end = seconds(shift['end']);

    if (start <= time && time < end) {
      return true;
    }
    return false;
    // List<Person> person = await LoadPerson().loadPerson();
    // var id_att = person[0].id_att;
    // final prefs = await SharedPreferences.getInstance();
    // var id = prefs.getString('personId');
    // await db
    //     .collection("attendance")
    //     .doc(id_att)
    //     .update({"serverTimestamp": FieldValue.serverTimestamp()});
    // return await db.collection("attendance").doc(id_att).get().then((d) async {
    //   var time =
    //       readTimestampH(d.data()!['serverTimestamp'].millisecondsSinceEpoch);
    //   var data = await userShift(id);
    //   var start = data['start'];
    //   var end = data['end'];
    //   if (seconds(start) <= seconds(time) && seconds(time) < seconds(end)) {
    //     return true;
    //   }
    //   return false;
    // });
  }

  Future<int> timeRecord() async {
    var data = await getData('date/');
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('att_time') == null) {
      await prefs.setString('att_time', data['date'].toString());
    } else {
      var attTime = prefs.getString('att_time');
      var p = prefs.getInt('id');
      var t = prefs.getString('token');
      var time = (data['date'] - double.parse(attTime!)) / 3600;
      var d = await getData('employees_info/$p/', t: t);
      d['not_paid_hours'] = d['not_paid_hours'] + time;
      await updateData('employees_info/$p/', d, t);
      //todo long id
      var timeNow = await getData('time/');
      var td = {
        "name": p,
        "date": readTimestampD(double.parse(attTime).toInt()),
        "Time_attendace": readTimestampH(double.parse(attTime).toInt()),
        "time_leaves": timeNow['time']
      };
      await setData('attendace_info/', td, t: t);
      await prefs.remove('att_time');
    }
    return 1;
  }

  Future<bool> notDeparture() async {
    final prefs = await SharedPreferences.getInstance();
    var data = await getData('date/');
    if (prefs.getString('att_time') != null) {
      if ((await canAttendance()) &&
          (data['date'] - double.parse(prefs.getString('att_time')!) >
              86400.0)) {
        var attTime = prefs.getString('att_time');
        var shift = await userShift();
        int end = seconds(shift['end']);
        double time =
            (end - seconds(readTimestampH(double.parse(attTime!).toInt()))) /
                3600;
        var p = prefs.getInt('id');
        var t = prefs.getString('token');
        var d = await getData('employees_info/$p/', t: t);
        d['not_paid_hours'] = d['not_paid_hours'] + time;
        await updateData('employees_info/$p/', d, t);
        var td = {
          "name": p,
          "date": readTimestampD(double.parse(attTime).toInt()),
          "Time_attendace": readTimestampH(double.parse(attTime).toInt()),
          "time_leaves": shift['end']
        };
        await setData('attendace_info/', td, t: t);
        await prefs.remove('att_time');
      }
    }
    return await canAttendance();
  }

  Future<String> attStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('att_time') == null) {
      return 'Attendance';
    }
    return 'Departure';

    // List<Person> person = await LoadPerson().loadPerson();
// var id_att = person[0].id_att;
// var data = await timeStampNow(id_att);
// return await db.collection("attendance").doc(id_att).get().then((d) async {
//   List? isNull =
//       await d.data()?[readTimestampD(data.millisecondsSinceEpoch)];
//   if (isNull == null ||
//       ((d.data()![readTimestampD(data.millisecondsSinceEpoch)].length) %
//               2 ==
//           0)) {
//     return 'Attendance';
//   } else {// });
  }

  String readTimestampH(int timestamp) {
    //var now = DateTime.now();
    var format = DateFormat('HH:mm');
    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000000);
    // var diff = date.difference(now);
    var time = '';

    //if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
    time = format.format(date);
    // } else {
    //  if (diff.inDays == 1) {
    //    time = diff.inDays.toString() + 'DAY AGO';
    //   } else {
    //    time = diff.inDays.toString() + 'DAYS AGO';
    //  }
    //  }

    return time;
  }

  String readTimestampD(int timestamp) {
    var format = DateFormat('yyyy-MM-dd');
    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000000);
    var time = '';
    time = format.format(date);
    return time;
  }

  Future departmentPosition() async {
    final prefs = await SharedPreferences.getInstance();
    var deId = prefs.getString('department');
    var t = prefs.getString('token');
    var d = await getData('department_info/$deId/', t: t);
    return d['location'].split(',');
  }

  Future<bool> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.openAppSettings();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    }

    var d = await departmentPosition();
    var v = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return (Geolocator.distanceBetween(
            v.latitude, v.longitude, double.parse(d[0]), double.parse(d[1])) <=
        30.0);
  }
}

// Future timeStampNow(att_id) async {
//   // await db
//   //     .collection("attendance")
//   //     .doc(att_id)
//   //     .update({"serverTimestamp": FieldValue.serverTimestamp()});
//   // return await db.collection("attendance").doc(att_id).get().then((d) {
//   //   return d.data()!['serverTimestamp'];
//   // });
// }

// Future createUser(emailAddress, password, context) async {
//   try {
//     final credential =
//         await FirebaseAuth.instance.createUserWithEmailAndPassword(
//       email: emailAddress,
//       password: password,
//     );
//     await credential.user?.sendEmailVerification();
//     await signOutUser(context);
//     await Dialogs().verifyEmail(context);
//   } on FirebaseAuthException catch (e) {
//     if (e.code == 'weak-password') {
//       Fluttertoast.showToast(
//           msg: "The password provided is too weak.",
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 1,
//           //backgroundColor: color,
//           textColor: color3,
//           fontSize: 16.0);
//     } else if (e.code == 'email-already-in-use') {
//       Fluttertoast.showToast(
//           msg: "The account already exists for that email.",
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 1,
//           //backgroundColor: color,
//           textColor: color3,
//           fontSize: 16.0);
//     }
//   } catch (e) {
//     print(e);
//   }
// }

// Future sendPassword(email) async {
//   //await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
// }

// Future enrollPerson(BuildContext context, state, String? email) async {
//   final facesdkPlugin = Init().facesdkPlugin;
//   Progress().progress(context);
//   String idAtt = '', idBank = '', idDep = '', idShift = '', idLev = '';
//   final ref = FirebaseDatabase.instance.ref('Number/person');
//   await ref.set(ServerValue.increment(1));
//   final personNumber = await ref.get();
//
//   try {
//     Fluttertoast.showToast(
//         msg: "Pick CV file!",
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         //backgroundColor: color,
//         textColor: color3,
//         fontSize: 16.0);
//     FilePickerResult? resultFile = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['docx', 'pdf'],
//     );
//     File file = File(resultFile!.files.single.path.toString());
//     try {
//       final storageRef = FirebaseStorage.instance.ref();
//       final mountainsRef = storageRef.child("${personNumber.value}");
//       await mountainsRef.putFile(file);
//     } catch (e) {
//       Fluttertoast.showToast(
//           msg: "CV file Error!",
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 1,
//           //backgroundColor: color,
//           textColor: color3,
//           fontSize: 16.0);
//     }
//
//     Fluttertoast.showToast(
//         msg: "Add your face photo!",
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         //backgroundColor: color,
//         textColor: color3,
//         fontSize: 16.0);
//     final image = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (image == null) {
//       return;
//     }
//     var rotatedImage =
//         await FlutterExifRotation.rotateImage(path: image.path);
//     final faces = await facesdkPlugin.extractFaces(rotatedImage.path);
//     print(faces);
//     for (var face in faces) {
//       // ignore: use_build_context_synchronously
//       List info = await Dialogs().showDialogTextField(context, state);
//
//       await db.collection("attendance").add({"List": []}).then(
//           (documentSnapshot) => idAtt = documentSnapshot.id);
//       await db.collection("Leave").add({"List": []}).then(
//           (documentSnapshot) => idLev = documentSnapshot.id);
//       await db
//           .collection("bank_info")
//           .add({}).then((documentSnapshot) => idBank = documentSnapshot.id);
//       // await db
//       //     .collection("department")
//       //     .add({}).then((documentSnapshot) => idDep = documentSnapshot.id);
//       // await db
//       //     .collection("shift")
//       //     .add({}).then((documentSnapshot) => idShift = documentSnapshot.id);
//       await db.collection("person").doc("${personNumber.value}").set({
//        "gender": "${info[0]}",
//         "dob": info[1],
//         "email": email,
//         "phone": "${info[2]}",
//         "job": "${info[3]}",
//         "description": "${info[4]}",
//         "name": "${info[5]}",
//         "status": "cv",
//         "templates": face['templates'],
//         "faceJpg": face['faceJpg'],
//         "id_att": idAtt,
//         "id_bank": idBank,
//         "id_dep": idDep,
//         "id_shift": idShift,
//         "LeavesId": idLev,
//         "cv_path": "${personNumber.value}"
//       });
//
//       await Fluttertoast.showToast(
//           msg: "CV enrolled!",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 1,
//           // backgroundColor: color,
//           textColor: color3,
//           fontSize: 16.0);
//     }
//
//     if (faces.length == 0) {
//       await Fluttertoast.showToast(
//           msg: "No face detected!",
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 1,
//           //backgroundColor: color,
//           textColor: color3,
//           fontSize: 16.0);
//     }
//   } catch (e) {
//     debugPrint(e.toString());
//   }
//   Navigator.of(context).pop();
// }

// Future enrollLeave(BuildContext context, state) async {
//   Progress().progress(context);
//   List<Person> personList = await LoadPerson().loadPerson();
//   await FirebaseDatabase.instance
//       .ref('Number')
//       .child('Leave')
//       .set(ServerValue.increment(1));
//
//   try {
//     List info = await Dialogs().showDialogLeaveTextField(context, state);
//     await db.collection("Leave").doc(personList[0].LeavesId).update({
//       "List": FieldValue.arrayUnion([
//         {
//           "reason": "${info[0]}",
//           "start": info[1],
//           "end": info[2],
//           "description": "${info[3]}",
//           "sickLeavePatch": info[4],
//         }
//       ])
//     });
//
//     await Fluttertoast.showToast(
//         msg: "Leave duration enrolled!",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         // backgroundColor: color,
//         textColor: color3,
//         fontSize: 16.0);
//   } catch (e) {
//     await Fluttertoast.showToast(
//         msg: "Leave Error!",
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         //backgroundColor: color,
//         textColor: color3,
//         fontSize: 16.0);
//     debugPrint(e.toString());
//   }
//   Navigator.of(context).pop();
// }

// Future<bool> haveCV(context, email) async =>
//     await db.collection("person").get().then((querySnapshot) async {
//       for (var docSnapshot in querySnapshot.docs) {
//         if (docSnapshot.data()['email'] == email) {
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString('personId', docSnapshot.id);
//           List<Person> person = await LoadPerson().loadPerson();
//           await prefs.setString('personStatus', person[0].status);
//
//           return true;
//         }
//       }
//       return false;
//     });

// personStatusPage() async {
//   final prefs = await SharedPreferences.getInstance();
//   var p = prefs.getString('personStatus');
//   switch (p) {
//     case "emp":
//       return const EmployedPage();
//     case "cv":
//       return const CVPage();
//     case "int":
//       return const InterviewPage();
//   }
// }
//
// Future<List<String>> loadJobs() {
//   return db.collection("job_opportunities").doc('0').get().then(
//       (docSnapshot) => (docSnapshot.data()!['jobs'] as List)
//           .map((item) => item as String)
//           .toList());
// }

// getDepartment() async {
//   final prefs = await SharedPreferences.getInstance();
//   var p = prefs.getString('personId');
//   return await db.collection("person").doc(p).get().then((docSnapshot1) => db
//       .collection("department")
//       .doc('0')
//       .get()
//       .then((docSnapshot2) =>
//           (docSnapshot2.data()![(docSnapshot1.data()!['id_dep'])])));
// }

// getShift() async {
//   final prefs = await SharedPreferences.getInstance();
//   var p = prefs.getString('personId');
//   return await db.collection("person").doc(p).get().then((docSnapshot1) => db
//       .collection("shift")
//       .doc('0')
//       .get()
//       .then((docSnapshot2) =>
//           (docSnapshot2.data()![(docSnapshot1.data()!['id_shift'])])));
// }

// Future<void> deletePerson(context) async {
//   final storageRef = FirebaseStorage.instance.ref();
//   final prefs = await SharedPreferences.getInstance();
//   var p = prefs.getString('personId');
//   Progress().progress(context);
//   db.collection("person").doc(p).delete();
//   final desertRef = storageRef.child(p!);
//   await desertRef.delete();
//   Navigator.of(context).pop();
// }

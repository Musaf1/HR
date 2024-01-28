
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../Data/person.dart';
import '../UI/CV.dart';
import '../UI/Dialogs.dart';
import '../UI/Employed.dart';
import '../UI/Interview.dart';
import 'Init.dart';
import 'Progress.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show File;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';


class Process {
  final db = FirebaseFirestore.instance;
  static const color3 = Color.fromRGBO(0, 150, 150, 1);

  Future createUser(emailAddress, password, context) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      await credential.user?.sendEmailVerification();
      await signOutUser(context);
      await Dialogs().verifyEmail(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(
            msg: "The password provided is too weak.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: color,
            textColor: color3,
            fontSize: 16.0);
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
            msg: "The account already exists for that email.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: color,
            textColor: color3,
            fontSize: 16.0);
      }
    } catch (e) {
      print(e);
    }
  }

  Future userAccess(context) async {
    try {
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        var user = FirebaseAuth.instance.currentUser;
        if (await Process().haveCV(context, user?.email)) {
          GoRouter.of(context).go('/ThePage');
        }
      }
    } catch (e) {}
  }

  Future sendPassword(email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future signUser(emailAddress, password, context, state) async {
    Progress().progress(context);
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        var user = FirebaseAuth.instance.currentUser;
        if (!await Process().haveCV(context, user?.email)) {
          //print(_auth.currentUser?.displayName);
          await Process().enrollPerson(context, state, user?.email);
        }
        await userAccess(context);
        //GoRouter.of(context).go('/ThePage');
      } else {
        Dialogs().verifyEmail(context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        Fluttertoast.showToast(
            msg: "Check your email and password",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: color,
            textColor: color3,
            fontSize: 16.0);
      }
    }
    Navigator.of(context).pop();
  }

  Future signOutUser(context) async {
    await FirebaseAuth.instance.signOut();
    GoRouter.of(context).go('/');
  }

  userShift(id) async {
    var querySnapshot = db.collection("person").doc(id);
    return await querySnapshot.get().then((docSnapshot) async {
      var querySnapshot2 = db.collection("shift").doc('0');
      return await querySnapshot2.get().then((docSnapshot2) {
        return docSnapshot2.data()![docSnapshot.data()!['id_shift']];
      });
    });
  }

  String readTimestampH(int timestamp) {
    //var now = DateTime.now();
    var format = DateFormat('HH:mm');
    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
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
    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
    var time = '';
    time = format.format(date);
    return time;
  }

  seconds(x) {
    var splited = x.split(':');
    return (int.parse(splited[0]) * 3600) + (int.parse(splited[1]) * 60);
  }

  Future<bool> canAttendance() async {
    List<Person> person = await LoadPerson().loadPerson();
    var id_att = person[0].id_att;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('personId');
    await db
        .collection("attendance")
        .doc(id_att)
        .update({"serverTimestamp": FieldValue.serverTimestamp()});
    return await db.collection("attendance").doc(id_att).get().then((d) async {
      var time =
          readTimestampH(d.data()!['serverTimestamp'].millisecondsSinceEpoch);
      var data = await userShift(id);
      var start = data['start'];
      var end = data['end'];
      if (seconds(start) <= seconds(time) && seconds(time) < seconds(end)) {
        return true;
      }
      return false;
    });
  }

  Future enrollPerson(BuildContext context, state, String? email) async {
    final facesdkPlugin = Init().facesdkPlugin;
    Progress().progress(context);
    String idAtt = '', idBank = '', idDep = '', idShift = '', idLev = '';
    final ref = FirebaseDatabase.instance.ref('Number/person');
    await ref.set(ServerValue.increment(1));
    final personNumber = await ref.get();

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
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }
      var rotatedImage =
          await FlutterExifRotation.rotateImage(path: image.path);
      final faces = await facesdkPlugin.extractFaces(rotatedImage.path);
      print(faces);
      for (var face in faces) {
        // ignore: use_build_context_synchronously
        List info = await Dialogs().showDialogTextField(context, state);

        await db.collection("attendance").add({"List": []}).then(
            (documentSnapshot) => idAtt = documentSnapshot.id);
        await db.collection("Leave").add({"List": []}).then(
            (documentSnapshot) => idLev = documentSnapshot.id);
        await db
            .collection("bank_info")
            .add({}).then((documentSnapshot) => idBank = documentSnapshot.id);
        // await db
        //     .collection("department")
        //     .add({}).then((documentSnapshot) => idDep = documentSnapshot.id);
        // await db
        //     .collection("shift")
        //     .add({}).then((documentSnapshot) => idShift = documentSnapshot.id);
        await db.collection("person").doc("${personNumber.value}").set({
         "gender": "${info[0]}",
          "dob": info[1],
          "email": email,
          "phone": "${info[2]}",
          "job": "${info[3]}",
          "description": "${info[4]}",
          "name": "${info[5]}",
          "status": "cv",
          "templates": face['templates'],
          "faceJpg": face['faceJpg'],
          "id_att": idAtt,
          "id_bank": idBank,
          "id_dep": idDep,
          "id_shift": idShift,
          "LeavesId": idLev,
          "cv_path": "${personNumber.value}"
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

  Future enrollLeave(BuildContext context, state) async {
    Progress().progress(context);
    List<Person> personList = await LoadPerson().loadPerson();
    await FirebaseDatabase.instance
        .ref('Number')
        .child('Leave')
        .set(ServerValue.increment(1));

    try {
      List info = await Dialogs().showDialogLeaveTextField(context, state);
      await db.collection("Leave").doc(personList[0].LeavesId).update({
        "List": FieldValue.arrayUnion([
          {
            "reason": "${info[0]}",
            "start": info[1],
            "end": info[2],
            "description": "${info[3]}",
            "sickLeavePatch": info[4],
          }
        ])
      });

      await Fluttertoast.showToast(
          msg: "Leave duration enrolled!",
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

  changePhoneNumber(context) async {
    var phoneNum;
    Progress().progress(context);
    final prefs = await SharedPreferences.getInstance();
    var p = prefs.getString('personId');
    await db.collection("person").doc(p).get().then((d) {
      phoneNum = d.data()!['phone'];
    });
    phoneNum = await Dialogs().showDialogChangePhoneNumber(context, phoneNum);
    await db.collection("person").doc(p).update({"phone": phoneNum});

    Navigator.of(context).pop();
  }

  Future<int> timeId(att_id, context) async {
    var data = await timeStampNow(att_id);
    await db.collection("attendance").doc(att_id).update({
      readTimestampD(data.millisecondsSinceEpoch): FieldValue.arrayUnion([data])
    });
    await attStatus();
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
    return 1;
  }

  Future timeStampNow(att_id) async {
    await db
        .collection("attendance")
        .doc(att_id)
        .update({"serverTimestamp": FieldValue.serverTimestamp()});
    return await db.collection("attendance").doc(att_id).get().then((d) {
      return d.data()!['serverTimestamp'];
    });
  }

  Future<String> attStatus() async {
    List<Person> person = await LoadPerson().loadPerson();
    var id_att = person[0].id_att;
    var data = await timeStampNow(id_att);
    return await db.collection("attendance").doc(id_att).get().then((d) async {
      List? isNull = await d.data()?[readTimestampD(data.millisecondsSinceEpoch)];
      if (isNull == null ||
          ((d.data()![readTimestampD(data.millisecondsSinceEpoch)].length) %
                  2 ==
              0)) {
        return 'Attendance';
      } else {
        return 'Departure';
      }
    });
  }

  Future<bool> haveCV(context, email) async =>
      await db.collection("person").get().then((querySnapshot) async {
        for (var docSnapshot in querySnapshot.docs) {
          if (docSnapshot.data()['email'] == email) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('personId', docSnapshot.id);
            List<Person> person = await LoadPerson().loadPerson();
            await prefs.setString('personStatus', person[0].status);

            return true;
          }
        }
        return false;
      });

  personStatusPage() async {
    final prefs = await SharedPreferences.getInstance();
    var p = prefs.getString('personStatus');
    switch (p) {
      case "emp":
        return const EmployedPage();
      case "cv":
        return const CVPage();
      case "int":
        return const InterviewPage();
    }
  }

  Future<List<String>> loadJobs() {
    return db.collection("job_opportunities").doc('0').get().then(
        (docSnapshot) => (docSnapshot.data()!['jobs'] as List)
            .map((item) => item as String)
            .toList());
  }

  getDepartment() async {
    final prefs = await SharedPreferences.getInstance();
    var p = prefs.getString('personId');
    return await db.collection("person").doc(p).get().then((docSnapshot1) => db
        .collection("department")
        .doc('0')
        .get()
        .then((docSnapshot2) =>
            (docSnapshot2.data()![(docSnapshot1.data()!['id_dep'])])));
  }

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

  Future<void> deletePerson(context) async {
    final storageRef = FirebaseStorage.instance.ref();
    final prefs = await SharedPreferences.getInstance();
    var p = prefs.getString('personId');
    Progress().progress(context);
    db.collection("person").doc(p).delete();
    final desertRef = storageRef.child(p!);
    await desertRef.delete();
    Navigator.of(context).pop();
  }
}

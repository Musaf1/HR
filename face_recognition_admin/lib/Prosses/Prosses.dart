import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:mysql1/mysql1.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import '../View/Dialogs/Dialogs.dart';
import '../person.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:email_sender/email_sender.dart';

class Prosses {
  var settings = ConnectionSettings(
      host: '192.168.8.231',
      port: 3306,
      user: 'musa',
      password: '2002',
      db: 'dbm');
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

  Future<void> openCV(id) async {
    String path = '';
    var conn = await MySqlConnection.connect(settings);
    var result = await conn.query('select cvpath from cv where id=?', [id]);

    for (var row in result) {
      path = row[0];
    }
    final client = SSHClient(
      await SSHSocket.connect('192.168.8.231', 22),
      username: 'musa',
      onPasswordRequest: () => '2002',
    );
    final sftp = await client.sftp();
    final file = await sftp.open(path);
    final content = await file.readBytes();
    File('C:/Users/Musa/AndroidStudioProjects/face_recognition_admin/lib/cv.docx')
        .writeAsBytes(content);
    await OpenAppFile.open(
        "C:/Users/Musa/AndroidStudioProjects/face_recognition_admin/lib/cv.docx");
  }

  Future<List<Person>> loadAllPersons(text) async {
    List personList = [];
    var conn = await MySqlConnection.connect(settings);
    var maps = await conn.query(text);

    try {
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
          'endWork': row[11],
          'ivt': row[13]
        });
      }
    } catch (e) {
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
          'endWork': row[11],
        });
      }
    }

    return List.generate(personList.length, (i) {
      return Person.fromMap(personList[i]);
    });
  }

  String dateFormatOnly(date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> deletePerson(index, text, currentPersonList, context, state,
      {text2}) async {
    var conn = await MySqlConnection.connect(settings);
    await conn.query(text, [currentPersonList[index].id]);
    if (text2 != null) {
      await conn.query(text2, [currentPersonList[index].id]);
    }
    state.setState(() {
      currentPersonList.removeAt(index);
    });
    FlutterToastr.show("Person removed!", context,
        duration: FlutterToastr.lengthShort, position: FlutterToastr.bottom);
  }

  Future<void> infoPerson(index, currentPersonList, context) async {
    List attendanceList = [];
    var conn = await MySqlConnection.connect(settings);
    var attendance = await conn.query('select time from attendance  where id=?',
        [currentPersonList[index].id]);
    for (var row in attendance) {
      attendanceList.add(dateFormat(row[0]));
    }
    Dialogs().showDialogInfo(
        currentPersonList[index].id,
        currentPersonList[index].name,
        currentPersonList[index].gender,
        currentPersonList[index].dob,
        currentPersonList[index].email,
        currentPersonList[index].phone,
        currentPersonList[index].job,
        currentPersonList[index].faceJpg,
        currentPersonList[index].description,
        timeOfDateFormat(
            minutesToTimeOfDay(currentPersonList[index].startWork), context),
        timeOfDateFormat(
            minutesToTimeOfDay(currentPersonList[index].endWork), context),
        attendanceList,
        context);
  }

  // Future<void> editPerson(index, currentPersonList, context, state) async {
  //   String name = '';
  //   String job = '';
  //   dynamic startWork;
  //   dynamic endWork;
  //   var conn = await MySqlConnection.connect(settings);
  //   var result = await conn.query(
  //       'select name, job, startWork, endWork from person where id=?',
  //       [currentPersonList[index].id]);
  //
  //   for (var row in result) {
  //     name = row[0];
  //     job = row[1];
  //     startWork = row[2];
  //     endWork = row[3];
  //   }
  //
  //   List info = await Dialogs().showDialogTextField(name, job,
  //       minutesToTimeOfDay(startWork), minutesToTimeOfDay(endWork), context);
  //
  //   await conn.query(
  //       'update person set name=?, job=?, startWork=?, endWork=? where id=?',
  //       [info[0], info[1], info[2], info[3], currentPersonList[index].id]);
  //   List<Person> personList = await loadAllPersons('select * from person');
  //   state.setState(() {
  //     currentPersonList = personList;
  //   });
  //   FlutterToastr.show("Person edited!", context,
  //       duration: FlutterToastr.lengthShort, position: FlutterToastr.bottom);
  // }

  Future<void> addPersonToInterview(
      index, currentPersonList, context, state) async {
    var date =
        dateFormatOnly(await Dialogs().datePicker('Interview Date', context));
    var time = timeOfDateFormat(
        await Dialogs().timePicker(
            'Interview Time', const TimeOfDay(hour: 9, minute: 00), context),
        context);
    String body= await Dialogs().showDialogEmailBody(context);
    EmailSender emailsender = EmailSender();
     await emailsender.sendMessage(currentPersonList[index].email,"Job interview","job interview in the company",'$body \nplease come $date $time');

    var conn = await MySqlConnection.connect(settings);
    var result = await conn
        .query('select * from cv where id=?', [currentPersonList[index].id]);
    //print(result);
    for (var row in result) {
      await conn.query(
          'insert into interview (name, gender, dob, email, phone, job, faceJpg, template, description, startWork, endWork, cvpath, ivt) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            row[1],
            row[2],
            row[3],
            row[4],
            row[5],
            row[6],
            row[7],
            row[8],
            row[9],
            timeOfDateFormat(minutesToTimeOfDay(row[10]), context),
            timeOfDateFormat(minutesToTimeOfDay(row[11]), context),
            row[12],
            '$date $time'
          ]);
    }
    await deletePerson(
        index, 'delete from cv  where id=?', currentPersonList, context, state);

    List<Person> personList = await loadAllPersons('select * from cv');
    state.setState(() {
      currentPersonList = personList;
    });
    FlutterToastr.show("Person add!", context,
        duration: FlutterToastr.lengthShort, position: FlutterToastr.bottom);
  }

  Future<void> addPersonToJob(index, currentPersonList, context, state) async {
    String startWork = timeOfDateFormat(
        await Dialogs().timePicker(
            'Start Work', const TimeOfDay(hour: 9, minute: 00), context),
        context);
    String endWork = timeOfDateFormat(
        await Dialogs().timePicker(
            'End Work', const TimeOfDay(hour: 17, minute: 00), context),
        context);
    String body= await Dialogs().showDialogEmailBody(context);
    EmailSender emailsender = EmailSender();
    await emailsender.sendMessage(currentPersonList[index].email,"Job interview","job interview in the company",'$body \nplease come $date $time');

    var conn = await MySqlConnection.connect(settings);
    var result = await conn.query(
        'select * from interview where id=?', [currentPersonList[index].id]);
    //print(result);
    for (var row in result) {
      await conn.query(
          'insert into person (name, gender, dob, email, phone, job, faceJpg, template, description, startWork, endWork, cvpath) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            row[1],
            row[2],
            row[3],
            row[4],
            row[5],
            row[6],
            row[7],
            row[8],
            row[9],
            startWork,
            endWork,
            row[12]
          ]);
    }
    await deletePerson(index, 'delete from interview  where id=?',
        currentPersonList, context, state);

    List<Person> personList = await loadAllPersons('select * from person');
    state.setState(() {
      currentPersonList = personList;
    });
    FlutterToastr.show("Person add!", context,
        duration: FlutterToastr.lengthShort, position: FlutterToastr.bottom);
  }

  String dateFormat(date) {
    return DateFormat('yyyy-MM-dd kk:mm:ss').format(date);
  }

  Future<TimeOfDay?> timePicker(text, time, context) {
    return showTimePicker(
      helpText: text,
      initialTime: time,
      context: context,
    );
  }

  String timeOfDateFormat(timeOfDate, context) {
    return MaterialLocalizations.of(context)
        .formatTimeOfDay(timeOfDate!, alwaysUse24HourFormat: true);
  }

  TimeOfDay minutesToTimeOfDay(Duration minutes) {
    List<String> parts = minutes.toString().split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

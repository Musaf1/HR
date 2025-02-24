// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:go_router/go_router.dart';
import 'package:mac_address/mac_address.dart';
import 'package:path_provider/path_provider.dart';
import '../Widget/Dialogs.dart';
import 'init.dart';
import 'progress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'dart:math' as math;

class Process {
  static const color3 = Color.fromRGBO(0, 150, 150, 1);

  String baseUrl = "https://ems-70yg.onrender.com/";
  String apiUrl = "https://ems-70yg.onrender.com/api/";
  //todo https

  // get data http
  Future getData(string, {text}) async {
    try {
      var response = await http.get(
        Uri.parse(apiUrl + string),
        headers: {
          'Authorization': 'TOKEN $text',
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

  // set data http
  Future setData(string, data, {text}) async {
    try {
      var response = await http.post(
        Uri.parse(apiUrl + string),
        body: jsonEncode(data),
        headers: text != null
            ? <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'TOKEN $text',
              }
            : <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return 'Server Error';
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  // update data http
  Future updateData(string, data, text) async {
    try {
      var response = await http.put(
        Uri.parse(apiUrl + string),
        body: jsonEncode(data),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'TOKEN $text',
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

  //add user face in app and store in server
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
    var token = prefs.getString('token');
    var data = await getData('linkUser/', text: token);
    for (var d in data) {
      if (d['name'] == id) {
        if (d['image'] == '${baseUrl}media/default.png' || d['image'] == null) {
          await Fluttertoast.showToast(
              msg: "Add your face photo!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
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
              await Dio().put("${apiUrl}linkUser/${d['id']}/",
                  data: formData,
                  options: Options(
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                      'Authorization': 'TOKEN $token',
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

  //user access to home page
  Future userAccess(context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getInt('change_mac')! < 4) {
        GoRouter.of(context).go('/EmployedPage');
      } else {
        await Dialogs().changeMac(context,
            'You cannot change the device any more time, for help ask IT support',
            b: false);
        await signOutUser(context);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //sign user and store the information about it
  Future signUser(username, password, context, state) async {
    Progress().progress(context);
    var data = {
      "username": username.toString(),
      "password": password.toString()
    };
    var token = await setData('api-token-auth/', data);
    if (token != "Server Error") {
      var users = await getData('user/', text: token['token']);
      for (var user in users) {
        if (user['username'] == username) {
          var linIds = await getData('linkUser/', text: token['token']);
          for (var linId in linIds) {
            if (linId['user'] == user['id']) {
              var userInfo = await getData('employees_info/${linId['name']}/',
                  text: token['token']);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('change_mac', linId['change_mac']);
              await prefs.setInt('id', userInfo['id']);
              await prefs.setInt('uid', user['id']);
              await prefs.setString('name', userInfo['name']);
              await prefs.setInt('build', userInfo['build']);
              await prefs.setString('token', token['token'].toString());
              await getMac(linId, context);
              await addFace();
            }
          }
        }
      }
    } else {
      Navigator.of(context).pop();
      Dialogs().showDialogFun(context, state, 'Not Authenticated');
    }
  }

  //sign out user and remove data
  Future signOutUser(context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.getString('att_time') != null ? await timeRecord() : null;
    await prefs.remove('id');
    await prefs.remove('name');
    await prefs.remove('token');
    await prefs.remove('build');
    await prefs.remove('change_mac');
    await databaseFactory
        .deleteDatabase(join(await getDatabasesPath(), 'mydb.db'));
    GoRouter.of(context).go('/');
  }

  // record attendance in server
  Future timeRecord({task = false}) async {
    var data = await getData('date/');
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('att_time') == null) {
      await prefs.setString('att_time', data['date'].toString());
    } else {
      var attTime = prefs.getString('att_time');
      var p = prefs.getInt('id');
      var t = prefs.getString('token');
      var timeNow = await getData('time/');
      int time1 = timeToInt(readTimestampH(double.parse(attTime!).toInt()));
      int time2 = timeToInt(task ? "16:00" : timeNow['time']);
      var td = {
        "name": p,
        "date": readTimestampD(double.parse(attTime).toInt()),
        "Time_attendace": readTimestampH(double.parse(attTime).toInt()),
        "time_leaves": task ? "16:00" : timeNow['time'],
        "total_time": (math.max(time1, time2) - math.min(time1, time2)) / 60,
      };
      await setData('attendace_info/', td, text: t);
      await prefs.remove('att_time');
    }
  }

  //handle if user do not departure manually
  Future notDeparture() async {
    final prefs = await SharedPreferences.getInstance();
    var data = await getData('date/');
    if (prefs.getString('att_time') != null) {
      if ((data['date'] - double.parse(prefs.getString('att_time')!) >
          86400.0)) {
        var attTime = prefs.getString('att_time');
        var p = prefs.getInt('id');
        var t = prefs.getString('token');
        var td = {
          "name": p,
          "date": readTimestampD(double.parse(attTime!).toInt()),
          "Time_attendace": readTimestampH(double.parse(attTime).toInt()),
          "time_leaves": "12:00"
        };
        await setData('attendace_info/', td, text: t);
        await prefs.remove('att_time');
      }
    }
    return true;
  }

  //check attendance status
  Future<String> attStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('att_time') == null) {
      return 'Attendance';
    }
    return 'Departure';
  }

  //get building position
  Future buildPosition() async {
    final prefs = await SharedPreferences.getInstance();
    var deId = prefs.getInt('build');
    var t = prefs.getString('token');
    var d = await getData('building_info/$deId/', text: t);
    return d['location'].split(',');
  }

  //check the distance
  Future<double> buildingPosition() async {
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

    var d = await buildPosition();
    var v = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return Geolocator.distanceBetween(
            v.latitude, v.longitude, double.parse(d[0]), double.parse(d[1]));
  }

  //get mac address or android id
  Future getMac(linId, context) async {
    final prefs = await SharedPreferences.getInstance();
    var mac = await GetMac.macAddress == ""
        ? await const AndroidId().getId()
        : await GetMac.macAddress;
    if (linId['mac'] != mac) {
      if (linId['change_mac']! < 4) {
        int macNum = 4 - prefs.getInt('change_mac')!;
        if (macNum == 1) {
          await Dialogs().changeMac(
              context, 'You can change device 1 more time',
              linId: linId);
        } else {
          await Dialogs().changeMac(
              context, 'You can change device $macNum more times',
              linId: linId);
        }
      } else {
        await Dialogs().changeMac(context,
            'You cannot change the device any more time, for help ask IT support',
            b: false);
      }
    } else {
      await userAccess(context);
    }
  }

  //store mac address in the server
  Future updateMac(linId, context) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var data = {
      "mac": await GetMac.macAddress == ""
          ? await const AndroidId().getId()
          : await GetMac.macAddress,
      "change_mac": linId['change_mac'] + 1,
      "name": linId['name']
    };
    await prefs.setInt('change_mac', linId['change_mac']);
    await updateData('linkUser/${linId['id']}/', data, token);
    await userAccess(context);
  }

  //add task leave
  Future addTaskLeave(String d) async {
    var intDate = await getData('date/');
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var p = prefs.getInt('uid');
    String date = readTimestampD(intDate['date'].toInt());
    var data = {
      "startdate": date,
      "enddate": date,
      "leavetype": "task",
      "reason": d,
      "user": p
    };
    await setData('leave/', data, text: token);
  }

  //check if user can attendance
  Future<bool> canAttendance() async {
    var getTime = await getData('time/');
    int time = seconds(getTime['time']);
    int start = seconds("7:45");
    int end = seconds("16:15");

    //todo if (start <= time && time < end) {
    final prefs = await SharedPreferences.getInstance();
    var t = prefs.getString('token');
    var intDate = await getData('date/');
    var data = await getData('attendace_info/', text: t);
    var p = prefs.getInt('id');
    String date = readTimestampD(intDate['date'].toInt());
    for (var d in data) {
      if (d["date"] == date && d["name"] == p) {
        return false;
      }
    }
    return true;
    // }
    // return false;
  }

  //convert time stamp to string
  String readTimestampH(int timestamp) {
    var format = DateFormat('HH:mm');
    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000000);
    var time = '';
    time = format.format(date);
    return time;
  }

  //convert time stamp to string
  String readTimestampD(int timestamp) {
    var format = DateFormat('yyyy-MM-dd');
    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000000);
    var time = '';
    time = format.format(date);
    return time;
  }

  //convert string timestamp to minutes
  int timeToInt(String timeString) {
    final hours = int.parse(timeString.substring(0, 2));
    final minutes = int.parse(timeString.substring(3));
    return hours * 60 + minutes;
  }

  //convert string timestamp to seconds
  seconds(string) {
    var splited = string.split(':');
    return (int.parse(splited[0]) * 3600) + (int.parse(splited[1]) * 60);
  }
}

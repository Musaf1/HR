import 'dart:io';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:go_router/go_router.dart';
import 'package:mac_address/mac_address.dart';
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
import 'dart:math' as math;

class Process {
  static const color3 = Color.fromRGBO(0, 150, 150, 1);

  String baseUrl = "http://192.168.8.132:8000/";
  String apiUrl = "http://192.168.8.132:8000/api/";

  Future getData(s, {t}) async {
    try {
      var response = await http.get(
        Uri.parse(apiUrl + s),
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
        Uri.parse(apiUrl + s),
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        if (response.statusCode == 400) {
          return jsonDecode(response.body);
        }
        return Future.error('Server Error');
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  Future updateData(s, data, t) async {
    try {
      var response = await http.put(
        Uri.parse(apiUrl + s),
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
      //user['mac'] == mac ? await signOutUser(context) : null;
      if (prefs.getInt('change_mac')! < 4) {
        GoRouter.of(context).go('/EmployedPage');
      } else {
        await Dialogs().changeMac(context,
            'You cannot change the device any more time, for help ask IT support',
            b: false);
        await signOutUser(context);
      }
      // }
    } catch (e) {}
  }

  Future signUser(username, password, context, state) async {
    Progress().progress(context);
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
          print(linIds);
          for (var linId in linIds) {
            print(linId);
            if (linId['user'] == user['id']) {
              var userInfo = await getData('employees_info/${linId['name']}/',
                  t: token['token']);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('change_mac', user['change_mac']);
              await prefs.setInt('id', userInfo['id']);
              await prefs.setInt('uid', user['id']);
              await prefs.setString('name', userInfo['name']);
              await prefs.setInt('build', userInfo['build']);
              await prefs.setString('token', token['token'].toString());
              await getMac(user, context);
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

  seconds(x) {
    var splited = x.split(':');
    return (int.parse(splited[0]) * 3600) + (int.parse(splited[1]) * 60);
  }

  Future<int> timeRecord({task = false}) async {
    var data = await getData('date/');
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('att_time') == null) {
      await prefs.setString('att_time', data['date'].toString());
    } else {
      var attTime = prefs.getString('att_time');
      var p = prefs.getInt('id');
      var t = prefs.getString('token');
      //todo long id
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
      await setData('attendace_info/', td, t: t);
      await prefs.remove('att_time');
    }
    return 1;
  }

  Future notDeparture() async {
    final prefs = await SharedPreferences.getInstance();
    var data = await getData('date/');
    if (prefs.getString('att_time') != null) {
      if (
          (data['date'] - double.parse(prefs.getString('att_time')!) >
              86400.0)) {
        var attTime = prefs.getString('att_time');
        var p = prefs.getInt('id');
        var t = prefs.getString('token');
        var td = {
          "name": p,
          "date": readTimestampD(double.parse(attTime!).toInt()),
          "Time_attendace": readTimestampH(double.parse(attTime).toInt()),
          "time_leaves": "16:00"
        };
        await setData('attendace_info/', td, t: t);
        await prefs.remove('att_time');
      }
    }
    return true;
  }

  Future<String> attStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('att_time') == null) {
      return 'Attendance';
    }
    return 'Departure';

  }

  String readTimestampH(int timestamp) {
    var format = DateFormat('HH:mm');
    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000000);
    var time = '';
    time = format.format(date);
    return time;
  }

  String readTimestampD(int timestamp) {
    var format = DateFormat('yyyy-MM-dd');
    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000000);
    var time = '';
    time = format.format(date);
    return time;
  }

  Future buildPosition() async {
    final prefs = await SharedPreferences.getInstance();
    var deId = prefs.getInt('build');
    var t = prefs.getString('token');
    var d = await getData('building_info/$deId/', t: t);
    return d['location'].split(',');
  }

  Future<bool> buildingPosition() async {
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
    //todo 0.7 / 6362.72
    return (Geolocator.distanceBetween(
            v.latitude, v.longitude, double.parse(d[0]), double.parse(d[1])) <=
        10000);
  }

  Future getMac(user, context) async {
    final prefs = await SharedPreferences.getInstance();
    var mac = await GetMac.macAddress;
    if (user['mac'] != mac) {
      if (user['change_mac']! < 4) {
        int i = 4 - prefs.getInt('change_mac')!;
        if (i == 1) {
          await Dialogs().changeMac(
              context, 'You can change device 1 more time',
              user: user);
        } else {
          await Dialogs().changeMac(
              context, 'You can change device $i more times',
              user: user);
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

  Future updateMac(user, context) async {
    final prefs = await SharedPreferences.getInstance();
    var t = prefs.getString('token');
    var p = prefs.getInt('uid');
    user['mac'] = await GetMac.macAddress;
    user['change_mac'] += 1;
    await prefs.setInt('change_mac', user['change_mac']);
    await updateData('user/$p/', user, t);
    await userAccess(context);
  }

  Future addTaskLeave(String d) async {
    var intDate = await getData('date/');
    final prefs = await SharedPreferences.getInstance();
    var t = prefs.getString('token');
    var p = prefs.getInt('uid');
    String date = readTimestampD(intDate['date'].toInt());
    var data = {
      "startdate": date,
      "enddate": date,
      "leavetype": "task",
      "reason": d,
      "user": p
    };
    await setData('leave/', data, t: t);
  }

  Future<bool> canAttendance() async {
    var getTime = await getData('time/');
    int time = seconds(getTime['time']);
    int start = seconds("8:00");
    int end = seconds("16:00");

    //if (start <= time && time < end) {
    final prefs = await SharedPreferences.getInstance();
    var t = prefs.getString('token');
    var intDate = await getData('date/');
    var data = await getData('attendace_info/', t: t);
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

  int timeToInt(String timeString) {
    final hours = int.parse(timeString.substring(0, 2));
    final minutes = int.parse(timeString.substring(3));
    return hours * 60 + minutes;
  }
}


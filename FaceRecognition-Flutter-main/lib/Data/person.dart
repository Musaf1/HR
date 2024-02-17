// import 'dart:typed_data';
// //import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class Person {
//   final int id;
//   final String name;
//   //final String LeavesId;
//   //final String status;
//
//   // final String gender;
//   // final String dob;
//   // final String email;
//   // final String phone;
//   // final String job;
//   final Uint8List faceJpg;
//   final Uint8List templates;
//
//   // final String description;
//   // final Duration startWork;
//   // final Duration endWork;
//   final String id_att;
//
//   const Person({
//     required this.id,
//     required this.name,
//     //required this.LeavesId,
//     //required this.status,
//     // required this.gender,
//     // required this.dob,
//     // required this.email,
//     // required this.phone,
//     // required this.gender,
//     // required this.dob,
//     // required this.email,
//     // required this.phone,
//     // required this.gender,
//     // required this.dob,
//     // required this.email,
//     // required this.phone,
//     // required this.job,
//     required this.faceJpg,
//     required this.templates,
//     // required this.description,
//     // required this.startWork,
//     // required this.endWork
//     required this.id_att,
//   });
//
//   factory Person.fromMap(Map<String, dynamic> data) {
//     return Person(
//       id: data['id'],
//       name: data['name'],
//       //LeavesId: data['LeavesId'],
//       //status: data['status'],
//       // gender: data['gender'],
//       // dob: data['dob'],
//       // email: data['email'],
//       // phone: data['phone'],
//       // gender: data['gender'],
//       // dob: data['dob'],
//       // email: data['email'],
//       // phone: data['phone'],
//       // gender: data['gender'],
//       // dob: data['dob'],
//       // email: data['email'],
//       // phone: data['phone'],
//       // job: data['job'],
//       faceJpg: Uint8List.fromList(data['faceJpg'].cast<int>().toList()),
//       templates: Uint8List.fromList(data['templates'].cast<int>().toList()),
//       id_att: data['id_att'],
//       // description: data['description'],
//       // startWork: data['startWork'],
//       // endWork: data['endWork']
//     );
//   }
// }
//
// // class LoadPerson {
//   //final db = FirebaseFirestore.instance;
//
//   //Future<List<Person>> loadPerson() async {
//    // Progress().progress(context);
//    //  List personList = [];
//    //  //await db.collection("person").doc("1").delete();
//    //  final prefs = await SharedPreferences.getInstance();
//    //  var p = prefs.getString('personId');
//    //  var querySnapshot =
//     //     db.collection("person").doc(p);
//     // await querySnapshot.get().then((docSnapshot) {
//     //   personList.add({
//     //     'id': int.parse(docSnapshot.id),
//     //     'name': docSnapshot.data()?['name'],
//     //     'LeavesId': docSnapshot.data()?['LeavesId'],
//     //     'status': docSnapshot.data()?['status'],
//     //     'faceJpg': docSnapshot.data()?['faceJpg'],
//     //     'templates': docSnapshot.data()?['templates'],
//     //     'id_att': docSnapshot.data()?['id_att'],
//     //   });
//     // });
//    // Navigator.of(context).pop();
//    //  return List.generate(personList.length, (i) {
//    //    return Person.fromMap(personList[i]);
//    //  });
//   // }
// // }

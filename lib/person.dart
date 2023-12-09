import 'dart:typed_data';

class Person {
  final int id;
  final String name;
  final String gender;
  final String dob;
  final String email;
  final String phone;
  final String job;
  final Uint8List faceJpg;
  final Uint8List templates;
  final String description;
  final Duration startWork;
  final Duration endWork;

  const Person(
      {required this.id,
      required this.name,
      required this.gender,
      required this.dob,
      required this.email,
      required this.phone,
      required this.job,
      required this.faceJpg,
      required this.templates,
      required this.description,
      required this.startWork,
      required this.endWork});

  factory Person.fromMap(Map<String, dynamic> data) {
    return Person(
        id: data['id'],
        name: data['name'],
        gender: data['gender'],
        dob: data['dob'],
        email: data['email'],
        phone: data['phone'],
        job: data['job'],
        faceJpg: Uint8List.fromList(data['faceJpg'].toBytes()),
        templates: Uint8List.fromList(data['templates'].toBytes()),
        description: data['description'],
        startWork: data['startWork'],
        endWork: data['endWork']);
  }

}

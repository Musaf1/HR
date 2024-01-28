// import 'package:flutter/material.dart';
// import '../Processes/Init.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   LoginPageState createState() => LoginPageState();
// }
//
// class LoginPageState extends State<LoginPage> {
//   @override
//   void initState() {
//     super.initState();
//     Init().initShowDialog(context, this);
//     //Init().signInWithGoogle(context, this);
//    // Process().signUser('musaalnimer82@gmail.com', 'aA@1AHGFHJKH');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(left: 16.0, right: 16.0),
//       child: Row(mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ElevatedButton.icon(
//               label: const Text(
//                 'Login',
//                 style: TextStyle(fontSize: 52),
//               ),
//               icon: const Icon(
//                 Icons.login_outlined,
//                 size: 100,
//               ),
//               style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.all(20),
//                   shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(12.0)),
//                   )),
//               onPressed: () async {
//                 Init().initShowDialog(context, this);
//                // await Init().signInWithGoogle(context, this);
//               }),
//         ],
//       ),
//     );
//   }
// }

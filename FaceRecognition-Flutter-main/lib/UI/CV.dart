//
//
// import 'package:flutter/material.dart';
//
// import '../Processes/Init.dart';
// import '../Processes/Process.dart';
//
// class CVPage extends StatefulWidget {
//   const CVPage({super.key});
//
//   @override
//   CVPageState createState() => CVPageState();
// }
//
// class CVPageState extends State<CVPage> {
//   @override
//   void initState() {
//     super.initState();
//     Init().initShowDialog(context, this);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     const textStyle = TextStyle(
//       color: Color.fromRGBO(0, 150, 150, 1),
//       fontWeight: FontWeight.w600,
//       fontSize: 26,
//     );
//     return Container(
//       margin: const EdgeInsets.only(left: 16.0, right: 16.0),
//       child:  Center(
//         child: Column(mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const SizedBox(height: 10),
//             const Image(
//               width: 200,
//               height: 200,
//               image: AssetImage('assets/correct.png'),
//             ),
//             const SizedBox(height: 10),
//             const Text('CV enrolled', style: textStyle),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                       label: const Text(
//                         'Replace CV',style: textStyle,
//
//                   // style: textStyle
//                       ),
//                       icon: const Icon(
//                   //  color: textColor,
//                         Icons.edit_note_outlined,size: 36,
//                   // color: Colors.white70,
//                       ),
//                       style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.only(top: 10, bottom: 10),
//                   // foregroundColor: Colors.white70,
//                   //  backgroundColor: color,
//                           shape: const RoundedRectangleBorder(
//                             borderRadius: BorderRadius.all(Radius.circular(12.0)),
//                           )),
//                       onPressed: () async {
//                         Init().initShowDialog(context, this);
//                         await Process().deletePerson(context);
//                         await Process().signOutUser(context);
//                       }),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

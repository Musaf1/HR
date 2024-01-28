import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../Processes/Init.dart';
import '../Processes/Process.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  @override
  void initState() {
    super.initState();
    Init().initShowDialog(context, this);
  }

  @override
  Widget build(BuildContext context) {
    String email = '';
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Reset Password',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 60.0,
                      color: Color.fromRGBO(0, 150, 150, 1)),
                ),
                const SizedBox(
                  height: 25,
                ),
                TextFormField(
                  onChanged: (value) {
                    email = value.toString();
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: MaterialButton(
                    onPressed: () async {
                      await Process().sendPassword(email);
                      GoRouter.of(context).go('/');
                    },
                    color: const Color.fromRGBO(0, 150, 150, 1),
                    child: const Text(
                      'Send',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

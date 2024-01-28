import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../Processes/Init.dart';
import '../Processes/Process.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    Init().initShowDialog(context, this);
    Process().userAccess(context);
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    String email = '';
    String password = '';
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Register',
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
                  height: 20,
                ),
                TextFormField(
                  onChanged: (value) {
                    password = value.toString();
                  },
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
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
                    onPressed: () =>
                        Process().createUser(email, password, context),
                    color: const Color.fromRGBO(0, 150, 150, 1),
                    child: const Text(
                      'Register',
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
                const Divider(
                  color: Color.fromRGBO(0, 150, 150, 1),
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Have an account? ',
                      style: TextStyle(
                        color: Color.fromRGBO(0, 100, 100, 1),
                        fontSize: 16.0,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        GoRouter.of(context).go('/');
                      },
                      child: const Text('Sign Now'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

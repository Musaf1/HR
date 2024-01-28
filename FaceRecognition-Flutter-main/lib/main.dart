
import 'package:facerecognition_flutter/UI/Register.dart';
import 'package:facerecognition_flutter/UI/Sign.dart';
import 'package:facerecognition_flutter/UI/resetPassword.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'UI/ThePage.dart';
import 'package:go_router/go_router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

// GoRouter configuration
  final _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SignScreen()),
      GoRoute(path: '/Register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/resetPassword', builder: (context, state) => const ResetPasswordScreen()),
      GoRoute(
        path: '/ThePage',
        builder: (context, state) => const ThePage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    Color color = const Color.fromRGBO(0, 100, 100, 1);
    return MaterialApp.router(
      //navigatorKey: navigatorKey,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // home: const ThePage());
    );
  }
}

import 'package:facerecognition_flutter/UI/Sign.dart';
import 'package:flutter/material.dart';
import 'UI/Employed.dart';
import 'package:go_router/go_router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SignScreen()),
      GoRoute(
        path: '/EmployedPage',
        builder: (context, state) => const EmployedPage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    Color color = const Color.fromRGBO(0, 100, 100, 1);
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
    );
  }
}

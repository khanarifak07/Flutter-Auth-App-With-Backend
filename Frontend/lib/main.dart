import 'package:flutter/material.dart';
import 'package:frontend/profile.dart';
import 'package:frontend/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        routes: {
          "/register": (context) => const Register(),
          "/profile": (context) => const Profile()
        },
        home: const Register());
  }
}

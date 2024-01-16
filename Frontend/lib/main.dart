import 'package:flutter/material.dart';
import 'package:frontend/change_password.dart';
import 'package:frontend/create_todo.dart';
import 'package:frontend/dashboard.dart';
import 'package:frontend/login.dart';
import 'package:frontend/profile.dart';
import 'package:frontend/register.dart';
import 'package:frontend/todo_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //get the saved access token
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('accessToken');
  print("Access Token Retrived : $token");
  runApp(MyApp(accessToken: token));
}

class MyApp extends StatelessWidget {
  final String? accessToken;
  const MyApp({super.key, this.accessToken});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      routes: {
        "/login": (context) => const Login(),
        "/register": (context) => const Register(),
        "/profile": (context) => const Profile(),
        "/change-password": (context) => const ChangePassword(),
        "/todo-list": (context) => const TodoList(),
        "/create-todo": (context) => const CreateTodo(),
        "/dashboard": (context) => const Dashboard()
      },
      home: accessToken != null ? const Dashboard() : const Login(),
    );
  }
}

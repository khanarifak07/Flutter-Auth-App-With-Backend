import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/models/todo.model.dart';
import 'package:frontend/update_todo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<List<TodoModel>?> getTodos() async {
    try {
      //get the accessToken
      var pref = await SharedPreferences.getInstance();
      var token = pref.getString('accessToken');
      //create dio instance
      Dio dio = Dio();
      //no need to create formdata as we are not passing any data
      //make dio get request
      Response response = await dio.get(getTodoApi,
          options: Options(
            headers: {"Authorization": "Bearer $token"},
          ));
      //handle the response
      if (response.statusCode == 200) {
        log("All todos fetched successfully ${response.data}");
        // Parse the response data into a list of TodoModel
        List<dynamic> todoDataList = response.data['data'];
        List<TodoModel> todos = todoDataList
            .map((todoData) => TodoModel.fromMap(todoData))
            .toList();

        log("All todos fetched successfully $todos");
        return todos;
      } else {
        print("Error while fetching todos ${response.statusCode}");
      }
    } catch (e) {
      print("Error while getting todos $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.red.shade200,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/profile");
              },
              child: const Text("Profile"),
            ),
          )
        ],
      ),
      body: FutureBuilder(
          future: getTodos(),
          builder: (context, snapshot) {
            print("Snapshot Data: ${snapshot.data}");
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData && snapshot.data != null) {
              if (snapshot.data!.isEmpty) {
                return const Center(child: Text("No todos found"));
              } else {
                return ListView(
                  children: snapshot.data!
                      .map((e) => ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateTodo(todoModel: e)));
                            },
                            title: Text(e.title),
                            subtitle: Text(e.description ?? ""),
                          ))
                      .toList(),
                );
              }
            } else {
              return const Center(child: Text("No data available"));
            }
          }),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, "/create-todo");
        },
        child: const CircleAvatar(
          radius: 35,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

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
  bool isComplete = false;
  void changeStatus() {
    setState(() {
      isComplete = !isComplete;
    });
  }

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

  Future<void> deleteTodo({
    required id,
  }) async {
    try {
      //get the access token
      var pref = await SharedPreferences.getInstance();
      var token = pref.getString('accessToken');
      //create dio instace
      Dio dio = Dio();
      //make dio delete request
      Response response = await dio.delete(deleteTodoApi(id),
          options: Options(
            headers: {"Authorization": "Bearer $token"},
          ));
      //handle the response
      if (response.statusCode == 200) {
        print("todo deleed successfully ${response.data}");
      } else {
        print("error while deleting todo ${response.statusCode}");
      }
    } catch (e) {
      print("Error while deleting todo $e");
    }
  }

  Future<void> changeCompleteStatus({
    required id,
  }) async {
    try {
      //get the access token
      var prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("accessToken");
      //create dio instace
      Dio dio = Dio();
      //create formdata instace if you want to pass data with image else normal obj

      //make dio pathc request
      Response response = await dio.patch(changeCompleteStatusApi(id),
          options: Options(
            headers: {"Authorization": "Bearer $token"},
          ));
      //handle response
      if (response.statusCode == 200) {
        print("✅Status changed successfully ${response.data}");
      } else {
        print("❌Failed to Change Status : HTTPCODE :${response.statusCode}");
      }
    } catch (e) {
      print("Error while changing complete status");
    }
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
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    children: snapshot.data!
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                tileColor: Colors.red.shade50,
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UpdateTodo(todoModel: e)));
                                },
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.title),
                                    TextButton(
                                        onPressed: () async {
                                          await changeCompleteStatus(id: e.id);
                                          setState(() {});
                                        },
                                        child: isComplete
                                            ? const CircularProgressIndicator()
                                            : Container(
                                                height: 30,
                                                width: 140,
                                                decoration: BoxDecoration(
                                                    color: Colors.red.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16)),
                                                child: const Center(
                                                  child:
                                                      Text("Mark As Complete"),
                                                )))
                                  ],
                                ),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.description ?? ""),
                                    TextButton(
                                        onPressed: () async {
                                          setState(() {
                                            deleteTodo(id: e.id);
                                          });
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.only(right: 45),
                                          child: Text("Delete ❌"),
                                        ))
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
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

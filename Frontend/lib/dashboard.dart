import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/create_todo.dart';
import 'package:frontend/models/todo.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // bool initialLoading = false;
  bool isDelete = false;
  bool isComplete = false;

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
      setState(() {
        isDelete = true;
      });
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
    } finally {
      setState(() {
        isDelete = false;
      });
    }
  }

  Future<void> changeCompleteStatus({
    required id,
  }) async {
    setState(() {
      isComplete = true;
    });
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
    } finally {
      setState(() {
        isComplete = false;
      });
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
            /*  if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else */
            if (snapshot.hasError) {
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
                                tileColor: e.priority == "High"
                                    ? Colors.red.shade50
                                    : e.priority == "Medium"
                                        ? Colors.blue.shade50
                                        : e.priority == "Low"
                                            ? Colors.green.shade50
                                            : Colors.transparent,
                                onTap: () async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CreateTodo(
                                                todoModel: e,
                                              )));

                                  setState(() {});
                                },
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.title),
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      child: TextButton(
                                        key: ValueKey(e.complete),
                                        onPressed: () async {
                                          await changeCompleteStatus(id: e.id);
                                          setState(() {
                                            e.complete;
                                          });
                                        },
                                        child: e.complete!
                                            ? Container(
                                                key: UniqueKey(),
                                                height: 30,
                                                width: 140,
                                                decoration: BoxDecoration(
                                                    color: e.priority == "High"
                                                        ? Colors.red.shade100
                                                        : e.priority == "Medium"
                                                            ? Colors
                                                                .blue.shade100
                                                            : e.priority ==
                                                                    "Low"
                                                                ? Colors.green
                                                                    .shade100
                                                                : Colors
                                                                    .transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16)),
                                                child: Center(
                                                  child: Text(
                                                    "Completed",
                                                    style: TextStyle(
                                                      color: e.priority ==
                                                              "High"
                                                          ? Colors.red
                                                          : e.priority ==
                                                                  "Medium"
                                                              ? Colors.blue
                                                              : e.priority ==
                                                                      "Low"
                                                                  ? Colors.green
                                                                  : Colors
                                                                      .transparent,
                                                    ),
                                                  ),
                                                )) // Show "Completed" text when item is marked as complete
                                            : Container(
                                                key: UniqueKey(),
                                                height: 30,
                                                width: 140,
                                                decoration: BoxDecoration(
                                                    color: e.priority == "High"
                                                        ? Colors.red.shade100
                                                        : e.priority == "Medium"
                                                            ? Colors
                                                                .blue.shade100
                                                            : e.priority ==
                                                                    "Low"
                                                                ? Colors.green
                                                                    .shade100
                                                                : Colors
                                                                    .transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16)),
                                                child: Center(
                                                  child: Text(
                                                    "Mark As Complete",
                                                    style: TextStyle(
                                                      color: e.priority ==
                                                              "High"
                                                          ? Colors.red
                                                          : e.priority ==
                                                                  "Medium"
                                                              ? Colors.blue
                                                              : e.priority ==
                                                                      "Low"
                                                                  ? Colors.green
                                                                  : Colors
                                                                      .transparent,
                                                    ),
                                                  ),
                                                )),
                                      ),
                                    )
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
        onTap: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CreateTodo()));
          setState(() {});
        },
        child: const CircleAvatar(
          radius: 35,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

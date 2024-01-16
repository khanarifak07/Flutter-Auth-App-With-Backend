import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/models/todo.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateTodo extends StatefulWidget {
  TodoModel todoModel;
  UpdateTodo({super.key, required this.todoModel});

  @override
  State<UpdateTodo> createState() => _UpdateTodoState();
}

class _UpdateTodoState extends State<UpdateTodo> {
  late TextEditingController titleCtrl =
      TextEditingController(text: widget.todoModel.title);
  late TextEditingController descriptionCtrl =
      TextEditingController(text: widget.todoModel.description);
  bool isLoading = false;

  Future<void> updateTodo({
    required title,
    String? description,
    required id,
  }) async {
    try {
      setState(() {
        isLoading = true;
      });

      // get the access token
      var pref = await SharedPreferences.getInstance();
      var token = pref.getString('accessToken');

      //create dio instance
      Dio dio = Dio();
      //reaquest normal object data as we are not passign images so no need to create form data
      var updateTodo = {
        'title': title,
        'description': description,
      };
      //make dio patch request
      Response response = await dio.patch(updateTodoApi(id));
      //handle the response
      if (response.statusCode == 200) {
        log("Todo Updated Successfully ${response.data}");
      } else {
        print("Error while updating todo ${response.statusCode}");
      }
    } catch (e) {
      print("Error while updating todo $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Update Todo'),
          backgroundColor: Colors.red.shade200,
        ),
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  hintText: "title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionCtrl,
                decoration: const InputDecoration(
                  hintText: "description",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              MaterialButton(
                minWidth: double.maxFinite,
                height: 50,
                color: Colors.red.shade200,
                onPressed: () async {
                  await updateTodo(
                    id: widget.todoModel.id,
                    title: titleCtrl.text,
                    description: descriptionCtrl.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Todo Updated Successfully")));
                  Navigator.pushNamed(context, "/dashboard");
                  /*  await createTodo(
                  title: titleCtrl.text,
                  description: descriptionCtrl.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Todo Created Successfully")));
                Navigator.pushNamed(context, "/dashboard"); */
                },
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Create"),
              ),
            ],
          ),
        ));
  }
}

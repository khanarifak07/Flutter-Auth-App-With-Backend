import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTodo extends StatefulWidget {
  const CreateTodo({super.key});

  @override
  State<CreateTodo> createState() => _CreateTodoState();
}

class _CreateTodoState extends State<CreateTodo> {
  TextEditingController titleCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();
  bool isLoading = false;

  Future<void> createTodo({
    required String title,
    String? description,
  }) async {
    try {
      setState(() {
        isLoading = true;
      });

      var prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('accessToken');

      Dio dio = Dio();
      var todoData = {
        "title": title,
        "description": description ?? "",
      };

      Response response = await dio.post(
        createTodoApi,
        data: todoData,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
      if (response.statusCode == 200) {
        print("Todo created successfully ${response.data}");
      } else {
        print("Todo creation failed with status code ${response.statusCode}");
      }
    } catch (e) {
      print("Error while creating todo: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateTodo({
    required String title,
    String? description,
    required String id,
  }) async {
    try {
      setState(() {
        isLoading = true;
      });

      var prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('accessToken');

      Dio dio = Dio();

      var todoData = {
        "title": title,
        "description": description ?? "",
      };

      Response response = await dio.patch(
        updateTodoApi(id),
        data: todoData,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
      if (response.statusCode == 200) {
        print("Todo updated successfully ${response.data}");
      } else {
        print("Todo updation failed with status code ${response.statusCode}");
      }
    } catch (e) {
      print("Error while updating todo: $e");
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
        backgroundColor: Colors.red.shade200,
        title: const Text("Create Todo"),
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
                await createTodo(
                  title: titleCtrl.text,
                  description: descriptionCtrl.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Todo Created Successfully")));
                Navigator.pushNamed(context, "/dashboard");
              },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }
}

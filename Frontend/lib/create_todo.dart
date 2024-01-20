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
  String selectedPriority = "";

  Future<void> createTodo(
      {required String title, String? description, String? priority}) async {
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
        "priority": priority ?? ""
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                priorityContainer("High"),
                priorityContainer("Medium"),
                priorityContainer("Low"),
              ],
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
                  priority: selectedPriority,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Todo Created Successfully")));
                Navigator.pop(context);
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

  Widget priorityContainer(String priority) {
    Color colorContainer = getPriorityColor(priority);
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPriority = priority;
        });
      },
      child: Container(
        height: 50,
        width: 120,
        decoration: BoxDecoration(
            color: colorContainer,
            border: Border.all(
                color: selectedPriority == priority
                    ? Colors.black
                    : Colors.transparent,
                width: 2)),
        child: Center(
            child: Text(
          priority,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        )),
      ),
    );
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.blue;
      case "Low":
        return Colors.green;
      default:
        return Colors.transparent;
    }
  }
}

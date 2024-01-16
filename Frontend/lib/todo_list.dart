import 'package:flutter/material.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade200,
        title: const Text("Todo List"),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, "/create-todo");
        },
        child: CircleAvatar(
          radius: 35,
          backgroundColor: Colors.red.shade200,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

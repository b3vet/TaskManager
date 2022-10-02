import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

void main() async {
  final prefs = await SharedPreferences.getInstance();
  final stringList = prefs.getString('list');
  List<Task> listOfTasks = stringList != null
      ? (jsonDecode(stringList) as List<Map<String, dynamic>>)
          .map(
            (e) => Task.fromJson(e),
          )
          .toList()
      : [];
  runApp(MyApp(
    listOfTasks: listOfTasks,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.listOfTasks});
  final List<Task> listOfTasks;
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: TaskList(
        listOfTasks: listOfTasks,
      ),
    );
  }
}

class TaskList extends StatefulWidget {
  const TaskList({super.key, required this.listOfTasks});
  final List<Task> listOfTasks;

  @override
  State<TaskList> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TaskList> {
  List<Task> listOfTasks = [];
  @override
  void initState() {
    listOfTasks = widget.listOfTasks;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: ListView(
        children: listOfTasks
            .map(
              (e) => Text(e.title),
            )
            .toList(),
      ),
    );
  }
}

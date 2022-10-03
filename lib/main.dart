import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final stringList = prefs.getString('list');
  List<Task> listOfTasks = stringList != null
      ? (jsonDecode(stringList))
          .map<Task>(
            (e) => Task.fromJson(e),
          )
          .toList()
      : <Task>[];
  for (var i = 0; i < listOfTasks.length; i++) {
    final now = DateTime.now();
    final startOfToday = now.subtract(
      Duration(
        hours: now.hour,
        minutes: now.minute,
        seconds: now.second,
        milliseconds: now.millisecond,
        microseconds: now.microsecond,
      ),
    );
    if (startOfToday.difference(listOfTasks[i].startTime).inDays >= 1) {
      listOfTasks[i] = listOfTasks[i].copyWith(
        minuteDone: 0,
        completed: false,
        onGoing: false,
      );
    }
  }
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

class _MyHomePageState extends State<TaskList> with WidgetsBindingObserver {
  List<Task> listOfTasks = [];
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    listOfTasks = widget.listOfTasks;
    super.initState();
  }

  void saveList(List<Task> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('list', jsonEncode(list));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        print('paused');
        saveList(listOfTasks);
        break;
      case AppLifecycleState.detached:
        print('detached');
        saveList(listOfTasks);
        break;
      default:
        break;
    }
  }

  void addTask(Task task) {
    setState(() {
      listOfTasks.add(task);
    });
    saveList(listOfTasks);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Task Manager'),
        trailing: CupertinoButton(
          child: const Icon(CupertinoIcons.add),
          onPressed: () {
            showCupertinoDialog(
              context: context,
              builder: (buildContext) {
                return AddTask(addTask: addTask);
              },
            );
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: listOfTasks
              .map(
                (e) => _taskTile(e),
              )
              .toList(),
        ),
      ),
    );
  }

  void toggleTaskStatus(Task task) {
    if (task.completed) {
      return;
    }
    if (task.onGoing) {
      task = task.copyWith(
        onGoing: false,
        minuteDone: task.minuteDone +
            DateTime.now().difference(task.startTime).inSeconds,
      );
      if (task.minuteDone / 60 >= task.minuteToFinish) {
        task = task.copyWith(
          completed: true,
          onGoing: false,
          minuteDone: task.minuteToFinish.toDouble(),
        );
      }
    } else {
      task = task.copyWith(
        onGoing: true,
        completed: false,
        startTime: DateTime.now(),
      );
    }
    setState(() {
      listOfTasks = listOfTasks
          .map(
            (e) => e.title == task.title ? task : e,
          )
          .toList();
    });
  }

  Widget _taskTile(Task task) {
    final displayedMinute = (task.minuteDone / 60).toStringAsFixed(2);
    return Dismissible(
      key: Key(task.title),
      onDismissed: (direction) async {
        setState(() {
          listOfTasks.remove(task);
        });
        saveList(listOfTasks);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: CupertinoColors.secondarySystemFill,
            ),
            borderRadius: BorderRadius.circular(10),
            color: CupertinoColors.extraLightBackgroundGray,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(task.title),
                const Spacer(),
                Text(
                  '$displayedMinute/${task.minuteToFinish}',
                  style: const TextStyle(
                    color: CupertinoColors.inactiveGray,
                  ),
                ),
                CupertinoButton(
                  child: Icon(
                    task.onGoing
                        ? CupertinoIcons.pause_circle_fill
                        : CupertinoIcons.play_circle_fill,
                  ),
                  onPressed: () {
                    toggleTaskStatus(task);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddTask extends StatefulWidget {
  const AddTask({super.key, required this.addTask});
  final void Function(Task task) addTask;

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  String title = '';
  int duration = 0;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Add Task'),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                CupertinoTextField(
                  autocorrect: false,
                  padding: const EdgeInsets.all(4),
                  placeholder: 'Task Title',
                  onChanged: (value) {
                    setState(() {
                      title = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                CupertinoTextField(
                  keyboardType: TextInputType.number,
                  autocorrect: false,
                  padding: const EdgeInsets.all(4),
                  placeholder: 'Duration in minutes',
                  onChanged: (value) {
                    setState(() {
                      duration = int.parse(value);
                    });
                  },
                ),
                CupertinoButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (title == '' || duration == 0) {
                      return;
                    }
                    widget.addTask(
                      Task(
                        completed: false,
                        title: title,
                        minuteToFinish: duration,
                        onGoing: false,
                        minuteDone: 0,
                        startTime: DateTime.now(),
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

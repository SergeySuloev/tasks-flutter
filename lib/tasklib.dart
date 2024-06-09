import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';

part 'tasklib.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  bool isDone;

  @HiveField(1)
  String taskString;

  Task({this.isDone = false, required this.taskString});

  void toggleTask() {
    if (isDone == true) {
      isDone = false;
    } else {
      isDone = true;
    }
  }

  void editTask(newTaskString) {
    taskString = newTaskString;
  }
}

late Box<Task> tasksBox;

Future<void> openHiveBox() async {
  tasksBox = await Hive.openBox('tasks');
}

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await openHiveBox();
}

Future<int> addTaskToDB(Task task) async {
  final taskKey = tasksBox.add(task);
  return taskKey;
}

Future<List<Task>> readAllTasks() async {
  final List<Task> tasks = tasksBox.values.cast<Task>().toList();
  return tasks;
}

Future<void> removeTaskFromDB(int taskKey) async {
  try {
    await tasksBox.delete(taskKey);
  } catch (e) {
    if (kDebugMode) {
      print('Error: $e');
    }
  }
}

Future<Task?> getTask(int taskKey) async {
  final task = tasksBox.get(taskKey);
  return task;
}

Future<List<int>> getAllTaskKeys() async {
  final List<int> keys = tasksBox.keys.cast<int>().toList();
  return keys;
}

Future<void> toggleTaskInHive(int taskKey) async {
  final task = tasksBox.get(taskKey);
  task!.toggleTask();
  await tasksBox.put(taskKey, task);
}

Future<void> editTaskInHive(int taskKey, String newTask) async {
  final task = tasksBox.get(taskKey);
  task!.editTask(newTask);
  await tasksBox.put(taskKey, task);
}

Future<void> closeHive() async {
  await tasksBox.close();
  await Hive.close();
}

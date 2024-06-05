class Task {
  bool isDone;
  String taskString;

  Task({this.isDone = false, required this.taskString});

  void toggleTask() {
    if (isDone == true) {
      isDone = false;
    } else {
      isDone = true;
    }
  }
}

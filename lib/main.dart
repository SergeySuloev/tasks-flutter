import 'package:flutter/material.dart';
import 'tasklib.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasks App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TasksList(title: 'Flutter Demo Home Page'),
    );
  }
}

class TasksList extends StatefulWidget {
  final String title;
  final List<Task> tasks = [
    Task(taskString: 'Task 1'),
    Task(taskString: 'Task 2'),
    Task(taskString: 'Task 3'),
  ];
  TasksList({super.key, required this.title});

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: widget.tasks.length,
        itemBuilder: (BuildContext context, int index) {
          return TaskWidget(taskVar: widget.tasks[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your code here
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskWidget extends StatefulWidget {
  final Task taskVar;

  const TaskWidget({super.key, required this.taskVar});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  // ignore: prefer_const_constructors
  TextDecoration? strikeThrough;
  bool? isDoneVariable;

  @override
  void initState() {
    super.initState();
    isDoneVariable = widget.taskVar.isDone;
    strikeThrough = isDoneVariable! ? TextDecoration.lineThrough : null;
  }

  void _toggleTask() {
    setState(() {
      widget.taskVar.toggleTask();
      isDoneVariable = widget.taskVar.isDone;
      strikeThrough = isDoneVariable! ? TextDecoration.lineThrough : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var textStyle = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    textStyle = textStyle.copyWith(decoration: strikeThrough);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Checkbox(
              value: isDoneVariable,
              onChanged: (bool? value) {
                _toggleTask();
              },
            ),
            Text('test', style: textStyle),
          ],
        ),
      ),
    );
  }
}

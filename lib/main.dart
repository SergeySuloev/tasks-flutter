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
      home: TasksList(title: 'Tasks'),
    );
  }
}

// ignore: must_be_immutable
class TasksList extends StatefulWidget {
  final String title;
  List<Task> tasks = <Task>[];
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
        onPressed: () async {
          final result = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (context) => const AddNewTask()),
          );
          if (result != null) {
            setState(() {
              widget.tasks.add(Task(taskString: result));
            });
          }
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
            Text(widget.taskVar.taskString, style: textStyle),
          ],
        ),
      ),
    );
  }
}

class AddNewTask extends StatefulWidget {
  const AddNewTask({super.key});

  @override
  State<AddNewTask> createState() => _AddNewTaskState();
}

class _AddNewTaskState extends State<AddNewTask> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
      ),
      body: Center(
        child: Container(
          color: Theme.of(context).colorScheme.background,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.3,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _controller,
                  decoration: const InputDecoration(labelText: 'Task'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a task';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context, _controller.text);
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
